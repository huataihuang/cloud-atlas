.. _log_systems:

==================
日志系统
==================

.. note::

   本文目前是日志系统的调研资料搜集，实际上有多种日志系统，有的专注于传统的日志记录和存储，有的侧重日志查询和分析，有的则在日志分析基础上衍生出告警监控。总之，适合不同的业务场景以及开发维护日志系统的技术储备，可以选择不同的日志系统，并没有绝对的唯一。

   我准备不断更新和改进这篇综述，并融合自己的实践经验，并且力争实现全面的日志基础设施。

现代日志(管理)系统包含了日志数据存储、处理、分析和可视化，是分布式集群运维管理的关键基础设施，也是现代可观测系统(logs, metrics, traces)的重要组成部分。

OpenObserve
=============

`GitHub: openobserve <https://github.com/openobserve/openobserve>`_ 是 `OpenObserve.ai <https://openobserve.ai/>`_ 开源的日志观测系统:

- 和 :ref:`loki` 类似，没有采用 :ref:`elasticsearch` 全文索引，所以也就具备了 "低存储成本、高速查询" 的 ``优势``
- 集成提供了 ``logs, metrics, traces, analytics`` 来替代 :ref:`elasticsearch` / :ref:`prometheus` / :ref:`jaeger` / :ref:`grafana` (对于中小型公司，这种All In One系统有吸引力，但对于具备二次开发和已经有技术选型的公司而言，缺乏融合到现有平台的灵活性)
- 支持SQL查询日志， :ref:`promql` 查询指标 (可以说这是一个模仿并再造 :ref:`elasticsearch` 和 :ref:`prometheus` 并力求和用户现有使用习惯一致)
- 使用 :ref:`rust` 开发 
- 提供内置报警机制(类似 :ref:`alertmanager` )可以将告警发送到 slack, Microsoft Teams等渠道

.. note::

   ``OpenObserve`` 可以说是对现有可观测系统不同开源项目的一个综合再造，从理念来说不算创新，但是集成了众多开源项目(再造)功能，成为一个功能全面的日志观测平台(并且不局限于日志)

Loki
=========

:ref:`loki` 是 :ref:`grafana` Labs团队的开源项目，但是和十项全能型日志系统 :ref:`elasticsearch` 不同，是简化版的日志聚合系统: :ref:`loki_startup` 综合介绍工作原理和特点。

SigNoz
==========

:ref:`signoz` 也是一个全面集成 ``logs, metrics, traces, analytics`` 的监控系统: :ref:`intro_signoz` 介绍原理和特点

Graylog
=========

`graylog <https://graylog.org/>`_ 开源了 `github: graylog2-server <graylog2-server>`_ ，采用java开发，根据 `Graylog Docs > Installing Graylog <https://go2docs.graylog.org/5-2/downloading_and_installing_graylog/installing_graylog.html>`_ 可以初略了解graylog的架构:

- 后端基于 :ref:`elasticsearch` 或者 :ref:`opensearch` (目前看 ``OpenSearch`` 是发展趋势) 
- 使用Java开发的日志管理系统，可以视为 :ref:`elasticsearch` 或者 :ref:`opensearch` 的管理增强(使用MangoDB存储用户信息、流配置等元数据；日志数据完全存储在 :ref:`elasticsearch` 或者 :ref:`opensearch` )

.. note::

   初略查看了Graylog资料，看起来这个LMS是  :ref:`elasticsearch` 或者 :ref:`opensearch` 的再包装版本，不是很看好。毕竟对于大型企业，完全有能力自己维护 :ref:`elasticsearch` 或者 :ref:`opensearch` ，核心功能具备后自己定制并非难事。

syslog-ng
===========

:ref:`syslog-ng` 是传统的日志采集系统的现代化发展: 实际上核心的syslog-ng日志采集系统已经成熟发展了很多年，一度是很多Linux发行版默认或推荐的日志采集系统:

- 很久以前，蚂蚁金服还叫 "支付宝公司" 的时候，生产环境使用的Red Hat Enterprise Linux还都是使用 ``syslog-ng`` 来采集日志(现在已经全部改为阿里云的SLS，类似 :ref:`elasticsearch` )
- 配置语法有些特别，需要花时间学习，但是后续 :ref:`redhat_linux` 全系列转换为 :ref:`rsyslog` 所以逐渐退出了主流

看起来有商业公司收购和重新支持起 ``syslog-ng`` 准备打造成全系列的底层日志采集系统。我仅观察并在必要的遗留系统中维护 :ref:`syslog-ng`

Highlight.io
==============

`highlight.io <https://www.highlight.io/>`_ 是一个非常年轻的开源日志监控系统，最早开始于2020年12月1日(以GitHub首次提交)，也是采用 :ref:`elasticsearch` 作为后端的搜索分析平台，主要增强在于:

- 不仅提供日志管理，还提供会话重放和错误监控(基于日志设置告警阀值和频率，支持不同渠道通知)
- 使用 :ref:`clickhouse` 进行数据存储和检索
- 提供多种语言框架SDK

这是一个相对较为年轻的开源项目，可能还没有得到广泛的验证

Circonus
============

`circonus3 <https://docs.circonus.com/circonus3/getting-started/introduction>`_ 是 `circonus.com <https://circonus.com>`_ 公司的 ``logs, metrics, traces, analytics`` 产品:

- 基于 :ref:`elasticsearch` 并集成 :ref:`opentelemetry` (例如 :ref:`jaeger` 或 ``Zipkin`` ) 和 :ref:`metrics` (采用自己的Circonus Unified Agent)
- `Circonus集成了很多第三方库 <https://docs.circonus.com/circonus3/integrations/library/>`_ 提供深入的功能，例如 :ref:`intel_rdt` 库 `Circonus 3.0 Liberty: Intel RDT <https://docs.circonus.com/circonus3/integrations/library/intel-rdt/>`_ 是一种比较好的全面参考方案(你可以了解如何使用Intel RDT Software Package来获取pqos信息)

思考
======

- 目前看来突出 **低成本和高速** 的日志系统( 典型如 ``OpenObserve`` 和 :ref:`loki` )都是舍弃了全文索引，采用 Label 聚合查询的方式，对于特定应用是有优势的，但同时也具有局限性
- 产品化的日志管理系统大多数基于 :ref:`elasticsearch` 构建，并集成 :ref:`opentelemetry` (例如 :ref:`jaeger` 或 ``Zipkin`` ) 和 :ref:`metrics` (可能会直接使用 :ref:`prometheus_exporters` 也可能直接提供自己的Agent)
- 架构大同小异，所以可以精研其中的典型解决方案来了解和掌握这种日志分析基础架构

参考
=======

- `2023年值得关注的6个开源日志管理工具 <https://www.sohu.com/a/716725440_411876>`_ 英文原文见 `6 Open Source Log Management Tools for 2023 <https://betterstack.com/community/comparisons/open-source-log-managament/>`_
- `哪一个开源的日志收集系统比较好？ <https://www.zhihu.com/question/22761013>`_
