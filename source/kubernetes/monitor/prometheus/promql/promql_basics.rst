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

.. note::

   Tips: 其实我开始的时候也不适应 ``PromQL`` ，毕竟 PromQL 内置指标非常多，得摸索。不过，我发现 :ref:`gpt` 能够提供很好的起步参考(简单向GPT-3.5提出需要查询prometheus的要求就能返回一些案例和解释，稍加修改就能使用)

内置指标
==========

PromQL提供了很多非常有用的Kubernetes集群内置指标，只需要检查查询这些指标就能获得集群概况，加上一些 ``label`` 过滤(类似 :ref:`sql` 的 ``where`` )就能组装成所需的查询:

- ``kube_pod_status_phase`` Pod状态:

.. literalinclude:: promql_basics/kube_pod_status_phase_running
   :caption: 查询集群中指定 ``<YOUR_NAMESPACE>`` 中处于 ``Running`` 状态Pod数量

- 增加限定: 在 ``kube_pod_status_phase`` PromQL内置指标，可以使用 ``namespace`` , ``phase`` , ``deployment`` 等标签来筛选指定 Namespace 中处于 Running 状态且属于指定 Deployment 的 Pod:

.. literalinclude:: promql_basics/kube_pod_status_phase_running_deployment
   :caption: 查询集群中指定 ``<YOUR_NAMESPACE>`` 中且指定 ``<YOUR_DEPLOYMENT_NAME>`` 的处于 ``Running`` 状态Pod数量

- 分组统计(类似于 :ref:`sql` 的 ``GROUP BY`` ): 将上述查询按照 ``Deployment`` 进行分组:

.. literalinclude:: promql_basics/kube_pod_status_phase_running_deployment_count_by_deployment
   :caption: 按照 ``Deployment`` 统计(count)集群中指定 ``<YOUR_NAMESPACE>`` 中且指定 ``<YOUR_DEPLOYMENT_NAME>`` 的处于 ``Running`` 状态Pod数量

- 找 ``cluster`` 和 ``deployment`` 分组:

.. literalinclude:: promql_basics/kube_pod_status_phase_running_deployment_count_by_cluster_deployment
   :caption: 按照 ``Cluster`` 和  ``Deployment`` (组合进行分组) 统计(count)集群中指定 ``<YOUR_NAMESPACE>`` 中且指定 ``<YOUR_DEPLOYMENT_NAME>`` 的处于 ``Running`` 状态Pod数量

快速起步
=========

``PromQL`` 的第一个重要功能是聚合(Aggregation)，类似 :ref:`sql` 中的 ``GROUP BY`` 按字段分组并对另一个字段的值进行聚合( ``AVG()`` 或 ``COUBT()`` )。在 ``PromQL`` 中聚合是指结果通过指标标签(metric label)并由 ``sum()`` 等聚合运算符进行处理。 

参考
======

- `QUERYING PROMETHEUS: Bssics <https://prometheus.io/docs/prometheus/latest/querying/basics/>`_
- `PromQL Tutorial: 5 Tricks to Become a Prometheus God <https://coralogix.com/blog/promql-tutorial-5-tricks-to-become-a-prometheus-god/>`_
