.. _mobile_cloud_ceph_add_ceph_osds_lvm:

===================================
移动云计算Ceph添加Ceph OSDs (LVM卷)
===================================

在完成了初始 :ref:`mobile_cloud_ceph_mon` 之后，就可以添加 OSDs。只有完成了足够的OSDs部署(满足对象数量，例如 ``osd pool default size =2`` 要求集群至少具备2个OSDs)才能达到 ``active + clean`` 状态。在完成了 ``bootstap`` Ceph monitor之后，集群就具备了一个默认的 ``CRUSH`` map，但是此时 ``CRUSH`` map还没有具备任何Ceph OSD Daemons map到一个Ceph节点。

Ceph提供了一个 ``ceph-vlume`` 工具，用来准备一个逻辑卷，磁盘或分区给Ceph使用，通过增加索引来创建OSD ID，并且将新的OSD添加到CRUSH map。需要在每个要添加OSD的节点上执行该工具。

.. note::

   我有3个服务器节点提供存储，需要分别在这3个节点上部署OSD服务。

.. note::

   Ceph官方文档的案例都是采用 ``ceph-volume lvm`` 来完成的，这个命令可以在Ceph的OSD底层构建一个 :ref:`linux_lvm` ，带来的优势是可以随时扩容底层存储容量，对后续运维带来极大便利。在生产环境中部署，建议使用 ``lvm`` 卷。

bluestore
============

:ref:`bluestore` 是最新的Ceph采用的默认高性能存储引擎，底层不再使用OS的文件系统，可以直接管理磁盘硬件。

需要部署OSD的服务器首先准备存储，通常采用LVM卷作为底层存储块设备，这样可以通过LVM逻辑卷灵活调整块设备大小(有可能随着数据存储增长需要调整设备)。

使用LVM作为bluestore底层
-----------------------------------

- 执行 ``ceph-volume --help`` 可以看到支持3种底层存储::

   lvm                      Use LVM and LVM-based technologies to deploy OSDs
   simple                   Manage already deployed OSDs with ceph-volume
   raw                      Manage single-device OSDs on raw block devices

我这里构建实践采用 ``ceph-volume lvm`` ，这个命令会自动创建底层 :ref:`linux_lvm` 

.. _prepare_vdb_parted:

准备 ``vdb`` 虚拟磁盘分区
---------------------------

.. note::

   生产环境请使用LVM卷作为底层设备 - 参考 :ref:`bluestore_config`

   我的部署实践是在3台虚拟机 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 上完成，分区完全一致

- 准备底层块设备( 虚拟机有2块磁盘，其中 ``/dev/vdb`` 用于Ceph数据 磁盘空间有限，分配50G)，这里划分 GPT 分区1 :

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/parted_vdb
   :language: bash
   :caption: 划分/dev/vdb 50G

完成后检查 ``fdisk -l`` 可以看到:

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/fdisk_vdb
   :language: bash
   :caption: fdisk -l /dev/vdb 输出信息显示 /dev/vdb1

.. note::

   以上分区操作在3台存储虚拟机上完成

创建OSD使用的bluestore存储
----------------------------

- 创建第一个OSD，注意我使用了统一的 ``data`` 存储来存放所有数据，包括 ``block.db`` 和 ``block.wal`` :

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/ceph_volume_create_bluestore
   :language: bash
   :caption: 在/dev/vdb1上构建基于LVM的bluestore存储卷

.. note::

   ``ceph-volume raw -h`` 包含子命令::

      list                     list BlueStore OSDs on raw devices
      prepare                  Format a raw device and associate it with a (BlueStore) OSD
      activate                 Discover and prepare a data directory for a (BlueStore) OSD on a raw device

   ``ceph-volume lvm -h`` 包含子命令::

      activate                 Discover and mount the LVM device associated with an OSD ID and start the Ceph OSD
      deactivate               Deactivate OSDs
      batch                    Automatically size devices for multi-OSD provisioning with minimal interaction
      prepare                  Format an LVM device and associate it with an OSD
      create                   Create a new OSD from an LVM device
      trigger                  systemd helper to activate an OSD
      list                     list logical volumes and devices associated with Ceph
      zap                      Removes all data and filesystems from a logical volume or partition.
      migrate                  Migrate BlueFS data from to another LVM device
      new-wal                  Allocate new WAL volume for OSD at specified Logical Volume
      new-db                   Allocate new DB volume for OSD at specified Logical Volume

   对于 ``raw`` 命令需要分步骤完成，不像 ``lvm`` 命令提供了更为丰富的批量命令

