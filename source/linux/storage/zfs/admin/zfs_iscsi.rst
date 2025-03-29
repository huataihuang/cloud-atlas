.. _zfs_iscsi:

============================
使用ZFS卷构建iSCSI LUN共享
============================

在 :ref:`k8s_persistent_volumes` 支持iSCSI，本文构建基于ZFS卷的iSCSI LUN输出，为 :ref:`k8s_iscsi` 提供存储服务

:ref:`zfs_admin_prepare`
===========================

在 :ref:`zfs_admin_prepare` 划分了3个分区，其中 ``zpool-data`` 用于数据存储并构建 iSCSI 输出(也已经部分用于 :ref:`k8s_nfs` 所以本步骤已执行过)

.. literalinclude:: zfs_admin_prepare/parted_nvme_libvirt_docker_output
   :language: bash
   :caption: parted分区后状态(新增3个分区用于zpool)
   :emphasize-lines: 13

创建 zpool 和 LUN
====================

- 对 ``/dev/nvme0n1p7`` 构建 zpool(已经在 :ref:`k8s_nfs` 完成该步骤):

.. literalinclude:: zfs_nfs/zpool_create_zpool-data
   :language: bash
   :caption: 创建zpool-data存储池

参考
======

- `How to Share ZFS Volumes via iSCSI <https://linuxhint.com/share-zfs-volumes-via-iscsi/>`_
- `Using a ZFS Volume as an iSCSI LUN <https://docs.oracle.com/cd/E53394_01/html/E54801/gechv.html>`_
