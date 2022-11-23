.. _zfs_nfs:

=============
ZFS NFS
=============

ZFS内置NFS功能为企业级应用提供了方便的共享存储，在很多应用领域有广泛应用:

- :ref:`machine_learning` 大量的训练共享数据
- 医疗影像行业存储大量的医疗图片
- ...

.. note::

   本文实现ZFS NFS服务配置，为后续构建 :ref:`zfs_infra` 的企业应用提供基础

:ref:`zfs_admin_prepare`
===========================

在 :ref:`zfs_admin_prepare` 划分了3个分区，其中 ``zpool-data`` 用于数据存储并构建 NFS 共享给 :ref:`kind` 部署 :ref:`k8s_nfs`

.. literalinclude:: zfs_admin_prepare/parted_nvme_libvirt_docker_output
   :language: bash
   :caption: parted分区后状态(新增3个分区用于zpool)
   :emphasize-lines: 13

创建 zpool 和 zfs
====================

- 对 ``/dev/nvme0n1p7`` 构建 zpool:

.. literalinclude:: zfs_nfs/zpool_create_zpool-data
   :language: bash
   :caption: 创建zpool-data存储池

- 创建ZFS文件系统 ``docs`` :

.. literalinclude:: zfs_nfs/zfs_create_docs
   :language: bash
   :caption: 创建zpool-data存储池中ZFS文件系统docs，开启压缩

- 准备 ``docs`` 数据(将我的文档目录迁移到 ``docs`` ZFS存储中):

.. literalinclude:: zfs_nfs/copy_docs
   :language: bash
   :caption: 将文档目录docs复制到 zpool-data存储池中ZFS文件系统docs

ZFS共享NFS存储数据集
======================

ZFS的NFS服务也是通过Linux :ref:`nfs` 来实现，所以也需要 :ref:`setup_nfs_arch_linux` 相同的软件包安装:

.. literalinclude:: ../../../../infra_service/nfs/setup_nfs_arch_linux/pacman_install_nfs-utils
   :language: bash
   :caption: 在arch linux上安装nfs-utils支持NFS

参考
======

- `How to Share ZFS Filesystems with NFS <https://linuxhint.com/share-zfs-filesystems-nfs/>`_
- `Sharing ZFS Datasets Via NFS <https://blog.programster.org/sharing-zfs-datasets-via-nfs>`_
- `Sharing and Unsharing ZFS File Systems <https://docs.oracle.com/cd/E23824_01/html/821-1448/gayne.html>`_
- `arch linux: NFS <https://wiki.archlinux.org/title/NFS>`_
