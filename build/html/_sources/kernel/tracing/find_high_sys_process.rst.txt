.. _find_high_sys_process:

==========================
找出消耗CPU的sys的进程
==========================

.. note::

   本文介绍一种找出大量消耗CPU的sys的进程的思路，适合采用cgroup隔离进程的生产系统问题排查。在找出大量消耗sys的进程后，我们可以采用 :ref:`debug_high_sys_process` 来进一步分析进程，找出代码问题。

   如果没有使用cgroup，则稍微有些麻烦(话说应该没有不使用cgroup的系统了吧)，就是通过 ``cpuset`` 命令手工将进程指定到某个CPU上，观察CPU负载变化来排查。

大量消耗sys的场景
=================

在生产环境中，会采用 :ref:`cgroup` 进行资源隔离不同类型的进程，例如，会把监控服务(大量的数据采集脚本)都加入到 ``agent`` 的cgroup控制组，并绑定使用 ``cpu 24`` 。这种方式可以闭麦呢辅助程序和应用系统争抢CPU资源。

但是，发现数十个辅助程序绑定到 ``cpu 24`` 之后，这个CPU出现了非常严重的 ``sys`` 使用率，从 :ref:`top` 来看，系统 ``load average`` 负载非常高，但是实际上除了少数 ``cpu`` 确实计算较为繁忙，大多数cpu都是空闲的::

   top - 22:35:20 up 50 days,  8:33,  2 users,  load average: 40.91, 41.86, 42.51
   Tasks: 7101 total,  38 running, 7058 sleeping,   0 stopped,   5 zombie
   Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 88.4%id, 11.6%wa,  0.0%hi,  0.0%si,  0.0%st
   Cpu1  :  0.0%us,  3.7%sy,  0.0%ni, 95.0%id,  1.3%wa,  0.0%hi,  0.0%si,  0.0%st
   Cpu2  : 21.7%us,  6.2%sy,  0.0%ni, 69.1%id,  2.0%wa,  0.0%hi,  1.0%si,  0.0%st
   Cpu3  : 27.6%us, 12.8%sy,  0.0%ni, 57.2%id,  0.0%wa,  0.0%hi,  2.3%si,  0.0%st
   ...
   Cpu24 : 32.1%us, 67.6%sy,  0.0%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
   ...
   Mem:  263819896k total, 137107080k used, 126712816k free,  2005040k buffers
   Swap:        0k total,        0k used,        0k free, 30639512k cached

     PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
   27980 root      20   0 1189m 1.0g 5148 S 107.1  0.4   8049:15 qemu-kvm
   32303 root      20   0 1274m 1.0g 5136 S 106.5  0.4   2790:12 qemu-kvm
    3869 root      20   0 1193m 171m 5108 S 43.6  0.1   0:05.26 qemu-kvm

* 由于 ``cpu 24`` 上的某个程序（如果我推测没有错的话）导致CPU大量消耗 ``sys`` ，并且导致运行队列过长，所以临时将所有的进程都迁移到另一个控制组 ``service`` 中（这个 ``service`` 控制组分配了多个CPU资源( ``2-5,26-29`` )，可以承担较大负载）::

   for i in `cat /cgroup/cpuset/agent/tasks`;do sudo cgclassify -g cpuset:service $i;done

完成后可以看到 ``agent`` 这个cgroup组已经没有进程(也就是 ``24`` 这个cpu上已经不再绑定进程，之前大量消耗 ``sys`` 的进程全部迁移到CPU ``2-5,26-29`` 上，此时可以看到这8个CPU上 ``sys`` 大量增加。不过好在有8个CPU分担，没有造成CPU完全满负荷，所以可以看到运行队列立即得到缓解，系统`load average`从原先40以上下降到10以下::

   top - 23:18:20 up 50 days,  9:16,  3 users,  load average: 9.14, 15.95, 28.81
   Tasks: 6994 total,   3 running, 6988 sleeping,   0 stopped,   3 zombie
   Cpu0  :  0.0%us,  0.3%sy,  0.0%ni, 97.7%id,  2.0%wa,  0.0%hi,  0.0%si,  0.0%st
   Cpu1  :  0.0%us,  6.7%sy,  0.0%ni, 91.6%id,  1.3%wa,  0.0%hi,  0.3%si,  0.0%st
   Cpu2  : 15.5%us, 41.3%sy,  4.2%ni, 35.5%id,  0.0%wa,  0.0%hi,  3.5%si,  0.0%st
   Cpu3  : 16.4%us, 43.4%sy,  7.4%ni, 26.4%id,  0.0%wa,  0.0%hi,  6.4%si,  0.0%st
   Cpu4  : 17.7%us, 38.3%sy,  4.8%ni, 31.5%id,  2.3%wa,  0.0%hi,  5.5%si,  0.0%st
   Cpu5  : 24.7%us, 24.0%sy,  0.6%ni, 40.7%id,  0.0%wa,  0.0%hi,  9.9%si,  0.0%st
   ...
   Cpu24 :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.3%wa,  0.0%hi,  0.0%si,  0.0%st
   Cpu25 :  0.0%us,  7.0%sy,  0.0%ni, 93.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
   Cpu26 : 18.9%us, 46.2%sy,  6.7%ni, 27.9%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
   Cpu27 : 14.6%us, 42.1%sy,  1.3%ni, 42.1%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
   Cpu28 : 41.3%us, 24.1%sy,  3.2%ni, 28.6%id,  0.0%wa,  0.0%hi,  2.9%si,  0.0%st
   Cpu29 : 38.1%us, 21.6%sy,  0.0%ni, 35.6%id,  0.0%wa,  0.0%hi,  4.8%si,  0.0%st
   ...
   Mem:  263819896k total, 137200564k used, 126619332k free,  2004656k buffers
   Swap:        0k total,        0k used,        0k free, 30641964k cached

     PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
   27980 root      20   0 1189m 1.0g 5148 S  108  0.4   8095:26 qemu-kvm
   32303 root      20   0 1274m 1.0g 5136 S  107  0.4   2836:03 qemu-kvm
   46073 root      20   0 4514m 4.1g 5340 S   72  1.6   8376:12 qemu-kvm

经过对比，可以看到 ``load average`` 非常高的原因是 ``cpu 24`` 存在 ``阻塞`` ：这个CPU异常高的 ``sys`` 完全消耗了CPU资源，导致任务在运行队列中很长。

我的目标是找出导致如此高的 ``sys`` 消耗的程序，解决辅助程序堆积在运行队列中导致 ``load average`` 过高问题。
