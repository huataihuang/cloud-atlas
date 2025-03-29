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

- 使用 :ref:`parted` 工具对磁盘分区进行检查:

.. literalinclude:: gentoo_zfs_xcloud/parted_print
   :caption: ``parted`` 检查当前磁盘分区

输出显示:

.. literalinclude:: gentoo_zfs_xcloud/parted_print_output
   :caption: ``parted`` 检查当前磁盘分区显示分区3具备384G
   :emphasize-lines: 10

.. warning::

   磁盘分区操作是高危操作，务必提前备份，特别是已有多个分区在使用中，特别容易出现操作错误导致分区破坏。慎重!!!

- 磁盘分区: 删除掉第3分区(原先使用 :ref:`macos` 的diskutils工具调整磁盘后空出分区，并重建分区用于ZFS存储

.. literalinclude:: gentoo_zfs_xcloud/parted_delete_partiton3
   :caption: 删除分区3

此时分区3被删除，此时再次检查分区

.. literalinclude:: gentoo_zfs_xcloud/parted_print
   :caption: ``parted`` 检查当前磁盘分区

显示分区3已经消失了:

.. literalinclude:: gentoo_zfs_xcloud/parted_print_partition3_deleted
   :caption: ``parted`` 检查当前磁盘分区显示分区3已经被删除了

- 再次执行 :ref:`parted` 工具来完成分区创建，一定要确保分区位置不要覆盖现有使用分区:

.. literalinclude:: gentoo_zfs_xcloud/parted_create_partition3
   :caption: ``parted`` 创建分区3

怎么检查分区是否正确(大小和位置)，我使用 ``parted /dev/nvme0n1 print`` 和 ``fdisk -l /dev/nvme0n1`` 分别检查，可以看到分区3创建正确，没有出现分区错位问题:

.. literalinclude:: gentoo_zfs_xcloud/parted_print_partition3_created
   :caption: ``parted /dev/nvme0n1 print`` 输出显示重新创建的分区3
   :emphasize-lines: 10

.. literalinclude:: gentoo_zfs_xcloud/fdisk_partition3_created
   :caption: ``fdisk -l /dev/nvme0n1`` 显示重新创建的分区3，可以看到和之前记录完全一致分区
   :emphasize-lines: 12

ZFS文件系统构建
====================

我最终目标是在一个完整的底层host主机上构建3个ZFS存储池:

- ``zpool-data`` 数据存储池
- ``zpool-libvirt`` 用于 :ref:`libvirt_zfs_pool` (虽然不一定要用独立的ZFS pool，但是为了区分不混用，实际正式环境我还是独立设置一个zpool
- ``zpool-docker`` 用于 :ref:`docker_zfs_driver` : Docker需要直接使用存储池作ZFS后端驱动，并且要挂载到 ``/var/lib/docker`` 目录，这和 :ref:`libvirt` 不同， ``libvirt`` 可以使用多个存储，libvirt只需配置一个ZFS zpool作为libvirt的pool就可以(可以复用现有的ZFS存储池)

.. note::

   在非正式开发测试环境，我暂时合并 ``zpoool-data`` 和 ``zpoool-libvirt`` ，只使用 ``zpool-data`` : 本文的测试环境实践也是我后期在 :ref:`pi_5_nvme_zfs` 所采用的布局，以便能够在模拟测试环境中尽可能节约存储资源，同时满足模拟大规模集群架构

   不过这个合并方式对于运维比较容易混淆，所以后续我构建服务器的时候，将拆分开: 详见 :ref:`zfs_admin_prepare` 方案(针对实际生产环境构建了3个不同用途的zpool存储池)

.. note::

   根据文档和我的之前实践，我初步判断 :ref:`libvirt_zfs_pool` 对于zpool没有强制要求，所以实际上是可以复用 :ref:`docker_zfs_driver` 的zpool，甚至我的数据存储也可以在 docker zpool 下继续构建。由于是个人笔记本测试环境，我小心地构建了这个混用zpool存储(但不推荐)，后续我的服务器实践将改进为分离存储池

.. warning::

   这段是测试笔记本，使用了一个存储池 ``zpool-data`` ，挂载到 ``/var/lib/docker`` 目录(为了满足 :ref:`docker_zfs_driver` 要求，仅适合测试环境。生产环境压力大， :ref:`libvirt` 和 :ref:`docker` 同时操作共用存储池预计会发生冲突，影响性能和稳定性。

- 创建 ``zpool-data`` 存储池，默认挂载到 ``/var/lib/docker`` 目录(特例，为了满足 :ref:`docker_zfs_driver` :

.. literalinclude:: gentoo_zfs_xcloud/zpool
   :caption: 创建 ``zpool-data`` 存储池挂载到 ``/var/lib/docker`` 目录

完成后使用 ``df -h`` 检查分区挂载:

.. literalinclude:: gentoo_zfs_xcloud/df_output
   :caption: 使用 ``df -h`` 检查分区挂载
   :emphasize-lines: 8

存储就绪之后，则可以开始构建 :ref:`gentoo_virtualization` 以便运行一个多虚拟化的开发测试环境
