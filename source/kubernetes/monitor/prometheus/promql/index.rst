.. _promql:

======================
PromQL
======================

PromQL (Prometheus Query Language): 查询和聚合时序数据

我们已经初步完成了 Prometheus 部署( :ref:`helm3_prometheus_grafana` )，现在就可以开始学习如何使用 ``PromQL`` 查询，并且尝试配置 :ref:`prometheus_alerting_rules` 来是实现告警(这也是我们部署监控的目的)

当然，实际上部署还是会遇到很多问题，我实际上先跳过了 ``PromQL`` 和 :ref:`prometheus_rules` 折腾了很久部署工作才得到了一个可用的生产环境 ``kube-prometheus-stack``

.. toctree::
   :maxdepth: 1

   promql_basics.rst
   promql_examples.rst
