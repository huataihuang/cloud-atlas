.. _add_ceph_osds_raw:

=======================
添加Ceph OSDs (RAW磁盘)
=======================

.. warning::

   我尝试通过默认集群名来避免 :ref:`add_ceph_osds_zdata` 遇到的无法传递自定义集群名的问题，但是本次尝试依然失败(虽然也有一些经验积累)。所以我准备重新开始采用标准 :ref:`add_ceph_osds_lvm` 部署，后续再准备虚拟机环境解决本文实践问题。` 

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

作为我的实践环境 :ref:`hpe_dl360_gen9` 每个 :ref:`ovmf` 虚拟机仅有一个pass-through PCIe NVMe存储，所以我没有划分不同存储设备来分别存放 ``block`` / ``block.db`` 和 ``block.wal`` 。并且也因为无法扩展存储，我就尝试不使用LVM卷，而直接采用磁盘分区。

使用raw分区作为bluestore底层(失败)
-----------------------------------

- 执行 ``ceph-volume --help`` 可以看到支持3种底层存储::

   lvm                      Use LVM and LVM-based technologies to deploy OSDs
   simple                   Manage already deployed OSDs with ceph-volume
   raw                      Manage single-device OSDs on raw block devices

我这里构建实践采用 ``ceph-volume raw`` ，直接采用 NVMe 存储分区

.. note::

   生产环境请使用LVM卷作为底层设备 - 参考 :ref:`bluestore_config`

   我的部署实践是在3台虚拟机 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 上完成，分区完全一致

- 准备底层块设备，这里划分 GPT 分区1 ::

   parted /dev/nvme0n1 mklabel gpt
   parted -a optimal /dev/nvme0n1 mkpart primary 0% 700GB

完成后检查 ``fdisk -l`` 可以看到::

   Disk /dev/nvme0n1: 953.89 GiB, 1024209543168 bytes, 2000409264 sectors
   Disk model: SAMSUNG MZVL21T0HCLR-00B00
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: E131A860-1EC8-4F34-8150-2A2C312176A1
   
   Device         Start        End    Sectors   Size Type
   /dev/nvme0n1p1  2048 1367187455 1367185408 651.9G Linux filesystem

.. note::

   以上分区操作在3台存储虚拟机上完成

- 创建第一个OSD，注意我使用了统一的 ``data`` 存储来存放所有数据，包括 ``block.db`` 和 ``block.wal`` ::

   sudo ceph-volume raw prepare --bluestore --data /dev/nvme0n1p1

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


我在执行::

   sudo ceph-volume raw prepare --data /dev/nvme0n1p1

命令提示只支持 ``--bluestore`` 作为后端，但是提示 ``/dev/nvme0n1p1: not a block device`` 让我很疑惑，NVMe分区为何不是块设备？::

   stderr: lsblk: /dev/nvme0n1p1: not a block device
   stderr: Unknown device "/dev/nvme0n1p1": Inappropriate ioctl for device
   --> must specify --bluestore (currently the only supported backend)

修订命令，添加 ``--bluestore`` 参数::

   sudo ceph-volume raw prepare --bluestore --data /dev/nvme0n1p1

.. note::

   从 ``lsblk`` 输出来看 ``/dev/nvme0n1p1`` 没有显示为正常的块设备，原因我在下文会说明

      # lsblk /dev/nvme0n1
      NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
      nvme0n1     259:0    0 953.9G  0 disk
      └─nvme0n1p1 259:1    0 651.9G  0 part

      # lsblk /dev/nvme0n1p1
      lsblk: /dev/nvme0n1p1: not a block device

   但是对于 ``vda`` 设备却没有报错::

      # lsblk /dev/vda
      NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
      vda    252:0    0    6G  0 disk
      ├─vda1 252:1    0  243M  0 part /boot/efi
      └─vda2 252:2    0  5.8G  0 part /

      # lsblk /dev/vda2
      NAME MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
      vda2 252:2    0  5.8G  0 part /

但是 ``ceph-volume raw prepare`` 报错:

.. literalinclude:: add_ceph_osds_raw/ceph-volume_raw_fail.txt
   :language: bash
   :linenos:
   :caption: ceph-volume raw 输出(错误)

问题根源
~~~~~~~~~

实际我也发现即使采用 ``ceph-volume lvm create`` 也是失败的，提示信息中也有::

   stderr: lsblk: /dev/nvme0n1p1: not a block device

我仔细检查了设备文件，发现了异常::

   $ ls -lh /dev/nvme0n1
   brw-rw---- 1 root disk 259, 0 Nov 29 20:19 /dev/nvme0n1

   $ ls -lh /dev/nvme0n1p1
   -rw-r--r-- 1 ceph ceph 10M Nov 29 17:00 /dev/nvme0n1p1

也就是说，设备分区 ``nvme0n1p1`` 异常，没有显示为块设备，我想起来之前做了一个 ``/usr/bin/dd if=/dev/zero of=/dev/nvme0n1p1 bs=1M count=10 conv=fsync`` 但当时没有注意到已经删除了分区 ``nvme0n1p1`` 所以导致 ``dd`` 命令直接作用于 ``/dev`` 目录下形成了上述文件。这就导致后续分区之后，实际上没有正确创建出 ``/dev/nvme0n1p1`` 块设备。

解决方法是重建分区表，并且重启一次操作系统::

   parted /dev/nvme0n1 mklabel gpt
   shutdown -r now

重启以后再划分分区::

   parted -a optimal /dev/nvme0n1 mkpart primary 0% 700GB

完成以后再检查设备文件就可以看到是正常的块设备::

   $ ls -lh /dev/nvme0*
   crw------- 1 root root 241, 0 Nov 29 20:32 /dev/nvme0
   brw-rw---- 1 root disk 259, 0 Nov 29 20:33 /dev/nvme0n1
   brw-rw---- 1 root disk 259, 2 Nov 29 20:33 /dev/nvme0n1p1

然后重新执行创建OSD磁盘成功:

.. literalinclude:: add_ceph_osds_raw/ceph-volume_raw.txt
   :language: bash
   :linenos:
   :caption: ceph-volume raw 输出(成功)

- 检查raw设备::

   sudo ceph-volume raw list

可以看到设备文件如下::

   {
       "0": {
           "ceph_fsid": "39392603-fe09-4441-acce-1eb22b1391e1",
           "device": "/dev/nvme0n1p1",
           "osd_id": 0,
           "osd_uuid": "8d889fc0-110c-45fa-a259-6a876183bc46",
           "type": "bluestore"
       }
   }

- 激活OSD: 需要注意 ``raw`` 格式的设备激活和 lvm卷不同，采用如下格式::

   ceph-volume raw activate [--device DEVICE]

也就是只要指定设备就可以::

   sudo ceph-volume raw activate --device /dev/nvme0n1p1

提示报错::

   --> systemd support not yet implemented

- 这是因为需要先启动systemd::

   sudo systemctl start ceph-osd@0.service

然后检查::

   sudo systemctl status ceph-osd@0.service

显示输出::

   ● ceph-osd@0.service - Ceph object storage daemon osd.0
        Loaded: loaded (/lib/systemd/system/ceph-osd@.service; disabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-11-29 22:44:37 CST; 17s ago
       Process: 1370 ExecStartPre=/usr/lib/ceph/ceph-osd-prestart.sh --cluster ${CLUSTER} --id 0 (code=exited, status=0/SUCCESS)
      Main PID: 1382 (ceph-osd)
         Tasks: 69
        Memory: 25.0M
        CGroup: /system.slice/system-ceph\x2dosd.slice/ceph-osd@0.service
                └─1382 /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph
   
   Nov 29 22:44:37 z-b-data-1 systemd[1]: Starting Ceph object storage daemon osd.0...
   Nov 29 22:44:37 z-b-data-1 systemd[1]: Started Ceph object storage daemon osd.0.
   Nov 29 22:44:37 z-b-data-1 ceph-osd[1382]: 2021-11-29T22:44:37.656+0800 7f081f44ad80 -1 Falling back to public interface
   Nov 29 22:44:38 z-b-data-1 ceph-osd[1382]: 2021-11-29T22:44:38.332+0800 7f081f44ad80 -1 osd.0 0 log_to_monitors {default=true}
   Nov 29 22:44:40 z-b-data-1 ceph-osd[1382]: 2021-11-29T22:44:40.308+0800 7f0811535700 -1 osd.0 0 waiting for initial osdmap
   Nov 29 22:44:40 z-b-data-1 ceph-osd[1382]: 2021-11-29T22:44:40.336+0800 7f081898c700 -1 osd.0 13 set_numa_affinity unable to identify public interface '' numa node: (2) No such file or directory

这里可以看到 ``ceph-osd`` 启动会找寻 NUMA 节点

没有报错的话，别忘记激活这个osd服务::

   sudo systemctl enable ceph-osd@0.service

- 然后再次激活 ``ceph-0`` 这个OSD磁盘::

   sudo ceph-volume raw activate --device /dev/nvme0n1p1

依然报错::

   --> systemd support not yet implemented

似乎不需要手工激活，只需要启动 ``ceph-osd@0.service`` 就可以

- 现在检查 ``sudo ceph -s`` 状态已经看到激活了OSD::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             Degraded data redundancy: 1 pg undersized
             OSD count 1 < osd_pool_default_size 3
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 2h)
     mgr: z-b-data-1(active, since 2h)
     osd: 1 osds: 1 up (since 16m), 1 in (since 16m)
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   1.0 GiB used, 651 GiB / 652 GiB avail
     pgs:     100.000% pgs not active
              1 undersized+peered

.. note::

   注意，此时可以看到 ``data`` 段落显示::

      usage:   1.0 GiB used, 651 GiB / 652 GiB avail

- 检查OSD状态::

   sudo ceph osd tree

可以看到::

   ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
   -1         0.63660  root default
   -3         0.63660      host z-b-data-1
    0    ssd  0.63660          osd.0            up   1.00000  1.00000

请注意，现在只有一个OSD运行，不满足配置中要求3个副本的要求，我们需要添加OSD节点

重启操作系统验证
======================

重启操作系统 ``sudo shutdown -r now``

- 启动后检查::

   sudo ceph -s

发现服务启动，但是OSD空间是0::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             OSD count 1 < osd_pool_default_size 3
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 4m)
     mgr: z-b-data-1(active, since 3m)
     osd: 1 osds: 1 up (since 45m), 1 in (since 45m)
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:     100.000% pgs unknown
             1 unknown

也即是 OSD没有启动成功

重新激活OSD
-------------

为何重启系统之前已经配置成功的OSD无法启动呢？

- 检查OSD服务::

   sudo systemctl status ceph-osd@0-service

输出显示::

   ● ceph-osd@0-service.service - Ceph object storage daemon osd.0-service
        Loaded: loaded (/lib/systemd/system/ceph-osd@.service; disabled; vendor preset: enabled)
        Active: inactive (dead)

- 尝试启动 OSD服务::

   sudo systemctl start ceph-osd@0.service

提示失败::

   Job for ceph-osd@0.service failed because the control process exited with error code.
   See "systemctl status ceph-osd@0.service" and "journalctl -xe" for details.

检查 ``systemctl status ceph-osd@0.service`` ::

   ● ceph-osd@0.service - Ceph object storage daemon osd.0
        Loaded: loaded (/lib/systemd/system/ceph-osd@.service; enabled; vendor preset: enabled)
        Active: failed (Result: exit-code) since Mon 2021-11-29 23:26:58 CST; 24min ago
       Process: 968 ExecStartPre=/usr/lib/ceph/ceph-osd-prestart.sh --cluster ${CLUSTER} --id 0 (code=exited, status=0/SUCCESS)
       Process: 983 ExecStart=/usr/bin/ceph-osd -f --cluster ${CLUSTER} --id 0 --setuser ceph --setgroup ceph (code=exited, status=1/FAILURE)
      Main PID: 983 (code=exited, status=1/FAILURE)
   
   Nov 29 23:26:58 z-b-data-1 systemd[1]: Failed to start Ceph object storage daemon osd.0.
   Nov 29 23:35:32 z-b-data-1 systemd[1]: ceph-osd@0.service: Start request repeated too quickly.
   Nov 29 23:35:32 z-b-data-1 systemd[1]: ceph-osd@0.service: Failed with result 'exit-code'.
   Nov 29 23:35:32 z-b-data-1 systemd[1]: Failed to start Ceph object storage daemon osd.0.
   Nov 29 23:36:06 z-b-data-1 systemd[1]: ceph-osd@0.service: Start request repeated too quickly.
   Nov 29 23:36:06 z-b-data-1 systemd[1]: ceph-osd@0.service: Failed with result 'exit-code'.
   Nov 29 23:36:06 z-b-data-1 systemd[1]: Failed to start Ceph object storage daemon osd.0.
   Nov 29 23:50:17 z-b-data-1 systemd[1]: ceph-osd@0.service: Start request repeated too quickly.
   Nov 29 23:50:17 z-b-data-1 systemd[1]: ceph-osd@0.service: Failed with result 'exit-code'.
   Nov 29 23:50:17 z-b-data-1 systemd[1]: Failed to start Ceph object storage daemon osd.0.

- 查看 ``inventory`` 输出::

   ceph-volume inventory

可以看到::

   Device Path               Size         rotates available Model name
   /dev/nvme0n1              953.87 GB    False   True      SAMSUNG MZVL21T0HCLR-00B00
   /dev/vda                  6.00 GB      True    False

检查详情输出::

   ceph-volume inventory /dev/nvme0n1

可以看到报告::

   ====== Device report /dev/nvme0n1 ======
   
        path                      /dev/nvme0n1
        lsm data                  {}
        available                 True
        rejected reasons
        device id                 SAMSUNG MZVL21T0HCLR-00B00_S676NF0R908202
        removable                 0
        ro                        0
        vendor
        model                     SAMSUNG MZVL21T0HCLR-00B00
        sas address
        rotational                0
        scheduler mode            none
        human readable size       953.87 GB

- 检查分区::

   ceph-volume inventory /dev/nvme0n1p1

输出显示 ``inventory`` 这个分区被拒绝，原因是已经具备了BlueStore设备标签::

   ====== Device report /dev/nvme0n1p1 ======
   
        path                      /dev/nvme0n1p1
        lsm data                  {}
        available                 False
        rejected reasons          Has BlueStore device label
        device id                 SAMSUNG MZVL21T0HCLR-00B00_S676NF0R908202
        human readable size       651.92 GB

- 我发现 ``/var/lib/ceph/osd/ceph-0/`` 目录完全是空的，之前的 ``sudo ceph-volume raw prepare --data /dev/nvme0n1p1`` 执行完成后，这个目录已经具备了初始化的内容，为何重启之后就丢失了呢？

参考 `ceph systmed帮助 <https://docs.ceph.com/en/latest/ceph-volume/simple/systemd/>`_ 可以看到， ``systemd`` 在启动时候，会检查 ``/etc/ceph/osd/{id}-{uuid}.json`` 配置文件加载相对应的systemd unit的实例名称，然后根据对应的卷使用 OSD 目标转换处理挂载，也就是 ``/var/lib/ceph/osd/{cluster name}-{osd id}`` 挂载，即 ``/var/lib/ceph/osd/ceph-0`` (第一个OSD)。一旦进程处理完毕，就会调用启动OSD，即 ``systemctl start ceph-osd@0`` 。

