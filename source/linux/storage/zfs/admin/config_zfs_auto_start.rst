.. _config_zfs_auto_start:

============================
配置ZFS自动启动
============================

在完成 :ref:`docker_zfs_driver` 配置并使用之后，如果重启物理主机，你会惊讶地发现 ``docker.service`` 启动失败，原因是 ``/var/lib/docker`` 没有就绪。

手工启动zfs
===============

此时检查ZFS会发现 ``zpool`` 是空的:

.. literalinclude:: config_zfs_auto_start/zpool_list_zfs_list
   :language: bash
   :caption: zpool list/ zfs list 都输出空

- 检查 ``zpool import`` 可以看到存储池是就绪的(但是没有导入):

.. literalinclude:: config_zfs_auto_start/zpool_import_output
   :language: bash
   :caption: zpool import可以看到zpool-docker就绪但没有导入

- 手工导入:

.. literalinclude:: config_zfs_auto_start/zpool_import_zpool-docker
   :language: bash
   :caption: zpool import zpool-docker

此时再次检查就能够看到zfs文件系统已经挂载 ( ``df -h`` )::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   zpool-docker    102G  6.4G   95G   7% /var/lib/docker

并且 ``zfs list`` 可以看到所有该存储池下文件系统::

   NAME                                                                                 USED  AVAIL     REFER  MOUNTPOINT
   zpool-docker                                                                        8.04G  94.7G     6.34G  /var/lib/docker
   zpool-docker/03ebbb6554f2f15ee36cedacade890f080081631375a60e3796fd160e6788a6d        104K  94.7G     16.6M  legacy
   zpool-docker/09315a96dcbfbfbc33929960905fc09793bd731a7645cdc625d56079d1643545        112K  94.7G     16.6M  legacy
   ...

配置自动导入和启动ZFS
=========================

ZFS被其创建者视为"零管理"文件系统，所以配置ZFS非常简单，主要使用 ``zfs`` 和 ``zpool`` 命令

自动启动
------------

为了实现ZFS的"零管理":

- 必须启用 ``zfs-import-cache.service`` 以导入存储池(import pools): ``zfs-import-cache.service`` 是通过 ``/etc/zfs/zpool.cache`` 配置来导入ZFS存储池
- 必须启用 ``zfs-mount.service`` 以挂载存储池中可用的文件系统(这样就不需要使用 ``/etc/fstab`` 来挂载ZFS)

对于每个想要 **自动** 通过 ``zfs-import-cache.service`` 自动实现自动导入的存储池，可以执行如下命令::

   zpool set cachefile=/etc/zfs/zpool.cache <pool>

.. note::

   从 OpenZFS 0.6.5.8 版本开始，必须明确激活ZFS服务

   除了 ``zfs-mount.service`` 以外，也可以使用 ``zfs-mount-generator`` 来完成 ``zfs-import-cache.service`` 之后的zfs挂载，区别在于 ``zfs-mount.service`` 不能保证 ``/var`` 目录足够提前完成挂载，此时就需要使用 ``zfs-mount-generator`` 来替代实现

方法一: ``zfs-import-cache`` + ``zfs-mount``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 激活 ``zfs-import-cache`` + ``zfs-mount`` :

.. literalinclude:: config_zfs_auto_start/enable_zfs-import-cache_zfs-mount
   :language: bash
   :caption: 激活 zfs-import-cache 和 zfs-mount 确保启动时自动挂载ZFS

.. note::

   升级 :ref:`arch_linux` 系统可能启动时日志显示报错::

      [    0.879506 ] systemd[306]: /usr/lib/systemd/system-generators/zfs-mount-generator failed with exit status 127.                    

   启动后执行 ``zpool import`` 报错::

      zpool: error while loading shared libraries: libcrypto.so.1.1: cannot open shared object file: No such file or directory

   原因是系统默认安装最新版本的 ``openssl 3.0.7-2`` ，自动卸载了不需要的 ``openssl-1.1 1.1.1.s-2`` ，但是第三方安装需要这个库，所以单独安装::

      pacman -S openssl-1.1

   这样就不会再出现 ``zpool import`` 报lib库文件问题，启动日志也就不报错了。为避免后续升级 ``openssl-1.1`` 被自动清理，采用 :ref:`pacman` 的版本hold配置，也就是修订 ``/etc/pacman.conf`` 添加::

      IgnorePkg   = openssl-1.1

   不过，对于 ``/var`` 目录及其下子目录，挂载还是需要采用 ``zfs-mount-generator``

