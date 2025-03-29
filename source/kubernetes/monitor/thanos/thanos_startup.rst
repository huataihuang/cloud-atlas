.. _thanos_startup:

==========================
Thanos - Prometheus高可用
==========================

`Thanos 提供长期存储能力的高可用Promethous解决方案 <https://thanos.io>`_ :

- 可以从多个Prometheus服务器和集群聚合查询Prometheus metrics
- 通过对象存储实现了无限时间的metrics存储
- 支持Prometheus Query API，可以集成Grafana
- 通过降低采样可以实现极大跨度范围的查询或者配置复杂的保留策略

Thanos的解决方案出现主要是为了解决Prometheus的短板：

- Prometheus没有提供自动本地数据同步，搭建多副本+联邦模式要保持数据一致性表困难

  - Prometheus采用Remote Write模式可以在多个节点采用Adapter选主，只推送一份数据到TSDB
  - Prometheus采用Remote Write模式，但是不同节点写入不同TSDB，使用Sync在TSDBs之间同步数据确保数据全量
  - 上述两个方案有侵入性风险，所以类似Thanos或者Victorimetrics采用查询时去重和join，通过全局视图来实现大规模高可用展示查询。

.. note::

   Thanos采用滚动发布方式，每6周发布一个小版本迭代，所以请注意关注项目发布情况，采用最新版本部署以便解决可能存在的问题。

参考
=====

- `一文详解 Prometheus 的高可用方案：Thanos <https://blog.csdn.net/tzs_1041218129/article/details/110211801>`_