我检查发现我的服务器上没有 ``/etc/ceph/osd/`` 目录，也就是说我之前的步骤动态激活了 OSD，但是没有创建 json 格式的配置文件，导致再次启动时 ``systemd`` 无法读取配置来尊卑实例以及对应目录挂载，所以也就无法启动OSD。

- 可以从 ``sudo ceph-volume raw list`` 获得json格式设备文件，输出到对应配置文件 ``/etc/ceph/osd/0-8d889fc0-110c-45fa-a259-6a876183bc46.json`` ::

   {
       "0": {
           "ceph_fsid": "39392603-fe09-4441-acce-1eb22b1391e1",
           "device": "/dev/nvme0n1p1",
           "osd_id": 0,
           "osd_uuid": "8d889fc0-110c-45fa-a259-6a876183bc46",
           "type": "bluestore"
       }
   }

从文档看 ``ceph-volume simple activate`` 可以激活已经构建过的OSD，所以我尝试::

   ceph-volume simple activate {ID} {FSID}

或::

   ceph-volume simple activate --file /etc/ceph/osd/{ID}-{FSID}.json

按照帮助提示，首先 ``scan`` ::

   sudo ceph-volume simple scan

然后执行激活::

   ceph-volume simple activate --all

这里提示错误，显示确实根据 ``--all`` 参数去激活所有 ``*.json`` 文件，但是::

   --> activating OSD specified in /etc/ceph/osd/0-8d889fc0-110c-45fa-a259-6a876183bc46.json
   --> Required devices (block and data) not present for bluestore
   --> bluestore devices found: []
   -->  AttributeError: 'RuntimeError' object has no attribute 'message'

