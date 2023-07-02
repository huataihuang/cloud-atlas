.. _centos_gluster_init:

===============================
为GlusterFS部署准备CentOS环境
===============================

CentOS目前依然是生产环境中常用的操作系统，虽然由于 :ref:`redhat_linux` 产品策略变化，CentOS已经不再作为Red Hat Enterprise Linux的下游产品，而是作为上游产品的滚动(stream)版本，稳定性和可靠性有所下降。目前很多遗留生产环境依然在使用CentOS 7系列，这里我将实践部署的完整过程。

说明
=======

- 根据 `Gluster Community Packages <https://docs.gluster.org/en/latest/Install-Guide/Community-Packages/>`_ 信息可以知道社区现在已经不再提供停止更新的CentOS 7系列的GlusterFS软件包，所以面对的第一个挑战就是自己 :ref:`build_glusterfs_11_for_centos_7`

准备
======

- 安装 :ref:`pssh` 帮助批量执行命令

存储文件系统
--------------

磁盘存储是Gluster的基础:

- Gluster是基于操作系统的文件系统构建的，底层需要构建一个文件系统
- 文件系统建议基于 :ref:`linux_lvm` + :ref:`xfs`

  - :ref:`linux_lvm` 是非常轻薄的存储层，对性能几乎无影响，但是带来极大的存储管理灵活性: 可以实现存储磁盘空间在线扩容，以及存储快照(备份)
  - 类似 :ref:`stratis` 结合 :ref:`linux_lvm` 和 :ref:`xfs` 可以实现高级文件系统特性(类似 :ref:`zfs` 和 :ref:`btrfs`)

- 简化方案可以仅采用 :ref:`xfs` 构架一个架构清晰简洁的 GlusterFS 系统


项目实践采用了每个服务器 12 块 :ref:`nvme` 磁盘

- 使用 ``fdisk -l`` 可以检查磁盘( :ref:`nvme` 部分 ):

.. literalinclude:: centos_gluster_init/fdisk_output
   :caption: ``fdisk -l`` 检查 :ref:`nvme` 信息部分( ``nvme0n1`` )

- 可以手工命令在每台服务器，对每个NVME磁盘进行分区并构建 :ref:`xfs` :

.. literalinclude:: centos_gluster_init/parted_xfs_glusterfs
   :caption: 命令行 :ref:`nvme` 分区并格式化成 :ref:`xfs` 文件系统(这里仅展示 ``nvme0n1`` ，实际需要对12块磁盘重复完成上述操作)

.. note::

   参数解析：

   - ``-a optimal`` 可以通过 ``parted`` 的自动4k对齐，这个参数非常重要，可以避免4k没有对齐对存储性能的影响
   - ``parted`` 的命令 ``mkpart primary 0% 100%`` 可以将磁盘整个创建一个主分区
   - ``parted`` 的命令 ``name 1 gluster_brick0`` 是将分区命名成gluster相关
   - ``mkfs.xfs -i size=512`` 格式化XFS文件系统

.. warning::

   ``mkfs.xfs``（从 ``xfsprogs 3.2.4`` 版开始）默认创建的XFS superblock v5版本，不兼容于 RHEL 7/CentOS 7 的3.10内核，需要在格式化时候增加 ``-m crc=0,finobt=0`` 来强制格式化成 XFS superblock v4。详见 :ref:`xfs_kernel_incompatible`

- 由于手工对一块块磁盘分区和格式化非常繁琐，所有可以准备一个脚本 ``parted_xfs.sh`` 脚本:

.. literalinclude:: centos_gluster_init/parted_xfs.sh
   :language: bash
   :caption: 对12块 :ref:`nvme` 批量进行分区和格式化xfs的脚本 ``parted_xfs.sh``

通过 :ref:`pssh` 分发到各个服务器上执行，就可以获得12块分区、格式化和挂载一气呵成的GlusterFS磁盘文件系统:

.. literalinclude:: centos_gluster_init/pssh_parted_xfs
   :language: bash
   :caption: 通过 :ref:`pssh` 批量完成分区、格式化和挂载

``wrong fs type, bad option, bad superblock``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

这里我遇到一个错误， ``mkfs.xfs`` 顺利完成，但是挂载报错:

.. literalinclude:: ../../../linux/storage/filesystem/xfs/xfs_kernel_incompatible/mount_xfs_err
   :caption: 挂载XFS文件系统报错 ``wrong fs type, bad option, bad superblock``
   :emphasize-lines: 1,5

解决方法见 :ref:`xfs_kernel_incompatible` (上文格式化脚本已经修订)
