.. _prometheus:

===============================
Prometheus（普罗米修斯）监控
===============================

概览
=======

`Prometheus（普罗米修斯）监控 <https://prometheus.io>`_ 是开源的系统监控和告警套装工具，最初由 `SoundCloud <http://soundcloud.com/>`_ 公司于2012年开发。Prometheus使用Go语言开发，并且采用Apache 2.0 license开源。Prometheus从2016年加入 `Cloud Native Computing Foundation, CNCF <https://cncf.io/>`_ ，成为Kubernetes之后第二个CNCF孵化项目。

Prometheus 提供了所有主流语言和运行环境的客户端库程序，包括 Go, Java/JVM, C#/.Net, Python, Ruby, Node.js, Haskell, Erlang 和 Rust。类似Kubernetes 和 Docker已经集成了Prometheus客户端库程序。对于第三方使用非Prometheus格式输出的软件，也有上百种集成方案。这种集成是通过 ``exporters`` 实现的，包括 HAProxy, MySQL, PostgreSQL, Redis, JMX, SNMP, Consul 和 Kafka等。

功能
-----

Prometheus主要功能包括：

- 一种具有 **通过度量名称(metric name)和键值对来标识的时序数据** 的多维度数据模型(data model)
- PromQL，一种具有伸缩行的查询语言，可以衡量不同维度
- 不依赖分布式存储; 单个服务器节点是自治的
- 通过HTTP的拉取模式采集时序数据
- 通过内建网管支持推送时序数据
- 通过一系列发现或静态配置来获取目标
- 多种图形和仪表盘支持的模式

组件
-------

Prometheus 包含多个组件：

- 主应用程序 Prometheus server 负责收集和存储时序数据
- client libraries 客户端库程序负责集成到应用程序代码中
- push gateway 推送网管支持短时间任务
- 特定用途的 exporters 用于诸如 HAProxy, StatsD, Graphite 等第三方服务
- alertmanager 告警管理器用于处理警报
- 以及一系列工具

.. note::

   通过 PromQL 可以定义告警，并且只要能数据图表化，就能够基于图表进行告警。

   Prometheus性能极佳并且易于运行。一个单机运行的Prometheus能够每秒处理百万级别的样本数据。所有的Prometheus组件都能够容器化，这样就可以避免基于配置管理工具来维护。Prometheus自身也设计成集成到基础架构中，无需单独维护。

架构
-------

.. figure:: ../../_static/kubernetes/prometheus_architecture.png
   :scale: 50

Prometheus可以从编排任务中获取metrics，既支持直接获取也支持通过中间推送网管执行的短时间任务。所有抓取短样本都存储在本地并且基于这些数据运行归来在聚合或者从现有数据中记录下新的时序数据或生成告警。通常Prometheus会结合到 :ref:`grafana` 或者其他API消费者平台来可视化采集的数据。

.. note::

   传统的监控系统，例如 `Nagios <https://www.nagios.org>`_ 是基于定时运行的检查脚本来检查服务异常返回值以确定是否告警；同时针对业务日志的监控和分析平台，例如Elasticsearh,Logstash和Kibana(ELK)提供了服务异常趋势分析。
   
   但是在云计算和云原生环境中，单独的服务判断已经无法反映系统的健康程度，而是在大量的虚拟化和容器化环境中，复杂的相互调用监控才能掌控整个架构。需要同时结合服务告警和趋势分析的监控平台逐步成为这种应用场景的监控需求，Prometheus恰到好处地结合 Docker / Kubernetes 内嵌的 :ref:`cadvisor` ，实现了完整的监控体系。

使用场景
----------

- Prometheus适合做:
  - 非常适合记录任何纯数字时序数据：Prometheus 适合基于主机监控和高度动态面向服务的架构。在微服务架构中，Prometheus支持多维度数据采集以及提供强大的查询能力
  - 适合快速诊断系统问题：Prometheus服务器是独立部署的，不依赖网络存储或其他远程服务。这样即使其他系统架构异常，也不会影响到监控平台

- Prometheus不适合做:
  - 虽然Prometheus非常稳定，但是并不能保证数据百分百精确
  - Prometheus不适合需要通过分析数据来记账的场景



参考
======

- `Prometheus Overview <https://prometheus.io/docs/introduction/overview/>`_
- `Prometheus - Up & Running: Infrastructure and Application Performance Monitoring <https://www.amazon.com/Prometheus-Infrastructure-Application-Performance-Monitoring-ebook-dp-B07FCV2VVG/dp/B07FCV2VVG/ref=mt_kindle?_encoding=UTF8&me=&qid=1560303117>`_
