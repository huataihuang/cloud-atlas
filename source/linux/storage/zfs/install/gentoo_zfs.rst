.. _gentoo_zfs:

===================
Gentoo上运行ZFS
===================

安装
=======

`ZFSOnLinux项目 <https://zfsonlinux.org/>`_ 提供了out-of-tree Linux内核模块。从ZFS模块版本 0.6.1 开始，OpenZFS项目宣布将ZFS视为可以广泛用于桌面到超级计算机的生产部署。

- 安装ZFS:

.. literalinclude:: gentoo_zfs/install_zfs
   :caption: ``emerge`` 安装 zfs

.. warning::

   每次内核编译之后，都需要重新 emerge ``sys-fs/zfs-kmod`` ，即使内核修改是微不足道的。如果你在merge了内核模块之后重新编译内核，则可能会是的zpool进入不可终端的睡眠(也就是不能杀死的进程)或者直接crash。

- 在内核变更之后，执行以下命令重新 remerge zfs-kmod :

.. literalinclude:: gentoo_zfs/remerge_zfs-kmod
   :caption: 重新emerge zfs-kmod

输出信息类似:

.. literalinclude:: gentoo_zfs/remerge_zfs-kmod_output
   :caption: 重新emerge zfs-kmod
   :emphasize-lines: 5

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

Systemd
================

如果系统使用 :ref:`systemd` 则配置如下:

.. literalinclude:: gentoo_zfs/systemd_zfs
   :caption: 配置 systemd 设置ZFS服务

内核
=======

``sys-fs/zfs`` 需要内核支持 ``zlib`` :

.. literalinclude:: gentoo_zfs/zfs_kernel_zlib
   :caption: ``sys-fs/zfs`` 需要内核支持 ``zlib``

.. note::

   内核更改必须重新编译内核模块

   如果使用clang来编译 ``sys-fs/zfs-kmod`` 则必须使用 2.1.7 以上版本

安装内核模块(前面安装 zfs 已经包括):

.. literalinclude:: gentoo_zfs/install_zfs-kmod
   :caption: 安装 ``zfs-kmod``

如果使用 ``initramfs`` ，则需要在编译模块以后重新生成initramfs

- 如果服务器没有重启过，可能需要手工夹在 ``zfs`` 内核模块:

.. literalinclude:: gentoo_zfs/modprobe_zfs
   :caption: 手工加载zfs模块

使用
=========

- 磁盘分区:

这里的案例是 :ref:`install_gentoo_on_mbp` ，磁盘已经划分了 ``sda1`` (/boot) 和 ``sda2`` (/) ，现在将剩余空间都作为ZFS分区:

.. literalinclude:: gentoo_zfs/parted
   :caption: 使用 :ref:`parted` 创建 /dev/sda3 分区用于ZFS

划分好以后，最后输出的分区信息:

.. literalinclude:: gentoo_zfs/parted_output
   :caption: 使用 :ref:`parted` 创建 /dev/sda3 分区用于ZFS

- ( **仅供参考** ``请不要执行这步`` )如果是常规使用，通常可以使用类似 :ref:`zfs_startup_zcloud` 方法(注意那个案例使用的是整块sda磁盘，和这里的案例磁盘分区 ``/dev/sda3`` 不同，注意区别):

.. literalinclude:: ../admin/zfs_startup_zcloud/zpool_create
   :caption: 在磁盘 ``sda`` 上创建ZFS的存储池，名字为 ``zpool-data``

- 我在 :ref:`install_gentoo_on_mbp` 计划使用一个ZFS文件系统来作为 :ref:`docker_zfs_driver` (需要将整个 zpool 存储池挂载到独立的 ``/var/lib/docker/`` 目录) ，所以我实际创建名为 ``zpool-docker`` 存储池:

.. literalinclude:: gentoo_zfs/docker_zfs_driver
   :caption: 创建 :ref:`docker_zfs_driver` 存储池

完成以后检查 ``zpool list`` 可以看到新创建的 ``zpool-docker`` 存储池:

.. literalinclude:: gentoo_zfs/zpool-docker
   :caption: ``zpool list`` 输出显示新创建的 ``zpool-docker`` 存储池

再检查 ``zfs list`` 可以看到这个存储池 ``zpool-docker`` 被挂载到 ``/var/lib/docker`` (通过 ``df -h`` 也能看到):

.. literalinclude:: gentoo_zfs/zfs_list
   :caption: ``zfs list`` 输出显示 存储池 ``zpool-docker`` 被挂载到 ``/var/lib/docker``

一切就绪，现在可以执行 :ref:`gentoo_docker` 部署了

子卷配置
==========

我的 :ref:`mba13_mid_2013` 内置存储空间有限(128G)，所以我在 :ref:`install_gentoo_on_mbp` ( :ref:`mba13_mid_2013` )，为操作系统分配了很小的分区(20G):

.. literalinclude:: gentoo_zfs/parted_output
   :caption: 分配给 ``rootfs`` 的 ``/dev/sda2`` 只有20G
   :emphasize-lines: 9

虽然 ``rootfs`` 精简能够空出更多宝贵的磁盘空间给数据盘，但是Gentoo的编译需要很大的空间，特别是 :ref:`gentoo_kernel` 。所以我在上文的 ``zpool-docker`` 存储池中划分出一些子卷给特定的数据目录 -- 通过 :ref:`trace_disk_space_usage` 找到最消耗空间目录::

   /var/cache
   /var/tmp
   /usr/src

:ref:`gentoo_virtualization` ``libvirt`` ::

   /var/lib/libvirt

- 将需要迁移的目录先重命名(添加 ``.bak`` 后缀)，然后创建对应的 ZFS 子卷 指定 :ref:`zfs_mount` 到对应目录下，最后使用 ``tar`` 命令迁移数据，并清理掉无用数据释放空间:

.. literalinclude:: gentoo_zfs/migrate_rootfs_subdir_zfs
   :caption: 将系统中占用空间较大的目录迁移到 ZFS 子卷

参考
======

- `Gentoo Wiki: ZFS <https://wiki.gentoo.org/wiki/ZFS>`_
