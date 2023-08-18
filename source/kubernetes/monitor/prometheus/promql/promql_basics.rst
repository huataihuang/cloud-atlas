.. _promql_basics:

==============================
PromQL查询基础
==============================

Prometheus提供了一种名为 ``PromQL`` 的函数式查询语言，可以让用户实时选择和聚合时序数据(series data)。表达式的结果可以显示为图形或表格形式，也可以通过HTTP API在外部调用。

表达式语言数据类型
======================

Prometheus的表达式语言(Expression language)中，表达式 或 子表达式 可以计算为 **4种** 类型之一:

- 即时向量(Instant vector) - 一组时间序列，每个时间序列包含一个样本，所有样本共享相同的时间戳
- 范围向量(Range vector) - 一组时间序列，每个时间序列随时间变化的一系列数据点
- 标量(Scalar) - 一个简单的浮点数字值
- 字符串(String) - 一个简单的字符串值，目前未使用

快速起步
=========

``PromQL`` 的第一个重要功能是聚合(Aggregation)，类似 :ref:`sql` 中的 ``GROUP BY`` 按字段分组并对另一个字段的值进行聚合( ``AVG()`` 或 ``COUBT()`` )。在 ``PromQL`` 中聚合是指结果通过指标标签(metric label)并由 ``sum()`` 等聚合运算符进行处理。 

参考
======

- `QUERYING PROMETHEUS: Bssics <https://prometheus.io/docs/prometheus/latest/querying/basics/>`_
- `PromQL Tutorial: 5 Tricks to Become a Prometheus God <https://coralogix.com/blog/promql-tutorial-5-tricks-to-become-a-prometheus-god/>`_
