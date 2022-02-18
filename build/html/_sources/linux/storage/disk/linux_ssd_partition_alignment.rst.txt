.. _linux_ssd_partition_alignment:

=====================
Linux SSD分区对齐
=====================

.. note::

   本文是探寻为何新购买的USB SSD磁盘起始扇区不是常规的 ``2048`` 而是 ``65535`` ，并且使用了 ``parted`` 强制手段来对齐到 ``2048`` ( ``1MiB`` )。

   不过，虽然可以强制对齐 ``2048`` ，但是考虑到 ``USB-to-SATA`` 控制器的参数是厂商提供的，应该有其优化原因(例如大数据块读写)。所以，最终并没有采用本文强制对齐 ``2048`` 扇区( ``1MiB`` )，而是按照 ``parted`` 默认对齐优化方式分区。所以会和之前SSD磁盘分区有些差异，对使用来说没有区别。

   本文仅供参考。

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

1 MiB-alignment
====================

对于SSD磁盘，通常会希望Linux使用 ``1 MiB-alignment`` ，也就是以 ``512`` 字节的逻辑扇区，共计 ``2048`` 个扇区，磁盘的第一个分区会对齐在 ``2048 * 512 = 1024 * 1024 = 1 (MiB) = 256 * 4096`` 。

这个第一分区的起始扇区也就是称为具备原生4k支持的AF磁盘，不论磁盘底层使用 ``512`` 字节还是 ``4096`` 字节，都能保证 ``1 MiB-alignment`` 能够对齐物理扇区。

- 磁盘通过 ``lsblk`` 检查::

   # lsblk /dev/sde
   NAME MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   sde    8:64   0 931.5G  0 disk

可以看到上述存在比较奇怪问题的 :ref:`wd_passport_ssd` 规格是 ``931.5G`` 。而我另外购买的2快同样型号 :ref:`wd_passport_ssd` 使用 ``lsblk`` 检查却是 ``953.8G`` ::

   # lsblk /dev/sda
   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   sda      8:0    0 953.8G  0 disk
   ├─sda1   8:1    0   256M  0 part /media/sda1
   └─sda2   8:2    0    32G  0 part /

- 当使用 ``fdisk`` 或者 ``pated`` 分区，就会看到第一个分区始终只能建立在从 ``65535`` 扇区开始，而这个 ``65535`` 扇区不是 ``2048`` 的倍数

.. literalinclude:: linux_ssd_partition_alignment/fdisk.txt
   :language: bash
   :caption: fdisk和parted分区显示从 65535 开始

`Linux SSD partition alignment – problems with external USB-to-SATA controllers – I <https://linux-blog.anracom.com/2018/12/03/linux-ssd-partition-alignment-problems-with-external-usb-to-sata-controllers-i/>`_ 的作者做了一个测试，将SSD移动硬盘从USB外接上拆下来，直接连接到主机的SATA控制器，则再次使用 ``fdisk`` 划分分区就会从 ``2048`` 扇区开始。这说明:

- 通过外接的 ``USB-to-Sata-controller bus`` ，磁盘的起始扇区会从 ``65535`` 的倍数开始

Linux如何搜集和报告磁盘属性
=============================

从 RedHat 的网站上可以找到 `io-limits.txt <https://people.redhat.com/msnitzer/docs/io-limits.txt>`_ 说明了 "I/O Limits" 是基于 ``sysfs`` 和 ``块设备`` 的 ``ioctl`` 接口( 如 ``libblkid`` )获取信息:

- ``sysfs interface`` ::

   /sys/block/<disk>/alignment_offset
   /sys/block/<disk>/<partition>/alignment_offset
   /sys/block/<disk>/queue/physical_block_size
   /sys/block/<disk>/queue/logical_block_size
   /sys/block/<disk>/queue/minimum_io_size
   /sys/block/<disk>/queue/optimal_io_size

我们检查这个存在问题的磁盘就可以看到:

.. literalinclude:: linux_ssd_partition_alignment/sysfs_block_sde.txt
   :language: bash
   :caption: 起始扇区65535的磁盘 I/O Limits信息

