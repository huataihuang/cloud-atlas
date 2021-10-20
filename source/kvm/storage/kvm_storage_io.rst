.. _kvm_storage_io:

==================
KVM存储I/O
==================

I/O Scheduler
=================

默认HDD的磁盘I/O调度是完全公平队列(CFQ)，这种调度提供了对所有进程完全公平对磁盘I/O带宽。不过，在虚拟化环境中，需要针对不同设备使用不同I/O调度。

为了能够获得host主机和VM虚拟机的最佳性能，在虚拟化的物理主机上建议使用 ``deadline`` scheduler(针对SSD优化)，而在VM Guest虚拟机中则使用 ``noop`` scheduler(禁用I/O调度)。

- 检查当前自磁盘I/O调度::

   cat /sys/block/sda/queue/scheduler

例如，在我的 :ref:`hpe_dl360_gen9` 服务器，使用SSD磁盘，安装了 :ref:`ubuntu_linux` ，系统安装后使用的磁盘I/O调度就是 ``deadline`` ::

   [mq-deadline] none

- 要修改系统的默认(所有磁盘)的I/O调度器，使用内核参数 ``elevator`` ，即对虚拟化的物理主机::

   elevator=deadline

对VM虚拟机，则使用::

   elevator=noop

如果需要针对每个磁盘使用不同的I/O schedulers，则创建 ``/usr/lib/tmpfiles.d/IO_ioscheduler.conf`` ，按照以下案例配置，例如 ``/dev/sda`` 设置 ``deadline`` scheduler , ``/dev/sdb`` 设置 ``noop`` scheduler ::

   w /sys/block/sda/queue/scheduler - - - - deadline
   w /sys/block/sdb/queue/scheduler - - - - noop

异步I/O
=========

很多虚拟磁盘后端的实现采用了Linux异步I/O (Asynchronous I/O, aio)。默认情况下，aio上下文的最大数量是 ``65536`` ，但主机上运行了上百使用Linux异步I/O的VM虚拟机时候，有可能会超出这个限制。所以，当在VM Host主机上运行大量VM Guests时，需要增加 ``/proc/sys/fs/aio-max-nr`` ::

   cat /proc/sys/fs/aio-max-nr

默认显示::

   65536

- 可以通过以下命令修订 ``aio-max-nr`` ::

   sudo echo 131072 > /proc/sys/fs/aio-max-nr

- 如果要持久化 ``aio-max-nr`` ，则配置一个本地 ``sysctl`` 文件，例如 ``/etc/sysctl.d/99-sysctl.conf`` ::

   fs.aio-max-nr = 1048576

I/O虚拟化
===========

I/O虚拟化有不同的技术，各自具有利弊:

.. csv-table:: I/O虚拟化解决方案
   :file: kvm_storage_io/io_virt_solutions.csv
   :widths: 30, 30, 40
   :header-rows: 1

在 :ref:`priv_cloud_infra` 就采用上述 ``Device Assignment(pass-through)`` 方式，也就是 :ref:`intel_vt-d`

参考
=======

- `SUSE Linux Enterprise Server 15 SP1 Virtualization Best Practices <https://documentation.suse.com/sles/15-SP1/pdf/article-vt-best-practices_color_en.pdf>`_
