.. _pi_5_cpufreq:

=====================
树莓派5 CPU主频
=====================

我在 :ref:`raspberry_pi_os_zfs` 中编译ZFS :ref:`dkms` 模块，发现如果没有使用官方27W电源的时候，一旦CPU全力运行会导致电压不稳而死机。由于目前正在旅途中无法获取匹配电源，所以我想到这种不稳定情况只有全速运行是才出现电压不足，那么何不将 :ref:`cpu_frequency_governor` 调整为最低频率( ``powersave`` )来实现稳定运行呢?

和 :ref:`intel_cpu` 的 :ref:`cpufreq` 类似， :ref:`arm` 架构也实现了类似的控制CPU主频管理机制。从 :ref:`pi_5` 的操作系统 ``sysfs`` 中检查目录 ``/sys/devices/system/cpu/cpu0/cpufreq/`` 可以看到

.. csv-table:: cpufreq 访问接口文件
   :file: ../../kernel/cpu/intel/cpufreq/intro_cpufreq/sys_cpufreq.csv
   :widths: 20, 80
   :header-rows: 1

- 安装 ``cpupower`` 工具:

.. literalinclude:: ../../kernel/cpu/intel/cpufreq/cpu_frequency_governor/apt_install_cpupower
   :caption: 在 :ref:`debian` 中安装 ``cpupower``

- 动态设置 ``powersave`` governor:

.. literalinclude:: ../../kernel/cpu/intel/cpufreq/cpu_frequency_governor/frequency-set_powersave_governor     
   :caption: 设置 ``powersave`` governor

然后就可以开始 :ref:`raspberry_pi_os_zfs` 编译工作

- 为了能够持久化配置 ``powersave`` governor，则修改 ``/etc/default/cpu_governor`` :

.. literalinclude:: ../../kernel/cpu/intel/cpufreq/cpu_frequency_governor/cpu_governor
   :caption: :ref:`debian` 系列设置启动的 CPU governor
   :emphasize-lines: 6

参考
=======

- `How to overclock the Raspberry Pi 5 beyond 3 GHz! <https://www.tomshardware.com/raspberry-pi/how-to-overclock-the-raspberry-pi-5-beyond-3-ghz>`_
- `Overclocking and *Underclocking* the Raspberry Pi 5 <https://www.jeffgeerling.com/blog/2023/overclocking-and-underclocking-raspberry-pi-5>`_
