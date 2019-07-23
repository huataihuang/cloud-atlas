.. _efi_system_partition:

====================
EFI系统分区
====================

.. note::

   现代化的计算机硬件已经采用EFI替代了早期的BIOS，对我这样从最早的DOS系统开始学习的人来说，总有一些疑惑需要厘清。特别是在类似 :ref:`tar_multi_boot_ubuntu` 这样涉及系统启动更需要对概念彻底理解。

EFI系统分区(EFI system partition)也称为ESP，是一个和操作系统无关的分区，实际上是由UEFI firmware加载的EFI bootloaders，应用程序和驱动的存储位置。

UEFI 标准支持 FAT12, FAT16 和 FAT32 文件系统，但是供应商可以选择支持附加的文件系统，例如Apple Mac的firmware支持HFS+文件系统。

检查分区
=========

- 检查系统分区 ``fdisk -l /dev/sda``

返回信息包含了磁盘分区表类型，分为 ``Disklabel type: gpt`` 表示分区表是GPT类型，而 ``Disklabel type: dos`` 则是MBR类型。此外，分区类型中显示 ``EFI System `` 或 ``EFI (FAT-12/16/32)`` 则表示是EFI系统分区，通常大小为 100-550 MB。

如果分区定义ESP，可以通过挂载分区检查是否包含一个 ``EFI`` 目录。

.. warning::

   对于多重启动，需要避免格式化ESP，因为其中可能包含启动其他操作系统的文件。

   如果找到系统中已经存在的EFI系统分区，只需要简单挂载分区就可以。如果没有找到EFI分区，则需要创建。

创建分区
===========

.. warning::

   EFI系统分区必须是磁盘主分区表的一个物理分区，不能位于LVM或者软RAID上。

   建议使用GPT分区表，因为一些firmware不支持UEFI/MBR启动（不被Windows支持）。

   为避免存储启动加载器以及启动所需的一些文件的磁盘需要，通常EFI分区至少260MB，对于一些早期或者存在bug的UEFI实现，则至少需要512MB.

GPT分区磁盘
------------

在GUID分区表（GPT分区表）的EFI系统分区是通过GUID来标记分区，可以使用以下3种磁盘分区工具创建ESP或GPT分区表：

- fdisk: 创建分区表类型是 ``EFI system``
- gdisk: 创建分区表类型是 ``EF00``
- GNU parted: 创建 ``fat32`` 分区作为文件系统，并且设置 ``esp`` 表哦乾

MBR分区磁盘
------------

MBR分区表上的EFI系统分区是通过分区类型 ``EF`` 来标记，可以使用以下工具创建:

- fdisk: 创建分区表类型是 ``EFI system``
- GNU parted: 创建 ``fat32`` 分区作为文件系统，并且设置 ``esp`` 表哦乾

格式化分区
-----------

UEFI标准支持 FAT12, FAT16 和 FAT32 文件系统，但是为了兼容不同操作系统，UEFI标准只支持在移动介质上支持 FAT16 和 FAT12，所以建议使用 FAT32。

格式化命令::

   mkfs.fat -F32 /dev/sda2

挂载分区
---------

内核, initranfs文件, 以及多数情况下，处理器的 microcode 都需要被 boot loader 或者 UEFI 自身直接访问以便能够启动系统。所以为了能够保持设置简单，boot loader要求EFI系统分区挂载点是特定的：

- 挂载ESP到 ``/efi`` 并使用在root文件系统中具有驱动的boot loader （例如，GRUB, rEFInd）
- 挂载ESP到 ``/boot`` 这是从UEFI直接启动一个EFISTUB内核的推荐方式

.. note::

   ``/efi`` 是代替以前流行的ESP挂载点 ``/boot/efi``

   ``/efi`` 目录默认不存在，需要在挂载ESP之前创建

UEFI启动原理
=============

BIOS-GPT系统不是UEFI
======================

.. note::

   最初我看到服务器上独立的 ``/boot`` 分区，不知道为何下意识想到是EFI分区，或许是因为最近几年采用的电脑设备都是使用EFI代替了BIOS，导致我形成了思维惯性。这是一个乌龙，实际上，系统具有一个大约数兆的磁盘分区，标记了 ``bios_grub`` flag就表明这个系统是 BIOS-GPT 系统，不是UEFI系统。

服务器分区表::

   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system     Name  Flags
    1      1049kB  4194kB  3146kB                        bios_grub
    2      4194kB  1078MB  1074MB  ext4                  boot
    3      1078MB  54.8GB  53.7GB  ext4
    4      54.8GB  56.9GB  2147MB  linux-swap(v1)
    5      56.9GB  1799GB  1742GB  ext4

如果采用EFI系统，例如在VMware虚拟机中安装系统，则分区如下，可以看到启动分区是 ``esp`` flag 并且是格式化成 FAT32::

   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  538MB   537MB   fat32              boot, esp
    2      538MB   6441MB  5903MB  ext4

.. note::

   参考 `parted设置分区 flag <https://www.gnu.org/software/parted/manual/html_node/set.html>`_ ::

      set 1 bios_grub on
      # 或者
      set 1 boot on
      set 1 esp on

参考
=====

- `UEFI boot: how does that actually work, then? <https://www.happyassassin.net/2014/01/25/uefi-boot-how-does-that-actually-work-then/>`_ 这是一篇非常详细介绍UFEI原理的文章，对于理解有很大帮助，建议阅读
- `Unified Extensible Firmware Interface <https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface>`_ archlinux的UEFI文档，提供了很多参考资料
- `EFI system partition <https://wiki.archlinux.org/index.php/EFI_system_partition>`_
- `Unified Extensible Firmware Interface <https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface>`_
