.. _freebsd_monitor:

=====================
FreeBSD系统监控
=====================

FreeBSD 继承了正统 BSD 家族极其深厚且强大的性能监控工具链。相比 Linux 各发行版工具的碎片化，FreeBSD 的原生工具在内核数据采集上非常高效且直接。

.. note::

   本文仅做整理记录，有待后续不断实践补充完善

vmstat: 全局系统状态与内存指标
==================================

FreeBSD的 ``vmstat`` 比Linux平台功能更为丰富，是排查系统负载、虚拟内存和中断的核心利器。

基础流式监控(每秒刷新一次)
---------------------------

.. literalinclude:: freebsd_monitor/vmstat
   :caption: 基础流式监控（每秒刷新一次）

在输出中，重点关注 ``r`` (运行队列进程数)、 ``idle`` (CPU空闲率)、内存区 ``avm`` (Active Virtual Memory)和 ``fre`` (Free Memory)。

内核内存分配器状态(Slab Allocator)
---------------------------------------

.. literalinclude:: freebsd_monitor/vmstat_z
   :caption: 内核内存分配器状态

对于分析内核内存泄漏或观察系统的内存池消耗（比如 ZFS 对象的内核缓存占用）非常直观

硬件中断统计
--------------

.. literalinclude:: freebsd_monitor/vmstat_i
   :caption: 观察设备中断

可以用来观察虚拟机的各个设备中断（如 virtio/SCSI 盘、网卡）触发频率是否均衡

systat: 全能的实时交互式可视化面板
====================================

systat 是 FreeBSD 中一个类似 top 但功能更加模块化的 curses 终端监控工具。它允许你在运行过程中通过键盘随时切换不同的观察维度。

ZFS监控
============

.. note::

   需要安装 ``zfs-stats`` 软件包

:ref:`zfs-stats` 工具提供了非常丰富的参数，通过不同选项来精细化观察 ZFS 的各项内核统计数据

- 不带任何参数 ``zfs-stats`` 会全面输出全部统计信息

- 观察ARC缓存( ``-A`` ):
