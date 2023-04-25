.. _kube-prometheus-stack_additionalScrapeConfigs:

====================================================
``kube-prometheus-stack`` 添加Prometheus scrape配置
====================================================

.. note::

   本文记录一些配置案例，逐步完善。详细的解析会在相应的文档中完善

在 :ref:`k8s_kube_state_metircs` 和 :ref:`z-k8s_gpu_prometheus_grafana` 过程中，逐步添加了一些附加监控项，也就是在 ``prometheus`` 中实现一些自定义 ``metrics`` 抓取:

- :ref:`intergrate_gpu_telemetry_into_k8s` 添加一段抓取 :ref:`dcgm-exporter` 的GPU信息
- 采集 :ref:`aliyun_prometheus` ``staragent`` Agent输出的GPU metrics
- 采集公司自研Agent输出的服务器metrics

.. literalinclude:: kube-prometheus-stack_additionalScrapeConfigs/kube-prometheus-stack_values.yaml
   :language: yaml
   :caption: ``kube-prometheus-stack`` 添加 ``additionalScrapeConfigs``

参考
=====

- `Prometheus: monitoring services using additional scrape config for Prometheus Operator <https://fabianlee.org/2022/07/08/prometheus-monitoring-services-using-additional-scrape-config-for-prometheus-operator/>`_
- `prometheus-operator/Documentation/additional-scrape-config.md <https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md>`_