而之前正常磁盘的信息

.. literalinclude:: linux_ssd_partition_alignment/sysfs_block_sda.txt
   :language: bash
   :caption: 起始扇区2048的磁盘 I/O Limits信息

上述信息称为 "I/O Limits" 数据

通过 ``lsblk`` 命令，我们可以看出上述数据::

   lsblk -o  NAME,ALIGNMENT,MIN-IO,OPT-IO,PHY-SEC,LOG-SEC

此时输出对比就可以看到，那块起始扇区异常位于 ``65535`` 扇区的USB外接SSD磁盘输出如下::

   NAME                          ALIGNMENT MIN-IO   OPT-IO PHY-SEC LOG-SEC
   sde                                   0   4096 33553920     512     512

而正常输出则是::

   NAME   ALIGNMENT MIN-IO  OPT-IO PHY-SEC LOG-SEC
   sda            0   4096 1048576    4096     512

此外，对比直接连接在SATA接口上的SSD磁盘，会看到这个 ``optimal_io_size`` 显示是 ``0`` ，例如，以下是一块intel 内置2.5" SSD固态硬盘::

   NAME                          ALIGNMENT MIN-IO   OPT-IO PHY-SEC LOG-SEC
   sda                                   0    512        0     512     512

将SSD移动硬盘直接接在SATA接口上，则 ``optimal_io_size`` 显示是 ``0`` ，而我购买的 :ref:`wd_passport_ssd` 接在USB接口上显示有2种值，一种是比较正常的::

   NAME   ALIGNMENT MIN-IO  OPT-IO PHY-SEC LOG-SEC
   sda            0   4096 1048576    4096     512

另一种是比较异常的::

   NAME                          ALIGNMENT MIN-IO   OPT-IO PHY-SEC LOG-SEC
   sde                                   0   4096 33553920     512     512

导致不同对齐的原因
=====================

Linux分区工具，例如 ``parted`` 使用 ``libblkid`` 的输出信息，而 Linux 则是基于磁盘的属性数据( ``I/O Limits`` )来 ``启发`` 对齐决策，根据: `io-limits.txt <https://people.redhat.com/msnitzer/docs/io-limits.txt>`_ 所谓的启发分区::

   "The heuristic parted uses is:
   1)  Always use the reported 'alignment_offset' as the offset for the
       start of the first primary partition.
   2a) If 'optimal_io_size' is defined (not 0) align all partitions on an
       'optimal_io_size' boundary.
   2b) If 'optimal_io_size' is undefined (0) and 'alignment_offset' is 0
       and 'minimum_io_size' is a power of 2: use a 1MB default alignment.
       - as you can see this is the catch all for "legacy" devices which
         don't appear to provide "I/O hints"; so in the default case all
         partitions will align on a 1MB boundary.
       - NOTE: we can't distinguish between a "legacy" device and modern
         device that provides "I/O hints" with alignment_offset=0 and
         optimal_io_size=0.  Such a device might be a single SAS 4K device.
         So worst case we lose < 1MB of space at the start of the disk." 

由于异常磁盘报告: ``optimal_io_size: 33553920 (bytes)`` (32MB)，则 ``33553920 / 512 = 65535`` ，所以就会把磁盘分区的起始扇区决定为 **65535** 

而正常的磁盘报告: ``optimal_io_size: 1048576 (bytes)`` (1MB)，则 ``1048576 / 512 = 2048`` ，则把磁盘分区的起始扇区决定为 **2048** 

注意，对于直接通过SATA接口连接的intel SSD磁盘，报告的 ``optimal_io_size: 0`` ，则Linux内核自动把扇区对齐到 1MB 位置。

.. note::

   为什么我最近购买的 :ref:`wd_passport_ssd` 会报告一个非常高的 ``optimal_io_value`` ，高达 32MiB ？

gdisk
=========

