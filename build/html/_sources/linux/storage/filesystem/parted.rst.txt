.. _prated:

=========================
使用parted对磁盘分区
=========================

``parted`` 是当前主流发型版替代 ``fdisk`` 实现大容量磁盘分区管理的工具。 ``parted`` 支持交互模式，也支持直接的命令行模式（可以在shell中使用）。

``分区的文件系统类型`` 和 ``mkfs``
=====================================

磁盘分区可以有一个 ``类型`` 但是这不是强制要求分区类型和实际文件系统类型一致，只是表示分区期望的文件系统类型。 ``parted`` 将分区定义为 ``磁盘之上的一部分`` (a part of the overall disk)，实际上 ``parted`` 并不知道分区类型(该参数可选)。不过，如果分区设置文件系统类型和实际文件系统类型不一致，在使用中，文件系统自动检测和自动挂载可能不能正常工作。

命令行案例
==========

基本命令模式（注意，选项在设备名前面，命令在设备之后，这样选项就会传递给 ``parted`` 命令） ::

   parted [OPTION]... [DEVICE [COMMAND [PARAMETERS]...]...]

例如::

   parted -a optimal /dev/sda mkpart primary 0% 256MB

..

   检查分区是否对齐4k，使用 ``parted /dev/sda`` 然后执行命令 ``align-check opt 1`` ，如果对齐则显示 ``1 aligned``

如果直接使用 ``parted [OPTION]... [DEVICE]`` 就会进入交互模式。

- 列出磁盘分区::

   parted /dev/sda print

- 在交互模式下，也可以通过 ``select`` 切换磁盘::

   (parted) select /dev/sdX

- 创建分区表

分区表是通过命令 ``mklabel`` 完成的，类型有 ``msdos`` （即传统的DOS分区表），也可以使用现在主流的 ``gpt`` ::

   parted /dev/sda mklabel gpt

..

   ``警告`` ：重建分区表将擦除磁盘上所有数据。

-  创建分区

使用交互命令 ``mkpart`` 可以实现创建分区，但是非常繁琐。直接命令行实现较为快捷::

   parted -a optimal /dev/sda mkpart primary 0% 256MB

- 调整分区大小: ``resizepart`` 命令调整分区大小

- 删除分区 ::

   parted /dev/sda rm 1

``rm 1`` 表示删除分区

- 挽救分区

``rescure`` 可以恢复开始和结束点之间的分区，如果在这个开始和结束点之间的分区被找到， ``parted`` 就会尝试恢复::

   (parted) rescue
   Start? 1
   End? 15000
   (parted) print
   Model: Unknown (unknown)
   Disk /dev/sdb1: 15.0GB
   Sector size (logical/physical): 512B/512B
   Partition Table: loop
   Disk Flags:
   Number Start End Size File system Flags
   1 0.00B 15.0GB 15.0GB ext4

- 修改分区标记

支持多种分区标记::

   boot
   root
   swap
   hidden
   raid
   lvm
   lba
   legacy_boot
   irst
   esp
   palo

例如执行::

   (parted) set 2 boot on

案例实践
============

LFS磁盘分区准备案例
----------------------

在LFS磁盘分区准备工作中，使用 ``parted`` 来完成分区，详情请参考 :ref:`lfs_prepare`

初始化磁盘分区表（擦除原先的所有数据） ::

   parted /dev/sda mklabel gpt

创建第一个 ``sda1`` 分区，用于EFI启动 ::

   parted -a optimal /dev/sda mkpart ESP fat32 0% 256MB
   parted /dev/sda set 1 esp on

主分区59G空间，剩余用于swap ::

   parted -a optimal /dev/sda mkpart primary ext4 256MB 59GB
   parted -a optimal /dev/sda mkpart primary linux-swap 59GB 100%

完成后最后检查 ``fdisk -l /dev/sda`` ::

   Disk /dev/sda: 56.5 GiB, 60666413056 bytes, 118489088 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 25AAF5C2-70A9-4B7A-8350-C11F96658DC1

   Device         Start       End   Sectors  Size Type
   /dev/sda1       2048    499711    497664  243M EFI System
   /dev/sda2     499712 115234815 114735104 54.7G Linux filesystem
   /dev/sda3  115234816 118487039   3252224  1.6G Linux swap

:ref:`xfs_startup` 磁盘分区案例
---------------------------------

参考
======

- `8 Linux ‘Parted’ Commands to Create, Resize and Rescue Disk Partitions <https://www.tecmint.com/parted-command-to-create-resize-rescue-linux-disk-partitions/>`_
- `archlinux: GNU Parted - UEFI/GPT examples <https://wiki.archlinux.org/index.php/GNU_Parted#UEFI.2FGPT_examples>`_
- `Partitioning Disks with parted <https://access.redhat.com/sites/default/files/attachments/parted_0.pdf>`_
- `Why does parted need a filesystem type when creating a partition, and how does its action differ from a utility like mkfs.ext4? <https://unix.stackexchange.com/questions/551030/why-does-parted-need-a-filesystem-type-when-creating-a-partition-and-how-does-i>`_
