.. _add_ceph_osds_more:

==========================
Ceph集群添加更多ceph-osd
==========================

在Ceph集群的初始化过程中，首先在第一台 ``z-b-data-1`` 部署了 ``ceph-mon`` ( :ref:`install_ceph_mon` ) 和 ``ceph-osd`` ( :ref:`add_ceph_osds_lvm` ) 。此时，整个只有1个OSD服务，而在配置 ``/etc/ceph/ceph.conf`` 中，采用的配置是3副本。所以当前集群状态::

   sudo ceph -s

显示输出::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             Degraded data redundancy: 1 pg undersized
             OSD count 1 < osd_pool_default_size 3
   
   services:
     mon: 3 daemons, quorum z-b-data-1,z-b-data-2,z-b-data-3 (age 18m)
     mgr: z-b-data-1(active, since 47h)
     osd: 1 osds: 1 up (since 47h), 1 in (since 3d)
   
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   1.0 GiB used, 465 GiB / 466 GiB avail
     pgs:     100.000% pgs not active
              1 undersized+peered

可以看到当前集群提示::

   OSD count 1 < osd_pool_default_size 3

现在我们就在 ``z-b-data-2`` 和 ``z-b-data-3`` 上部署起OSD，使用 :ref:`ovmf` pass-through PCIe NVMe存储

部署新增OSD
==============

- 在两台 ``z-b-data-2`` 和 ``z-b-data-3`` 复制配置和keyring (在部署 :ref:`add_ceph_mons` 时已经完成)::

   scp 192.168.6.204:/etc/ceph/ceph.client.admin.keyring /etc/ceph/
   scp 192.168.6.204:/etc/ceph/ceph.conf /etc/ceph/

- 在两台 ``z-b-data-2`` 和 ``z-b-data-3`` 准备磁盘::

   sudo parted /dev/nvme0n1 mklabel gpt
   sudo parted -a optimal /dev/nvme0n1 mkpart primary 0% 500GB

- 在 :ref:`install_ceph_mon` 过程中，节点 ``z-b-data-1`` 已经生成了 ``bootstrap-osd`` keyring ``/var/lib/ceph/bootstrap-osd/ceph.keyring`` ，需要将这个文件复制到部署OSD的服务器对应目录::

   scp 192.168.6.204:/var/lib/ceph/bootstrap-osd/ceph.keyring /var/lib/ceph/bootstrap-osd/

- 在两台 ``z-b-data-2`` 和 ``z-b-data-3`` 上创建OSD磁盘卷::

   sudo ceph-volume lvm create --bluestore --data /dev/nvme0n1p1


和 :ref:`add_ceph_osds_lvm` 一样，使用 ``LVM`` 卷方式管理是最方便的，自动添加了 ``systemd`` 服务 ``ceph-osd@.service`` 并且自动启动，也创建了该服务在操作系统启动时自动启动的 ``systemd`` 链接配置

.. note::

   注意， ``ceph-volume`` 会自动把后续添加的OSD的ID设置为 ``1`` 和 ``2`` ，你可以看到 在 ``z-b-data-2`` 的systemd配置是 ``ceph-osd@1.service`` ，启动服务是::

      systemctl start ceph-osd@1.service

   而在 ``z-b-data-3`` 是::

      systemctl start ceph-osd@2.service

此时检查osd卷设备::

   sudo ceph-volume lvm list

可以看到在 ``z-b-data-2`` 和 ``z-b-data-3`` 添加的卷文件

- 此时检查ceph集群状态，可以看到由于满足了3副本要求，整个集群进入稳定健康状态::

   sudo ceph -s

输出::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_OK
    
   services:
     mon: 3 daemons, quorum z-b-data-1,z-b-data-2,z-b-data-3 (age 43m)
     mgr: z-b-data-1(active, since 2d)
     osd: 3 osds: 3 up (since 4m), 3 in (since 4m)
    
   data:
     pools:   1 pools, 1 pgs
     objects: 1 objects, 0 B
     usage:   3.0 GiB used, 1.4 TiB / 1.4 TiB avail
     pgs:     1 active+clean

- 从 :ref:`ceph_dashboard` 观察可以看到非常漂亮的健康绿色 ``HEALTH_OK`` ，此时 ``PG Status`` 也恢复正常:

.. figure:: ../../../_static/ceph/deploy/install_ceph_manual/ceph_3_mon_3_osd.png
   :scale: 60
