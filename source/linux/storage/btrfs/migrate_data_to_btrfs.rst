.. _migrate_data_to_btrfs:

=====================
迁移数据到Btrfs存储
=====================

在 :ref:`upgrade_ubuntu_20.04_to_22.04` 之前，需要清理出足够空间用于系统升级。原先在根目录只保留了32G空间，日常累积下来可用空间很小。

准备工作
============

首先采用 :ref:`trace_disk_space_usage` 找出存储较多的磁盘目录::

   du -Sh --exclude=./var/lib/docker | sort -rh | head -5

.. note::

   ``/var/lib/docker`` 是 :ref:`btrfs_in_studio` 独立的Btrfs挂载磁盘分区，用于 :ref:`docker_btrfs_driver` ，所以跳过检查。

输出::

   8.6G ./var/lib/libvirt/images
   7.4G .
   832M ./home/huatai/github.com
   817M ./var/log/journal/63189bc6f6c149598d5bef3afa0cbf40
   714M ./usr/bin

这里:

- ``/var/lib/libvirt/images`` 是 :ref:`libvirt` 镜像目录。不过，我采用了 :ref:`libvirt_lvm_pool` ，所有本地存储镜像都存放在 :ref:`linux_lvm` ，所以这个目录下文件只有一些安装 ``.iso`` 光盘镜像，可以直接迁移走
- ``/`` 目录下占用 ``7.4G`` 是之前配置的swap文件，日常实际用不上，所以关闭swap，释放空间
- ``/home/huatai/github.com`` 是一些代码仓库，无需本地存储
- ``/var/log/journal/63189bc6f6c149598d5bef3afa0cbf40`` 是 :ref:`journalctl` 管理系统日志，可以通过 ``journalctl --vacuum-size=50M`` 将以往日志清理掉

一切就绪，就可以开始 Btrfs 的独立卷创建和数据迁移了。完成后，即开始 :ref:`upgrade_ubuntu_20.04_to_22.04` 。
