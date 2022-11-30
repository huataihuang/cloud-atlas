.. _btrfs_startup:

=================
Btrfs快速起步
=================

Btrfs的一些提示
==================

根据官方 `Btrfs Getting started <https://btrfs.wiki.kernel.org/index.php/Getting_started>`_ 提示如下:

- Btrfs是一个快速迭代的文件系统，和内核版本紧密结合(位于内核主线)，每次内核版本升级都有很多错误修复和增强功能(也意味着Btrfs稳定性是一个巨大的考验)
- 建议使用支持Btrfs的Linux发行版(例如 :ref:`suse_linux` 企业版从SLES11 SP2就开始支持 )或者运行最新的内核 - 发行版支持的优势是会将最新内核补丁移植到早期版本，所以可以兼顾兼容性和稳定性
- 不建议运行内核比kernel.org提供的最新版本落后两个或更多版本
- 建议使用最新的用户空间工具，可以用于调试和恢复文件系统

.. note::

   Btrfs长期被视为试验阶段，不过核心功能被认为是足够稳定满足日常需要。所以务必关注官方的发布说明和搜集各方实验数据进行对比和验证。

创建文件系统
===============

- 分区: 采用 :ref:`parted` 工具 - 按照 :ref:`btrfs_mobile_cloud` 进行磁盘分区划分

.. literalinclude:: btrfs_mobile_cloud/parted_nvme_btrfs
   :language: bash
   :caption: parted分区: 50G data, 48G docker, 216G libvirt

.. note::

   本文在 ``btrfs-data`` 分区上操作，实践如何对数据分区进行常规的 ``Btrfs`` 操纵:

   .. literalinclude:: btrfs_mobile_cloud/parted_nvme_print
      :language: bash
      :caption: parted分区输出
      :emphasize-lines: 14

- 对磁盘(例如 ``/dev/sdb`` )或者磁盘分区(例如，我这里的实际案例 ``/dev/nvme0n1p7`` ):

.. literalinclude:: btrfs_startup/mkfs.btrfs_data
   :language: bash
   :caption: 在NVMe磁盘第7分区创建btrfs文件系统格式化

.. note::

   ``Btrfs`` 也支持类似 :ref:`zfs` 的内置RAID功能，目前支持 ``RAID 0, RAID 1, RAID 10, RAID 5 and RAID 6`` :ref:`btrfs_multiple_devices`

- 磁盘挂载(磁盘UUID使用 ``blkid`` 工具查看):

.. literalinclude:: btrfs_startup/mount_btrfs_data
   :language: bash
   :caption: 挂载Btrfs文件系统到/data目录(root卷)

- 完成后文件系统目录挂载如下( ``/data`` 目录挂载后我迁移了 ``docs`` 目录到btrfs的 ``/data`` 目录下 )::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   /dev/nvme0n1p7   47G  7.9G   39G  17% /data
   ...

命令
=======

``btrfs`` 命令是管理 ``Btrfs`` 文件系统的控制程序，大多数操作，如创建快照，创建子卷以及扫描设备都可以使用该命令。

- 扫描设备: 可以检查所有btrfs文件系统的设备，或者指定分区::

   btrfs device scan
   btrfs device scan /dev/nvme0n1p7

子卷
-----

- 创建子卷: 这里创建一个 ``cloud-atlas_build`` 子卷，用于输出我的 :ref:`sphinx_doc` 编译输出目录::

   # 先清理掉 build 目录下文件: make clean
   rm -rf /home/huatai/docs/github.com/cloud-atlas/build/*

在 ``/data`` 挂载卷下创建 ``cloud-atlas_build`` 子卷:

.. literalinclude:: btrfs_startup/btrfs_subvolume_create
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
   
.. literalinclude:: btrfs_startup/btrfs_subvolume_mount
   :language: bash
   :caption: 通过配置 /etc/fstab btrfs的子卷 cloud-atlas_build 实现btrfs子卷挂载

.. note::

   接下来就可以实践 :ref:`btrfs_nfs` 将上述 ``cloud-atlas_build`` 子卷通过NFS输出给 :ref:`kind` 集群使用构建一个简单的个人WEB网站

快照
========

快照是为了避免数据被误删除的本地备份: 举例，上述 ``/data`` 数据卷，需要定时每天做一次快照::

   btrfs subvolume snapshot /data /data/data_snapshot_`date +%Y_%m_%d_%H:%M:%S`

提示信息::

   Create a snapshot of '/data' in '/data/data_snapshot_2022_11_30_00:17:57'

- 如果需要恢复数据::

   mkdir -p /snapshot/data_snapshot_2022_11_30_00:17:57
   mount -t btrfs -o subvol=data_snapshot_2022_11_30_00:17:57 /dev/nvme0n1p7 /snapshot/data_snapshot_2022_11_30_00:17:57

此时就可以到快照目录下去找数据进行恢复(如果你不幸误删除了某些重要数据)

.. note::

   你可以写一个简单的每日快照脚本，只要在快照前记录下时间戳，并且快照名是按照时间戳来命名的，就很容易恢复到某个快照备份数据。

参考
======

- `Btrfs Getting started <https://btrfs.wiki.kernel.org/index.php/Getting_started>`_