提示信息:

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/ceph-volume_lvm.txt
   :language: bash
   :linenos:
   :caption: ceph-volume lvm create 输出

这次实践似乎有一些报错，不像之前 :ref:`add_ceph_osds_lvm` 执行没有任何错误。看起来是缺少针对 ``osd`` 的 ceph.keyring

不过，在osd目录下有一个 ``/var/lib/ceph/osd/ceph-0/keyring`` ，并且也没有影响运行

- 检查osd 卷设备::

   sudo ceph-volume lvm list

可以看到设备文件如下::

   ====== osd.0 =======
   
     [block]       /dev/ceph-97fa0d8e-9538-462c-98a0-7d95fe2d4532/osd-block-2bcd1d3d-c9bf-4276-8fe2-b6f1e3efe931
   
         block device              /dev/ceph-97fa0d8e-9538-462c-98a0-7d95fe2d4532/osd-block-2bcd1d3d-c9bf-4276-8fe2-b6f1e3efe931
         block uuid                W4kXl5-5v9W-yhE3-MOXW-YzoP-HT8X-xaE1tV
         cephx lockbox secret      
         cluster fsid              598dc69c-5b43-4a3b-91b8-f36fc403bcc5
         cluster name              ceph
         crush device class        
         encrypted                 0
         osd fsid                  2bcd1d3d-c9bf-4276-8fe2-b6f1e3efe931
         osd id                    0
         osdspec affinity          
         type                      block
         vdo                       0
         devices                   /dev/vdb1

使用 ``ceph-volume lvm create`` 命令有以下优点:

  - OSD自动激活并运行
  - 自动添加了 :ref:`systemd` 对应服务配置，所以操作系统重启不会遇到我之前 :ref:`add_ceph_osds_raw` 中无法正确挂载卷和运行OSD的问题

- 检查集群状态::

   sudo ceph -s

可以看到OSD已经运行::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_WARN
             2 mgr modules have recently crashed
             OSD count 1 < osd_pool_default_size 3
  
   services:
     mon: 1 daemons, quorum a-b-data-1 (age 66m)
     mgr: a-b-data-1(active, since 53m)
     osd: 1 osds: 1 up (since 28m), 1 in (since 28m)
  
   data:
     pools:   0 pools, 0 pgs
     objects: 0 objects, 0 B
     usage:   19 MiB used, 47 GiB / 47 GiB avail
     pgs:

- 检查OSD状态::

   sudo ceph osd tree

可以看到::

   ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
   -1         0.04549  root default                                  
   -3         0.04549      host a-b-data-1                           
    0    hdd  0.04549          osd.0            up   1.00000  1.00000

请注意，现在只有一个OSD运行，不满足配置中要求3个副本的要求，我们需要添加OSD节点

整合脚本快速完成
===================

安装OSD非常简便，所以整合脚本也就更为简单:

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/host_1_ceph_osd.sh
   :language: bash
   :caption: 在节点1上完成ceph-osd部署脚本 host_1_ceph_osd.sh

重启操作系统验证
======================

重启操作系统 ``sudo shutdown -r now``

- 启动后检查::

   sudo ceph -s

可以看到 ``ceph-volume lvm`` 默认配置非常方便，重启后系统服务正常，OSD也能正常运行:

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/ceph_s_output
   :language: bash
   :caption: ceph -s输出显示3个服务都已经启动
   :emphasize-lines: 9-11

上述 ``HEALTH_WARN`` 暂时不用顾虑，原因是OSD数量尚未满足配置3副本要求，后续将会配置补上。根据目前输出信息，3个服务都已经启动

添加OSD
=======================

需要满足3副本要求，我们需要在服务器本地或者其他服务器上添加OSD。为了能够冗余，我采用集群3个服务器上每个服务器都启动 ``ceph-mon`` 和 ``ceph-osd`` ，所以下面我们来完成:

- :ref:`mobile_cloud_ceph_add_ceph_mons`

然后再执行:

- :ref:`mobile_cloud_ceph_add_ceph_osds_more`

参考
=======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
- `raw osd's are not started on boot after upgrade from 14.2.11 to 14.2.16 ; ceph-volume raw activate claim systemd support not yet implemented <https://tracker.ceph.com/issues/48783>`_
