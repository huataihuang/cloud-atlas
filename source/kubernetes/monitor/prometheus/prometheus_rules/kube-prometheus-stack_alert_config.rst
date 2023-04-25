.. _kube-prometheus-stack_alert_config:

======================================
``kube-prometheus-stack`` 告警配置
======================================

和 :ref:`prometheus_monitor_apps` 类似，通过配置 :ref:`prometheus_alerting_rules` 来实现告警通知，不过 ``kube-prometheus-stack`` 提供了 ``values`` 输入方法来简化配置，本文记录实践经验。`

参考
=======

- `How are Prometheus alerts configured on Kubernetes with prometheus-community/prometheus <https://home.robusta.dev/blog/prometheus-alerts-using-prometheus-community-helm-chart>`_
