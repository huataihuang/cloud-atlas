.. _nvidia_gpu_fan_control:

===================================
NVIDIA GPU散热风扇控制
===================================

在 :ref:`tesla_a2` 执行推理时，虽然功率不高(最高60w, idle时只有5-6W)但是被动撒热如果不能根据负载动态调整散热风扇转速，会导致GPU核心和内存温度过高，甚至导致降频或故障。

我的实践环境是 :ref:`nasse_c246` 组装兼容机(C246 芯片组 + AMI BIOS)，通过主板 ``4-Pin系统风扇`` 插口 + ``一分三线`` 控制 3 块 Tesla A2 的风扇。主板的这个 SYS_FAN 插口输出的 PWM 信号会同时控制这 3 个风扇。要实现自动调速，核心逻辑是：读取 3 块 A2 中温度最高的那块，并用它来动态决定主板风扇插口的转速。

- 安装驱动检测工具:

.. literalinclude:: nvidia_gpu_fan_control/install
   :caption: 安装驱动检测工具

- 检测主板 Sensor 芯片并加载内核驱动(详见 :ref:`lm_sensor` 实践记录):

.. literalinclude:: ../../../linux/server/hardware/lm_sensor/sensors-detect
   :caption: 检测系统

我遇到一个问题，我的主机执行 ``sensors-detect`` 时，关于 ``Super I/O sensors`` 的信息如下:

.. literalinclude:: ../../../linux/server/hardware/lm_sensor/sensors-detect_output_2
   :caption: 检测到 ``ITE IT8613E Super IO Sensors`` 但是没有驱动
   :emphasize-lines: 9,10

已经检测到了 ``ITE IT8613E Super IO Sensors`` 但是却没有对应的驱动(显示为 ``to-be-written`` )

这点可以通过 ``sensors`` 命令输出看到:

.. literalinclude:: ../../../linux/server/hardware/lm_sensor/sensors_output
   :caption: 由于没有加载对应 ``ITE IT8613E Super IO Sensors`` 驱动导致 ``sensor`` 输出中没有系统风扇的数据

并且检查 ``ls /sys/class/hwmon/hwmon*/pwm*`` 是没有任何输出信息的，也就是没有 ``PWM`` 信息，表明没有 pwm1、pwm2 等控速节点。

gemini提示， ``IT8613E`` 应该使用的驱动是 ``it87`` ，但是我执行 ``modprobe it87`` 却提示:

.. literalinclude:: nvidia_gpu_fan_control/modprobe_it87_error
   :caption: 无法加载 ``it87``

实际上内核模块有一个 ``/lib/modules/7.0.0-38-generic/kernel/drivers/hwmon/it87.ko.zst`` 模块，但是，这个官方模块驱动代码中写死了 **对支持芯片 ID 的安全白名单检查** 当驱动去探测主板时，发现 Super I/O 芯片型号是 IT8613E，而官方内核的老代码里不认这个 ID（或者没有将其放进支持列表），于是驱动直接拒绝初始化，并抛出 ``No such device`` 。

解决方法是编译社区提供的包含 ``IT8613E`` 补丁的 ``it87`` 驱动:

.. literalinclude:: nvidia_gpu_fan_control/it87
   :caption: 安装支持 ``IT8613E`` 补丁的 ``it87`` 驱动

安装完成后，重启电脑(或执行 ``sudo modprobe it87`` )，完成以后检查 ``lsmod | grep it87`` 可以看到已经加载了这个内核模块:

.. literalinclude:: nvidia_gpu_fan_control/it87_module
   :caption: 内核加载了 ``it87``

此时再检查 ``ls /sys/class/hwmon/hwmon*/pwm*`` 就有了输出信息，并且 ``sensors`` 命令终于有了风扇转速信息:

.. literalinclude:: nvidia_gpu_fan_control/sensors_output
   :caption: ``sensors`` 现在有了风扇输出信息
   :emphasize-lines: 15-17,21-24

现在检查主板上有哪些系统风扇可以enable实现 **手工控制**

.. literalinclude:: nvidia_gpu_fan_control/pwm_enable
   :caption: 检查哪些有可以搜供控制的PWM

输出显示:

.. literalinclude:: nvidia_gpu_fan_control/pwm_enable_output
   :caption: 检查哪些有可以搜供控制的PWM输出信息

可以看到当前在 ``/sys/class/hwmon/hwmon4/pwm3_enable`` 值是 ``2`` 表示主板 BIOS 自动控制

经过尝试调整PWM转速，验证出 ``/sys/class/hwmon/hwmon4/pwm3`` 就是控制当前 :ref:`tesla_a2` 风扇转速的主板 ``SYS_FAN`` ，所以采用如下方法来调控:

.. literalinclude:: nvidia_gpu_fan_control/pwm3
   :caption: 调整 Tesla A2 的风扇转速

- 验证成功以后，再使用以下温控脚本 ``/usr/local/bin/a2_fan_control.py`` :

.. literalinclude:: nvidia_gpu_fan_control/a2_fan_control.py
   :caption: 温控脚本 ``/usr/local/bin/a2_fan_control.py``
   :language: python

- 配置 Systemd 开机自启服务:

创建服务文件 ``/etc/systemd/system/a2-fan.service`` :

.. literalinclude:: nvidia_gpu_fan_control/a2-fan.service
   :caption: 服务文件 ``/etc/systemd/system/a2-fan.service``

- 启动并挂载服务:

.. literalinclude:: nvidia_gpu_fan_control/systemctl
   :caption: 启动并挂载服务

.. note::

   - C246 主板标准的 4-Pin 风扇插座供电上限通常是 1A (12W)
   - Tesla A2 属于单槽低功耗卡（TDP仅 40-60W），如果使用的是普通的 8020 或 9025 规格涡轮/轴流风扇（单个电流通常在 0.15A~0.3A），3 个叠加只有 0.5A~0.9A，主板供电完全没有任何问题。如果使用的是 1.5A 以上的暴力风扇，则需要改用带 SATA 独立供电的一分三线。
   - 一分三线上，只有其中一个头有 4 根针（带黄色的 RPM 测速线），另外两个头只有 3 根针（剥离了测速线）。必须确保将其中一块 A2 的风扇插在这个 4 针的主头上，这样主板和 ``sensors`` 才能正确读取到真实转速。

参考
======

- gemini
