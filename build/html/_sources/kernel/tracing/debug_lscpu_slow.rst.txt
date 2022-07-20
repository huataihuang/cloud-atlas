.. _debug_lscpu_slow:

====================
排查lscpu缓慢
====================

我最近的一个案例：升级了服务器的内核，并且按照运行 :ref:`gvisor` 需求，开启了 :ref:`iommu` 相关内核参数。被升级的服务器是比较早期安装的系统，由于生产环境内核经过多次迭代，近期安装的内核版本看起来差异不大(仅小版本序号变化)，但是内核参数变化极大，而且还可能存在hotfix差异，所以我对安装软件包(kernel+hotfix)和内核参数进行了比对。

升级完内核，安装完hotfix包，并且使用 :ref:`grubby` 对内核参数差异进行订正，确保了升级后的服务器内核参数和新安装服务器完全一致，看起来应该没有问题了。

然而，我非常惊讶地发现，系统中出现了很多 ``lscpu`` 进程，每个进程都占用了 100% 的CPU资源:

.. literalinclude:: debug_lscpu_slow/top_lscpu
   :language: bash
   :caption: top显示大量的lscpu占用100%的CPU资源

对比了一下异常的服务器(内核升级后的服务器)和正常的服务器(采用装机模版安装的最新标准服务器)，异常服务器实际上 ``lscpu`` 也能执行完成，只是异常缓慢::

   $time lscpu
   ...
   real 0m5.873s
   user 0m0.046s
   sys  0m5.799s

   $time lscpu
   ...
   real 0m53.452s
   user 0m0.033s
   sys  0m52.720s

耗时从 6秒到53秒 ，时间变化幅度很大，但都异常缓慢。正常服务器只耗时 0.36秒

排查
=============

- 使用 :ref:`strace` 来检查 ``lscpu`` 究竟做了什么事: 可以看到 正常的主机 ``lscpu`` 只有2位数的 ``read syscall`` ，但是异常主机则高达 2w 的 ``read syscall``

.. literalinclude:: debug_lscpu_slow/strace_c_lscpu_unusual
   :language: bash
   :caption: strace -c lscpu可以看到异常的lscpu调用了大量的read syscall

.. literalinclude:: debug_lscpu_slow/strace_c_lscpu_normal
   :language: bash
   :caption: strace -c lscpu可以看到正常的lscpu只有几十次read syscall

那么究竟是什么导致异常 ``lscpu`` 消耗了这么多 ``read syscall`` ?

- 再次使用 ``strace lscpu`` 直接查看调用了那些syscall::

   time strace lscpu 2>&1 | tee strace_lscpu.log

我对比了正常服务器和异常服务器的 ``strace_lscpu.log`` ，惊讶地发现，实际上两个日志文件的行数差别并不是特别大:

.. code:: bash

   # 异常服务器
   $wc -l strace_lscpu.log
   11045 strace_lscpu.log

   # 正常服务器
   $wc -l strace_lscpu.log
   9507 strace_lscpu.log

而且每次生成的 ``strace_lscpu.log`` 行数完全一致。能够明显感觉到异常服务器的 ``strace`` 输出特别缓慢

- 使用了文件diff工具 ``meld`` 对比了两个主机的 ``strace_lscpu.log`` ，发现了一点点差异: ``lscpu`` 会尝试去读取 ``/sys/devices/system/cpu/cpu0/cpufreq`` ，此时异常服务器是能够读取的，而正常服务器则显示该目录文件不存在。这是一个线索:

检查发现，异常服务器多了一个 ``/sys/devices/system/cpu/cpuX/cpufreq`` ，例如::

   /sys/devices/system/cpu/cpu0 目录下
   lrwxrwxrwx 1 root root    0 Jul 20 16:44 cpufreq -> ../cpufreq/policy0

每个CPU核心都对应有这个 ``policyX`` 目录，包含了一下内容::

   affected_cpus  cpuinfo_cur_freq  cpuinfo_transition_latency  scaling_available_frequencies  scaling_driver    scaling_min_freq
   bios_limit     cpuinfo_max_freq  freqdomain_cpus             scaling_available_governors    scaling_governor  scaling_setspeed
   cpb            cpuinfo_min_freq  related_cpus                scaling_cur_freq               scaling_max_freq

所以 ``lscpu`` 会读取这个目录下的 ``cpuinfo_max_freq`` 和 ``cpuinfo_min_freq`` 实际内容如下::

   $cat cpuinfo_max_freq
   2000000

   $cat cpuinfo_min_freq
   1200000

服务器硬件略有差异(型号和主频)，可以看到

异常服务器是::

   Model name:            Hygon C86 7285 32-core Processor
   Stepping:              1
   CPU MHz:               2456.693
   CPU max MHz:           2000.0000
   CPU min MHz:           1200.0000
   BogoMIPS:              4000.20
   Virtualization:        AMD-V

正常服务器::

   Model name:            Hygon C86 7291 32-core Processor
   Stepping:              1
   CPU MHz:               2744.609
   BogoMIPS:              4600.23
   Virtualization:        AMD-V

