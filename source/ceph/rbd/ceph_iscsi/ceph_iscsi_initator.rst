.. _ceph_iscsi_initator:

===========================
Ceph iSCSI initator客户端
===========================

:ref:`config_ceph_iscsi` 服务端iSCSI target配置完成后，就可以配置Linux的iSCSI initator客户端。需要安装和配置2个客户端:

- ``iscsi-initiator-utils``
- ``device-mapper-multipath``

参考
======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway » Configuring the iSCSI Initiators » iSCSI Initiator for Linux <https://docs.ceph.com/en/latest/rbd/iscsi-initiator-linux/>`_
