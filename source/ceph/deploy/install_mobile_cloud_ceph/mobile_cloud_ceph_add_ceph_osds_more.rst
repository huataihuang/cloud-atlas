.. _mobile_cloud_ceph_add_ceph_osds_more:

=====================================
移动云计算Ceph集群添加更多ceph-osd
=====================================

在Ceph集群的初始化过程中，首先在第一台 ``a-b-data-1`` 部署了 ``ceph-mon`` ( :ref:`install_ceph_mon` ) 和 ``ceph-osd`` ( :ref:`add_ceph_osds_lvm` ) 。此时，整个只有1个OSD服务，而在配置 ``/etc/ceph/ceph.conf`` 中，采用的配置是3副本。所以当前集群状态::

   sudo ceph -s

显示输出::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_WARN
             mons are allowing insecure global_id reclaim
             1 monitors have not enabled msgr2
             OSD count 1 < osd_pool_default_size 3
  
   services:
     mon: 3 daemons, quorum a-b-data-1,a-b-data-2,a-b-data-3 (age 19m)
     mgr: a-b-data-1(active, since 3h)
     osd: 1 osds: 1 up (since 3h), 1 in (since 20h)
  
   data:
     pools:   0 pools, 0 pgs
     objects: 0 objects, 0 B
     usage:   5.7 MiB used, 47 GiB / 47 GiB avail
     pgs:

可以看到当前集群提示::

   OSD count 1 < osd_pool_default_size 3

现在我们就在 ``a-b-data-2`` 和 ``a-b-data-3`` 上部署起OSD

部署新增OSD
==============

- 在两台 ``a-b-data-2`` 和 ``a-b-data-3`` 已经做过 :ref:`prepare_vdb_parted`

- 在 ``$HOST_2`` ( ``a-b-data-2`` ) 和 ``$HOST_3`` ( ``a-b-data-3`` ) :ref:`copy_admin_keyring_and_conf` (在部署 :ref:`mobile_cloud_ceph_add_ceph_mons` 时已经完成)

- 在 :ref:`mobile_cloud_ceph_mon` 过程中，节点 ``$HOST_1`` ( ``a-b-data-1`` )已经生成了 ``bootstrap-osd`` keyring ``/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring`` ( ``ceph.keyring`` )  ，需要将这个文件复制到部署OSD的服务器对应目录:

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_more/copy_bootstrap_osd_keyring
   :language: bash
   :caption: 复制bootstrap-osd的keyring

- 在 ``$HOST_2`` ( ``a-b-data-2``  ) 和 ``$HOST_3`` ( ``a-b-data-3``  ) 上创建OSD磁盘卷:

.. literalinclude:: mobile_cloud_ceph_add_ceph_osds_lvm/ceph_volume_create_bluestore
   :language: bash
   :caption: 在/dev/vdb1上构建基于LVM的bluestore存储卷

和 :ref:`mobile_cloud_add_ceph_osds_lvm` 一样，使用 ``LVM`` 卷方式管理是最方便的，自动添加了 ``systemd`` 服务 ``ceph-osd@.service`` 并且自动启动，也创建了该服务在操作系统启动时自动启动的 ``systemd`` 链接配置

.. note::

   注意， ``ceph-volume`` 会自动把后续添加的OSD的ID设置为 ``1`` 和 ``2`` ，你可以看到 在 ``a-b-data-2`` 的systemd配置是 ``ceph-osd@1.service`` ，启动服务是::

      systemctl start ceph-osd@1.service

   而在 ``a-b-data-3`` 是::

      systemctl start ceph-osd@2.service

此时检查osd卷设备::

   sudo ceph-volume lvm list

可以看到在 ``a-b-data-2`` 和 ``a-b-data-3`` 添加的卷文件

- 此时检查ceph集群状态，可以看到由于满足了3副本要求，整个集群进入稳定健康状态::

   sudo ceph -s

输出::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_WARN
             mons are allowing insecure global_id reclaim
             1 monitors have not enabled msgr2
  
   services:
     mon: 3 daemons, quorum a-b-data-1,a-b-data-2,a-b-data-3 (age 99m)
     mgr: a-b-data-1(active, since 4h)
     osd: 3 osds: 3 up (since 56s), 3 in (since 72s)
  
   data:
     pools:   1 pools, 1 pgs
     objects: 2 objects, 449 KiB
     usage:   49 MiB used, 140 GiB / 140 GiB avail
     pgs:     1 active+clean

- 从 :ref:`ceph_dashboard` 观察可以看到非常漂亮的健康绿色 ``HEALTH_OK`` ，此时 ``PG Status`` 也恢复正常:

.. figure:: ../../../_static/ceph/deploy/install_ceph_manual/ceph_3_mon_3_osd.png
   :scale: 60
