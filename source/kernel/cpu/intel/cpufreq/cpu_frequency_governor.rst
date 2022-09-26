.. _cpu_frequency_governor:

======================
CPU频率调节器
======================

cpufreq governor
===================

- 检查 cpufreq governor :

.. literalinclude:: cpu_frequency_governor/cpupower_frequency-info
   :language: bash
   :caption: cpupower frequency-info 命令检查CPU主频伸缩策略

.. note::

   Ubuntu系统需要安装 ``linux-tools-common`` 软件包，然后执行 ``cpupower`` 命令会提示你按照内核版本安装对应工具包，例如我当前运行内核 ``5.4.0-121-generic`` ，提示安装 ``linux-tools-5.4.0-121-generic``

在我的 :ref:`hpe_dl360_gen9` 服务器上，输出案例:

.. literalinclude:: cpu_frequency_governor/cpupower_frequency-info_output
   :language: bash
   :caption: cpupower frequency-info 命令输出案例

Linux内核支持的cpufreq调节器
==============================

.. literalinclude:: cpu_frequency_governor/cpufreq_governor.csv
   :language: bash
   :caption: Linux内核支持的cpufreq调节器种类

要人工调整处理器主频，则需要采用 ``userspace`` governor，否则设置时候会报错

当使用 ``userspace`` governor时，可以通过如下命令设置某个处理器的主频(案例是cpu 0)::

   cpufreq-set -c 0 -f 3100000

注意， cpufreq驱动可能只支持部分cpufreq governor。例如 Intel :ref:`cpu_p-state` 就只支持 ``performance`` 和 ``powersave`` 调节器。所以，此时只能切换这两者之一

修改cpufreq governor
=========================

- 直接通过 ``sys`` 文件系统可以单独对每个CPU核心调整不同的 cpufreq governor ，例如以下命令只调整 cpu 0 的 cpufreq governor::

   echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor

此时检查::

   cpupower monitor -m Mperf

会看到(我的CPU是 ``Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz`` )::

                | Mperf
   PKG|CORE| CPU| C0   | Cx   | Freq
     0|   0|   0|  3.11| 96.89|  2268
     0|   0|  24| 11.91| 88.09|  2234
     0|   1|   1| 11.67| 88.33|  1250
     0|   1|  25|  6.88| 93.12|  1240
     0|   2|   2|  0.95| 99.05|  1201
     0|   2|  26|  6.48| 93.52|  1209 
   ...

注意看，这里只有 cpu core 0 (启用超线程时，对应core 0的是CPU 0和24)显示主频提升到 ``2.2GHz`` ，而其他CPU核心的主频依然处于 ``powersave`` 的cpufreq governor下，所以主频只有 ``1.2GHz``

- 现在我们使用 :ref:`simulate_load`  ``stress`` 来测试CPU::

   stress -c 48 -v -t 120s

这里将48个CPU都压满

然后检查 ``cpupower monitor -m Mperf`` 输出如下::

                | Mperf
   PKG|CORE| CPU| C0   | Cx   | Freq
     0|   0|   0| 99.83|  0.17|  2596
     0|   0|  24| 99.86|  0.14|  2596
     0|   1|   1| 99.83|  0.17|  2596
     0|   1|  25| 99.86|  0.14|  2596
     0|   2|   2| 99.83|  0.17|  2596
     0|   2|  26| 99.86|  0.14|  2596
   ...

这里看到所有CPU都运行在 ``2.6GHz`` 频率，这说明不管是 ``performance`` 还是 ``powersave`` 的cpufreq governor，在压力下都会达到处理器的最高频率。区别在于 ``performance`` 策略下，默认空闲状态就是较高频率，所以在压力下会更快运行在最高频率。这样对于应用看来，就是响应更快(更快运行在全速状态)

但是，在这里你看到的 ``2.6GHz`` 却不是处理器物理限制的最高频率: 该处理器物理限制频率是 ``3.1GHz`` 。也就是说，我们还没有释放出处理器的最高性能。不过，这里的 ``2.6GHz`` 已经是开启了 ``turbo`` 模式，可以从::

   cat /sys/devices/system/cpu/intel_pstate/no_turbo

看到默认值是 ``0`` ，也就是关闭 ``no_turbo`` ，相当于启用 ``turbo`` 。

如果 ``echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo`` 关闭 ``turbo`` ，则压力下处理器主频会降低，对于我的 ``Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz`` 在没有启用Trubo时候，最高主频只有 ``2.3GHz`` 。

- 启用全面的Performance策略::

   cpupower frequency-set -g performance

此时会看到所有cpu都滚动一遍设置::

   Setting cpu: 0
   Setting cpu: 1
   Setting cpu: 2
   Setting cpu: 3
   ...

然后检查 ``cpupower monitor -m Mperf`` 输出如下::

                | Mperf
   PKG|CORE| CPU| C0   | Cx   | Freq
     0|   0|   0|  2.25| 97.75|  2345
     0|   0|  24|  2.83| 97.17|  2495
     0|   1|   1|  0.37| 99.63|  2271
     0|   1|  25|  2.47| 97.53|  2509
     0|   2|   2|  0.29| 99.71|  2258
     0|   2|  26|  5.23| 94.77|  2585
   ...

可以看到即使系统压力不大，所有运行程序的处理器核心频率都在 ``2.3GHz ~ 2.6GHz`` 之间，基本上就是最高主频了

.. note::

   但是还没有能够压到极限频率 3.1G Hz ，待探索

参考
======

- `arch linux: CPU frequency scaling <https://wiki.archlinux.org/title/CPU_frequency_scaling>`_
- `CPU Frequency utility <https://wiki.analog.com/resources/tools-software/linuxdsp/docs/linux-kernel-and-drivers/cpufreq/cpufreq>`_