- 检查详情::

   ceph health detail

显示输出::

   HEALTH_WARN 1 osds down; 1 host (1 osds) down; 1 root (1 osds) down; Reduced data availability: 1 pg inactive; OSD count 1 < osd_pool_default_size 3
   [WRN] OSD_DOWN: 1 osds down
       osd.0 (root=default,host=z-b-data-1) is down
   [WRN] OSD_HOST_DOWN: 1 host (1 osds) down
       host z-b-data-1 (root=default) (1 osds) is down
   [WRN] OSD_ROOT_DOWN: 1 root (1 osds) down
       root default (1 osds) is down
   [WRN] PG_AVAILABILITY: Reduced data availability: 1 pg inactive
       pg 1.0 is stuck inactive for 3h, current state unknown, last acting []
   [WRN] TOO_FEW_OSDS: OSD count 1 < osd_pool_default_size 3

- 检查 ``osd`` ::

   ceph osd tree

显示状态down::

   ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
   -1         0.63660  root default
   -3         0.63660      host z-b-data-1
    0    ssd  0.63660          osd.0          down   1.00000  1.00000

- 我检查了之前 ``sudo ceph-volume raw prepare --bluestore --data /dev/nvme0n1p1`` 输出记录，发现其中有将设备文件设置为 ``ceph`` 用户的步骤::

   /usr/bin/chown -R ceph:ceph /dev/nvme0n1p1

