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

思考
======

- 目前看来突出 **低成本和高速** 的日志系统( 典型如 ``OpenObserve`` 和 :ref:`loki` )都是舍弃了全文索引，采用 Label 聚合查询的方式，对于特定应用是有优势的，但同时也具有局限性

参考
=======

- `2023年值得关注的6个开源日志管理工具 <https://www.sohu.com/a/716725440_411876>`_ 英文原文见 `6 Open Source Log Management Tools for 2023 <https://betterstack.com/community/comparisons/open-source-log-managament/>`_
- `哪一个开源的日志收集系统比较好？ <https://www.zhihu.com/question/22761013>`_
