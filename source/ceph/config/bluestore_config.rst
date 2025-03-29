.. _bluestore_config:

===================
Ceph BlueStore配置
===================

Ceph BlueStoe设备
==================

对于存储系统来说，性能优化往往会将数据存储、元数据存储、日志存储分离开，Ceph BlueStore也是这样: BlueStore存储管理可以使用3个存储设备来分别存放不同用途的数据:

- ``primary device`` 主设备
- ``write-ahead log`` 设备(WAL设备)，在该设备数据目录下有一个 ``block.wal`` ，是BlueStore内置日志或者提前写入日志。WAL设备通常要求更高性能，并且通常要求比主设备更快。
- ``DB device`` 数据库设备，也就是用来存储BlueStore内置元数据。BlueStore采用嵌入的RocksDB来存储元数据，存放到DB设备来提高性能。如果DB设备存满了，元数据就会存放到主设备或其他位置(性能会降低)。同样， DB设备也应该比主设备更快

由于WAL设备通常存储容量较小，DB设备也如此，所以我们会采用高速但是容量小一些的存储设备。应该将日志(journal)存储到最快存储中，其次DB设备也应存储到较快设备中。

对于测试环境或者要求不高环境，可以将上述3个设备合成一个设备使用。

- 采用单一存储设备构建BlueStore OSD::

   ceph-volume lvm prepare --bluestore --data <device>

- 指定WAL设备 和/或 DB设备::

   ceph-volume lvm prepare --bluestore --data <device> --block.wal <wal-device> --block.db <db-device>

.. note::

   这里的 ``<device>`` 可以是使用 ``vg/lv`` 标记的逻辑卷，或者是现有的 ``逻辑卷`` 或者 ``GPT 分区``

只使用一个设备作为block(data)设备
======================================

如果服务器中所有磁盘都是一样的类型，例如都是传统的机械磁盘，也就是没有快速的设备(例如SSD)来用于元数据，则可以采用单一磁盘来完成BlueStore存储。

- 单块磁盘构建bluestore::

   ceph-volume lvm create --bluestore --data /dev/sda

- 或者先在所有磁盘上构建好一个LVM逻辑卷，然后再把BlueStore存储到这个LVM卷::

   ceph-volume lvm create --bluestore --data ceph-vg/block-lv

分离block(data)设备和block.db(元数据)
======================================


如果系统中有多块传统的机械硬盘(案例中有4块机械硬盘)，同时又有一块高速SSD磁盘，则可以将每块机械硬盘构建一个LVM逻辑卷作为OSD主设备存储数据，然后将高速SSD另外构建一个LVM卷来存储 ``block.db`` (元数据)

- 构建LVM卷::

   pvcreate /dev/sda
   pvcreate /dev/sdb
   pvcreate /dev/sdc
   pvcreate /dev/sdd

   vgcreate ceph-block-0 /dev/sda
   vgcreate ceph-block-1 /dev/sdb
   vgcreate ceph-block-2 /dev/sdc
   vgcreate ceph-block-3 /dev/sdd

   lvcreate -l 100%FREE -n block-0 ceph-block-0
   lvcreate -l 100%FREE -n block-1 ceph-block-1
   lvcreate -l 100%FREE -n block-2 ceph-block-2
   lvcreate -l 100%FREE -n block-3 ceph-block-3

- 由于我们有4个OSD，所以我们需要在 ``/dev/sdx`` (SSD存储) 上划分出4个逻辑卷来作为 ``block.db`` 存储::

   pvcreate /dev/sdx
   vgcreate ceph-db-0 /dev/sdx
   lvcreate -L 50GB -n db-0 ceph-db-0
   lvcreate -L 50GB -n db-1 ceph-db-0
   lvcreate -L 50GB -n db-2 ceph-db-0
   lvcreate -L 50GB -n db-3 ceph-db-0

- 最后创建4个OSD，并且分别对应分布到机械硬盘的LVM卷(block)和SSD的LVM卷(block.db)::

   ceph-volume lvm create --bluestore --data ceph-block-0/block-0 --block.db ceph-db-0/db-0
   ceph-volume lvm create --bluestore --data ceph-block-1/block-1 --block.db ceph-db-0/db-1
   ceph-volume lvm create --bluestore --data ceph-block-2/block-2 --block.db ceph-db-0/db-2
   ceph-volume lvm create --bluestore --data ceph-block-3/block-3 --block.db ceph-db-0/db-3

大小规格
=============

.. note::

   建议使用LVM卷管理作为Ceph底层的存储块设备，因为LVM卷可以随时扩展，方便在后续维护中按需调整。

   我的测试环境采用 :ref:`hpe_dl360_gen9` 安装了3块NVMe存储，分别通过3个 :ref:`ovmf` pass-through虚拟机来访问存储，所以因为没有多个设备，也就不区分OSD的独立分离存储了，只指定一个 ``--data`` 设备，也不需要使用LVM卷(因为没有可扩容的可能)。

- 通常情况下 ``block.db`` 大小应该是 ``block`` 大小的 4% (或更多)
- 当使用相同速度的设备，就不需要独立的逻辑卷用于 ``block.db`` 或 ``block.wal`` ，BlueStore会自动计算它们在 ``block`` 中的空间

自动缓存大小
===============

当 ``TCMalloc`` 被配置成内存分配器并且 ``bluestore_cache_autotune`` 设置成激活，则BlueStore会自动配置缓存大小。这个选项默认激活。

BlueStore会尝试保持OSD堆栈内存使用低于通过 ``osd_memory_target`` 配置项指定的目标大小。最佳算法和缓存是不收缩小雨 ``osd_memory_cache_min`` 的指定大小。缓存率会基于优先级层级来选择。如果优先级信息没有提供，则 ``bluestore_cache_meta_ratio`` 和 ``bluestore_cache_kv_ratio`` 选项作为fallback。

- ``bluestore_cache_autotune`` 默认 ``true``
- ``osd_memory_target`` 默认 ``4G`` 最小 ``896M``
- ``bluestore_cache_autotune_interval`` 默认 ``5.0``
- ``osd_memory_base`` 默认 ``768M``
- ``osd_memory_expected_fragmentation`` 默认 ``0.15`` 消除内存碎片
- ``osd_memory_cache_min`` 默认 ``128M``
- ``osd_memory_cache_resize_interval`` 默认 ``1.0``

.. warning::

   BlueStore有很多调优参数，我现在缺乏实践和生产环境验证，所以无法一一分析。请参考原文档结合自己的使用场景调优，我后续会逐步根据自己的使用经验总结和补充完善。

有用的一些功能
===============

BlueStore提供了一些对生产非常有用的功能，这里做一些举例，后续根据实践再补充:

- checksums 校验元数据和数据，通过RocksDB和crc32c实现
- 在线压缩 使用snappy, zlib 或 lz4实现在线压缩。注意lz4压缩插件不是官方版本提供
- RocksDB sharding (分片) 通过将数据存储到多个 RocksDB 列族(column families)可以提高缓存和压缩性能
- 使用SPDK driver for NVMe 可以加速 :ref:`nvme` 读写性能(待实践)

参考
=======

- `BlueStore Config Reference <https://docs.ceph.com/en/latest/rados/configuration/bluestore-config-ref/>`_
- `Red Hat Ceph Storage 4 Administration Guide: BlueStore <https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/4/html/administration_guide/osd-bluestore>`_
