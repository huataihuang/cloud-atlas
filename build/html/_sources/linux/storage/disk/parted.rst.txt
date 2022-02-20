.. _parted:

=================
parted分区工具
=================

块设备概览
=============

我们日常使用的磁盘在Unix/Linux中称为 ``块设备`` ，之所以称为块设备是因为这些设备的读写数据总是以一个固定大小的块来完成。所以当硬盘插入主机显示的设备文件是有别于打印机、麦克风或者相机。要列出所有连接到Linux系统的跨设备，可以使用 ``lsblk`` 命令(list block devices)::

   lsbk

显示可能类似::

   NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   sda            8:0    0 953.9G  0 disk
   ├─sda1         8:1    0   256M  0 part /boot/firmware
   └─sda2         8:2    0    32G  0 part /
   mmcblk0      179:0    0  29.3G  0 disk
   ├─mmcblk0p1  179:1    0  29.3G  0 part
   ├─mmcblk0p2  179:2    0   128K  0 part
   ...

上述 ``lsblk`` 命令仅仅用于侦测和显示设备，不会修改，所以可以在任何数据设备上使用。可以看到 ``TYPE MOUNTPOINT`` 有两种类型 ``disk`` 和 ``part`` 分别表示磁盘和分区

dmesg显示块设备
------------------

如果将USB移动硬盘设备插入系统，可以从系统日志中显示出相关信息，可以使用dmesg命令::

   sudo dmesg | tail

插入和拔出设备都会看到磁盘块设备信息变化

文件系统概览
==============

在真正开始使用磁盘块设备之前，我们需要在块设备上创建文件系统。

.. warning::

   本段操作是一个高危操作，会破坏磁盘上数据，所以请确保操作的是没有重要数据的磁盘，并且已经提前做好了数据备份。 ``警告!!!``

实际上块设备也能直接操作，例如以下案例:

- 我们可以卸载一个磁盘文件系统挂载 ``/dev/sdx`` (假设有这个 ``sdx`` 磁盘设备文件) ::

   umount /dev/sdx{,1}

- 在磁盘设备没有挂载情况下，我们可以直接向裸设备写入数据::

   echo 'hello world' > /dev/sdx

虽然我们没有挂载磁盘文件系统，实际上写入到块设备文件的字符串依然可以读出::

   head -n 1 /dev/sdx

可以看到输出的信息就是我们写入的::

   hello world

parted工具
=============

parted是一个创建和维护分区表的工具，提供了交互模式和直接的命令行模式（可以在shell中使用）.

基本命令模式（注意，选项在设备名前面，命令在设备之后，这样选项就会传递给`parted`命令）::

   parted [OPTION]... [DEVICE [COMMAND [PARAMETERS]...]...]

举例::

   parted -a optimal /dev/sda mkpart primary 0% 256MB

.. note::

   在磁盘块设备使用中，有一个非常重要的选项是 :ref:`4k_alignment` ，上述参数 ``-a optimal`` 就是启用4K对齐设置，可以确保分区完全4K对齐，提高磁盘读写性能。

   检查分区 ``/dev/sda`` 是否4k对齐::

      parted /dev/sda align-check opt 1

   输入显示::

      1 aligned

   则表明分区已经对齐

- 列出磁盘分区::

   parted /dev/sda print

显示输出::

   Model: WD My Passport 25F3 (scsi)
   Disk /dev/sda: 1024GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: msdos
   Disk Flags:
   
   Number  Start   End     Size    Type     File system  Flags
    1      1049kB  269MB   268MB   primary  fat32        boot, lba
    2      269MB   34.6GB  34.4GB  primary  ext4

- 如果已经进入 ``parted`` 交互模式，可以通过 ``select`` 命令切换磁盘::

   (parted) select /dev/sdX

- 重建分区表

分区表是通过命令 ``mklabel`` 完成的，类型有 ``msdos`` （即传统的DOS分区表），也可以使用现在主流的 ``gpt`` ::

   parted /dev/sda mklabel gpt

.. warning::

   ``警告`` ：重建分区表将擦除磁盘上所有数据。

- 创建分区

使用交互命令 ``mkpart`` 可以实现创建分区，但是非常繁琐。直接命令行实现较为快捷::

   parted -a optimal /dev/sda mkpart primary 0% 256MB

.. note::

   在 :ref:`linux_ssd_partition_alignment` 实践时，我发现这里的 ``parted -a optimal`` 参数起始位置设置 ``0%`` 实际上就是 ``1MiB alignment`` 。不过，对于USB转SATA接口的控制器，如果控制器提供给Linux内核的 ``I/O limits`` 参数 ``optimize_io_size`` 是特殊的 ``33553920`` (32MiB)，则会导致 ``parted`` 使用 ``0%`` 无法对齐。

- 调整分区大小: ``resizepart`` 命令可以调整分区大小

- 删除分区 - 这里数字 ``1`` 表示分区1::

   parted /dev/sda rm 1

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

- 修改分区标记 - 支持多种分区标记:

  - boot
  - root
  - swap
  - hidden
  - raid
  - lvm
  - lba
  - legacy_boot
  - irst
  - esp
  - palo

举例::

   (parted) set 2 boot on

案例实践
============

在 :ref:`lfs_linux` 磁盘分区准备工作中，使用 ``parted`` 来完成分区

- 初始化磁盘分区表（擦除原先的所有数据）::

   parted /dev/sda mklabel gpt

- 创建第一个 ``sda1`` 分区，用于EFI启动::

   parted -a optimal /dev/sda mkpart ESP fat32 0% 256MB
   parted /dev/sda set 1 esp on

- 主分区59G空间，剩余用于swap::

   parted -a optimal /dev/sda mkpart primary ext4 256MB 59GB
   parted -a optimal /dev/sda mkpart primary linux-swap 59GB 100%

- 完成后最后检查 ``fdisk -l /dev/sda`` ::

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

参考
=======

- `How to partition and format a drive on Linux <https://opensource.com/article/18/11/partition-format-drive-linux>`_
- `8 Linux ‘Parted’ Commands to Create, Resize and Rescue Disk Partitions <https://www.tecmint.com/parted-command-to-create-resize-rescue-linux-disk-partitions/>`_
- `archlinux: GNU Parted - UEFI/GPT examples <https://wiki.archlinux.org/index.php/GNU_Parted>`_
