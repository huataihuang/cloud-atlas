.. _etcd_defrag:

==================
etcd碎片整理
==================

在 :ref:`etcd_auto_compact` 之后，后端数据库可能会出现内部碎片。内部碎片空间可以被 ``etcd`` 使用，但是这部分空间不会释放给文件系统，也就是意味着不会回收磁盘空间(从操作系统角度来看)。

.. note::

   我理解 ``etcd`` 空间压缩一般就能够保证etcd正常工作了，因为我们通常都是独立运行 ``etcd`` ，对于操作系统不回收这部分磁盘空间不重要，只要这部分空间能够继续被 ``etcd`` 自己使用就可以了。

   所以通常应该不需要defragmentation

.. note::

   每天一次告警也有点烦，尝试defrag

准备工作
==========

:ref:`etcd_env`

- 执行 defragmentation 之前，先检查一次etcd集群健康状态:

.. literalinclude:: etcd_env/etcd_status_output
   :caption: ``etcd_status`` 命令查看etcd健康状态

执行
=====

- 执行 ``etcd`` 碎片整理:

.. literalinclude:: etcd_defrag/etcd_defrag
   :language: bash
   :caption: 执行 ``etcdctl defrag`` 进行碎片整理

这个执行速度很快，秒级完成，并且是依次对所有 :ref:`etcd` 服务器进行碎片整理，此时显示输出:

.. literalinclude:: etcd_defrag/etcd_defrag_output
   :language: bash
   :caption: 执行 ``etcdctl defrag`` 进行碎片整理输出信息

- 再次执行 ``etcd_status`` 检查碎片整理后的etcd:

.. literalinclude:: etcd_env/etcd_status_after_defrag_output
   :caption: 完成defrag之后再次 ``etcd_status`` 命令查看etcd健康状态

.. note::

   以上实践记录是在我的线下测试环境执行实践，实际生产环境数据量比这个要大很多

参考
=====

- `etcd Operations guide: Maintenance/Defragmentation <https://etcd.io/docs/v3.5/op-guide/maintenance/#defragmentation>`_
