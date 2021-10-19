.. _introduce_stratis:

======================
Stratis存储技术简介
======================

在Linux本地存储技术领域存在多种成熟稳定的技术:

- device mapper(dm)
- 逻辑卷管理(LVM)
- XFS文件系统

这些技术组件提供的功能包括大规模的伸缩文件系统，快照(snapshots)，冗余(RAID)逻辑卷,多路径，thin provisioning(精简配置?)，缓存，重复数据删除(deduplication)，以及支持虚拟机和容器。每个存储堆栈曾(dm, LVM 和 XFS)都是需要使用特定的命令和工具来维护，这就要求系统管理员将这些存储层作为独立的存储组件来维护，所以相对复杂和运维成本高。

Red Hat当前的存储战略(CentOS/RHEL 8)是新型的 Stratis 存储，结合了上述3种成熟的本地存储技术，但是通过统一的管理工具来维护。Stratis作为服务运行，管理了物理存储设备以及透明创建和管理卷、文件系统。由于Stratis使用现有的存储驱动和工具，所以所有LVM, XFS以及device-mapper的高级存储功能都得到了继承。

在卷管理文件系统，文件系统是使用一种称为 ``thin provisioning`` 来构建磁盘设备的共享池。Stratis文件系统没有固定大小，也不会预分配没有使用的块空间。虽然这个文件系统依然建筑在一个隐藏的LVM卷上，Stratis管理这个底层卷，并且可以按需扩展。这种 ``in-use`` 大小的文件系统只显示实际包含文件的块，而文件系统可用空间实际上是整个存储池设备的剩余空间。多个文件系统可以共享相同的磁盘设备存储池，共享这个可用空间，但是文件系统可以预留存储池空间以确保当需要时可以存储数据。

Stratis使用存储元数据(stored metadata)来标识被管理的存储池，卷和文件系统。这样，通过Stratis创建的文件系统就不需要重新格式化或者手工重新配置；它们只需要使用Stratis工具和命令进行管理。手工配置Stratis文件系统会导致元数据丢失并导致Stratis不能感知文件系统已经被创建。

可以在不同的块设备集合上创建多个存储池。从每个存储池可以创建一个或多个文件系统。当前，支持在每个存储池创建最多224个文件系统:

.. figure:: ../../../_static/linux/storage/stratis/components-of-Stratis-RHEL-8.jpg
   :scale: 80

存储池将块设备组织成数据层(data tier)以及可选的缓存层(cache tier)，数据层聚焦于灵活性(flexibility)和完整性(integrity)，而缓存层则聚焦于提升性能。由于缓存层趋向于提升性能，所以建议使用高IOPS(input/output per second)的固态存储设备，例如SSDs。

简化存储堆栈
==============

Stratis简化了很多本地存储供给(local storage provisioning)和一系列Red Hat产品的配置访问的交互。例如，在Anaconda安装的早期版本，系统管理员不得不处理每个磁盘管理的方方面面，而现在使用Stratis，只需要简单磁盘设置。其他使用Statis的产品包括 :ref:`cockpit` ， Red Hat Virtualization 以及 Red Hat Enterprise Linux Atomic Host。对于这些产品，Stratis都能够简化和更少犯错地管理存储空间和快照。Stratis还提供了易于集成到更高层管理工具的能力，这样就不必使用任何编程CLI。

.. figure:: ../../../_static/linux/storage/stratis/Stratis-in-the-Linux-storage-management-stack.jpg
   :scale: 80

Stratis层
============

Stratis内部使用 ``Backstore`` 子系统来管理块设备，用 ``Thinpool`` 子系统来管理存储池。其中 ``Backstore`` 子系统有一个数据层来维护在块设备上(on-disk)的元数据(metadata)并且检测和修复数据腐化。缓存层( ``cache tier`` )使用高性能的块设备作为数据层( ``data tier`` )上的缓存。这个子系统使用 ``dm-thin`` device-mapper驱动来代替位于虚拟卷之上的LVM，这样可以实现伸缩和管理。 ``dm-thin``
使用一个大型虚拟规格来创建卷，使用XFS格式化，但是维持了一个实际上非常小的使用量。当物理存储空间接近满的时候，Stratis会自动扩展卷。(也就是说， ``dm-thin`` 最大的好处是创建虚拟规格的逻辑卷，但实际上只占用很小的磁盘空间，只在空间接近满的时候自动扩展，这样大大节约了磁盘)

.. figure:: ../../../_static/linux/storage/stratis/Stratis-layers-CentOS-8.jpg
   :scale: 80

管理thin-provisoned文件系统
=============================

要使用Stratis存储管理解决方案来管理thin-provisoned文件系统，需要安装 ``stratis-cli`` 和 ``stratisd`` 软件包。其中 ``stratis-cli`` 软件包包括了 ``stratis`` 命令，这个命令可以通过D-Bus API转换用户请求到statisd服务。 ``statisd`` 软件包提供了 ``statisd`` 服务，这服务实现了D-Bus接口，并且管理和监控了Stratis的元素，例如快设备，存储池，和文件系统。只要 ``statisd`` 服务在运行，这个D-Bus API就存在。

详细的实践操作见 :ref:`stratis_startup`

参考
=======

- `Beginners Guide to Stratis local storage management in CentOS/RHEL 8 <https://www.thegeeksearch.com/beginners-guide-to-stratis-local-storage-management-in-centos-rhel-8/>`_
- `CHAPTER 23. MANAGING LAYERED LOCAL STORAGE WITH STRATIS <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/managing-layered-local-storage-with-stratis_managing-file-systems>`_
