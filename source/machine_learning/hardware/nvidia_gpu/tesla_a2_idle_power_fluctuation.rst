.. _tesla_a2_idle_power_fluctuation:

=================================
Tesla A2待机功耗波动
=================================

我在 :ref:`tesla_a2_lost_debug` 发现一个异常现象，就是原本idle状态下功耗只有6W，但是我在调整风扇转速是意外发现功耗在不断波动:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/nvidia-smi_wave
   :caption: A2的待机功率波动

这让我非常困扰，而且我发现A2的外壳也越来越烫，监控观察到的温度确实比之前6W稳定时上升了10度左右。

但是，我明明是调整主板上的SYS FAN，和 :ref:`tesla_a2` 完全没有关系，风扇又不是连接在GPU上的。难道是这点风扇电流也影响了PCIe电气波动？(虽然gemini最初是这么猜测的)

我怀疑是BIOS调整(因为当时确实为了解决多GPU运行，正在调整 :ref:`nasse_c246` 的BIOS)，我反复调整BIOS中的 ``CSM`` 设置(也就是UEFI和Legency设置兼容)，尝试屏蔽之前为了 :ref:`nvidia_gpu_fan_control` 编译安装的 ``it87`` 内核模块。总之，把最近的系统变更都回滚了一遍，发现完全没有效果 :ref:`tesla_a2` 的 ``nvidia-smi`` 显示 idle功率依然是波动的，并且也导致了散热壳发烫(升高了10度)。

我甚至也排查了系统中哪些进程在使用nvidia设备，发现完全没有进程使用中，仅仅是正常 ``nvidia-persistenced`` 服务在使用中，这应该不影响功率波动。

正当我纠结万分时，我问了gemini一句如何观察GPU的 p-state ，也就是类似 :ref:`intel_turbo_boost_pstate` 功率控制状态。gemini提供了如下命令:

.. literalinclude:: tesla_a2_idle_power_fluctuation/nvidia-smi_pstate
   :caption: 检查NVIDIA GPU的pstate

输出可以看到 :ref:`tesla_a2` 处于 ``P8`` pstate，并且功率大约是 ``6W``

.. literalinclude:: tesla_a2_idle_power_fluctuation/nvidia-smi_pstate_output
   :caption: 检查NVIDIA GPU的pstate

等等...

怎么我发现反复刷上述命令，3块 :ref:`tesla_a2` 始终输出是 ``P8`` pstate，并且功率稳定在 ``6W`` **稳如老狗**

我会过去直接使用没有任何参数的 ``nvidia-smi`` 刷新，果然发现直接使用没有任何参数的 ``nvidia-smi`` 反复刷就出现了功率波动...

原来 ``nvidia-smi`` 不带任何参数的时候，它向底层驱动（NVML）请求的不仅仅是几个简单的指标，而是全套的 **全量诊断数据——包括显存占用、ECC 错误计数、PCIe 吞吐量、内部温度、风扇状态、所有进程上下文、驱动版本、甚至是显卡的详细健康状况** 。

为了汇总这些全量数据，驱动必须高频地向 GPU 内部的微控制器（PMU）发送硬件状态查询请求。这种密集的寄存器轮询会瞬间“惊醒”正在深层节能状态（如 P8 或更深状态）的 GPU。

而使用了 ``--query-gpu=...`` 指定极少数几个轻量级字段（如 pstate 和 power.draw）时，NVML 驱动只需要读取几个最基础的寄存器缓存即可，甚至不需要完全唤醒 GPU 的核心状态机，因此不会剧烈干扰显卡的待机状态。

.. note::

   说来可笑，这是一个非常简单的经验教训，频繁的"重查询"带来的"观测者效应"，导致了原本安静idle的GPU被干扰。

   这也提醒我，后续需要修订 :ref:`nvidia_gpu_fan_control` 绝不能简单使用原生 ``nvidia-smi`` 或全量 NVML 接口，否则监控脚本会白白消耗资源，干扰GPU的深度待机。
