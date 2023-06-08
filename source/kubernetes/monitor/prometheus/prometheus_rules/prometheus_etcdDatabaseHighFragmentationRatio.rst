.. _prometheus_etcdDatabaseHighFragmentationRatio:

======================================================
Prometheus规则 ``etcdDatabaseHighFragmentationRatio``
======================================================

收到关于 :ref:`etcd` 告警:

.. literalinclude:: prometheus_etcdDatabaseHighFragmentationRatio/alert_etcdDatabaseHighFragmentationRatio
   :caption: etcd数据库使用大小小于实际分配存储的50%告警

这个告警初看没有明白，既然使用率不到50%为何还要告警? 而且还提示我要做碎片整理(run defragmentation)

在 :ref:`helm_customize_kube-prometheus-stack` 解析社区 ``kube-prometheus-stack`` 可以看到在 ``templates/prometheus/rules-1.14/etcd.yaml`` 有如下规则:

.. literalinclude:: prometheus_etcdDatabaseHighFragmentationRatio/etcd.yaml
   :language: yaml
   :caption: ``kube-prometheus-stack`` 的 etcd 监控规则
   :emphasize-lines: 13

可以看到这个Prometheus查询规则::

   (last_over_time(etcd_mvcc_db_total_size_in_use_in_bytes[5m]) / last_over_time(etcd_mvcc_db_total_size_in_bytes[5m])) < 0.5

查询出 ``etcd_mvcc_db`` 的使用空间和总空间的比率，小于 ``50%``

并且 ``etcd_mvcc_db`` 使用空间 **大于** ``100MB`` 就会发送告警

.. note::

   目前这个告警出现频率不高，而且我观察了 ``etcd_mvcc_db`` 使用空间会自动压缩，所以告警之后再去观察可能使用空间只有 50MB 左右。暂时忽略这个告警

   :ref:`etcd_defrag`
