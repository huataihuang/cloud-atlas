.. _docker_btrfs:

=========================
Docker btrfs 存储驱动
=========================

btrfs是现代化的 ``copy-on-write`` 文件系统，支持很多高级技术，非常适合用于Docker。并且btrfs已经进入Linux内核主线。

Docker的 ``btrfs`` 存储驱动使用了很多btrfs的功能用于镜像和容器管理。功能包括块级别操作，thin provisioning，copy-on-write快照，并且易于管理。

准备工作
===========

``btrfs`` 支持需要满足以下条件：

- ``Docker CE`` : 对于docker ce， btrfs 仅在 Ubuntu 和 Debian 下才建议使用
- ``Docker EE`` : 对于Docker EE 和 CS-Engine，仅在SLES下才支持 ``btrfs`` 。请参考 `Product compatibility matrix <https://success.docker.com/Policies/Compatibility_Matrix>`_ 获取所有商业支持Docker支持的配置
- 注意：修改存储驱动会导致已经在本地文件系统上创建的容器不可访问。 请使用 ``docker save`` 先保存容器，并将镜像推送到Docker Hub或私有仓库，在修改存储驱动之后才能恢复回来。
- ``btrfs`` 需要使用一个独立的块存储设备，例如物理磁盘。并且被格式化成btrfs，然后挂载到 ``/var/lib/docker/`` 目录。配置指令会指导你过程。默认情况下，SLES的根文件系统已经格式化成BTRFS，所以对于SLES，不需要使用独立的快设备文件，但是你选择独立块设备可以提高性能。
- ``btrfs`` 已经得到内核支持，可以通过以下命令验证::

   $ sudo cat /proc/filesystems | grep btrfs
           btrfs

- 为了能够在操作系统级别管理BTRFS文件系统，需要 ``btrfs`` 命令，则需要安装 ``btrfsprogs`` 软件包(SLES)或 ``btrfs-tools`` 软件包(Ubuntu)。

磁盘块设备(分区)准备
==============================

在 :ref:`btrfs_in_studio` 准备工作中，我们已经通过 ``parted`` 工具划分了 ``/dev/sda3`` 给btrfs使用::

   parted -a optimal
   mkpart primary 51.4GB 251GB   #注意分区不可重叠，这里划分了200G
   name 3 docker
   print

上述指令完成后最后print输出分区空间如下::

   Number  Start   End     Size    File system  Name     Flags
   ...
   3      51.4GB  251GB   200GB                docker

.. _configure_docker_btrfs:

配置Docker使用btrfs存储驱动
================================

- 停止Docker::

   systemctl stop docker

- 备份 ``/var/lib/docker`` 目录内容，并清空该目录::

   sudo cp -au /var/lib/docker /var/lib/docker.bk
   sudo rm -rf /var/lib/docker/*

- 格式化目标块设备成为 ``btrfs`` 文件系统::

   sudo mkfs.btrfs -f /dev/sda3

- 在 ``/etc/fstab`` 中添加以下配置::

   /dev/sda3    /var/lib/docker    btrfs    defaults,compress=zstd   0    1

- 然后挂载btrfs文件系统::

   sudo mount /var/lib/docker

- 检查挂载::

   mount | grep sda3

输出显示::

   /dev/sda3 on /var/lib/docker type btrfs (rw,relatime,compress=zstd,ssd,space_cache,subvolid=5,subvol=/)

- 将 ``/var/lib/docker.bk`` 内容恢复回 ``/var/lib/docker/`` ::

   sudo cp -au /var/lib/docker.bk/* /var/lib/docker/

- 配置 Docker 使用 ``btrfs`` 存储驱动：编辑或创建文件 ``/etc/docker/daemon.json`` 添加以下内容（注意，如果已经有该文件，则只需要增加 ``{ }`` 内的键值::

   {
     "storage-driver": "btrfs"
   }

.. note::

   实际上述设置 ``/etc/docker/daemon.json`` 请参考 :ref:`minikube_debug_cri_install` 排查过程，按照 :ref:`install_docker_in_studio` 设置如下::

      {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "100m"
        },
        "storage-driver": "btrfs"
      }

- 启动 docker ，然后执行 ``docker info`` 检查 ``btrfs`` 是否已经用作存储驱动::

   sudo systemctl start docker

   docker info

输出显示::

   ...
   Storage Driver: btrfs
    Build Version: Btrfs v4.7.3
    Library Version: 101
   ...

- 确保没有问题之后，删除 ``/var/lib/docker.bk`` 目录

管理btrfs卷
=============

``btrfs`` 的优点是易于管理，不需要卸载文件系统或者重启docker就可以维护。

例如，当磁盘空间不足时，btrfs会自动按照1GB空间自动扩展卷。

要将一个块设备加入到 ``btrfs`` 卷，使用命令 ``btrfs device add`` 和 ``btrfs filesystem balance`` 命令::

   sudo btrfs device add /dev/sda4 /var/lib/docker
   sudo btrfs filesystem balance /var/lib/docker

``btrfs`` 存储驱动工作原理
============================


参考
=======

- `Use the BTRFS storage driver <https://docs.docker.com/storage/storagedriver/btrfs-driver/>`_