但是我发现服务器重启之后，这个设备文件恢复回root用户::

   brw-rw---- 1 root disk 259, 1 Nov 30 16:05 /dev/nvme0n1p1

我重试 :ref:`udev` 设置正确的ownership，但是重启系统依然没有正确启动OSD。

重新开始
============

由于解决不了问题，我参考 `Adding/Removing OSDs <https://docs.ceph.com/en/latest/rados/operations/add-or-rm-osds/>`_ 删除掉osd，然后重新开始::

   sudo ceph osd stop 0
   sudo ceph osd purge 0 --yes-i-really-mean-it

此时::

   sudo ceph osd tree

显示::

   ID  CLASS  WEIGHT  TYPE NAME            STATUS  REWEIGHT  PRI-AFF
   -1              0  root default
   -3              0      host z-b-data-1

已经没有了 ``osd.0``

- 重新创建OSD::

   sudo ceph-volume raw prepare --bluestore --data /dev/nvme0n1p1

但是非常奇怪的报错::

   ...
   Running command: /usr/bin/ceph-osd --cluster ceph --osd-objectstore bluestore --mkfs -i 0 --monmap /var/lib/ceph/osd/ceph-0/activate.monmap --keyfile - --osd-data /var/lib/ceph/osd/ceph-0/ --osd-uuid e4725c90-9f08-45fd-b063-5807cc84e992 --setuser ceph --setgroup ceph
   stderr: 2021-11-30T17:57:15.364+0800 7f0464d78d80 -1 bluestore(/var/lib/ceph/osd/ceph-0/) _open_fsid (2) No such file or directory
   stderr: 2021-11-30T17:57:15.364+0800 7f0464d78d80 -1 bluestore(/var/lib/ceph/osd/ceph-0/) mkfs fsck found fatal error: (2) No such file or directory
   stderr: 2021-11-30T17:57:15.364+0800 7f0464d78d80 -1 OSD::mkfs: ObjectStore::mkfs failed with error (2) No such file or directory
   stderr: 2021-11-30T17:57:15.364+0800 7f0464d78d80 -1  ** ERROR: error creating empty object store in /var/lib/ceph/osd/ceph-0/: (2) No such file or directory
   --> Was unable to complete a new OSD, will rollback changes
   ...

