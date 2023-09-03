.. _zfs_startup_zcloud:

===================
ZFS快速起步(zcloud)
===================

:ref:`zfs_startup` 是我在 :ref:`docker_zfs_driver` 基础上完成的进一步卷管理。不算完整操作。

现在为了 :ref:`install_kubeflow_single_command` 准备 :ref:`zfs_nfs` ，则是完整的 :ref:`hpe_dl360_gen9` 服务器独立磁盘操作，记录如下

- 在ZFS操作前检查磁盘 ``fdisk -l`` 可以看到磁盘是一个dos分区表，但没有分区(买来时候) :

.. literalinclude:: zfs_startup_zcloud/fdisk_before_zfs
   :caption: 在ZFS之前的磁盘是一个dos分区表
   :emphasize-lines: 6

- 在独立磁盘 ``/dev/sda`` (这个根据操作系统启动时识别磁盘获得，每个系统可能不同)创建zpool:

.. literalinclude:: zfs_startup_zcloud/zpool_create
   :caption: 在磁盘 ``sda`` 上创建ZFS的存储池，名字为 ``zpool-data``

- 检查 ``zpool`` :

.. literalinclude:: zfs_startup_zcloud/zpool_list
   :caption: 使用 ``zpool list`` 检查现有的zpool存储池

可以看到输出是一个完整磁盘:

.. literalinclude:: zfs_startup_zcloud/zpool_list_output
   :caption: 使用 ``zpool list`` 检查现有的zpool存储池 可以看到刚创建的 ``zpool-data``

- 注意，对于完整磁盘使用，ZFS会立即自动创建 ``GPT`` 分区表(抹掉之前的dos分区表)，并且划分为两个分区以及做好类型标注，一切都是自动化的: 使用 ``fdisk -l`` 可以看到如下新的磁盘分区:

.. literalinclude:: zfs_startup_zcloud/fdisk_zfs
   :caption: zpool命令在完整磁盘上创建存储池的之后，就可以看到GPT分区以及2个ZFS分区
   :emphasize-lines: 10,11

待续...

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