由于Linux的分区工具，是通过 ``libblkid`` 库来监测磁盘拓扑参数(I/O limits)，通过 ``heuristic rules`` (启发式规则)来决定对齐，这就导致了SSD磁盘接在内置SATA磁盘接口和USB转换SATA外置接口不同的参数，引发不同的对齐策略。

虽然 ``fdisk`` 和 ``prated`` 都是使用 ``libblkid`` 库，导致磁盘起始扇区没有实现 ``1MiB-alignment`` ，但是，如果使用 ``gdisk`` 则会忽略这个问题，即使通过外接 ``USB-to-SATA-controller`` 依然会执行 ``1MiB-alignment`` 。

此外，虽然 ``fdisk`` 不能忽略 ``65535`` 的起始扇区，但是 ``parted`` 却提供了强制创建分区(忽略对齐 ``65535`` )::

    # parted /dev/sde mkpart primary fat32 1MiB 257MiB
    Warning: The resulting partition is not properly aligned for best performance: 4000000s % 65535s !=
    0s
    Ignore/Cancel? i
    Information: You may need to update /etc/fstab.

可以看到，上面 ``parted`` 命令强制创建分区从 ``1MiB`` 开始，也就是 ``2048`` 扇区开始，同时结束是 ``257MiB`` ，则分区空间就是 256 MB。

然后通过 ``fdisk -l /dev/sde`` 命令可以检查::

   Disk /dev/sde: 931.53 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0xd7882f4e

   Device     Boot Start    End Sectors  Size Id Type
   /dev/sde1        2048 526335  524288  256M  c W95 FAT32 (LBA)

然后再添加第二个分区::

   parted /dev/sde mkpart primary ext4 257MiB 32GiB

不过，我发现 ``parted`` 划分的分区只能指定 ``start`` 和 ``end`` ，所以实际划分的分区大小和之前使用 ``fdisk`` 划分分区使用 ``+32G`` 获得的分区大小有一点点区别。所以最终第2个分区我是使用 ``fdisk`` 来添加的。使用 ``fdisk`` 命令添加分区可以直接指定扇区或分区大小(只有第一个分区受到 ``65535`` 影响无法指定 ``2048`` ，第二个分区已经超出 ``65535`` 就还是可以使用 ``fdisk`` 来管理分配的)

使用 ``fdisk /dev/sde`` 划分第二个分区步骤如下:

.. literalinclude:: linux_ssd_partition_alignment/fdisk_sde2.txt
   :language: bash
   :caption: 在parted强制划分第一个分区从2048扇区开始，再用fdisk添加第二个扇区

完成后可以看到，分区的扇区和之前 :ref:`alpine_install_pi_usb_boot` 完全一致。

然后就可以完成 :ref:`alpine_pi_usb_boot_clone`

- 不过，上述强制分区对齐到 ``1MiB`` 上，使用 ``parted`` 检查分区是显示不对齐的::

   Disk /dev/sde: 931.53 GiB, 1000204886016 bytes, 1953525168 sectors
   Disk model: ssport
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 4096 bytes / 33553920 bytes
   Disklabel type: dos
   Disk identifier: 0xd7882f4e

   Device     Boot  Start      End  Sectors  Size Id Type
   /dev/sde1         2048   526335   524288  256M  c W95 FAT32 (LBA)
   /dev/sde2       526336 67635199 67108864   32G 83 Linux

检查命令显示如下::

   # parted /dev/sde align-check opt 1
   1 not aligned: 2048s % 65535s != 0s
   
   # parted /dev/sde align-check opt 2
   2 not aligned: 526336s % 65535s != 0s

参考
======

- `Linux SSD partition alignment – problems with external USB-to-SATA controllers – I <https://linux-blog.anracom.com/2018/12/03/linux-ssd-partition-alignment-problems-with-external-usb-to-sata-controllers-i/>`_
- `Why does fdisk insist on starting the first partition at sector 65535 (MiB 31.9995...) <https://unix.stackexchange.com/questions/303354/why-does-fdisk-insist-on-starting-the-first-partition-at-sector-65535-mib-31-99>`_