似乎是因为没有清理么？

- 增加一个清理分区前10M空间的命令::

   sudo /usr/bin/dd if=/dev/zero of=/dev/nvme0n1p1 bs=1M count=10 conv=fsync

果然，重启系统后再次尝试创建OSD就能够正常完成::

   sudo ceph-volume raw prepare --bluestore --data /dev/nvme0n1p1

- 完成后检查 ``/var/lib/ceph/osd/ceph-0/`` 可以看到以下内容::

   total 48K
   -rw-r--r-- 1 ceph ceph 206 Nov 30 20:42 activate.monmap
   lrwxrwxrwx 1 ceph ceph  14 Nov 30 20:42 block -> /dev/nvme0n1p1
   -rw------- 1 ceph ceph   2 Nov 30 20:42 bluefs
   -rw------- 1 ceph ceph  37 Nov 30 20:42 ceph_fsid
   -rw-r--r-- 1 ceph ceph  37 Nov 30 20:42 fsid
   -rw------- 1 ceph ceph  56 Nov 30 20:42 keyring
   -rw------- 1 ceph ceph   8 Nov 30 20:42 kv_backend
   -rw------- 1 ceph ceph  21 Nov 30 20:42 magic
   -rw------- 1 ceph ceph   4 Nov 30 20:42 mkfs_done
   -rw------- 1 ceph ceph  41 Nov 30 20:42 osd_key
   -rw------- 1 ceph ceph   6 Nov 30 20:42 ready
   -rw------- 1 ceph ceph  10 Nov 30 20:42 type
   -rw------- 1 ceph ceph   2 Nov 30 20:42 whoami

并且这个 ``/var/lib/ceph/osd/ceph-0`` 已经挂载成 ``tmpfs`` ，通过 ``df -h`` 检查可以看到::

   tmpfs           7.9G   48K  7.9G   1% /var/lib/ceph/osd/ceph-0

- 注意此时只是完成磁盘初始化，尚未激活，所以::

   sudo ceph -s

看到如下输出::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             OSD count 1 < osd_pool_default_size 3
    
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 5m)
     mgr: z-b-data-1(active, since 4m)
     osd: 1 osds: 0 up (since 20h), 0 in (since 3h)
    
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:     100.000% pgs unknown
              1 unknown 

- 检查设备文件::

   sudo ceph-volume raw list

显示::

   {
       "0": {
           "ceph_fsid": "39392603-fe09-4441-acce-1eb22b1391e1",
           "device": "/dev/nvme0n1p1",
           "osd_id": 0,
           "osd_uuid": "4f6f2db9-894a-455c-bdaf-f3324ab5efe1",
           "type": "bluestore"
       }
   }

注意重新格式化之后 ``osd_uuid`` 是变化的

- 激活磁盘::

   sudo ceph-volume raw activate --device /dev/nvme0n1p1

此时提示::

   --> systemd support not yet implemented

- 启动 systemd 的 ``ceph-osd@0.service`` 服务::

   sudo systemctl enable ceph-osd@0.service
   sudo systemctl start ceph-osd@0.service

- 检查服务状态::

   sudo systemctl status ceph-osd@0.service

状态如下::

   ● ceph-osd@0.service - Ceph object storage daemon osd.0
        Loaded: loaded (/lib/systemd/system/ceph-osd@.service; disabled; vendor preset: enabled)
        Active: active (running) since Tue 2021-11-30 20:52:51 CST; 5s ago
       Process: 1390 ExecStartPre=/usr/lib/ceph/ceph-osd-prestart.sh --cluster ${CLUSTER} --id 0 (code=exited, status=0/SUCCESS)
      Main PID: 1403 (ceph-osd)
         Tasks: 69
        Memory: 26.3M
        CGroup: /system.slice/system-ceph\x2dosd.slice/ceph-osd@0.service
                └─1403 /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph
   
   Nov 30 20:52:51 z-b-data-1 systemd[1]: Starting Ceph object storage daemon osd.0...
   Nov 30 20:52:51 z-b-data-1 systemd[1]: Started Ceph object storage daemon osd.0.
   Nov 30 20:52:51 z-b-data-1 ceph-osd[1403]: 2021-11-30T20:52:51.712+0800 7f7ea0ba8d80 -1 Falling back to public interface
   Nov 30 20:52:52 z-b-data-1 ceph-osd[1403]: 2021-11-30T20:52:52.392+0800 7f7ea0ba8d80 -1 osd.0 0 log_to_monitors {default=true}
   Nov 30 20:52:53 z-b-data-1 ceph-osd[1403]: 2021-11-30T20:52:53.840+0800 7f7e92c93700 -1 osd.0 0 waiting for initial osdmap
   Nov 30 20:52:53 z-b-data-1 ceph-osd[1403]: 2021-11-30T20:52:53.896+0800 7f7e9a0ea700 -1 osd.0 111 set_numa_affinity unable to identify public interface '' numa node: (2) No such file or directory

