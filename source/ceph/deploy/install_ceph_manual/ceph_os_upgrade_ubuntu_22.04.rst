.. _ceph_os_upgrade_ubuntu_22.04:

==================================
Ceph底层Ubuntu操作系统升级到22.04
==================================

为提升软硬件性能，我尝试将 :ref:`priv_cloud_infra` 的虚拟机数据层，也就是运行Ceph集群的 :ref:`kvm` 虚拟机操作系统 :ref:`upgrade_ubuntu_20.04_to_22.04` :

升级方式
==========

理想的ceph升级方式应该采用 Ceph 官方文档 `UPGRADING CEPH <https://docs.ceph.com/en/quincy/cephadm/upgrade/>`_ 将整个升级过程控制在Ceph集群软件，而不是以来操作系统发行版进行升级。

.. warning::

   我的个人测试环境没有严格按照标准升级方案，所以本文记录仅供个人参考，切勿用于生产环境。 **数据存在丢失风险!!!**

我为了偷懒，直接采用发行版升级，同时携带ceph升级，但是整个升级采用:

- 单个节点完整完成操作系统升级以及ceph升级，然后再进行下一个节点升级

  - 如果遇到不可测宕机，则销毁虚拟机重建故障节点

- 升级过程前后观察 ``ceph status`` 以及监控，并在使用ceph作为存储的 

升级OS
==========

升级准备
---------

升级前需要确保操作系统根目录有足够空间，我的第一次升级OS版本就因为根目录打爆导致部分(内核)软件包安装失败。通过 :ref:`libvirt_lvm_pool_resize_vm_disk` 解决VM磁盘空间才最终完成升级。以下以 ``z-b-data-3`` 虚拟机根磁盘扩容为例:

- 在物理主机 ``zcloud`` 上完成以下操作扩容libvirt的对应虚拟机LVM卷::

   lvresize -L 16G /dev/vg-libvirt/z-b-data-3
   virsh blockresize z-b-data-3 --path /dev/vg-libvirt/z-b-data-3 --size 16G

- 登录 ``z-b-data-3`` 虚拟机内部::

   #安装growpart
   apt install cloud-guest-utils
   #扩展分区2
   growpart /dev/vda 2
   #扩展XFS根分区
   xfs_growfs /

升级操作
-----------

- 升级前检查ceph版本::

   # ceph version
   ceph version 15.2.16 (d46a73d6d0a67a79558054a3a5a72cb561724974) octopus (stable)

- 采用 :ref:`upgrade_ubuntu_20.04_to_22.04` 相同方法升级操作系统

.. note::

   我在升级Ceph集群的一个工作节点操作系统同时对运行在Ceph存储上的KVM虚拟机(大约10+ VM)同时升级操作系统，目测对Ceph集群的IO操作大约达到100MB/s流量，IOPS约上千，整个过程非常平滑，没有出现过hang机现象。

升级后检查
--------------

- 升级后服务器上的ceph版本从 15.2.16 升级到 17.2.0

- 观察Ceph集群状态，升级过程中可以看到只有在升级节点重启接管出现过集群unhealth，重启完成后Ceph集群回复到health状态::

   ceph status

显示运行正常::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_OK
  
   services:
     mon: 3 daemons, quorum z-b-data-1,z-b-data-2,z-b-data-3 (age 7m)
     mgr: z-b-data-1(active, since 8d)
     osd: 3 osds: 3 up (since 7m), 3 in (since 5w)
  
   data:
     pools:   2 pools, 33 pgs
     objects: 30.87k objects, 120 GiB
     usage:   361 GiB used, 1.0 TiB / 1.4 TiB avail
     pgs:     33 active+clean
  
   io:
     client:   6.7 KiB/s rd, 247 KiB/s wr, 0 op/s rd, 15 op/s wr

**但是，升级完成后，虽然整体上节点工作正常，但是存在WARNING** ::

   OSD_UPGRADE_FINISHED: all OSDs are running quincy or later but require_osd_release < quincy

解决 ``require_osd_release < quincy`` 问题
============================================

``quincy`` 是Ceph最新release版本，参考 `upgraded to 1.9.0 and ceph 17.1 and require_osd_release not updated automatically #10084 <https://github.com/rook/rook/issues/10084>`_ 

当Ceph的OSD完成升级后，需要将 osd 版本的最小要求设置成新版本 ``quincy`` ，所以执行以下命令进行修正::

   ceph osd require-osd-release quincy

然后再观察 ``ceph status`` 就不会有告警了
