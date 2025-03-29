.. _defs:

==================
ARM cpufreq(DVFS)
==================

DVFS简介
=========

在ARM系统中cpufreq子系统允许动态调节电压和CPU频率(dynamic voltage and frequency scaling, DVFS)，可以影响CPU性能以及电能消耗以适应当前工作负载。

检查CPU系统
-----------

通过 ``/proc/cpuinfo`` 可以查看CPU信息，例如 :ref:`pi_4` 上执行 ``cat /proc/cpuinfo`` 可以看到如下输出::

   processor: 0
   BogoMIPS: 108.00
   Features: fp asimd evtstrm crc32 cpuid
   CPU implementer: 0x41
   CPU architecture: 8
   CPU variant: 0x0
   CPU part: 0xd08
   CPU revision: 3      
   
   processor: 1
   ...
   processor: 2 
   ...
   processor: 3 
   ...

   Hardware: BCM2835
   Revision: b03112
   Serial: 100000003b6824d7
   Model: Raspberry Pi 4 Model B Rev 1.2      

这里 ``processors`` 后面的数字表示当前内核的CPU编号，例如  ``processor: 1`` 对应的 ``/sys/`` 目录下处理器 ``/sys/devices/system/cpu/cpu1``

``CPU part`` 是从 ``MIDR_EL1`` 系统寄存器中读取的CPU主型号，需要查询处理器的技术参考手册来找到对应的部件号，例如:

- ``0xd03`` 表示 ``Cortex-A53``
- ``0xd07`` 表示 ``Cortex-A57`` - :ref:`jetson` 使用的CPU
- ``0xd08`` 表示 ``Cortex-A72`` - :ref:`pi_4` 使用的CPU

.. note::

   在Android手机上执行 ``cat /proc/cpuinfo`` 通常会看到多核心采用了不同的处理器架构，也就是常说的大小核。

- 对于 :ref:`jetson_nano` 处理器::

   processor: 0
   model name: ARMv8 Processor rev 1 (v8l)
   BogoMIPS: 38.4           0
   Features: fp asimd evtstrm aes pmull sha1 sha2 crc32
   CPU implementer      : 0x41
   CPU architecture: 8
   CPU variant: 0x1
   CPU part: 0xd07
   CPU revi     sion: 1

将进程绑定(pinning)到CPU
==========================

在Linux中，每个进程的亲和性(affinity)描述了进程在SMP系统中将运行在哪个CPU上，默认是所有CPU，但是我们可以通过 ``taskset`` 命令来修改亲和性。

- 以下案例将 ``ls /lib`` 只运行在CPU 5上(Contex_A53_4)::

   taskset -c 5 ls /lib

- 以下案例则只在CPU 1和2上运行(两个Cortex-A57核心)::

   taskset -c 1,2 grep -i joe users.txt

- 以下案例在所有CPU(0-5)上运行命令::

   taskset -c 0-5 ping 192.0.0.1

动态电压和频率调整
====================

动态电压和频率调整(Dynamic Voltage and Frequency Scaling, DVFS)技术可以运行时调整CPU的时钟频率，通过降低时钟频率可以使得处理idle并且降低电能消耗和热量产生。

- 查看当前CPU 3的时钟频率::

   cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq

例如 :ref:`pi_4` 显示600MHz的低压节电频率::

   600000

- 可以检查CPU支持的可用频率::

   cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_available_frequencies

例如 :ref:`pi_4` 显示出有4档处理器频率::

   600000 750000 1000000 1500000

- 手动调整CPU 3的频率::

   echo 1000000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_setspeed

这里遇到报错::

   -bash: echo: write error: Invalid argument

这个报错参考 `/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed: Invalid argument <https://unix.stackexchange.com/questions/434735/sys-devices-system-cpu-cpu0-cpufreq-scaling-setspeed-invalid-argument>`_ 的解释:

``sysfs`` 和 ``procfs`` 是内核的接口，通过读写这些分拣来和内核中驱动交互。通常出现 ``permission denied`` 则是文件系统权限不足，但是这里的返回是 ``invalid argument`` 表明是驱动返回这个错误，很可能是写入数据是驱动不支持的数值范围。

经过测试，我发现树莓派 Raspberry Pi 4不是所有CPU核心都支持 ``echo`` 某个CPU频率到 ``scaling_setspeed`` ，对于 ``CPU0`` 和 ``CPU1`` 是支持该指令参数，但是 ``CPU2`` 和 ``CPU3`` 则不支持。但是，我测试下来即使 ``echo`` 指定CPU频率值，例如 ``echo 1000000 /sys/devices/system/cpu/cpu1/cpufreq/scaling_setspeed`` ，但是读取 ``cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`` 值依然不是设定值。

Scaling governor(主频调节)
==============================

内核动态调节主频的规则是通过 cpufreq scaling governor 定义的。

cpu频率调节策略定义了系统CPU的电源管理特性，会直接影响到CPU性能。每个调节策略有自己独特的特性和用途，适合不同的应用环境。

处理器支持的cpu频率调节策略可以通过以下命令检查::

   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

对于 :ref:`pi_4` 有以下cpu频率调节策略::

   conservative ondemand userspace powersave performance schedutil

- 检查当前cpu频率调节策略::

   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

可以看到默认是按需::

   ondemand

上述按需cpu频率策略，在idle时候，cpu频率就是最低的600MHz，我们可以通过::

   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

看到输出是::

   600000

- 我们可以调整策略成性能优先::

   echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

然后检查策略::

   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

输出确实是性能优先::

   performance

.. note::

   在 :ref:`pi_4` 和 :ref:`jetson_nano` 上4个CPU核心的cpu频率调节策略是完全同步的，也就是修改 cpu0 的调节策略会立即在其他cpu核心同步生效。

- 现在我们检查CPU当前核心频率::

   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

可以看到飙升到最高频率::

   1500000

我在 :ref:`jetson_nano` 上调整 ``scaling_governor`` 设置成 ``performance`` 之后，频率从原先 ``518400`` 上升到 ``1479000``

不过设置cpufreq scaling governor为performance可能会带来CPU温度上升。

.. note::

   我在 :ref:`pi_cluster` 中组建 :ref:`kubernetes` 集群，希望能够尽可能压榨出处理器性能，所以我设置 governor 都是 ``performance`` 。注意，需要配备好散热风扇，并且部署好监控，随时应对处理器国人风险。

governor系统配置
===================

虽然可以通过 ``rc.local`` 这样的启动脚本来人为设置处理器运行策略，但是最好的方式还是采用系统发行版约定熟成的配置方式。所以，在Ubuntu中，可以采用如下方法::

   sudo apt-get install cpufrequtils
   echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
   sudo systemctl disable ondemand

.. note::

   CPU电源管理对系统性能影响重大，在服务器运维领域，我需要系统学习和整理

参考
=====

- `ARM开发者社区文档:Open source software > Linux/Android > cpufreq(DVFS) <https://community.arm.com/developer/tools-software/oss-platforms/w/docs/528/cpufreq-dvfs>`_
