.. _prometheus_service_discovery_file_based:

=====================================
基于文件配置的Prometheus服务发现
=====================================

Prometheus提供了多种 :ref:`prometheus_service_discovery` 配置方法，其中有根据 ``consul``  , ``kubernetes`` 以及 ``mesos`` 等。对于一些静态配置，随着规模越来越大，静态配置会非常难以维护，此时我们可以采用基于文件的配置Prometheus服务发现:

- 创建一个包含目标的YAML或JSON文件
- 配置Prometheus从文件中抓取taerget
- 一旦需要添加或替换目标，则更新文件

待续...

参考
======

- `File based Service Discovery with Prometheus <https://ikod.medium.com/file-based-service-discovery-with-prometheus-65c8241aee03>`_
