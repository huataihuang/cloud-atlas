.. _tesla_a2_lost_debug:

=========================
Tesla A2突然消失异常排查
=========================

我实践 :ref:`nvidia_gpu_fan_control` 发生了一个意外:

这台兼容主机的 :ref:`nasse_c246` 安装了3块 :ref:`tesla_a2` ，经过BIOS的调整以及 :ref:`install_nvidia_linux_driver_ubuntu` ，此时执行 ``nvidia-smi`` 可以看到3块工作的GPU:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/nvidia-smi_output_a2
   :caption: ``nvidia-smi`` 输出显示有3块Tesla A2

但是，我 :ref:`nvidia_gpu_fan_control` 尝试调整风扇转速，在调整到 ``0`` (也可能是偶然？)，风扇确实停止转动:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/stop_pwm
   :caption: 停止风扇

再次执行 ``nvidia-smi`` 命令，显示输出却发现突然丢失了一个 :ref:`tesla_a2` :

.. literalinclude:: install_nvidia_linux_driver_ubuntu/nvidia-smi_error
   :caption: 丢失一块Tesla A2
   :emphasize-lines: 1

我注意到，在这块A2丢失前，系统报了一个 ``Unknown Error`` 

另外，我发现之前调整过风扇转速，包括调整到 40%, 100%，我发现A2的功率会从idle的5-6W上升到 10-16W。所以我有点怀疑是我的兼容主机使用的 :ref:`pcie_bifurcation` ，因为我设置了PCIe3 x16拆分成 ``x8x4x4`` ，可是我偶然发现在BIOS中显示的PCIe设备显示的是 ``x8x2x4`` ，为何会出现一个奇怪的 ``x2`` 带宽？

我又重新做了一次测试，确实发现， :strike:`当停止风扇 nvidia-smi 确实显示出A2的功率增加了(翻倍，甚至翻3倍)，而且是不断波动的` 功率波动

.. literalinclude:: install_nvidia_linux_driver_ubuntu/nvidia-smi_wave
   :caption: 停止了风扇，发现A2的功率波动

但是我最终排查 :ref:`tesla_a2_idle_power_fluctuation` 却发现，原来这是一个 "观测者效应"，即高频全量轮询导致 GPU 不断被唤醒、功耗波动。

gemini分析
============

.. note::

   gemini分析中关于电气噪声影响的原因我觉得确实很有可能，我的兼容机主板在电气稳定性上和品牌服务器有较大差距，并且将3个PWM风扇全部连接在一个SYS FAN插口上，电流波动确实有可能影响到PCIe总线。所以，我决定尝试将风扇插在2个SYS FAN上(该主板有2个SYS FAN)，并且尝试调整电源线的走向。

   以下是gemini的分析和建议摘要

这两个现象:

- **调整机箱风扇转速会导致 A2 待机功耗在 6W~19W 之间波动**
- **偶发GPU 0 突然丢失并报 Unknown Error**

高度关联，根源都指向主板供电/总线电气干扰（EMI/噪声）与 PCIe 链路电源管理（ASPM）之间的微妙冲突

在无 GPU 负载的情况下，A2 的功耗理应稳定在 5-6W 的最低 ASPM 节能状态（如 PCIe L1 状态）。但当你改变主板 SYS 风扇转速时，功耗发生波动，主要有三个潜在原因:

- PWM 脉冲信号的电磁干扰（EMI）与耦合

  - 主板的 SYS_FAN 接口是通过 PWM（脉冲宽度调制，通常频率在 21Hz 到 25kHz 不等）方波信号来控制风扇转速的
  - 如果风扇线缆、主板走线与 PCIe 插槽靠得太近，或者机箱接地不够完美，高频的 PWM 斩波信号产生的电磁噪声会耦合到 PCIe 插槽的供电或数据走线上
  - GPU 的响应：NVIDIA 显卡的内部功率管理单元（PMU）极其敏感。当 PCIe 参考时钟（PCIe REFCLK）或电源轨（3.3V / 12V）受到微小的纹波噪声干扰时，GPU 内部的 SerDes（串行/解串器）和物理层（PHY）会误以为有数据传输交互，从而频繁在不同的电源状态（P-states / ASPM 状态）之间唤醒和休眠，导致功耗仪或 nvidia-smi 显示功耗不断波动（从 6W 飙升到 10~19W）

- 主板供电轨波动（Voltage Droop / Ripple）

  - 多张 Tesla A2 插在主板上，虽然它们主要依靠 PCIe 插槽供电（A2 最大功耗 40W/60W，主要通过槽内 12V 取电），而风扇也是由主板供电
  - 改变风扇转速时，风扇马达的电感特性会引起母线电流的瞬时变化。如果 C246 主板的供电设计在应对风扇转速突变时产生轻微压降或纹波，会直接传导至 PCIe 槽的 12V/3.3V 供电轨，迫使 GPU 内部的稳压模块（VRM）调整工作状态，从而引起功耗监测值的波动

