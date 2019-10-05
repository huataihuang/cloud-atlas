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

以上分区3将作为数据存储的LVM卷。对于修改系统磁盘 ``/dev/sda`` 分区，则建议重启一次操作系统以便刷新。或者通过 ``partprobe`` 刷新分区。

创建物理卷
-------------

- 初始化物理卷::

   pvcreate /dev/sda3

.. note::

   如果有多个设备，可以一起初始化，例如::

      pvcreate /dev/sdd1 /dev/sde1 /dev/sdf1

- 检查物理卷::

   pvdispaly

显示::

     "/dev/sda3" is a new physical volume of "<428.78 GiB"
     --- NEW Physical volume ---
     PV Name               /dev/sda3
     VG Name               
     PV Size               <428.78 GiB
     Allocatable           NO
     PE Size               0   
     Total PE              0
     Free PE               0
     Allocated PE          0
     PV UUID               HYPqoi-s2Ga-r2c9-upv6-Q3by-DFf3-NJe9BT

卷组管理
----------

- 在物理卷上构建卷组::

   vgcreate data /dev/sda3

.. note::

   这里将卷组命名为 ``data``

   当物理卷用于创建卷组的时候，它的磁盘空间默认被划分为以4MB为单位的 ``extent`` 。这个 ``extent`` 是用于逻辑卷增长和缩减的最小大小。 ``extent`` 的数量不会影响逻辑卷的I/O性能。

- 如果要扩展卷组，可以新的物理卷加入到卷组，例如，以下在卷组 ``vg1`` 中添加 ``/dev/sdf1`` 物理卷来扩展卷组的大小::

   vgextend vg1 /dev/sdf1

逻辑卷
---------

- 在 ``data`` 卷组上创建 ``home`` 逻辑卷::

   lvcreate -L 100G -n home data

- 检查逻辑卷 ``lvdisplay`` 显示如下::

     --- Logical volume ---
     LV Path                /dev/data/home
     LV Name                home
     VG Name                data
     LV UUID                gIwomd-B9x2-MRNP-o2Jd-diqn-Tgji-N70rP4
     LV Write Access        read/write
     LV Creation host, time zcloud, 2019-10-05 23:02:59 +0800
     LV Status              available
     # open                 0
     LV Size                100.00 GiB
     Current LE             25600
     Segments               1
     Allocation             inherit
     Read ahead sectors     auto
     - currently set to     256
     Block device           254:0

- 同样再创建一个用于libvirt的逻辑卷::

   lvcreate -L 128G -n libvirt data 

XFS
===========



参考
======

- `Arch Linux社区文档 - LVM <https://wiki.archlinux.org/index.php/LVM>`_
- `Arch Linux社区文档 - XFS <https://wiki.archlinux.org/index.php/XFS>`_