- 按照 `ceph systmed帮助 <https://docs.ceph.com/en/latest/ceph-volume/simple/systemd/>`_ 文档，可以知道只要已经完成磁盘挂载，则启动 ``ceph-osd@0.service`` 就会激活磁盘(应该不需要手工 ``ceph-volume raw active`` )。此时检查集群状态可以看到第一个OSD已经激活启用::

   sudo ceph -s

输出显示::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             OSD count 1 < osd_pool_default_size 3
    
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 13m)
     mgr: z-b-data-1(active, since 13m)
     osd: 1 osds: 1 up (since 83s), 1 in (since 83s)
   
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   1.0 GiB used, 651 GiB / 652 GiB avail
     pgs:     100.000% pgs unknown
              1 unknown

- 激活系统启动时启动 ``ceph-osd`` ::

   sudo systemctl enable ceph-osd@0.service

- (这步应该不需要)参考 `OSD Config Reference <https://docs.ceph.com/en/latest/rados/configuration/osd-config-ref/>`_ 最小化的配置，在 ``/etc/ceph/ceph.conf`` 添加OSD Daemon配置::

   [osd.0]
   host = z-b-data-1

.. note::

   在 ``/etc/ceph/ceph.conf`` 中添加 ``osd.0`` 配置可能是非常关键的一步，我第二次执行操作多增加了这步，然后重启服务器就能够正常启动所有服务，包括OSD也能正常启动

然后 ``重启操作系统`` 验证::

   sudo ceph -s

如我所料，这次重启操作系统后，可以看到已经正常激活OSD::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             OSD count 1 < osd_pool_default_size 3
    
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 4m)
     mgr: z-b-data-1(active, since 4m)
     osd: 1 osds: 1 up (since 29m), 1 in (since 29m)
    
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:     100.000% pgs unknown
              1 unknown

但是，发现 ``systemctl status ceph-osd@0`` 是失败的::

   ● ceph-osd@0.service - Ceph object storage daemon osd.0
        Loaded: loaded (/lib/systemd/system/ceph-osd@.service; enabled; vendor preset: enabled)
        Active: failed (Result: exit-code) since Tue 2021-11-30 21:18:06 CST; 4min 2s ago
       Process: 966 ExecStartPre=/usr/lib/ceph/ceph-osd-prestart.sh --cluster ${CLUSTER} --id 0 (code=exited, status=0/SUCCESS)
       Process: 987 ExecStart=/usr/bin/ceph-osd -f --cluster ${CLUSTER} --id 0 --setuser ceph --setgroup ceph (code=exited, status=1/FAILURE)
      Main PID: 987 (code=exited, status=1/FAILURE)
   
   Nov 30 21:18:06 z-b-data-1 systemd[1]: ceph-osd@0.service: Scheduled restart job, restart counter is at 3.
   Nov 30 21:18:06 z-b-data-1 systemd[1]: Stopped Ceph object storage daemon osd.0.
   Nov 30 21:18:06 z-b-data-1 systemd[1]: ceph-osd@0.service: Start request repeated too quickly.
   Nov 30 21:18:06 z-b-data-1 systemd[1]: ceph-osd@0.service: Failed with result 'exit-code'.
   Nov 30 21:18:06 z-b-data-1 systemd[1]: Failed to start Ceph object storage daemon osd.0.

我发现一个奇怪的问题，就是虽然 ``ceph -s`` 显示OSD已经激活，但实际上系统中根本没有 ``ceph-osd`` 进程，在 ``/var/run/ceph`` 目录下也没有osd对应的socket。这说明 osd 实际没有启动。但是 ``ceph -s`` 始终显示 ``osd`` 是正常up ::

   sudo ceph osd tree

输出::

   ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
   -1         0.63660  root default
   -3         0.63660      host z-b-data-1
    0    ssd  0.63660          osd.0            up   1.00000  1.00000

从监控页面显示也是 OSDs : ``1 total: 1 up, 1 in``

但是显然 ``systemctl status ceph-osd@0.service`` 状态表明启动失败::

   Process: 983 ExecStart=/usr/bin/ceph-osd -f --cluster ${CLUSTER} --id 0 --setuser ceph --setgroup ceph (code=exited, status=1/FAILURE)

