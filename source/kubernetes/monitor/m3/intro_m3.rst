.. _intro_m3:

=========================
M3分布式时序数据库简介
=========================

.. figure:: ../../../_static/kubernetes/monitor/m3/m3_logo.png
   :scale: 30

M3组件
=============

- M3 Coordinator: 协调对上游系统之间对对读写服务，例如Prometheus和M3DB。 ``M3 Coordinator`` 是一个部署访问作为长期存储和多数据中心设置其他监控系统(Prometheus)的M3DB的桥接(bridge)。
- M3DB: 分布式时序数据库，提供可伸缩的存储以及时序的递归索引。M3DB可以高效和可靠实时以及长期保存metrics存储和索引。
- M3 Query: 在分布式M3DB节点上实现实时和历史数据的分布式查询引擎，支持不同查询语言。M3 Query设计成支持低延迟实时查询以及能够长时间运行查询，合并成较大的数据集用于分析。
- M3 Aggregator: 分布式metrics聚合器，提供基于状态流式样本提炼(stateful stream-based downsampling)，然后存储metrics到M3DB节点。M3 Aggregator使用etcd存储规则。

M3DB和M3 Aggregator都支持集群化和多副本复制，也就是metrics可以正确路由到相应节点并且实现metrics的聚合，也可以配置多个M3 Aggregator副本实现聚合器的冗灾。

.. note::

   M3 Aggregator 目前正在开发中，暂时还是需要使用者自己开发兼容的 producer 和 consumer

参考
======

- `M3: Uber’s Open Source, Large-scale Metrics Platform for Prometheus <https://eng.uber.com/m3/>`_
