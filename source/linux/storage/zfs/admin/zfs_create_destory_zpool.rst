.. _zfs_create_destory_zpool:

=============================
创建和销毁zpool
=============================

在 :ref:`zfs_admin_prepare` 完成后，创建存储数据的zpool: ``zpool-data``

.. note::

   zpool 创建后可以直接挂载，也可以不挂载，而在zpool下再创建卷用于不同目标(分别挂载)

创建zpool
============

销毁zpool
=============

恢复误销毁的zpool
------------------

如果zpool不小心误删除了，还是有可能 :ref:`zfs_pool_restore` 的

参考
======

- `Creating and Destroying ZFS Storage Pools <https://docs.oracle.com/cd/E23824_01/html/821-1448/gaypw.html#scrolltoc>`_

