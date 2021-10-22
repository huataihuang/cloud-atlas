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

:ref:`priv_cloud_infra` 采用上述 ``Device Assignment(pass-through)`` 方式，也就是 :ref:`iommu` ，现在这个传统的 KVM PCI Pass-Through 设备分配已经被VFIO 标准(Virtual Function I/O)取代。VFIO驱动直接输出设备访问到一个安全内存(IOMMU)保护环境的用户空间。使用VFIO，VM Guest虚拟机可以直接访问VM Host物理主机硬件设备(pass-through)，避免了模拟带来的性能损失。注意，这种模式不允许共享设备(和SR-IOV不同)，每个设备只能指派给一个唯一VM
Guest。要实现VFIO，需要满足条件有:

- Host物理主机服务器CPU和主板芯片以及BIOS/UEFI支持
- BIOS/EFI激活了IOMMU
- 内核参数设置激活IOMMU: 对于Intel处理器，内核参数使用 ``intel_iommu=on``
- 系统提供了VFIO架构，也即是内核加载了模块 ``vfio_pci``

.. note::

   我最初想通过 :ref:`intel_vt-d_startup` 设置VT-d来实现pass-through方式分配磁盘给虚拟机，虽然这个方法依然可以采用，但是显然目前虚拟化技术已经发展 VFIO 设备(底层还是IOMMU)，所以，实际实践采用 :ref:`vfio` 完成。

pass-through 分区(似乎不行)
-------------------------------

参考 `Pass through a partition? <https://www.reddit.com/r/VFIO/comments/j443ad/pass_through_a_partition/>`_

- 可以将一个磁盘分区pass through给虚拟机，但是需要注意分区在虚拟机内部会视为一个完整磁盘，所以虚拟机在这个分区中创建完整的GPT分区表，从外部看来这是一个嵌套的(nested)分区
- 需要非常小心，在物理服务器上不能直接访问pass-through给虚拟机的分区中的数据，需要特殊处理(我记得是要使用loop方式)

但是，参考 `Disk Passthrough Explained <https://passthroughpo.st/disk-passthrough-explained/>`_ 的 ``Direct SATA Controller Passthrough via vfio-pci`` :

SATA控制器是位于PCI总线，所以可以将SATA控制器直接pass
through给虚拟机，这样就几乎没有延迟或超载，提供了最高的带宽。这个方案的缺点是整个SATA控制器都被VM控制，所以这个SATA控制器无法在Host主机使用，也就是说你必须有2个SATA控制器，一个给Host主机使用，一个给VM虚拟机使用。由于主机上的SATA控制器数量有限(通常就2个)，扩展管理非常麻烦(Guest虚拟机使用这个SATA控制器时候，物理主机不能使用这个SATA控制器上的所有磁盘)。

`lennard0711/vfio <https://github.com/lennard0711/vfio>`_ 提供了一个配置案例，并且 `arch linux: PCI passthrough via OVMF - Physical disk/partition <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Physical_disk/partition>`_ 介绍了可以pass through磁盘或分区

基于磁盘的虚拟化存储
======================

`Tuning VM Disk Performance <https://www.heiko-sieger.info/tuning-vm-disk-performance/>`_ 的 ``Disk-based storage`` 方案和我设想相近:

- 使用LVM逻辑卷来构建 ``raw`` 磁盘，直接分配给虚拟机使用(虽然也能直接用分区，但是分区只能固定数量，很难调节，而LVM卷可以在底层伸缩)
- 虚拟机磁盘配置 ``cache=none`` 提高性能

这种方式去掉了Host主机上的文件系统层，理论上可以提高性能，不过性能肯定不如pass-through

实际上Red Hat虚拟化文档就提供了这个解决方法 `第 12 章 创建和管理精简配置的逻辑卷（精简卷） <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/assembly_thinly-provisioned-logical-volumes_configuring-and-managing-logical-volumes>`_


参考
=======

- `SUSE Linux Enterprise Server 15 SP1 Virtualization Best Practices <https://documentation.suse.com/sles/15-SP1/pdf/article-vt-best-practices_color_en.pdf>`_
- `SUSE Linux Enterprise Server 15 SP1 Virtualization Guide <https://documentation.suse.com/sles/15-SP1/html/SLES-all/book-virt.html>`_
- `Tuning VM Disk Performance <https://www.heiko-sieger.info/tuning-vm-disk-performance/>`_
