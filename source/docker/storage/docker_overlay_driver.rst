.. _docker_overlay_driver:

============================
Docker OverlayFS存储引擎
============================

OverlayFS是一个类似AUFS的现代化联合文件系统，但是速度更快并且实现更为简单。Docker提供了两种OverlayFS存储驱动：早期的 ``overlay`` 以及较新的更为稳定的 ``overlay2`` 。

在Linux内核驱动中，称为 ``OverlayFS`` ，在 Docker 存储驱动则称之为 ``overlay`` 或 ``overlay2`` 。

..note::

   如果使用OverlayFS，请使用 ``overlay2`` 而不是 ``overlay`` ，因为 ``overlay2`` 在inode使用上效率更高。为了使用较新的 ``overlay2`` 驱动，你需要Linux内核 4.0 或更高版本，或者在RHEL/CentOS中使用内核 ``3.10.0-514`` 以上版本。详细的 ``overlay`` 和 ``overlay2`` 区别，请参考 :ref:`docker_storage_driver` 。

系统要求
============

系统必须满足以下要求才能够支持OverlayFS:

- Docker Engine-Community (Docker-CE) 和 Docker EE 17.06.02-ee5及以上版本支持 ``overlay2`` 存储引擎，并且 ``overlay2`` 也是推荐的存储引擎。

- Linux内核版本 4.0以上或者 RHEL/CentOS 3.10.0-514 以上内核才支持 ``overlay2`` ，如果是早期版本内核，则只能使用 ``overlay`` 引擎(不推荐)。

- ``overlay`` 和 ``overlay2`` 存储引擎支持 ``xfs`` 文件系统，但是 ``xfs`` 文件系统必须激活 ``d_type=true``

请使用 ``xfs_info`` 来校验文件系统选项是否已经设置了 ``ftype`` 选项为 ``1`` 。如果没有激活 ``d_type=true`` ，则必须重新格式化xfs文件系统，格式化时候使用参数 ``-n ftype=1`` 。实践案例参考 :ref:`xfs`

使用 ``xfs_info /var/lib/docker`` 显示输出::

   ...
   naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
   ...

.. warning::

   没有启用 ``d_type`` 的XFS文件系统会导致Docker不能使用 ``overlay`` 或 ``overlay2`` 驱动。已经安装的Docker虽然可以运行但是会报错，这样至少能够允许用户迁移数据。但是未来版本，Docker将拒绝启动。

- 修改现有容器和镜像的存储引擎可能会导致不可访问。所以在修改 :ref:`docker_storage_driver` 之前，应该使用 ``docker save`` 命令将镜像存储或推送到镜像仓库中，以应对异常问题。

配置Overlay
=============

强烈建议使用 ``overlay2`` 存储引擎(内核4.0或以上版本)，如果内核不满足要求(例如内核版本低于4.0但高于3.18)则使用 ``overlay`` 存储引擎。

以下为切换存储引擎overlay2方法：

- 停止 Docker::

   sudo systemctl stop docker

- 备份 ``/var/lib/docker`` 内容::

   cp -au /var/lib/docker /var/lib/docker.bk

- 如果需要，重新挂载 ``/var/lib/docker`` 目录到新的磁盘

- 修改 ``/etc/docker/daemon.json`` 添加以下内容::

   {
     "storage-driver": "overlay2"
   }

- 启动Docker::

   sudo systemctl start docker

- 检查storage driver::

   sudo docker info

显示输出::

    Storage Driver: overlay2
      Backing Filesystem: xfs
      Supports d_type: true
      Native Overlay Diff: false

.. note::

   ``Native Overlay Diff: false`` 表明

``overlay2`` 驱动工作原理
==========================

OverlayFS在单个Linux主机上将两个目录表现为一个单一目录。这些目录被成为 ``层`` 并且统一的进程将它作为一个 ``统一挂载`` 。OverlayFS将较低层的目录称为 ``lowerdir`` 而较高层的目录称为 ``upperdir`` 。这个统一视图是通过称为 ``merged`` 的自有目录输出的。

``overlay2`` 原生最多支持 128 层OverlayFS文件层。这个能力使得和文件层相关的Docker命令，例如 ``docker build`` 和 ``docker commit`` ，获得较高的性能，并且消耗较少的后端文件系统inode。



参考
=========

- `Use the OverlayFS storage driver <https://docs.docker.com/storage/storagedriver/overlayfs-driver/>`_