我发现一个异常之处，异常服务的 ``/sys/devices/system/cpu/cpuX/policyX/cpuinfo_max_freq`` (2G MHz) 实际上比 CPU MHz （2.5G MHz) 要低很多，看上去策略限制CPU主频。这点会不会导致比较特别的异常呢？

- 想到还有一批服务器虽然 :ref:`grubby` 调整了启动参数，但是由于没有重启，实际上尚未生效。而且未重启的服务器硬件和我这台存在异常的服务器硬件是完全一致的。我找了一台，执行::

   $time lscpu
   ...
   Model name:            Hygon C86 7285 32-core Processor
   Stepping:              1
   CPU MHz:               2484.086
   BogoMIPS:              3999.78
   Virtualization:        AMD-V
   ...
   real 0m0.106s
   user 0m0.010s
   sys  0m0.096s

可以看到同样的硬件(处理器)，在没有启用新的内核参数时， ``lscpu`` 的性能极快。并且，可以看到，相同内核但是使用旧的内核配置，CPU主频是不显示CPU policy 主频的，也就是 ``没有`` ::

   CPU max MHz:           2000.0000
   CPU min MHz:           1200.0000

所以，很大可能是存在和 :ref:`cpufreq` 相关的问题

对比 :ref:`cpufreq`
====================

经过对比，基本可以确定存在异常的服务器启用了 :ref:`cpufreq` 功能: 那为何同样内核和内核参数，新安装的模版服务器不显示 ``cpu frequency scaling`` 的 governor ? 而我手动升级服务器却出现

- 检查 CPU governor:

.. literalinclude:: ../cpu/intel/cpufreq/cpu_frequency_governor/cpupower_frequency-info
   :language: bash
   :caption: cpupower frequency-info 命令检查CPU主频伸缩策略

可以看到:

.. literalinclude:: debug_lscpu_slow/cpupower_frequency-info_output_unusual
   :language: bash
   :caption: 海光7285处理器 cpupower frequency-info 显示异常的处理器主频范围（1.20 GHz - 2.00 GHz)

我推测系统加载了 ``Scaling drivers`` ，但是不确定是哪种，照理说 AMD 处理器 支持 ``amd_pstate`` 需要处理器有 ``cppc`` flag，则可以传递内核参数 ``amd_pstate.replace=1`` 来激活。不过，海光的这款 ``7285`` 处理器并没有这个 ``cppc`` flag，并且我的内核参数也没有激活 ``amd_pstate.replace=1`` 

在参考文档 `arch linux: CPU frequency scaling <https://wiki.archlinux.org/title/CPU_frequency_scaling>`_ 中关于 ``cpufreq`` 内核模块检查方法如下::

   ls /usr/lib/modules/$(uname -r)/kernel/drivers/cpufreq/

可以看到如下内核模块::

   acpi-cpufreq.ko  amd_freq_sensitivity.ko  p4-clockmod.ko  pcc-cpufreq.ko  powernow-k8.ko  speedstep-lib.ko

我突然想到看看是否加载了内核模块::

   lsmod | grep freq

果然看出了差异:

- 存在异常的(内核升级)服务器同时包含了2个 :ref:`cpufreq` 内核模块::

   pcc_cpufreq            16384  0
   acpi_cpufreq           24576  0

- 正常(新装机模版)服务器只有1个 :ref:`cpufreq` 内核模块::

   pcc_cpufreq            16384  0

移除 :ref:`cpufreq`
======================

在异常的(内核升级)服务器卸载 ``acpi_cpufreq`` 内核模块::

   modprobe -r acpi_cpufreq

果然，卸载以后，原先存在的 ``/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`` 入口立即消失了::

   #ls /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
   ls: cannot access /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors: No such file or directory

而且原先存在的 ``/sys/devices/system/cpu/cpuX/cpufreq`` 也消失了。有戏!

- 此时再次执行 ``time lscpu`` 发现速度大大提高，而且原先存在 ``CPU max MHz`` 和 ``CPU min MHz`` 也消失了(因为读不到 :ref:`cpufreq` 的sysfs内容)::

   $time lscpu
   ...
   Model name:            Hygon C86 7285 32-core Processor
   Stepping:              1
   CPU MHz:               2428.609
   BogoMIPS:              4000.20
   Virtualization:        AMD-V
   ...
   real 0m0.136s
   user 0m0.010s
   sys  0m0.125s

但不是每次都这么块，也有耗时3秒或者7秒，甚至依然耗时49秒的。但是，有进展，说明 ``cpufreq`` 功能确实影响

.. note::

   为何正常装机模版的服务器启动时候没有加载 ``acpi_cpufreq`` 内核模块？我并没有找到内核模块blacklist配置，存疑

排障
=======

排除法方案:

- 测试一: 将异常服务器上pods迁移走，然后重启服务器，在保留 ``cpufreq`` 开启情况下(即还是加载 ``acpi_cpufreq`` )，测试 ``lscpu`` 
- 测试二: 异常服务器配置 ``acpi_cpufreq`` 内核模块加载黑名单，然后重启服务器确保 **没有加载** ``acpi_cpufreq`` ，测试 ``lscpu``

参考
=====
