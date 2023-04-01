.. _update_prometheus_config_k8s:

====================================
更新Kubernetes集群的Prometheus配置
====================================

在 :ref:`helm3_prometheus_grafana` 中部署 :ref:`dcgm-exporter` 管理GPU监控，需要修订Prometheus配置来抓取特定节点和端口metrics，需要修订Prometheus配置。

参考
=====

- `How to update Prometheus config in k8s cluster <https://stackoverflow.com/questions/53227819/how-to-update-prometheus-config-in-k8s-cluster>`_
- `Prometheus, ConfigMaps and Continuous Deployment <https://www.weave.works/blog/prometheus-configmaps-continuous-deployment/>`_
- `Prometheus: monitoring services using additional scrape config for Prometheus Operator <https://fabianlee.org/2022/07/08/prometheus-monitoring-services-using-additional-scrape-config-for-prometheus-operator/>`_
- `Different Prometheus scrape URL for every target <https://stackoverflow.com/questions/44927130/different-prometheus-scrape-url-for-every-target>`_
