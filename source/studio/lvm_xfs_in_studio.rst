.. _lvm_xfs_in_studio:

=======================
Studio环境的LVM+XFS存储
=======================

.. note::

   最初我选择 :ref:`btrfs_in_studio` ，主要考虑到Btrfs文件系统接近ZFS的特性，结合了卷管理和文件系统的高级特性，灵活并且充分利用好磁盘空间。在 :ref:`ubuntu_on_mbp` 采用Btrfs构建libvirt卷和Docker卷，确实非常方便管理和维护。

   不过， :ref:`archlinux_on_thinkpad_x220` 实践中，我为了体验技术，启用了Btrfs的磁盘透明压缩功能。这次尝试似乎带来了不稳定的因素，Btrfs出现csum错误。目前我还不确实是否是因为SSD磁盘存在硬件故障。

   从Red Hat Enterprise Linux 8开始，Red Hat放弃了Btrfs支持，这对于企业运行RHEL/CentOS环境，实际上已经变相阻止了Btrfs。原因可能比较复杂，一方面是Btrfs的高级特性(如RAID)一直不稳定，另一方面可能和Oracle和Red Hat的存储竞争策略冲突相关。

   Red Hat Enterprise Linux推荐的默认文件系统是XFS，XFS文件系统是数据库本地磁盘首选的文件系统。

方案选择
==========

- 存储分区需要能够灵活调整，所以需要采用LVM卷管理来划分磁盘分区
- 需要有高性能文件系统，对SSD存储优化，并适合大型应用运行

LVM + XFS是适合数据库应用运行的Linux存储组合，并且也是Red Hat主推的用于取代ZFS和Btrfs的 `Stratis项目 <https://stratis-storage.github.io/>`_ 底层技术堆栈。所以，我选择这个存储技术组合。

LVM卷管理
=========

逻辑卷管理(Logical Volume Management)工具使用了内核 :ref:`device_mapper` 功能来提供系统分区无关的底层磁盘布局。通过LVM抽象存储就能够获得"虚拟分区"，已及方便的扩展和收缩功能。

虚拟分区允许添加或移除一个分区的底层磁盘，这样就无需担忧磁盘空间不足。

LVM构建基础概念:

- 物理卷(Physical volume, PV): Unix块设备节点。通常是磁盘、MBR或GPT分区，loopback文件，device mapper设备(例如，dm-crypt)。在物理卷上保存了LVM头部(LVM header)

- 卷组(Volume group, VG): PV组成卷足用于提供逻辑卷LV的容器。PV是通过VG提供给LV使用的。

- 逻辑卷(Logical volume, LV): 逻辑分区是在VG中表述并由PE组成的，LV是一个Unix块设备，类似物理分区，也就是可以直接用文件系统格式化。

- 物理扩展(Physical extent): 物理扩展PE时在PV上的最小连续扩展(默认4MB)，可以分配给LV，你可以将PE视为PV的一部分，被分配给LV。

创建分区
------------

- 使用parted划分分区，参数采用 ``--align`` ::

   parted -a optimal /dev/sda

- 创建分区3::

   mkpart primary 51.7GB 100%

- 设置分区名和启用分区LVM::

   name 3 data
   set 3 lvm on

- 最后检查::

   print

显示输出::

   Model: ATA INTEL SSDSC2KW51 (scsi)
   Disk /dev/sda: 512GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags: 
   
   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  512MB   511MB   fat16              boot, esp
    2      512MB   51.7GB  51.2GB  ext4
    3      51.7GB  512GB   460GB                data  lvm

以上分区3将作为数据存储的LVM卷。

不过 ``partprobe`` 提示::

   Warning: The driver descriptor says the physical block size is 2048 bytes, but Linux says it is 512 bytes.



参考
======

- `Arch Linux社区文档 - LVM <https://wiki.archlinux.org/index.php/LVM>`_
