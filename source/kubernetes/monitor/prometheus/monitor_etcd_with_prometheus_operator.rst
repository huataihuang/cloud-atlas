.. _monitor_etcd_with_prometheus_operator:

====================================
使用Prometheus Operator监控etcd
====================================

:ref:`kube-prometheus-stack_etcd` 借助 ``kube-prometheus-stack`` 可以快速完成Prometheus配置实现 :ref:`etcd` 监控，实际底层是采用 :ref:`prometheus_operator` 快速完成配置。通过解析并一步步配置 :ref:`prometheus_operator` 可以实现同样的监控 ``etcd`` 任务，并且能够较为详细了解 :ref:`prometheus_operator` 操作原理。

参考
==========

- `Monitoring ETCD with Prometheus Operator <https://hemanth-penmetcha.medium.com/monitoring-etcd-with-prometheus-operator-b9cd8eaff719>`_
