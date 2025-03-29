.. _docker_btrfs_driver:

=========================
Docker btrfs 存储驱动
=========================

btrfs是现代化的 ``copy-on-write`` 文件系统，支持很多高级技术，非常适合用于Docker。并且btrfs已经进入Linux内核主线。

Docker的 ``btrfs`` 存储驱动使用了很多btrfs的功能用于镜像和容器管理。功能包括块级别操作，thin provisioning，copy-on-write快照，并且易于管理。

准备工作
===========

``btrfs`` 支持需要满足以下条件：

- ``Docker CE`` : 对于docker ce， ``btrfs 仅在 Ubuntu 和 Debian 下才建议使用``
- ``Docker EE`` : 对于Docker EE 和 CS-Engine，仅在SLES下才支持 ``btrfs`` 。请参考 `Product compatibility matrix <https://success.docker.com/Policies/Compatibility_Matrix>`_ 获取所有商业支持Docker支持的配置
- 注意：修改存储驱动会导致已经在本地文件系统上创建的容器不可访问。 请使用 ``docker save`` 先保存容器，并将镜像推送到Docker Hub或私有仓库，在修改存储驱动之后才能恢复回来。
- ``btrfs`` 需要使用一个独立的块存储设备，例如物理磁盘。并且被格式化成btrfs，然后挂载到 ``/var/lib/docker/`` 目录。配置指令会指导你过程。默认情况下，SLES的根文件系统已经格式化成BTRFS，所以对于SLES，不需要使用独立的快设备文件，但是你选择独立块设备可以提高性能。
- ``btrfs`` 已经得到内核支持，可以通过以下命令验证::

   $ sudo cat /proc/filesystems | grep btrfs
           btrfs

- 为了能够在操作系统级别管理BTRFS文件系统，需要 ``btrfs`` 命令，则需要安装 ``btrfsprogs`` 软件包(SLES)或 ``btrfs-tools`` 软件包(Ubuntu)。

.. note::

   Btrfs的配置和优化比较复杂，请参考 :ref:`tune_btrfs` 以及 :ref:`rockstor` 

磁盘块设备(分区)准备
==============================

在 :ref:`btrfs_in_studio` 准备工作中，我们已经通过 ``parted`` 工具划分了 ``/dev/sda3`` 给btrfs使用::

   parted -a optimal /dev/sda

- 打印当前状态 ``print`` ::

   (parted) print
   Model: ATA INTEL SSDSC2KW51 (scsi)
   Disk /dev/sda: 512GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  538MB   537MB   fat32              boot, esp
    2      538MB   34.9GB  34.4GB  ext4

- 创建 200G 空间::

   mkpart primary 34.9GB 235GB   #注意分区不可重叠，这里划分了200G

- 重命名为 ``docker`` 分区名::

   name 3 docker
   print

上述指令完成后最后print输出分区空间如下::

   Number  Start   End     Size    File system  Name     Flags
   ...
   3      34.9GB  235GB   200GB                docker

.. _configure_docker_btrfs:

配置Docker使用btrfs存储驱动
================================

- 停止Docker::

   systemctl stop docker.socket
   systemctl stop docker

- 备份 ``/var/lib/docker`` 目录内容，并清空该目录::

   sudo cp -au /var/lib/docker /var/lib/docker.bk
   sudo rm -rf /var/lib/docker/*

- 格式化目标块设备成为 ``btrfs`` 文件系统::

   sudo mkfs.btrfs -f -L docker /dev/sda3

提示信息::

   btrfs-progs v5.4.1
   See http://btrfs.wiki.kernel.org for more information.
   
   Detected a SSD, turning off metadata duplication.  Mkfs with -m dup if you want to force metadata duplication.
   Label:              docker
   UUID:               d80f2f08-3b50-4b19-a0eb-058fb47693b0
   Node size:          16384
   Sector size:        4096
   Filesystem size:    186.36GiB
   Block group profiles:
     Data:             single            8.00MiB
     Metadata:         single            8.00MiB
     System:           single            4.00MiB
   SSD detected:       yes
   Incompat features:  extref, skinny-metadata
   Checksum:           crc32c
   Number of devices:  1
   Devices:
      ID        SIZE  PATH
       1   186.36GiB  /dev/sda3

- 在 ``/etc/fstab`` 中添加以下配置::

   #/dev/sda3    /var/lib/docker    btrfs    defaults,compress=zstd   0    1
   /dev/disk/by-uuid/d80f2f08-3b50-4b19-a0eb-058fb47693b0    /var/lib/docker   btrfs    defaults,compress=lzo   0    1

.. warning::

   在2019年的实践中，我Btrfs挂载启用了 ``zstd`` 压缩，但是感觉这个参数可能导致了 ``csum failed`` 进而系统负载过高hang住。所以，上述参数请谨慎使用，并做严格测试验证。

   2021年10月，我再次部署时参考 :ref:`tune_btrfs` 尝试采用 lzo 压缩算法，根据官方FAQ，这种压缩算法压缩率较高且快速。不过，还需要研究和实践

- 然后挂载btrfs文件系统::

   sudo mount /var/lib/docker

- 检查挂载::

   mount | grep sda3

输出显示::

   /dev/sda3 on /var/lib/docker type btrfs (rw,relatime,compress=lzo,ssd,space_cache,subvolid=5,subvol=/)

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
    Build Version: Btrfs v5.4.1
    Library Version: 102
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
