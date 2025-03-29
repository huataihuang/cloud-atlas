.. _zfs_startup:

===================
ZFS快速起步
===================

我在近期的ZFS实践大多数是围绕虚拟化和容器技术展开的:

- :ref:`libvirt_zfs_pool`
- :ref:`docker_zfs_driver`

实际上对ZFS操作较少

不过，在 :ref:`mobile_cloud_x86_zfs` 将磁盘大部分构建提供给 :ref:`docker_zfs_driver` 存储池 ``zpool-data`` 之后，我希望将这个存储池中部分空间用于数据存储。毕竟要充分利用有限的磁盘空间，采用完整的大ZFS存储池可以得到较高的利用率。

- 当前存储使用情况::

   # zpool list
   NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
   zpool-data   888G   877M   887G        -         -     0%     0%  1.00x    ONLINE  -

   # zfs list
   NAME                                                                               USED  AVAIL     REFER  MOUNTPOINT
   zpool-data                                                                         877M   860G     1.77M  /var/lib/docker
   zpool-data/0e7zhf1ohmfdfgqnsq1gy0b7n                                                62K   860G     43.0M  legacy
   zpool-data/2u92kzautzwoc6qrp9keufrqa                                              41.5K   860G     43.1M  legacy
   zpool-data/44045b17230cf2c63a9c3099a48d546f8d7eb301a4bb9f62bbb675746b59f5b4         42K   860G     11.0M  legacy
   ... 容器占用

- 准备在 ``zpool-data`` 下构建一个 ``home`` 卷，挂载到 ``/home`` 目录，这样大多数数据都能够得到有效保存

- 首先以 ``root`` 身份登陆，并确保 ``/home`` 目录没有用户访问，将 ``/home`` 目录重命名:

.. literalinclude:: zfs_startup/rename_home
   :language: bash
   :caption: 将/home目录重命名(备份)

- 由于 ``zpool-data`` 存储池已经在 :ref:`mobile_cloud_x86_zfs` 构建好，所以忽略创建 ZFS 存储池步骤，直接创建卷 ``home`` ，并且创建 ``home`` 卷下面的子(用户目录):

.. literalinclude:: zfs_startup/zfs_create_volume
   :language: bash
   :caption: 创建 zpool-data 存储池的 home 卷

对于存储池下创建的 ``根`` 卷，需要指定挂载目录；对于 ``根`` 卷下的子卷，可以不指定挂载目录，则会自动按照层次结构进行独立卷挂载，非常巧妙的管理模式

- 完成后使用 ``df -h`` 检查可以看到当前ZFS存储挂载目录:

.. literalinclude:: zfs_startup/zfs_df_hierarchy
   :language: bash
   :caption: 创建 zpool-data 存储池的 home 卷以及子卷的挂载情况

- 卷和子卷会从上一级ZFS继承属性，由于在 :ref:`mobile_cloud_x86_zfs` 已经配置了 ``zpool-data`` 压缩属性，所以使用 ``zfs get compression`` 可以看到卷和子卷都继承了压缩属性::

   # zfs get compression zpool-data/home
   NAME             PROPERTY     VALUE           SOURCE
   zpool-data/home  compression  lz4             inherited from zpool-data
   
   # zfs get compression zpool-data/home/huatai
   NAME                    PROPERTY     VALUE           SOURCE
   zpool-data/home/huatai  compression  lz4             inherited from zpool-data

- 可以设置卷的quota，例如::

   zfs set quota=10G zpool-data/home/huatai

- 恢复 ``/home/huatai`` 目录数据:

.. literalinclude:: zfs_startup/restore_home_huatai
   :language: bash
   :caption: 恢复/home/huatai目录数据

参考
======

- `Oracle Solaris ZFS Administration Guide  > Chapter 2 Getting Started With Oracle Solaris ZFS <https://docs.oracle.com/cd/E19253-01/819-5461/setup-1/index.html>`_
