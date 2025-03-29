.. _linux_cfs_bandwidth_control:

==========================================
Linux CFS带宽控制(CFS Bandwidth Control)
==========================================

Linux内核对CFS带宽控制是通过 ``CONFIG_FAIR_GROUP_SCHED`` 扩展来指定一个 ``group`` 或 ``层级`` (hierarchy) 的最大CPU带宽。

这个CPU带宽针对一个group来配置 ``配额`` (quota) 和 ``周期`` (period)。对于每个给定 ``周期`` (毫秒,microseconds)，一个task group将被分配一个 CPU 时间的 "限定" 毫秒数( ``quota microseconds`` )。当一个cgroup可运行时，这个quota被指定给切片线程运行的每个CPU运行队列(That quota is assigned to per-cpu run queues in slices as threads in the cgroup become
runnable.)一旦分配了所有的配额，则任何额外的配额都会导致这些线程被限制，受限制的线程将无法运行，直到下一个时间段恢复配额。

.. note::

   上面这段原文有点拗口，简单理解就是在时间范围中CPU计算能力被分片分配，每个cgroup被分配了一定的CPU分片(slice)，用完了就只能等下一个CPU时间段才能再次运行。

   虽然对于每个SA来说，Linux的调度管理都多少懂一些，但是还是有些懵懵懂懂，所以后续再学习一些教程再回来阅读kernel文档。

.. note::

   `Unthrottled: Fixing CPU Limits in the Cloud <https://engineering.indeedblog.com/blog/2019/12/unthrottled-fixing-cpu-limits-in-the-cloud/>`_ Indeed公司(世界流量最大的求职网站，日本公司)工程师博客，有不少技术深度的文章，并且我也曾经找到过该公司技术分享的PDF，类似于LinkIn。这篇文章先Mark，后面我再来实践

参考
=====

- `Linux Scheduler » CFS Bandwidth Control <https://www.kernel.org/doc/html/latest/scheduler/sched-bwc.html>`_ 
