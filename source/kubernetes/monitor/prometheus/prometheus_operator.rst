.. _prometheus_operator:

=============================
Prometheus Operator
=============================

Prometheus Operator 提供 Kubernetes 原生部署和管理 Prometheus 及相关监控组件。这样可以简化并自动化基于 :ref:`prometheus` 的监控堆栈的部署和配置:

- Kubernetes 自定义资源(CR, Custom Resources)：使用 Kubernetes 自定义资源部署和管理 Prometheus、Alertmanager 及相关组件。
- 简化的部署配置：配置 Prometheus 的基础功能，例如版本(versions)、持久化(persistence)、保留策略(retention policies) 和 本地 Kubernetes 资源的副本(replicas)。
- Prometheus Target Configuration：根据熟悉的Kubernetes标签查询，自动生成监控目标配置；无需学习 Prometheus 特定的配置语言。

参考
======

- `Prometheus Operator Docs: Introduction  <https://prometheus-operator.dev/docs/prologue/introduction/>`_
