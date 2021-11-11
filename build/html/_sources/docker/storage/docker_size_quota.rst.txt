.. _docker_size_quota:

=====================
Docker容器规格Quota
=====================

通常 ``/var/lib/docker`` 文件系统采用一个独立的分区比较合适，可以通过文件系统的Quota来限制Docker容器规格。Docker size Quota建议使用XFS的quota属性实现，不过，现在ext4文件系统也扩展成能够支持quota，所以两者都可以使用 ``overlay`` 作为存储引擎来限制容器规格。推荐使用XFS结合 ``overlay2`` 来实现 project quotas。

XFS实现prjquota
=================

- 格式化XFS::

   mkfs.xfs /dev/sdb

- 挂载配置 ``/etc/fstab`` ::

   /dev/sdb /var/lib/docker xfs defaults,quota,prjquota,pquota,gquota 0 0

- 修订 ``/etc/systemd/system/docker.service.d/override.conf`` ::

   ExecStart=/usr/bin/dockerd --storage-driver=overlay2 --exec-opt native.cgroupdriver=systemd --log-driver=journald --storage-opt overlay2.override_kernel_check=true --storage-opt overlay2.size=10G

参数解读:

  - ``--storage-opt overlay2.override_kernel_check=true`` 是激活磁盘quota校验，是size quota生效的关键
  - ``--storage-opt overlay2.size=10G`` 是可选默认配置，在容器启动时可以覆盖这个配置。

EXT4实现prjquota
===================

在 EXT4文件系统之上使用 :ref:`docker_overlay_driver` 也可以实现容器的文件系统quota。这个功能是通过EXT4文件系统的 ``project quota`` 功能实现的。如果内核支持这个功能，需要使用 ``SYS_IOCTL`` syscall 来设置目录的project ID，然后使用 ``SYS_QUOTACTL`` 对对应的 ``project ID`` 设置hard limit和soft limit。

- 确保文件系统支持 ``Project ID`` 和 ``Project Quota`` 属性的环境要求:

  - 内核需要 ``4.19`` 或更高版本
  - ``e2fsprogs`` 需要 ``1.43.4-2`` 或更高版本

- 在挂载overlayfs到容器前，首先需要不同容器的上一级目录和自身工作目录使用不同的 ``Project ID`` 并设置 ``inheritance`` 选项。一旦overlayfs被挂载到容器，这个 ``Project ID`` 和继承属性不能修改

- 在容器外使用特权用户账号身份设置quota

- 在启动docker服务时使用以下配置参数::

   -s overlay2 --storage-opt overlay2.override_kernel_check=true

- Docker服务支持以下选项来设置容器的默认quota::

   –storage-opt overlay2.basesize=128M

如果 ``-storage-opt size`` 也传递了参数，则该参数优先级更高(生效)。如果Docker服务没有设置默认quota，并且运行容器时也没有传递 ``-storage-opt size`` 参数，则容器quota没有限制。

- 格式化EXT4文件系统则需要传递参数来激活prjquota::

   mkfs.ext4 -O quota,project /dev/sdb
   mount -o prjquota /dev/sdb /var/lib/docker

- 或者修改 ``/etc/fstab`` 配置::

   /dev/sdb /var/lib/docker ext4 defaults,quota,prjquota,pquota,gquota 0 0

参考
=====

- `Docker Container Size Quota <https://reece.tech/posts/docker-container-size-quota/>`_
- `Restricting the Rootfs Storage Space of a Container <https://docs.openeuler.org/en/docs/20.03_LTS/docs/Container/container-resource-management.html#restricting-the-rootfs-storage-space-of-a-container>`_
