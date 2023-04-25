.. _promql_basics:

==============================
PromQL查询基础
==============================

Prometheus提供了一种名为 ``PromQL`` 的函数式查询语言，可以让用户实时选择和聚合时序数据(series data)。表达式的结果剋显示为图形或表格形式，页可以通过HTTP API在外部调用。

表达式语言数据类型
======================

Prometheus的表达式语言(Expression language)中，表达式 或 子表达式 可以计算为 **4种** 类型之一:

- 即时向量(Instant vector) - 一组时间序列，每个时间序列包含一个样本，所有样本共享相同的时间戳
- 范围向量(Range vector) - 一组时间序列，每个时间序列随时间变化的一系列数据点
- 标量(Scalar) - 一个简单的浮点数字值
- 字符串(String) - 一个简单的字符串值，目前未使用



参考
======

- `QUERYING PROMETHEUS: Bssics <https://prometheus.io/docs/prometheus/latest/querying/basics/>`_
