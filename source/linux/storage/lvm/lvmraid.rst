.. _lvmraid:

=========================
LVM RAID( ``lvmraid`` )
=========================

虽然 :ref:`linux_software_raid` 的 :ref:`mdadm` 使用更为广泛和成熟，我也依然想尝试一下 ``lvmraid`` 部署。 ``lvmraid`` 基于 ``MD`` 驱动实现了RAID功能，是另一种解决方案。不过，从各方面信息来看， ``lvmraid`` 可能不够成熟，存在一些性能问题。

.. note::

   以下是我的构想方案，尚未实践(还没有遇到实践环境)，谨慎参考

- 假设方案使用 3块 磁盘构建 RAID 5(构建RAID5只少需要3块磁盘，我这里复用了 :ref:`xfs_startup`  的磁盘分区方案):

.. literalinclude:: ../filesystem/xfs/xfs_startup/parted_multi_disk
   :caption: 3块 :ref:`nvme` 磁盘使用 :ref:`parted` 完成分区

- 使用LVM创建RAID的方法其实和 :ref:`striped_lvm` (条代化也是分布数据到多个数据磁盘)非常类似，区别在于传递了参数 ``--type`` ，例如 ``--type raid5`` ，并且数据盘数量参数 ``-i`` 需要比 :ref:`striped_lvm` 减少 ``1`` （因为有一块磁盘作为校验盘不直接存储数据)

举例，之前在 :ref:`striped_lvm` 使用以下命令构建跨3块磁盘的条代化LVM:

.. literalinclude:: ../filesystem/xfs/xfs_startup/lvm_striped
   :caption: 创建跨3块磁盘的条代化LVM卷
   :emphasize-lines: 4,5
  
则需要调整数据盘数量(n-1) ``-i 2`` ，并且传递类型 ``--type raid5`` :

.. literalinclude:: lvmraid/lvmraid5
   :caption: 简单的创建RAID5的LVM卷
   :emphasize-lines: 4,5

参考
=========

- `Configure RAID Logical Volumes on Oracle Linux <https://docs.oracle.com/en/learn/ol-lvmraid/>`_
- `Create RAID with LVM <https://blog.programster.org/create-raid-with-lvm>`_
- `Raid1 with LVM from scratch <https://wiki.gentoo.org/wiki/Raid1_with_LVM_from_scratch>`_
- `RAIDing with LVM vs MDRAID - pros and cons? <https://unix.stackexchange.com/questions/150644/raiding-with-lvm-vs-mdraid-pros-and-cons>`_ 回答中包含了一个完整的指南
