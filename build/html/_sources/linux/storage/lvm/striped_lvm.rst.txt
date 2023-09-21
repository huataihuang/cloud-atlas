.. _striped_lvm:

========================
条带化逻辑卷管理(LVM)
========================

``lvdisplay -m``
===================

在我们构建的 LVM 中，数据是如何分布的，可以通过 ``-m`` 参数查看 ( ``--maps`` ):

.. literalinclude:: striped_lvm/lvdisplay_maps
   :caption: 检查LVM磁盘数据分布

.. literalinclude:: striped_lvm/lvdisplay_maps_output
   :caption: 检查LVM磁盘数据分布
   :emphasize-lines: 20,25

可以看到这里的类型是 ``linear`` ，也就是顺序分布

构建条代化分布LVM
=======================

条代化 ``striped`` 配置实际上也非常简单，主要是传递参数 ``-i`` 表示数据跨几块物理磁盘分布，以及 ``-I`` 参数设置条代化大小。我在 :ref:`xfs_startup` 为数据库构建的就是跨3块磁盘的条代化LVM，以便能够实现性能提升以及大容量磁盘:

.. literalinclude:: ../filesystem/xfs/xfs_startup/lvm_striped
   :caption: 创建条代化LVM卷 

说明:

  - ``-i 3`` 表示使用3块磁盘作为volume group，这样条带化会分布到3个磁盘上
  - ``-I 128k`` 表示使用 128k 作为条带化大小，也可以使用单纯数字 ``128`` 默认单位就是 ``k``
  - ``-l`` 表示扩展百分比，这里采用了 ``10%FREE`` 和 ``100%FREE`` 表示空闲空间的10%和100% ; 另外一种常用的扩展大小表示是使用 ``-L`` 参数，则直接表示扩展多少容量，例如 ``-L 10G`` 表示扩展 10GB 空间

参考
=======

- `Striped Logical Volume in Logical volume management (LVM) <https://www.linuxsysadmins.com/create-striped-logical-volume-on-linux/>`_
