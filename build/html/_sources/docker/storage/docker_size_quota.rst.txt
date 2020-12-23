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

- 格式化EXT4文件系统则需要传递参数来激活prjquota::

   mkfs.ext4 -O quota<Plug>PeepOpenroject /dev/sdb
   mount -o prjquota /dev/sdb /var/lib/docker

- 或者修改 ``/etc/fstab`` 配置::

   /dev/sdb /var/lib/docker ext4 defaults,quota,prjquota,pquota,gquota 0 0

参考
=====

- `Docker Container Size Quota <https://reece.tech/posts/docker-container-size-quota/>`_
- `Restricting the Rootfs Storage Space of a Container <https://openeuler.org/en/docs/20.03_LTS/docs/Container/container-resource-management.html#restricting-the-rootfs-storage-space-of-a-container>`_