- 手工执行::

   sudo /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph

可以看到错误原因::

   2021-11-30T22:59:37.828+0800 7f60db9f3d80 -1 auth: unable to find a keyring on /var/lib/ceph/osd/ceph-0/keyring: (2) No such file or directory
   2021-11-30T22:59:37.828+0800 7f60db9f3d80 -1 AuthRegistry(0x557f7fe96938) no keyring found at /var/lib/ceph/osd/ceph-0/keyring, disabling cephx
   2021-11-30T22:59:37.832+0800 7f60db9f3d80 -1 auth: unable to find a keyring on /var/lib/ceph/osd/ceph-0/keyring: (2) No such file or directory
   2021-11-30T22:59:37.832+0800 7f60db9f3d80 -1 AuthRegistry(0x7fff676473f0) no keyring found at /var/lib/ceph/osd/ceph-0/keyring, disabling cephx
   failed to fetch mon config (--no-mon-config to skip)

但是手工创建文件也不能解决( ``ceph-volume raw prepare`` 过程命令)::

   /usr/bin/ceph-authtool /var/lib/ceph/osd/ceph-0/keyring --create-keyring --name osd.0 --add-key AQA2yqRhes0wORAAttpUh5aRZsr1pLdHeXRezg==
   /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-0/keyring
   /usr/bin/ln -s /dev/nvme0n1p1 /var/lib/ceph/osd/ceph-0/block

这个问题困扰了我两天，为何 ``ceph-volume raw prepare`` 命令的子命令有::

   /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-0

那么 ``/var/lib/ceph/osd/ceph-0`` 岂不是一个内存中的存储，一旦重启数据就会丢失？ ``keyring`` 等文件在tmpfs中，是如何重启后继续存在的？

`how the files in /var/lib/ceph/osd/ceph-0 are generated <http://lists.ceph.com/pipermail/ceph-users-ceph.com/2018-April/025914.html>`_ 讨论提到::

   bluestore will save all the information at the starting of
   disk (BDEV_LABEL_BLOCK_SIZE=4096)
   this area is used for saving labels, including keyring, whoami etc.

通过以下命令检查::

   ceph-bluestore-tool  show-label --path /var/lib/ceph/osd/ceph-0

可以看到::

   {
       "/var/lib/ceph/osd/ceph-0/block": {
           "osd_uuid": "d34a6c89-0c53-4378-ac43-108b47722abf",
           "size": 699998928896,
           "btime": "2021-11-30T23:35:24.910469+0800",
           "description": "main",
           "bfm_blocks": "170898176",
           "bfm_blocks_per_key": "128",
           "bfm_bytes_per_block": "4096",
           "bfm_size": "699998928896",
           "bluefs": "1",
           "ceph_fsid": "39392603-fe09-4441-acce-1eb22b1391e1",
           "kv_backend": "rocksdb",
           "magic": "ceph osd volume v026",
           "mkfs_done": "yes",
           "osd_key": "AQC8RKZhuuYFCRAAAFhRXTyApcLIIsi1bZUxdA==",
           "ready": "ready",
           "require_osd_release": "15",
           "whoami": "0"
       }
   }

当挂载 ``/var/lib/ceph/osd/ceph-0`` 时，ceph会dump这些内容到tmpfs目录。

根据之前 ``ceph-volume raw activate`` 可以看到 ``/var/lib/ceph/osd/ceph-0`` 挂载了 ``tmpfs`` 并获得了所有必须的 ``keyring`` 等文件，然后才能正确 ``systemctl start ceph-osd@0.service`` 。也就是说，能够正常启动 ``ceph-osd`` 进程的前提条件是 ``/var/lib/ceph/osd/ceph-0`` 目录正确挂载( ``activate`` )。操作系统重启，没有正确挂载和准备好这个目录，是导致无法启动 ``ceph-osd`` 的原因，那么是在哪里完成这个启动挂载配置呢？

应该有一个 ``/etc/ceph/osd/xxxx.json`` 配置提供了ceph启动时准备好目录挂载，这样就能正确启动 ``ceph-osd@0.service`` ...

`how the files in /var/lib/ceph/osd/ceph-0 are generated <http://lists.ceph.com/pipermail/ceph-users-ceph.com/2018-April/025914.html>`_ 讨论，有人回答了这个准备 ``osd`` 目录的工具命令是 ``ceph-bluestore-tool prime-osd-dir`` ，可以重新创建所有的文件正确指向OSD block设备，所以我执行以下命令::

   sudo ceph-bluestore-tool prime-osd-dir --dev /dev/nvme0n1p1 --path /var/lib/ceph/osd/ceph-0

但是，上述命令只传递了部分文件::

   total 24K
   -rw------- 1 root root 37 Dec  1 10:07 ceph_fsid
   -rw------- 1 root root 37 Dec  1 10:07 fsid
   -rw------- 1 root root 55 Dec  1 10:07 keyring
   -rw------- 1 root root  6 Dec  1 10:07 ready
   -rw------- 1 root root 10 Dec  1 10:07 type
   -rw------- 1 root root  2 Dec  1 10:07 whoami

