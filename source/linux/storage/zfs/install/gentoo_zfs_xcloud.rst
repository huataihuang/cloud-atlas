.. _gentoo_zfs_xcloud:

=======================
Gentoo上运行ZFS(xcloud)
=======================

我在重新构建的xcloud比基本上，重新构建了基于 :ref:`gentoo_linux` 的 :ref:`mobile_cloud_infra` :

- 采用 :ref:`macos` 和 :ref:`gentoo_linux` 双启动，通过macOS的disk utility对磁盘进行重新分区，空出部分磁盘分区给Linux使用
- 由于不是一次性完成磁盘划分，而且我需要分阶段缩减macOS磁盘空间，所以为Getoo Linux提供的存储磁盘分区也是不断增加的

当前状态
===============

- 使用 ``fdisk -l`` 检查当前磁盘分区，其中分区4是我最初安装 Gentoo Linux 的系统分区，分区3则是我刚刚从macOS中调整分区获得的空白分区，也就是准备用于ZFS存储的分区

.. literalinclude:: gentoo_zfs_xcloud/fdisk
   :caption: 分区3将用于ZFS系统
   :emphasize-lines: 12

安装
===========

- 和 :ref:`gentoo_zfs` 实践相同，首先安装OpenZFS提供的ZFS软件:

.. literalinclude:: gentoo_zfs/install_zfs
   :caption: 在Gentoo中安装zfs

.. warning::
   每次内核编译之后，都需要重新 emerge ``sys-fs/zfs-kmod`` ，即使内核修改是微不足道的。如果你在merge了内核模块之后重新编译内核，则可能会是的zpool进入不可中断的睡眠(也就是不能杀死的进程)或者直接crash。

- 每次内核变更(例如 :ref:`upgrade_gentoo` ，执行以下命令 remerge zfs-kmod :

.. literalinclude:: gentoo_zfs/remerge_zfs-kmod
   :caption: 重新emerge zfs-kmod

ZFS Event Daemon通知
=====================

ZED(ZFS Event Daemon)监控ZFS内核模块产生的事件: 当一个 ``zevent`` (ZFS Event)发出是，ZED将为对应的zevent分类运行一个 ``ZEDLETs`` (ZFS Event Daemon Linkage for Executable Tasks)。

- 配置 ``/etc/zfs/zed.d/zed.rc`` :

.. literalinclude:: gentoo_zfs/zed.rc
   :caption: ``/etc/zfs/zed.d/zed.rc`` 配置案例，激活通知邮件地址以及定期发送pool健康通知

OpenRC
=============

- 配置 openrc 设置ZFS在操作系统启动时启动:

.. literalinclude:: gentoo_zfs/openrc_zfs
   :caption: 配置 openrc 设置ZFS服务

.. note::

   - 多数情况下只需要配置 zfs-import 和 zfs-mount
   - zfs-share 是提供NFS共享
   - zfs-zed 是ZFS Event Daemon用于处理磁盘hotspares替换以及故障的电子邮件通知

.. note::

   我的gentoo实践中没有使用 :ref:`systemd` ，而是采用轻量级 :ref:`openrc`

内核
=======

目前尚未定制内核，待后续实践...

使用
=========

- 磁盘分区:

