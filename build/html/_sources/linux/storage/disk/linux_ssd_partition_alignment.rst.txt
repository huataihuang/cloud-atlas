.. _linux_ssd_partition_alignment:

=====================
Linux SSD分区对齐
=====================

正如 `Linux SSD partition alignment – problems with external USB-to-SATA controllers – I <https://linux-blog.anracom.com/2018/12/03/linux-ssd-partition-alignment-problems-with-external-usb-to-sata-controllers-i/>`_ 开头所说: 当你尝试解决一个问题，就会发现你从来没有意料的新问题出现。

奇怪的65535起始扇区
=======================

我在构建 :ref:`edge_cloud` 的树莓派集群，选购的 :ref:`wd_passport_ssd` ，在第三次购买的西数Passport SSD虽然 ``fdisk -l /dev/sda`` 显示有::

   Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0x221a87f7

   Device     Boot Start        End    Sectors   Size Id Type
   /dev/sda1        2048 1953521663 1953519616 931.5G  7 HPFS/NTFS/exFAT

但是我发现不管怎样使用 ``fdisk`` 创建分区，默认都只能从 ``65535`` 扇区开始::

   Welcome to fdisk (util-linux 2.36.1).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.


   Command (m for help): p
   Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0xcb6a7256

   Command (m for help): n
   Partition type
      p   primary (0 primary, 0 extended, 4 free)
      e   extended (container for logical partitions)
   Select (default p): p
   Partition number (1-4, default 1):
   First sector (65535-1953525167, default 65535):
   Last sector, +/-sectors or +/-size{K,M,G,T,P} (65535-1953525167, default 1953525167): +256MB

   Created a new partition 1 of type 'Linux' and of size 256 MiB.

   Command (m for help): p
   Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0xcb6a7256

   Device     Boot Start    End Sectors  Size Id Type
   /dev/sda1       65535 589814  524280  256M 83 Linux

   Partition 1 does not start on physical sector boundary.

可以看到分区开始位置并不是物理扇区边界 ``Partition 1 does not start on physical sector boundary.``

我注意到我前2次购买到 ``Disk model: My Passport 25F3`` 设备的 ``Sector size`` 和 ``I/O size (logical/physical)`` 和第3次购买的设备不同，原先是::

   Disk /dev/sda: 953.86 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd

   Device     Boot  Start      End  Sectors  Size Id Type
   /dev/sda1  *      2048   526335   524288  256M  c W95 FAT32 (LBA)
   /dev/sda2       526336 67635199 67108864   32G 83 Linux

为什么第3次购买的设备::

   Disk model: ssport
   ...
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes

而之前2次购买的设备sector不同::

   Disk model: My Passport 25F3
   ...
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes

物理扇区从 ``4096`` 字节变成了 ``512`` 字节，而优化I/O大小从原先的 1MB (1048576/1024.0=1024.0) 更改成了约 32MB (33553920/1024.0/1024.0=31.99951171875)

`How to fix “Partition does not start on physical sector boundary” warning? <https://askubuntu.com/questions/156994/how-to-fix-partition-does-not-start-on-physical-sector-boundary-warning>`_ 提到了西部数据 `Advanced_Format <https://en.wikipedia.org/wiki/Advanced_Format>`_ 使用了4096字节的物理扇区取代陈旧的每个扇区512字节。并且西数还提供了一个 `Advanced Format Hard Drive Download Utility <https://web.archive.org/web/20150912110749/http://www.wdc.com/global/products/features/?id=7&language=1>`_ 介绍了在旧设备上启用Advanced Formatting提高性
能。

Western Digital Dashboard
----------------------------

西部数据提供了 `Western Digital Dashboard <https://support.wdc.com/downloads.aspx?lang=en&p=279>`_ 帮助用户分析磁盘(包括磁盘型号，容量，firmware版本和SMART属性)以及firmware更新

`Western Digital Dashboard <https://support.wdc.com/downloads.aspx?lang=en&p=279>`_ 提供了Windows版本，我部署使用 :ref:`alpine_extended` ，通过 :ref:`kvm` 运行Windows虚拟机来测试SSD 磁盘，验证和排查为何最新购买的SSD磁盘使用了较小的物理扇区(512字节sector)

参考
======

- `Linux SSD partition alignment – problems with external USB-to-SATA controllers – I <https://linux-blog.anracom.com/2018/12/03/linux-ssd-partition-alignment-problems-with-external-usb-to-sata-controllers-i/>`_
- `Why does fdisk insist on starting the first partition at sector 65535 (MiB 31.9995...) <https://unix.stackexchange.com/questions/303354/why-does-fdisk-insist-on-starting-the-first-partition-at-sector-65535-mib-31-99>`_
