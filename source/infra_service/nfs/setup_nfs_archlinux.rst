.. _setup_nfs_archlinux:

=======================
arch linux配置NFS服务
=======================

Network File System (NFS)是1984年Sun Microsystems公司(唏嘘)开发的一种分布式文件系统协议，允许客户端用户访问在远程网络上共享的文件，就好像本地文件访问。

.. note::

   - NFS本身不提供加密，但可以采用 ``Kerberos`` 和 :ref:`linux_vpn` 加密协议来Tunnnel NFS
   - 和 :ref:`samba` 不同，NFS默认没有任何用户认证，客户端访问是通过IP地址和主机名限制来提供一定安全性
   - NFS在客户端和服务端采用相同的user/user group
   - NFS不支持POSIX ACLs

.. note::

   本文实践在 :ref:`asahi_linux` 上进行，实现 :ref:`btrfs_nfs`

安装NFS
========

- 在 :ref:`arch_linux` 上安装NFS支持软件包(只需要 ``nfs-utils`` ):

.. literalinclude:: setup_nfs_archlinux/pacman_install_nfs-utils
   :language: bash
   :caption: 在arch linux上安装nfs-utils支持NFS

.. note::

   强烈建议在客户端和服务端采用 :ref:`ntp` ，例如 :ref:`sync_time_by_chrony` 。如果所有节点没有精确的时钟，NFS会出现非预期的延迟。

配置
=======

NFS服务器的全局配置位于 ``/etc/nfs.conf`` ，对于简单配置使用无需修改。

NFS服务器需要一个 ``exports`` 列表来确定输出的文件系统，输出列表在 ``/etc/exports`` 或者 ``/etc/exports.d/*.exports`` 定义，这些共享配置称为 ``NFS root`` 。

.. note::

   为了能够提升NFS安全性，建议在不同的目录中定义 ``NFS root`` ，这样可以限制用户在指定的挂载点:

   - 使用NFS输出用户目录，建议每个用户输出一个 ``NFS root`` ，避免由于 ``uid/gid`` 匹配错误导致用户能够访问非授权的目录
   - 建议采用 :ref:`zfs_nfs` 或者 :ref:`btrfs_nfs` 这样的结合了卷管理的文件系统，方便灵活配置完全隔离的逻辑卷，能够安全地限制客户端访问
   - 也可以采用传统的 :ref:`linux_lvm` 结合 :ref:`xfs` ，同样采用LVM卷隔离文件系统，或者采用两者结合的 :ref:`stratis`

准备输出的服务器文件系统目录( :ref:`btrfs` )
----------------------------------------------

- 在 :ref:`btrfs_startup` 中采用 :ref:`parted` 划分磁盘:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_mobile_cloud/parted_nvme_btrfs
   :language: bash
   :caption: parted分区: 50G data, 48G docker, 216G libvirt

- 将磁盘分区7格式化成 :ref:`btrfs` :

.. literalinclude:: ../../linux/storage/btrfs/btrfs_startup/mkfs.btrfs_data
   :language: bash
   :caption: 在NVMe磁盘第7分区创建btrfs文件系统格式化

- 磁盘挂载:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_startup/mount_btrfs_data
   :language: bash
   :caption: 挂载Btrfs文件系统到/data目录(root卷)

此时 ``/data`` 目录挂载了 ``/dev/nvme0n1p7`` 磁盘分区，但这还不是我们输出的NFS文件目录。虽然我们可以直接指定这个 ``/data`` 目录下的子目录输出，但是 :ref:`btrfs` 的 ``subvolume`` 可以提供清晰的隔离，所以我在NFS输出 :ref:`btrfs` 目录采用了子卷功能:

- 在 ``/data`` 挂载卷下创建 ``cloud-atlas_build`` 子卷:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_subvolume/btrfs_subvolume_create
   :language: bash
   :caption: 在Btrfs文件/data挂载卷下创建子卷 cloud-atlas_build

- 在 ``/etc/fstab`` 配置 ``cloud-atlas_build`` 子卷的挂载项:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_subvolume/btrfs_subvolume_mount
   :language: bash
   :caption: 通过配置 /etc/fstab btrfs的子卷 cloud-atlas_build 实现btrfs子卷挂载

配置NFS输出(/etc/exports)
-------------------------------

- 对于 :ref:`docker` 容器访问，采用只读输出NFS卷，并且限制IP段为容器的网络段(注意，对于 :ref:`kind` 用户容器是 ``docker_in_docker`` 所以要通过 ``kubectl exec`` 进入用户容器检查网络段10.244.7)

.. literalinclude:: setup_nfs_archlinux/exports
   :language: bash
   :caption: NFS服务器/etc/exports设置输出

.. note::

   这里没有直接将 ``/data/docs/github.com/cloud-atlas/build`` 下的子目录 ``html`` 输出为NFS，因为这个目录会随着 :ref:`sphinx_doc` 的 ``make clean`` 命令删除，会导致NFS客户端挂载hang，所以只能输出稳定的不会删除的 ``cloud-atlas_build`` 子卷，也就是 ``/data/docs/github.com/cloud-atlas/build`` 目录。

- 修改 ``/etc/exports`` 配置后，需要执行以下命令重新输出NFS:

.. literalinclude:: setup_nfs_archlinux/exportfs
   :language: bash
   :caption: 修改/etc/exports配置后使用exportfs输出

启动NFS服务
--------------

- 启动并激活 ``nfs-server.service`` :

.. literalinclude:: setup_nfs_archlinux/nfs-server.service
   :language: bash
   :caption: 启动并激活nfs-server.service

NFS客户端
==========



参考
======

- `arch linux: NFS <https://wiki.archlinux.org/title/NFS>`_
