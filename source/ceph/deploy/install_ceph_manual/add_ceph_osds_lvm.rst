.. _add_ceph_osds_lvm:

=======================
添加Ceph OSDs (LVM卷)
=======================

.. note::

   我在 :ref:`add_ceph_osds_raw` 遇到了重启后无法正确挂载 ``/var/lib/ceph/osd/ceph-0`` 问题，暂时无法解决。所以回归最标准的采用 :ref:`linux_lvm` 卷作为底层的方法，重试尽快部署完Ceph，进入下阶段测试。后续再做方案完善...`

在完成了初始 :ref:`install_ceph_mon` 之后，就可以添加 OSDs。只有完成了足够的OSDs部署(满足对象数量，例如 ``osd pool default size =2`` 要求集群至少具备2个OSDs)才能达到 ``active + clean`` 状态。在完成了 ``bootstap`` Ceph monitor之后，集群就具备了一个默认的 ``CRUSH`` map，但是此时 ``CRUSH`` map还没有具备任何Ceph OSD Daemons map到一个Ceph节点。

Ceph提供了一个 ``ceph-vlume`` 工具，用来准备一个逻辑卷，磁盘或分区给Ceph使用，通过增加索引来创建OSD ID，并且将新的OSD添加到CRUSH map。需要在每个要添加OSD的节点上执行该工具。

.. note::

   我有3个服务器节点提供存储，需要分别在这3个节点上部署OSD服务。

.. note::

   Ceph官方文档的案例都是采用 ``ceph-volume lvm`` 来完成的，这个命令可以在Ceph的OSD底层构建一个 :ref:`linux_lvm` ，带来的优势是可以随时扩容底层存储容量，对后续运维带来极大便利。在生产环境中部署，建议使用 ``lvm`` 卷。

   我这里的测试环境，采用简化的 ``磁盘分区`` 来提供Ceph :ref:`bluestore` 存储，原因是我需要简化配置，同时我的测试服务器也没有硬件进行后续扩容。

bluestore
============

:ref:`bluestore` 是最新的Ceph采用的默认高性能存储引擎，底层不再使用OS的文件系统，可以直接管理磁盘硬件。

需要部署OSD的服务器首先准备存储，通常采用LVM卷作为底层存储块设备，这样可以通过LVM逻辑卷灵活调整块设备大小(有可能随着数据存储增长需要调整设备)。

作为我的实践环境 :ref:`hpe_dl360_gen9` 每个 :ref:`ovmf` 虚拟机仅有一个pass-through PCIe NVMe存储，所以我没有划分不同存储设备来分别存放 ``block`` / ``block.db`` 和 ``block.wal`` 。采用LVM可以不断扩容底层存储，所以即使开始时候磁盘空间划分较小也没有关系。我这次实践采用划分500GB作为初始分区，后续我将实践在线扩容。

使用LVM作为bluestore底层
-----------------------------------

- 执行 ``ceph-volume --help`` 可以看到支持3种底层存储::

   lvm                      Use LVM and LVM-based technologies to deploy OSDs
   simple                   Manage already deployed OSDs with ceph-volume
   raw                      Manage single-device OSDs on raw block devices

我这里构建实践采用 ``ceph-volume lvm`` ，这个命令会自动创建底层 :ref:`linux_lvm` 

.. note::

   生产环境请使用LVM卷作为底层设备 - 参考 :ref:`bluestore_config`

   我的部署实践是在3台虚拟机 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 上完成，分区完全一致

- 准备底层块设备，这里划分 GPT 分区1 ::

   sudo parted /dev/nvme0n1 mklabel gpt
   sudo parted -a optimal /dev/nvme0n1 mkpart primary 0% 500GB

完成后检查 ``fdisk -l`` 可以看到::

   Disk /dev/nvme0n1: 953.89 GiB, 1024209543168 bytes, 2000409264 sectors
   Disk model: SAMSUNG MZVL21T0HCLR-00B00
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: BF78F6A8-7654-4646-83B7-8331F77921E1
   
   Device         Start       End   Sectors   Size Type
   /dev/nvme0n1p1  2048 976562175 976560128 465.7G Linux filesystem

.. note::

   以上分区操作在3台存储虚拟机上完成

- 创建第一个OSD，注意我使用了统一的 ``data`` 存储来存放所有数据，包括 ``block.db`` 和 ``block.wal`` ::

   sudo ceph-volume lvm create --bluestore --data /dev/nvme0n1p1

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

 .. literalinclude:: add_ceph_osds_lvm/ceph-volume_lvm.txt
    :language: bash
    :linenos:
    :caption: ceph-volume lvm create 输出

- 检查osd 卷设备::

   sudo ceph-volume lvm list

可以看到设备文件如下::

   ====== osd.0 =======
   
     [block]       /dev/ceph-b7d91a2a-72ca-488b-948f-c42613698cca/osd-block-33b7d928-8075-4531-9177-9253a71dec84
   
         block device              /dev/ceph-b7d91a2a-72ca-488b-948f-c42613698cca/osd-block-33b7d928-8075-4531-9177-9253a71dec84
         block uuid                T3vB57-w3fx-7g7r-Zgk6-ZqJK-Ijrc-zy3LZW
         cephx lockbox secret
         cluster fsid              0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
         cluster name              ceph
         crush device class        None
         encrypted                 0
         osd fsid                  33b7d928-8075-4531-9177-9253a71dec84
         osd id                    0
         osdspec affinity
         type                      block
         vdo                       0
         devices                   /dev/nvme0n1p1

使用 ``ceph-volume lvm create`` 命令有以下优点:

  - OSD自动激活并运行
  - 自动添加了 :ref:`systemd` 对应服务配置，所以操作系统重启不会遇到我之前 :ref:`add_ceph_osds_raw` 中无法正确挂载卷和运行OSD的问题

- 检查集群状态::

   sudo ceph -s

可以看到OSD已经运行::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             Degraded data redundancy: 1 pg undersized
             OSD count 1 < osd_pool_default_size 3
   
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 47m)
     mgr: z-b-data-1(active, since 36m)
     osd: 1 osds: 1 up (since 6m), 1 in (since 6m)
   
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   1.0 GiB used, 465 GiB / 466 GiB avail
     pgs:     100.000% pgs not active
              1 undersized+peered

- 检查OSD状态::

   sudo ceph osd tree

可以看到::

   ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
   -1         0.45470  root default
   -3         0.45470      host z-b-data-1
    0    ssd  0.45470          osd.0            up   1.00000  1.00000

请注意，现在只有一个OSD运行，不满足配置中要求3个副本的要求，我们需要添加OSD节点

重启操作系统验证
======================

重启操作系统 ``sudo shutdown -r now``

- 启动后检查::

   sudo ceph -s

可以看到 ``ceph-volume lvm`` 默认配置非常方便，重启后系统服务正常，OSD也能正常运行::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             Degraded data redundancy: 1 pg undersized
             OSD count 1 < osd_pool_default_size 3
   
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 82m)
     mgr: z-b-data-1(active, since 81m)
     osd: 1 osds: 1 up (since 82m), 1 in (since 100m)
   
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   1.0 GiB used, 465 GiB / 466 GiB avail
     pgs:     100.000% pgs not active
              1 undersized+peered

上述 ``HEALTH_WARN`` 暂时不用顾虑，原因是OSD数量尚未满足配置3副本要求，后续将会配置补上。根据目前输出信息，3个服务都已经启动::

   services:
     mon: 1 daemons, quorum z-b-data-1 (age 82m)
     mgr: z-b-data-1(active, since 81m)
     osd: 1 osds: 1 up (since 82m), 1 in (since 100m)

添加OSD
=======================

需要满足3副本要求，我们需要在服务器本地或者其他服务器上添加OSD。为了能够冗余，我采用集群3个服务器上每个服务器都启动 ``ceph-mon`` 和 ``ceph-osd`` ，所以下面我们来完成:

- :ref:`add_ceph_mons`

然后再执行:

- :ref:`add_ceph_osds_more`

参考
=======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
- `raw osd's are not started on boot after upgrade from 14.2.11 to 14.2.16 ; ceph-volume raw activate claim systemd support not yet implemented <https://tracker.ceph.com/issues/48783>`_