方法二: ``zfs-import-cache`` + ``zfs-mount-generator``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

对于 :ref:`docker_zfs_driver` ，ZFS存储池是位于 ``/var/lib/docker`` ，也就是 ``/var`` 子目录。如果采用上文 ``zfs-import-cache`` + ``zfs-mount`` 会发现启动还是没有自动挂载。

原因是 ``/var`` 目录需要在系统启动早期时挂载，此时 ``zfs`` 内核模块尚未加载。这就导致 ``zpool-docker`` 这个 ``zpool`` 导入失败。

对于上述问题，需要改为使用 ``zfs-mount-generator`` 替代 ``zfs-mount.service`` 来确保启动时创建好 ``systemd mount units`` ，这样 :ref:`systemd` 就会自动基于 ``mount units`` 完成文件系统挂载而无需使用 ``zfs-mount.service`` :

- 创建 ``/etc/zfs/zfs-list.cache`` 目录::

   mkdir /etc/zfs/zfs-list.cache

- 激活 ZFS Event Daemon(ZED) 脚本(称为 ZEDLET) 请求来创建一系列ZFS文件系统挂载列表(对于OpenZFS>=2.0.0这个链接是自动创建的)::

   ln -s /usr/lib/zfs/zed.d/history_event-zfs-list-cacher.sh /etc/zfs/zed.d

- 激活 ``zfs.target`` 和 ``zfs-zed.service`` 并启动 ``zfs-zed.service`` ::

   systemctl enable zfs-import-cache
   systemctl disable zfs-mount

   systemctl enable zfs.target
   systemctl enable zfs-zed.service
   systemctl start zfs-zed.service

- 在 ``/etc/zfs/zfs-lilst.cache`` 目录下创建存储池命名的空文件::

   touch /etc/zfs/zfs-list.cache/<pool-name>

- 检查 ``/etc/zfs/zfs-list.cache/<pool-name>`` 内容，如果这个文件是空的，则确保 ``zfs-zed.service`` 正在运行情况下，然后通过以下命令修改ZFS文件系统的 ``canmount`` 属性::

   zfs set canmount=off zroot/fs1

这个命令会导致ZFS的事件被ZED捕获，此时就会运行ZEDLET来更新 ``/etc/zfs/zfs-list.cache`` 目录下文件内容。如果此时检查了 ``/etc/zfs/zfs-list.cache/<pool-name>`` 有内容之后，再将文件系统重新设置 ``canmount`` 属性::

   zfs set canmount=on zroot/fs1

.. note::

   我这里没有采用设置 ``zpool/zpool-docker`` 的  ``canmount`` 属性开关，是因为我这时刚重启主机， ``zpool-docker`` 尚未自动导入。所以我采用了命令 ``zpool import zpool-docker`` 命令，也同样可以触发 ``ZED`` 自动更新 ``/etc/zfs/zfs-list.cache/zpool-docker`` 内容。anyway，只要有ZED事件发生就能触发更新。

- 完整的针对 ``zpool-docker`` zpool存储池的操作命令如下:

.. literalinclude:: config_zfs_auto_start/zfs-mount-generator_auto_start_zfs
   :language: bash
   :caption: 使用zfs-mount-generator自动启动ZFS

然后重新启动操作系统观察 ``/var/lib/docker`` 就是正常自动挂载的::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   zpool-docker    102G  6.8G   95G   7% /var/lib/docker

``couldn't start libzfs``
==============================

我在完成 ``zfs-import-cache`` + ``zfs-mount-generator`` 配置之后，确实启动之后自动导入 ``zpool/zpool-docker`` 并挂载好 ``/var/lib/docker`` ，但是我发现 ``dmesg -T`` 依然有一个ZFS相关报错::

   [Mon Nov 21 15:21:34 2022] zfs-mount-generator[322]: couldn't start libzfs, ignoring
   [Mon Nov 21 15:21:35 2022] ZFS: Loaded module v2.1.6-1, ZFS pool version 5000, ZFS filesystem version 5

暂时没有发现 ``zpool`` 和 ``zfs`` 问题，待查

参考
=======

- `arch linux: ZFS Configuration <https://wiki.archlinux.org/title/ZFS#Configuration>`_
