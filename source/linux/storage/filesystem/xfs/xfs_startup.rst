.. _xfs_startup:

=====================
XFS文件系统快速起步
=====================

安装和修复XFS
===============

- 安装XFS管理工具 ``xfsprogs`` ::

   sudo pacman -S xfsprogs

- 如果需要修复XFS文件系统，需要先umount之后再修复::

   umount /dev/sda3
   xfs_repair -v /dev/sda3

XFS在线元数据检验(scrub)
===========================

.. warning::

   XFS的scrub可以用来检验元数据，但是这是一个试验性质程序。

``xfs_scrub`` 会查询内核有有关XFS文件系统所有元数据独爱想。元数据记录被扫描检查明显损坏值然后交叉应用另一个元数据。目的是通过检查单个元数据记录相对于文件系统中其他元数据的一致性来建立对整个文件系统一致性的合理信心。如果存在完整的冗余数据结构，则可以从其他元数据重建损坏的元数据。

通过启动和激活 ``xfs_scrub_all.timer`` 来周期性检查在线XFS文件系统的元数据。

XFS元数据校验
----------------

xfsprogs 3.2.0引入了一个磁盘格式v5包含了元数据校验和机制，称为"自描述元数据"(Self-Describing Metadata)，基于CRC32，提供了对于元数据的附加保护，避免电源故障时发生意外。从xfsprogs 3.2.3开始默认激活了校验，不过对于比较旧哦内核，可以通过 ``-m crc=0`` 关闭校验::

   mkfs.xfs -m crc=0 /dev/target_partition

XFS性能
============

在RAID设备上使用XFS时候，有可能通过使用 ``largeio`` , ``swalloc`` 参数值增加来提高性能。参考:

- `Recommended XFS settings for MarkLogic Server <https://help.marklogic.com/Knowledgebase/Article/View/505/0/recommended-xfs-settings-for-marklogic-server>`_

.. note::

   MarkLogic Server是面向文档的No-SQL数据库，上文提供了XFS优化策略可以参考实践。

XFS条带大小和宽度
-------------------

如果文件系统建立在条代化的RAID之上，通过 ``mkfs.xfs`` 命令参数设置特定条带大小可以显著提升性能。XFS有时能够检查出底层软RAID的分布，但是对于硬件RAID，请参考 `how to calculate the correct sunit,swidth values for optimal performance <http://xfs.org/index.php/XFS_FAQ#Q:_How_to_calculate_the_correct_sunit.2Cswidth_values_for_optimal_performance>`_

XFS案例
=========

以下案例在LVM上创建XFS文件系统

- 创建GPT分区:

.. literalinclude:: xfs_startup/parted
   :caption: 为 :ref:`linux_lvm` 准备磁盘

如果有多个NVMe磁盘，依次执行:

.. literalinclude:: xfs_startup/parted_multi_disk
   :caption: 多个磁盘分区

- 完成后检查磁盘::

   lsblk

输出类似::

   NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   nvme0n1     259:0    0  3.5T  0 disk 
   └─nvme0n1p1 259:2    0  3.5T  0 part 
   nvme0n2     259:0    0  3.5T  0 disk 
   └─nvme0n2p1 259:2    0  3.5T  0 part 
   nvme0n3     259:0    0  3.5T  0 disk 
   └─nvme0n3p1 259:2    0  3.5T  0 part 
   ...

- 创建逻辑卷:

.. literalinclude:: xfs_startup/lvm_striped
   :caption: 创建条代化LVM卷

说明:

  - ``-i 3`` 表示使用3块磁盘作为volume group，这样条带化会分布到3个磁盘上
  - ``-I 128k`` 表示使用 128k 作为条带化大小，也可以使用单纯数字 ``128`` 默认单位就是 ``k`` 
  - ``-l`` 表示扩展百分比，这里采用了 ``10%FREE`` 和 ``100%FREE`` 表示空闲空间的10%和100% ; 另外一种常用的扩展大小表示是使用 ``-L`` 参数，则直接表示扩展多少容量，例如 ``-L 10G`` 表示扩展 10GB 空间

.. note::

   `Striped Logical Volume in Logical volume management (LVM) <https://www.linuxsysadmins.com/create-striped-logical-volume-on-linux/>`_ 提供了一个条带化LVM卷的构建案例，我在后续LVM实践案例中将参考。


- 创建文件系统::

   mkfs.xfs -n ftype=1 /dev/vg_db/vl_log
   mkfs.xfs -n ftype=1 /dev/vg_db/vl_data

说明:

  ``-n ftype=1`` 是XFS在overlay文件系统时候存储附加元数据时候必须使用的，这个参数在 RHEL 7.4 之后XFS模式激活 ``ftype=1`` ，详情参考RHEL 7文档，在 `Docker installation on RHEL 7.2 and file system requirement <https://serverfault.com/questions/1029785/docker-installation-on-rhel-7-2-and-file-system-requirement/1029872#1029872>`_ 可以看到，docker容器要求XFS格式化成 ``fytpe=1`` 才能正常用于 ``/var/lib/docker`` 正常工作。

- 创建挂载配置::

   echo "/dev/vgdb/log    /dbdata/log   xfs defaults,noatime,nodiratime,PeepOpenquota 0 0" >> /etc/fstab
   echo "/dev/vgdb/data   /dbdata/data  xfs defaults,noatime,nodiratime,PeepOpenquota 0 0" >> /etc/fstab

- 挂载目录::

   mkdir -p /dbdata/{log,data}
   mount -a

参考
======

- `Arch Linux社区文档 - XFS <https://wiki.archlinux.org/index.php/XFS>`_
- `Setting up LVM on three SCSI disks with striping <https://tldp.org/HOWTO/LVM-HOWTO/recipethreescsistripe.html>`_
