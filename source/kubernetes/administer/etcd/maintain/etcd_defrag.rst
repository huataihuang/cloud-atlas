.. _etcd_defrag:

==================
etcd碎片整理
==================

在 :ref:`etcd_auto_compact` 之后，后端数据库可能会出现内部碎片。内部碎片空间可以被 ``etcd`` 使用，但是这部分空间不会释放给文件系统，也就是意味着不会回收磁盘空间(从操作系统角度来看)。

.. note::

   我理解 ``etcd`` 空间压缩一般就能够保证etcd正常工作了，因为我们通常都是独立运行 ``etcd`` ，对于操作系统不回收这部分磁盘空间不重要，只要这部分空间能够继续被 ``etcd`` 自己使用就可以了。

   所以通常应该不需要defragmentation

参考
=====

- `etcd Operations guide: Maintenance/Defragmentation <https://etcd.io/docs/v3.5/op-guide/maintenance/#defragmentation>`_
