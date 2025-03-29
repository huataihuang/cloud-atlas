.. _kube-prometheus-stack_scrape_node_metrics:

====================================================
``kube-prometheus-stack`` 抓取节点metrics
====================================================

:ref:`kube-prometheus-stack_additionalScrapeConfigs` 采用标准的 :ref:`prometheus_service_discovery` 获取Kubernetes对象的监控数据。不过，生产环境也有很多服务器并不属于Kubernetes机群，而是独立部署的物理主机，有各种应用自己开发输出的 :ref:`metrics` ，也需要通过Prometheus采集。

以下是一个简单的配置案例，监控一种分布式存储不同角色(master/worker)输出的metrics，指定 ``scrape`` 目标以及通过 ``labels`` 方式为服务器分组，这样后续在 Prometheus 和 :ref:`grafana` 可以根据 ``group`` 这个label进行查询:

.. literalinclude:: kube-prometheus-stack_scrape_node_metrics/scrape_node_metrics.yaml
   :language: yaml
   :caption: 指定服务器抓取metrics

这里采用了多个Targes配置

参考
=====

- `Multiple Targets on prometheus <https://stackoverflow.com/questions/53295711/multiple-targets-on-prometheus>`_
