.. _gpart_linux_zfs_partition:

===============================
gpart实践(linux分区及zfs分区)
===============================

在部署FreeBSD+Linux的混合系统时，我的实践将一个NVMe分为多个分区:

- :ref:`freebsd_root_on_zfs_using_gpt` FreeBSD安装过程自定义256G空间用于 ``zroot`` 存储池，实现FreeBSD on ZFS root
- 划分256G用于 :ref:`lfs` 构建，分区将分别实验(最终采用 :ref:`xfs` ):

  - :ref:`freebsd_ext`
  - :ref:`freebsd_ext4`
  - :ref:`freebsd_xfs`

- 单独划分一个分区用于构建 :ref:`freebsd_zfs_stripe` 实现独立的 ``zdata`` 存储池，后续可以进一步扩展

磁盘
=======

- 由于PCIe被用于GPU设备，所以主机只安装了一块NVMe存储，使用 ``geom`` 检查如下：

.. literalinclude:: freebsd_disk_startup/geom_disk
   :caption: 使用 ``geom`` 列出磁盘

系统中只安装了一块 :ref:`kioxia_exceria_g2` 显示设备名为 ``nda0`` :

.. literalinclude:: gpart_linux_zfs_partition/geom_disk_list_output
   :caption: 单块NVMe存储分区
   :emphasize-lines: 1

- 由于我在安装过程中 :ref:`freebsd_root_on_zfs_using_gpt` ，所以当前为操作系统分配的 ``zroot`` 存储池只占用部分存储空间，使用 :ref:`gpart` 检查磁盘分区:

.. literalinclude:: gpart_linux_zfs_partition/gpart_show
   :caption: 使用 ``gpart`` 检查磁盘分区

当前有3个分区，是 :ref:`freebsd_root_on_zfs_using_gpt` 创建的

.. literalinclude:: gpart_linux_zfs_partition/gpart_show_output
   :caption: 使用 ``gpart`` 检查磁盘分区
   :emphasize-lines: 2,4,5

磁盘分区
==========

- 在上述3个分区之后，再创建一个(分区4)分区( ``-t linux-data`` 表示是Linux分区)，分配 ``256G`` ( ``-s`` )并设置以 ``1M`` 大小进行对齐( ``-a 1M`` ):

.. literalinclude:: gpart_linux_zfs_partition/gpart_add
   :caption: 添加分区

- 剩余磁盘空间再创建一个分区，此时因为是完全分配剩余空间，所以不指定 ``-s`` 参数

.. literalinclude:: gpart_linux_zfs_partition/gpart_add_all
   :caption: 将磁盘剩余空间再划分为一个分区

- 完成后检查 ``gpart show nda0`` 可以看到上述操作已经添加了2个分区:

.. literalinclude:: gpart_linux_zfs_partition/gpart_show_output_all
   :caption: 使用 ``gpart`` 检查磁盘分区可以看到添加的2个分区
   :emphasize-lines: 6,7

ZFS Stripe条带化
==================

.. note::

   由于FreeBSD对Linux文件系统支持有限，所以这里 ``linux-data`` 分区后续采用 :ref:`bhyve_ubuntu` 来完成文件系统创建(读写可以在FreeBSD中进行，所以我最终会采用 :ref:`linux_jail` 来实现 :ref:`freebsd_xfs` 读写访问，用于构建 :ref:`lfs` )

这里使用了单块磁盘的单个分区，所以实践采用 :ref:`freebsd_zfs_stripe_single_disk` :

.. literalinclude:: ../../linux/storage/zfs/admin/freebsd_zfs_stripe/zpool_zdata
   :caption: 创建 ``zdata`` zpool
