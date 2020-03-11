.. _recovery_etcd:

===================
etcd故障恢复
===================

etcd被设计成在服务器故障时依然可用，etcd集群会自动从临时故障中恢复（例如主机重启）并且可以承受最多 ``(N-1)/2`` 节点的持续故障（N表示集群etcd节点数量）。当etcd成员服务器永久性故障，无论是硬件或磁盘故障，就会和集群失去联系。需要注意，当出现超过 ``(N-1)/2`` 节点故障，etcd集群将持续故障，因为集群缺少足够的法定投票。如果投票不足，集群就不能达成一致，这样也就不能更新数据。

为了从灾难性故障中恢复，etcd v3提供了快照(snapshot)和恢复机制，以便能够在丢失v3关键数据时重建集群。

keyspace快照
-------------

要恢复一个集群，首先需要从给一个etcd成员服务器上获取keyspace的快照。快照可以从活着的成员服务器上使用 ``etcdctl snapshot save`` 命令获取，也可以从一个 etcd 数据目录中复制 ``member/snap/db`` 文件来得到。举例，以下通过 ``$ENDPOINT`` 从keyspace获得快照，存储到文件 ``snapshot.db`` ::

   ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save snapshot.db

参考
========

- `Disaster recovery <https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/recovery.md>`_
