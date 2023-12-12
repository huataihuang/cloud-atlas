.. _erasure_code:

======================
纠错码(erasure code)
======================

默认情况下，Ceph存储池使用 "复制" ( ``replicated`` )类型创建的。在复制类型池，每个对象都被复制到多个磁盘。这种多重复制是一种数据保护机制。而纠错码( ``erasure code`` )存储池使用复制不同的数据保护方法。

纠错码(erasure code)模式下，数据被分成两种片段: 数据块和 **奇偶校验块** 。如果驱动器发生故障或者损坏，奇偶校验块将用于重建数据。在规模上，纠错码相对于复制可以节省空间。 ``erasure code`` (纠错码)也称为"前向纠错码"( ``forward error correction codes`` )。

参考
======

- `Ceph Storage Cluster » Cluster Operations » Erasure code <https://docs.ceph.com/en/latest/rados/operations/erasure-code/>`_
- `Red Hat Ceph Storage >> 6 >> Storage Strategies Guide >> Chapter 5. Erasure code pools overview <https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/6/html/storage_strategies_guide/erasure-code-pools-overview_strategy#doc-wrapper>`_
