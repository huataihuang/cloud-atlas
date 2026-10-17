.. _lm_sensor:

=============================
lm_sensors(Linux监控传感器)
=============================

Linux服务器运维时非常重要的一项监控就是服务器内部温度监控。当出现服务器内部温度过高，例如风扇故障，就会导致CPU因温度过高降频，甚至出现死机或者其他数据异常现象。

在Linux中，软件包 ``lm_sensors`` (即Linux-monitoring sensors)提供了基础工具和驱动来监控CPU温度，电压，湿度和风扇。同时也提供了主板入侵检测(非授权开启机箱)。通过该工具结合监控软件，可以用来发现硬件异常，及时更换受损部件。

安装lm_sensors
==================

- Arch linux安装::

   sudo pacman -S lm_sensors

- RHEL/CentOS,Fedora::

   sudo yum install lm_sensors

- Debian, Ubuntu::

   sudo apt install lm-sensors

- SUSE/openSUSE::

   sudo zypper in sensors

配置lm_sensors
==================

安装以后，运行以下命令配置 ``lm_sensors`` :

.. literalinclude:: lm_sensor/sensors-detect
   :caption: 检测系统

``sensors-detect`` 是一个独立程序用来检测已经安装的硬件以及加载推荐的特定模块。默认的交互回答就是安全的，所以通常只需要回车接受默认配置就可以。根据最后提示修订配置文件，例如 ``/etc/modules-load.d/lm-sensors`` (不建议直接修改 ``/etc/modules`` ，详见该配置文件内系统说明) 配置文件用于 ``lm_sensors.service`` 服务自动在启动时加载模块。

以下是我的组装机 :ref:`nasse_c246` 上实践记录，参考gemini分析说明:

第1步开始扫描，检测到 ``Intel digital thermal sensor`` ，驱动是 ``coretemp`` : 这是CPU 内核驱动已经直接集成了核显温度监控，扫描 Super I/O 和 CPU 传感器时加载的 ``coretemp`` 驱动，或者运行 :ref:`intel_gpu_top` ，就能直接看到核显的温度和负载。

.. literalinclude:: lm_sensor/sensors-detect_output_1
   :caption: ``sensor-detect`` 交互步骤1
   :emphasize-lines: 12,28,29

第2步扫描 ``Super I/O sensors`` ，就是 C246 主板上负责管理风扇 PWM 和电压的芯片(如 Nuvoton 或 ITE 芯片)，这里可以看到检测到 ``ITE IT8613E Super IO Sensors``

.. literalinclude:: lm_sensor/sensors-detect_output_2
   :caption: ``sensor-detect`` 交互步骤2
   :emphasize-lines: 3,9,10

第3步扫描 :ref:`ipmi` ，不过我的兼容台式机并没有提供硬件支持

.. literalinclude:: lm_sensor/sensors-detect_output_3
   :caption: ``sensor-detect`` 交互步骤3
   :emphasize-lines: 6,9,10

第4步扫描 ISA I/O 端口，不过现代主机上已经取消了ISA接口，所以这里直接选择 ``no``

.. literalinclude:: lm_sensor/sensors-detect_output_4
   :caption: ``sensor-detect`` 交互步骤4
   :emphasize-lines: 4

第5步扫描 ``I2C/SMBus`` ，这是现代硬件中的主要监控接口，所以回答 ``yes`` 可以看到检测到 ``Cannon Lake-H (PCH)`` 并使用驱动 ``i2c-i801``

.. literalinclude:: lm_sensor/sensors-detect_output_5
   :caption: ``sensor-detect`` 交互步骤5
   :emphasize-lines: 5,6

第6步扫描 ``i2c-i801`` (SMBus I801 adapter)详情，因为是重点设备，所以将默认的 ``No`` 调整为 ``yes`` ，可以看到扫描出了 ``Dallas Semiconductor DS75`` (使用驱动 ``lm75`` )

  - ``SMBus`` (System Management Bus) 是一条硬件底层总线，除了挂载温度传感器外，内存条（SPD 芯片）、主板供电管理芯片（VRM）等敏感设备也挂在这条总线上
  - ``sensors-detect`` 在盲目探测 SMBus 上的未知地址时，可能会尝试向某些寄存器写入测试数据。在极少数主板上，这有可能导致内存配置文件（XMP/SPD）损坏或导致系统瞬间死机。
  - ``sensors-detect`` 将 SMBus（I801 适配器）扫描默认设置为 ``NO`` 是出于历史兼容性与极端安全防护考量
  - 在 :ref:`nasse_c246` (即上面扫描出的 ``Intel Cannon Lake-H PCH`` )现代化主板，Intel PCH SMBus 控制器非常成熟，没有任何写破坏风险，主板上的硬件监控芯片（如 Nuvoton 或 ITE 监控芯片）以及部分内存/主板温度传感器，往往正是挂载在 **SMBus (i2c-0) 总线** 上，所以我这里 **将默认的 No 调整为 yes**

