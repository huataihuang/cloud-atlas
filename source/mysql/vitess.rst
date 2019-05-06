.. _vitess:

=====================
Vitess数据库集群
=====================

`Vitess平台 <https://vitess.io>`_ 是YouTube开源的部署、扩展和管理大型MySQL实力集群的数据库解决方案：

- 采用数据库分片（shard）技术来实现MySQL横向扩展的数据库解决方案
- 提供裸机迁移到私有云或公有云方案
- 可以部署和管理大量的MySQL实例

Vitess 提供了兼容JDBC和Go数据库驱动，支持原生查询协议。

Vitess从2011年开始用于YouTube数据库，目前已经被很多企业用于生产。并且目前已经成为 `Cloud Native Computing Foundation <https://www.cncf.io>`_ (云原生计算基金会)孵化项目，并且和Kubernetes良好结合（可以扩展部署到数万个节点）。

.. note::

   在互联网公司，海量的用户数据使得单台x86服务器无法承受全量的用户数据读写，即使采用MySQL的主从数据库模式，使用一写多读的部署也无法实现主服务器承担全量数据的写入。由于纵向扩展（升级单台服务器硬件配置）无法满足业务增长，就需要采用分库分表方式来把全量用户切分成不同的。

   例如在阿里巴巴广泛采用了 `TDDL (Taobao Distributed Data Layer) <https://github.com/alibaba/tb_tddl>`_ ，可以参考 `数据库中间件TDDL调研笔记 <https://juejin.im/entry/5a0e53b4f265da431c6fdf20>`_ 了解实现原理。不过该开源项目已停止更新，并且有不支持多表查询、不支持join等限制。TDDL公布文档很少，只开源动态数据源，未开源分库分表，且强依赖diamond。 ( `分库分表中间件工具 <https://www.jianshu.com/p/c9bcd2f704b8>`_ ) 目前，TDDL 比较适合的场景是在阿里云上使用云计算厂商直接提供的 `DRDS 分库分表 <https://help.aliyun.com/wordpower/451996-1.html>`_ ，而不是自建集群。

Vitess特性
===========

- 性能

  - 连接池 - 多前段应用查询访问MySQL连接池以优化性能
  - 查询重复删除 - 复用正在进行的查询可过来获取相同请求的结果
  - 事务管理 - 限制并发事务数量并管理期限，优化整体吞吐量

- 保护

  - 查询重写和清理 - 增加限制并避免不确定性更新（？）
  - 查询黑名单 - 自定义规则过滤掉潜在问题的查询
  - 查询截断 - 占用时间过长的查询可以被截断
  - 表ACL - 基于链接用户的访问控制列表（ACL）

- 监控

  - 性能分析 - 提供监控、诊断和分析数据库性能的工具
  - 查询流化 - 使用传入查询列表来服务OLAP负载（？）
  - 更新流 - 数据库更新的行列表可以流式处理，这个功能可以用于和其他数据存储机制协作

- 拓扑管理工具

  - Master节点管理工具（处理重定位）
  - 基于web的管理GUI
  - 可以设计多数据中心/区域

- 数据分片

  - 几乎无缝的动态重新分片 - 这是非常突出的开源技术
  - 垂直和水平分片支持
  - 多种分片方案，能够插入自定义分片

.. note::

   在 `Vitess vs. Vanilla MySQL <https://vitess.io/docs/overview/whatisvitess/#vitess-vs-vanilla-mysql>`_ 对比了 Vitess 和 Vanilla MySL 技术 （请参考 `VITESS 学习（1）理解VITESS <https://www.cnblogs.com/zhangwushang/p/8523015.html>`_ 译文）：

   - Vitess连接池功能使用Go语言的并发支持将轻量级链接映射到一个小型MySQL链接池，所以可以支持数千个并发连接
   - Vitess采用的SQL解析器可以使用一组可配置规则来重写可能损害数据库性能的查询
   - Vitess支持多种分片方案，可以将表迁移到不同的数据库，具有分片数量的伸缩性（增加或减少）。这些功能是非侵入型执行，只需要几秒停机时间可以完成大部分数据转换
   - Vitess可以管理数据库的生命周期，支持处理跟中包括主站故障切换和数据库备份
   - Vitess使用一致性数据存储来支持拓扑，例如 etcd 或 ZooKeeper
   - Vitess提供代理可以有效将查询路由到最合适的MySQL实例

架构
========

Vitess平台由多个服务进程，命令行实用工具和基于WEB的实用程序组成，并由一致性的元数据存储提供支持。

.. image:: ../_static/mysql/vitess_overview.png
   :scale: 75

Topology服务
-------------

`Topology Service <https://vitess.io/docs/user-guides/topology-service>`_ 是一个存储有关运行服务器信息、分片方案以及复制关系的元数据存储。Topology 后端是一个持久化数据存储，可以使用 ``vtctl`` （命令行工具）和 ``vtctld`` （web）来浏览拓扑。

vtgate
--------

``vtgate`` 是轻量级代理服务器，将流量路由到正确的 ``vttablet`` 并返回合并的结果给客户端。这种解决方案使得客户端非常简单只需要能够找到 ``vtgate`` 实例。

为了路由查询，vtgate考虑了分片方案，请求延迟以及

参考
=========

- `What is Vitess <https://vitess.io/docs/overview/whatisvitess/>`_
- `VITESS 学习（1）理解VITESS <https://www.cnblogs.com/zhangwushang/p/8523015.html>`_ - 是 `What is Vitess <https://vitess.io/docs/overview/whatisvitess/>`_ 的翻译文档，可作为参考
- `深入理解开源数据库中间件 Vitess：核心特性以及如何进行数据存储的堆叠 <https://blog.csdn.net/defonds/article/details/47813071>`_ - 是 `Vitess Overview <http://vitess.io/overview/>`_ 的翻译文档，可作为参考
- `Kubernetes助力CNCF Vitess实现MySQL扩展 <http://dockone.io/article/3653>`_