- 突发的 Unable to determine the device handle for GPU0: 0000:01:00.0: Unknown Error 是一个危险信号，通常意味着 PCIe 总线链路训练失败（Link Training Failure） 或 PCIe 驱动层与硬件失去响应

  - 根本诱因: 开启了 Above 4G Decoding、Re-Size BAR、SR-IOV 以及 VT-d，系统在复杂的 PCIe 拓扑下运行
  - 崩溃过程:
    
    - 当风扇转速改变引发的瞬时电气噪声叠加在 PCIe 总线上时，如果恰好触碰了某张卡（GPU 0）的信号完整性容限
    - PCIe 控制器检测到总线传输错误（CRC Error 或 Framing Error），触发了 PCIe AER（高级错误报告）机制
    - 驱动层尝试恢复但超时，导致该卡从 PCIe 总线上“掉线（掉卡）”。此时内核驱动与硬件失联，nvidia-smi 访问该设备句柄时就会抛出 Unknown Error
    - 冷启动或温重启会触发主板和 GPU 重新进行 PCIe 链路初始化（Link Training），双方重新协商好信号参数后恢复正常

建议排查与解决步骤
-------------------

- 调整 BIOS 中的 PCIe 稳定性设

  - PCIe Gen 速度限制：在 BIOS 的 PCIe 配置中，如果当前是 Auto 或 Gen3，可以尝试将 A2 所在的 PCIe 插槽速率手动固定为 Gen3（因为 A2 是 PCIe 4.0 设备，而 C246 芯片组只支持 PCIe 3.0，固定 Gen3 可以减少协商时的误码率）。
  - 关闭或调整 ASPM：如果不需要极致的 5W 待机节能，可以在 BIOS 中关闭 PCIe ASPM（Active State Power Management），或者在 Linux 内核启动参数中加入 pcie_aspm=off。这能彻底掐断 GPU 频繁进出低功耗状态引起的总线抖动。

- 检查风扇接线与供电

  - 确保控制 3 个 A2 散热风道的 SYS_FAN 供电线远离主板的 PCIe 插槽区域，避免 PWM 高频线与显卡金手指或 PCIe 走线平行紧贴。
  - 如果风扇功率较大，建议不要直接全部并联在主板的一个 SYS_FAN 接口上（单接口电流通常限流 1A，约 12W），超负荷也容易引起主板供电噪声。

- 万一再发生类似抖动时能抓到确切原因，可以检查系统内核日志 ``dmesg | grep -i pcie`` 如果里面有大量的 AER: Corrected error，说明 PCIe 链路长期处于电气边缘，必须降低 PCIe 速率或优化机箱散热与抗干扰。

dmesg日志分析
--------------

我检查了dmesg输出和pcie相关信息:

.. literalinclude:: tesla_a2_lost_debug/dmesg_pcie
   :caption: 检查和pcie相关dmesg日志

可以看到:

.. literalinclude:: tesla_a2_lost_debug/dmesg_pcie_output
   :caption: 检查和pcie相关dmesg日志输出
   :emphasize-lines: 1,16,18,20,32,33

解析:

- 主板 BIOS 在 **ACPI 表中声明不支持 PCIe ASPM（主动状态电源管理）** ，这意味着系统层面禁用了 PCIe 省电休眠状态，直接减少了 PCIe 链路频繁在低功耗和高功耗之间切换引起的电气波动，在一定程度上降低了前面遇到的"掉卡"风险。
- **AER 与 DPC 错误防护机制已激活** : 日志中大量出现的 ``pcieport ... AER: enabled`` 和 ``DPC: enabled`` 说明 Linux 内核成功接管了 PCIe 的高级错误报告和 Downstream Port Containment。这能在总线发生电气抖动或异常时进行隔离，是服务器/工作站级别的标准配置。
- 3 张 :ref:`tesla_a2` 分别挂载在 ``0000:01:00.0`` 、 ``0000:02:00.0`` 和 ``0000:03:00.0`` ，已正确识别；但是需要注意，主板上的物理插槽把这 16 条通道拆分成了 ``x8 + x4 + x4`` ，其中 ``x4`` 带宽大约是 ``3.9GB/s`` 是交换数据的瓶颈
- 多网口网卡(igc): ``igc 0000:06:00.0: 4.000 Gb/s available PCIe bandwidth (5.0 GT/s PCIe x1 link)`` 共4行记录


由于没有启用ASPM，所以主要的功耗跳变(6W->19W)应该主要是风扇电磁脉冲干扰这些被强行拆分出来的 ``x4`` 总线，所以应该控制风扇控温脚本的调节频率，以避免高频斩波干扰 PCIe 总线稳定性。

我的实践
===========

:ref:`nasse_c246` 有2个机箱4PIN风扇插座(支持调速)，所以目前我把原先3个 :ref:`tesla_a2` 风扇分别插到这2个插座上

参考
======

- gemini
