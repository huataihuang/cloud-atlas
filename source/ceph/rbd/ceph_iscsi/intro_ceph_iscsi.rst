.. _intro_ceph_iscsi:

==================
Ceph iSCSI简介
==================

Ceph的 ``iSCSI网关`` 通过输出 :ref:`rados` 块设备(RBD)镜像作为SCSI磁盘来提供了一个高可用(Highly Available, HA) iSCSI target。iSCSI协议允许客户端(initiators)通过TCP/IP网络发送SCSI命令给存储设备(target)，这样就可以让没有原生Ceph客户端支持的客户端能够访问Ceph块存储。

.. note::

   我在 :ref:`mobile_cloud_ceph_rbd_libvirt` 探索中就遇到由于 :ref:`arch_linux` ARM发行版没有提供 ``libvirt-storage-ceph`` 导致缺少Ceph RBD支持。所以，对于这种情况，采用iSCSI Gateway方式可以绕开客户端缺乏的问题。

每个iSCSI网关都利用Linux IO target内核子系统(LIO)来提供iSCSI协议支持。LIO使用用户空间直通(userspace passthrough)(TCMU)来和Ceph的librbd库交互，并将RBD镜像暴露给iSCSI客户端。通过Ceph的iSCSI网关可以提供完全集成的块存储架构，具备传统存储区域网络(Storage Area Network, SAN)的所有功能和优势。

.. figure:: ../../../_static/ceph/rbd/ceph_iscsi/ceph_iscsi.png
   :scale: 80

   通过Ceph iSCSI网关将RBD镜像映射为iSCSI target

.. warning::

   从2022年11月开始，Ceph iSCSI网关进入维护状态，这意味着将不再活跃开发也不再增加新的功能。

参考
=======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway <https://docs.ceph.com/en/quincy/rbd/iscsi-overview/>`_
- `Manual ceph-iscsi Installation <https://docs.ceph.com/en/latest/rbd/iscsi-target-cli-manual-install/>`_
