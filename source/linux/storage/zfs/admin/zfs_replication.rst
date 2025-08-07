.. _zfs_replication:

========================
ZFS 复制(replication)
========================

``replication`` 是OpenZFS的数据管理功能，提供了一个确保硬件故障最小化丢失和宕机的机制。简单来说，能够通过跨磁盘或跨主机的快照复制，实现数据的冗余和容灾。

例如，你可以将一台主机的 ``/home`` 目录构建快照，然后通过 ``zfs send`` 将快照 ``serialized`` 数据流并通过 ``zfs receive`` 传输文件和目录到另外一个主机。接受快照就像处理一个动态文件系统，可以在另外一台主机上直接访问接收的快照。

在实践中，通过网络复制快照，不仅可以跨机房(物理容灾)，而且可以设置定时任务完成。只要接收方存储容量足够，并且随着时间复制修改，并且网络也有能力处理数据传输。

环境要求
=============

- ``Replication`` 要求发送和接收方至少有一个OpenZFS pool:

  - 存储池可以是不同大小
  - 存储池可以是不同的RAIDZ级别
  - 存储池也可以使用不同的参数属性

- 根据快照大小和网络传输速率，第一次 ``replication`` 可能需要非常长的时间，特别是复制整个存储池
- 在完成了首次复制之后，后续的增量数据复制通常会很快
- ``zfs send | zfs recv`` 是基于块级别的复制，并且内置了checksum，所以能够保障数据完整型
- 建议在启动 ``Replication`` 之前先检查目标服务器是否有足够空间容纳发送方数据

数据复制
============

.. literalinclude:: zfs_replication/backup_docs
   :caption: 备份docs数据集

当使用了 ``-v`` 参数会看到同步数据的进度

.. literalinclude:: zfs_replication/backup_docs_output
   :caption: 备份docs数据集

.. note::

   实际上，通过 ``snapshot`` 发送( ``send`` )，然后在目的端接收( ``receive`` ):

   - 目的端会创建相同的 **snapshot** 名字 ，(似乎是)然后再 ``clone`` 出来同名的 ``dataset`` ，所以你会在目的存储 ``zstore`` 看到 ``docs@2025-08-05_22:48:09`` 快照(但是实际使用空间几乎是0):

   .. literalinclude:: zfs_replication/receive_snapshot_list_zstore_docs
      :caption: 列出 ``zstore/docs`` 的快照(注意，这是接收目的端)

   输出显示:

   .. literalinclude:: zfs_replication/receive_snapshot_list_zstore_docs_output
      :caption: 列出 ``zstore/docs`` 的快照(目的端，快照使用空间几乎为0?)

   - 检查对应的数据集(可以看到用了 1.7T):

   .. literalinclude:: zfs_replication/receive_list_zstore_docs
      :caption: 列出 ``zstore/docs`` 的数据集(注意，这是接收目的端)

   输出显示数据集才真正使用了 1.7T

   .. literalinclude:: zfs_replication/receive_list_zstore_docs_output
      :caption: 列出 ``zstore/docs`` 的数据集(注意，这是接收目的端)

递归数据复制
---------------

上述数据复制是指定了 ``zdata`` pool 中的 ``docs`` 数据集，那么对于具有很多个数据集的存储池该如何复制呢？需要一个个指定数据集么？

zfs提供了一个 ``-r`` 参数表示 ``recursive`` (递归)，可以包含所有的子数据集。注意，这个 ``-r`` 参数不仅可以用于 ``list`` 也可以用于复制。

- 首先检查 ``zdata`` 所有( ``-r`` )的 ``filesyatem`` 类型( ``-t`` )的数据集

.. literalinclude:: zfs_replication/recursive_list
   :caption: 递归检查 ``zdata`` 存储池

输出显示有如下这么多卷集:

.. literalinclude:: zfs_replication/recursive_list_output
   :caption: 递归检查 ``zdata`` 存储池，可以看到有很多卷集(dataset)

.. note::

   其中的 ``zdata/docs`` 我已经做过复制，所以不需要再做

   主要是复制 ``zdata/jails`` 和 ``zdata/vms``

- 为 ``zdata/jails`` 和 ``zdata/vms`` 卷集做 ``递归`` 快照( ``-R`` 参数表示递归 ``send`` ):

.. literalinclude:: zfs_replication/recursive_snapshot
   :caption: 递归快照

注意，这里有一些有用的参数需要关注:

- 发送端 ``zfs send`` 参数:

  - ``-R`` 表示发送指定存储池(pool)或数据集(dataset)的整个递归集合。并且接收时，所有已删除的源快照都会在目标端删除
  - ``-I`` 包括最后一个复制快照和当前复制快照之间的所有中间快照（仅在增量发送时需要）

- 接收端 ``zfs recv`` 参数:

  - ``-F`` 扩展目标池，包括删除源上已删除的现有数据集
  - ``-d`` 丢弃源池的名称并将其替换为目标池名称（其余文件系统路径将被保留，并且如果需要还会创建）(这个没有明白，待实践)
  - ``-u`` 目标端不要挂载文件系统(很有用的参数，如果没有这个参数，则目标端会自动挂载，挺清晰，但是对于备份数据可能不需要自动挂载)

上述方法参考 `how to one-way mirror an entire zfs pool to another zfs pool <https://unix.stackexchange.com/questions/263677/how-to-one-way-mirror-an-entire-zfs-pool-to-another-zfs-pool>`_ ，我用来备份到移动硬盘。该答案提供了一个简单脚本，很简单，但是值得参考

.. literalinclude:: zfs_replication/replication.sh
   :language: shell
   :caption: 一个简单replication复制脚本可参考

参考
=====

- `Introduction to ZFS Replication <https://klarasystems.com/articles/introduction-to-zfs-replication/>`_
- `Oracle Solaris ZFS Administration Guide > Sending and Receiving ZFS Data <https://docs.oracle.com/cd/E18752_01/html/819-5461/gbchx.html>`_
- `ZFS High Availability with Asynchronous Replication and zrep <https://klarasystems.com/articles/zfs-high-availability-with-asynchronous-replication-and-zrep/>`_
- `Querying ZFS File System Information <https://docs.oracle.com/cd/E18752_01/html/819-5461/gazsu.html>`_
- `Basics of ZFS Snapshot Management <https://klarasystems.com/articles/basics-of-zfs-snapshot-management/>`_
- `how to one-way mirror an entire zfs pool to another zfs pool <https://unix.stackexchange.com/questions/263677/how-to-one-way-mirror-an-entire-zfs-pool-to-another-zfs-pool>`_ 这篇问答极好，回答中提供了详细的参数解答