.. literalinclude:: lm_sensor/sensors-detect_output_6
   :caption: ``sensor-detect`` 交互步骤6
   :emphasize-lines: 2,6,7

第7步扫描 ``i915 gmbus dpb (i2c-1)`` / ``i915 gmbus dpc (i2c-2)`` / ``i915 gmbus misc (i2c-3)`` / ``i915 gmbus dpd (i2c-4)`` / ``AUX B/DDI B/PHY B (i2c-5)`` ，根据gemini建议，都选择 ``no`` :

  - 和 ``i915`` 核显相关的 ``gmbus`` (Graphic Management Bus) 和 ``dpb`` (DisplayPort Port B) 都是和显示通讯相关的接口，这些接口没有任何风扇或主板传感器

    - ``gmbus`` (Graphic Management Bus)是 Intel 核显专门用来和显示器进行 DDC/CI 通讯的物理通道。它的作用是传输类似“这台显示器叫 Dell U2720Q”、“最高支持 4K 60Hz”这样的静态描述文件（EDID），或者用来让你在操作系统里调节显示器的硬件亮度。
    - Intel 核显（i915）：CPU 内核驱动已经直接集成了核显温度监控，扫描 Super I/O 和 CPU 传感器时加载的 coretemp 驱动，或者运行 intel_gpu_top，就能直接看到核显的温度和负载。
    - NVIDIA 独显( :ref:`tesla_a2` )显卡的温度、功耗、显存使用率等所有监控数据，全部由专用的 ``nvidia-smi`` 或 ``nvml`` 接口直接提供，完全绕过了 Linux 传统的 ``lm-sensors`` / ``hwmon`` 框架

  - ``AUX B/DDI B/PHY B (i2c-5)`` 是 Intel Xeon E-2274G 处理器自带核显（Intel UHD Graphics P630）的显示输出通道（DisplayPort / HDMI 辅助通道 Aux Channel），这个接口只用于连接显示器和传输图形握手信号，里面没有任何主板风扇、转速或电压温度传感器。

最后， ``sensor-detect`` 输出了配置信息调整，也就是最后需要添加到模块加载的配置:

.. literalinclude:: lm_sensor/sensors-detect_output_7
   :caption: 最后的输出信息，写入modules加载
   :emphasize-lines: 22,23,28

**现在准备工作都已经完成**

- 重新加载系统模块驱动:

.. literalinclude:: lm_sensor/systemd-modules-load
   :caption: 重新加载系统模块驱动

查看CPU温度
================

- 简单执行以下命令就可以查看Linux:

.. literalinclude:: lm_sensor/sensors
   :caption: 运行 ``sensors`` 命令

默认输出的单位是摄氏度，要输出为华氏度，则使用参数 ``-f``

.. literalinclude:: lm_sensor/sensors_output
   :caption: 运行 ``sensors`` 命令输出信息

这里的输出信息中:

  - ``coretemp-isa-0000`` ( :ref:`xeon_e-2274g` ) 实时温度 35°C ，各个CPU核心温差不大，大约31-34°C 。可以看到告警阀值(high)温度是80°C，危险宕机阀值(crit)温度是100°C，当前远没有达到告警阀值，所以非常安全
  - ``nvme-pci-0a00`` 和 ``nvme-pci-0500`` 两块NVme固态硬盘温度在 40.9°C - 43.9°C 左右，属于非常舒适的正常工作温度
  - ``pch_cannonlake_1-virtual-0`` : C246 南桥 PCH 芯片温度 +61.0°C。南桥无风扇被动散热达到 60°C 左右属于 Intel 芯片组的常规物理特性，完全正常
  - ``mt7921_phy0-virtual-0`` : Wi-Fi / 无线网卡芯片温度 +50.0°C，正常

- 为了持续查看温度变化(以下案例每2秒刷新一次)，可以使用命令::

   wtach -n 2 sensors

参考
=======

- `Monitor AMD RYZEN Temps in Linux <https://www.techhut.tv/monitor-amd-ryzen-temps-in-linux/>`_
