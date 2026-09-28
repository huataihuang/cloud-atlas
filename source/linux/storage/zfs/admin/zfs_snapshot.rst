.. _zfs_snapshot:

=====================
ZFS快照
=====================

``snapshot`` 快照是一个文件系统或卷的只读复制。快照的创建几乎是瞬间的，并且最初不会消耗pool中的任何磁盘空间。然而，随着数据集的活跃数据修改，通过不断引用旧数据，快照消耗的磁盘空间会不断增减，这也会导致磁盘空间不被释放。

ZFS snapshot包含以下功能:

- 系统重启可以持续访问
- 理论上快照的最大数量是2的64次方
- 注意，快照不是独立的备份存储，是直接在文件系统或卷创建的相同存储池中消耗磁盘空间
- :ref:`zfs_recursive_snapshot` 作为 **单一原子操作** 快速创建，这些快照要么作为一个整体( ``同时`` )创建，要么完全不创建。原子快照操作的优势在于，即使跨越了子文件系统，快照数据也始终是在统一时间点捕获的。

.. note::

   :ref:`zfs_recursive_snapshot` **原子操作** 非常有用的特性，对于大型多系统备份能够在瞬间对相关系统同时快照，确保备份和恢复时数据一致。例如，数据库和应用文件(用户上传数据)的一致时间点备份非常关键。



参考
=======

- `Using ZFS Snapshots and Clones <https://ubuntu.com/tutorials/using-zfs-snapshots-clones#1-overview>`_
- `Overview of ZFS Snapshots <https://docs.oracle.com/cd/E19253-01/819-5461/gbciq/index.html>`_