完成后检查就可以看到 ``sudo ls -lh /var/lib/ceph/osd/ceph-0`` 终于出现了正确挂载 ``/var/lib/ceph/osd/ceph-0`` 的 ``tmpfs`` 文件::

   total 52K
   -rw-r--r-- 1 ceph ceph 206 Nov 30 23:35 activate.monmap
   lrwxrwxrwx 1 ceph ceph  14 Nov 30 23:35 block -> /dev/nvme0n1p1
   -rw------- 1 ceph ceph   2 Nov 30 23:35 bluefs
   -rw------- 1 ceph ceph  37 Dec  1 08:47 ceph_fsid
   -rw-r--r-- 1 ceph ceph  37 Dec  1 08:47 fsid
   -rw------- 1 ceph ceph  55 Dec  1 08:47 keyring
   -rw------- 1 ceph ceph   8 Nov 30 23:35 kv_backend
   -rw------- 1 ceph ceph  21 Nov 30 23:35 magic
   -rw------- 1 ceph ceph   4 Nov 30 23:35 mkfs_done
   -rw------- 1 ceph ceph  41 Nov 30 23:35 osd_key
   -rw------- 1 ceph ceph   6 Dec  1 08:47 ready
   -rw------- 1 ceph ceph   3 Nov 30 23:40 require_osd_release
   -rw------- 1 ceph ceph  10 Dec  1 08:47 type
   -rw------- 1 ceph ceph   2 Dec  1 08:47 whoami

- 此时就能够正确启动 ``ceph-osd@0.service`` 服务::

   sudo systemctl start ceph-osd@0.service

.. note::

   完整 ``activate`` BlueStore的过程见文档 `ceph-volume » activate <https://docs.ceph.com/en/latest/ceph-volume/lvm/activate/#summary>`_

总结
-----------

- 删除掉OSD.0 准备重新开始::

   sudo ceph osd purge 0 --yes-i-really-mean-it

- 清理理分区前10M空间(重要，否则 ``ceph-volume raw prepare`` 失败::

   /usr/bin/dd if=/dev/zero of=/dev/nvme0n1p1 bs=1M count=10 conv=fsync

- 使用 ``raw`` 模式其实只有2个命令步骤::

   sudo ceph-volume raw prepare --bluestore --data /dev/nvme0n1p1
   sudo ceph-volume raw activate --device /dev/nvme0n1p1

此时 ``/var/lib/ceph/osd/ceph-0`` 会挂载 ``tmpfs`` 正确生成指向 ``/dev/nvme0n1p1`` BlueStore的文件，具备了启动 ``ceph-osd`` 的条件

- 启动 ``ceph-osd`` 服务::

   sudo systemctl start ceph-osd@0.service
   sudo systemctl enable ceph-osd@0.service

- 此时检查 ``sudo ceph -s`` 就可以看到OSD 0已经激活启用

- 检查 ``ceph-volume`` 输出的 ``osd_id`` 和 ``osd_uuid`` ::

   sudo ceph-volume raw list

显示::

   {
       "0": {
           "ceph_fsid": "39392603-fe09-4441-acce-1eb22b1391e1",
           "device": "/dev/nvme0n1p1",
           "osd_id": 0,
           "osd_uuid": "d34a6c89-0c53-4378-ac43-108b47722abf",
           "type": "bluestore"
       }
   }

- 激活对应的卷服务(似乎应该有这个步骤，但是还是没有成功)::

   sudo systemctl enable ceph-volume@raw-0-d34a6c89-0c53-4378-ac43-108b47722abf

输出提示::

   Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@raw-0-d34a6c89-0c53-4378-ac43-108b47722abf.service → /lib/systemd/system/ceph-volume@.service.

:strike:`这样启动才能够挂载好卷` 不过我重启还是没有解决挂载

- 如果不能正确挂载，则手工处理::

   mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-0
   sudo ceph-bluestore-tool prime-osd-dir --dev /dev/nvme0n1p1 --path /var/lib/ceph/osd/ceph-0

这里进展了一步，生成了一些必要文件，但还不完整，所以 ``ceph-osd@0.service`` 还不能正常运行   

- 检查分区uuid(这个步骤待参考，是为了解决块设备属主，有可能不需要)::

   udevadm info --query=all --name=/dev/nvme0n1p1 | grep -i uuid

将输出的 ``E: ID_PART_ENTRY_UUID`` 修订 ``/etc/udev/rules.d/99-perm.rules`` ::

   ACTION=="add|change", ENV{ID_PART_ENTRY_UUID}=="4a7db7a7-90fc-47cb-b473-8774db0c392f", OWNER="ceph", GROUP="ceph"

- 修订 ``/etc/ceph/ceph.conf`` 配置文件添加最简化的OSD配置(可能不需要)::

   [osd.0]
   host = z-b-data-1

这个配置可以确保操作系统重启后自动启动 ``osd.0``

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
