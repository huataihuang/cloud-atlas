.. _btrfs_subvolume:

=================
Btrfs子卷
=================

和 :ref:`linux_lvm` 类似，Btrfs提供了卷管理能力，但是也有一些借鉴 :ref:`zfs` 的管理改进:

- 通过独立子卷可以从操作系统层面隔离用户访问
- 在不同子卷采用针对不同业务的不同 :ref:`tune_btrfs` ，例如 :ref:`btrfs_compression`

本文实践中，我采用独立子卷来提供 :ref:`btrfs_nfs`

创建独立子卷
==============

- 创建子卷: 这里创建一个 ``cloud-atlas_build`` 子卷，用于输出我的 :ref:`sphinx_doc` 编译输出目录::

   # 先清理掉 build 目录下文件: make clean
   rm -rf /home/huatai/docs/github.com/cloud-atlas/build/*

在 ``/data`` 挂载卷下创建 ``cloud-atlas_build`` 子卷:

.. literalinclude:: btrfs_subvolume/btrfs_subvolume_create
   :language: bash
   :caption: 在Btrfs文件/data挂载卷下创建子卷 cloud-atlas_build

- 可以手工命令挂载子卷::

   # 挂载子卷 cloud-atlas_build
   mount -t btrfs -o subvol=cloud-atlas_build /dev/nvme0n1p7 /home/huatai/docs/github.com/cloud-atlas/build

.. note::

   注意，首先需要将 ``Btrfs`` 根卷挂载到 ``/data`` 目录，这样才能在 ``/data`` 下面创建子卷 ``/data/cloud-atlas_build``

- 挂载后检查 ``df -h`` 可以看到::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   /dev/nvme0n1p7   47G  7.9G   39G  17% /data
   /dev/nvme0n1p7   47G  7.9G   39G  17% /data/docs/github.com/cloud-atlas/build

为了能够启动时自动挂载，需要在在 ``/etc/fstab`` 中创建子卷的对应配置，但是怎么指定设备文件呢？

请注意上文中 Btrfs 文件系统以及其下的子卷都是使用了相同的设备 ``/dev/nvme0n1p7`` ，所以在 ``/etc/fstab`` 中，子卷的设备文件其实和父卷是一样的，差别仅在挂载选项上:
   
.. literalinclude:: btrfs_subvolume/btrfs_subvolume_mount
   :language: bash
   :caption: 通过配置 /etc/fstab btrfs的子卷 cloud-atlas_build 实现btrfs子卷挂载

.. note::

   接下来就可以实践 :ref:`btrfs_nfs` 将上述 ``cloud-atlas_build`` 子卷通过NFS输出给 :ref:`kind` 集群使用构建一个简单的个人WEB网站

参考
======

- `Btrfs Getting started <https://btrfs.wiki.kernel.org/index.php/Getting_started>`_
