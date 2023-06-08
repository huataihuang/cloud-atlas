.. _etcd_auto_compact:

===================
etcd自动压缩
===================

``etcd`` 可以设置为自动压缩 keyspace ，运行参数 ``--auto-compaction-*`` ::

   # keep one hour of history
   $ etcd --auto-compaction-retention=1

参考
=======

- `etcd Operations guide: Maintenance/Auto Compaction <https://etcd.io/docs/v3.5/op-guide/maintenance/#auto-compaction>`_
