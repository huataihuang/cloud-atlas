.. _grafana_config_startup:

===========================
Grafana配置快速起步
===========================

完成 :ref:`install_grafana` 或者 :ref:`helm3_prometheus_grafana` 之后，配置Grafana

- :ref:`install_grafana` 使用社区提供的apt软件仓库安装，则默认端口是 ``3000`` 首次登陆用户名和密码都是 ``admin`` ，会立即提示修改密码，请修改并保存密码
- :ref:`helm3_prometheus_grafana` 采用社区提供的 :ref:`helm` 安装在Kubernetes集群，通过 :ref:`grafana_behind_reverse_proxy` ，默认 ``admin`` 密码 ``prom-operator``

添加Prometheus数据源(metrics)
===============================

Prometheus是Grafana默认支持的核心组件，对于同时部署了 Prometheus 和 Grafana，所以添加数据源选择 ``Prometheus`` 类型后:

- 在导航栏，选择 ``Configuration`` 图标，然后点击 ``Data Sources``
- 点击 ``Add data source``
- 在数据源列表中，点击选择 ``Prometheus``
- 在URL栏，填写 http://localhost:9090 ( :ref:`install_grafana` ) 或者 Prometheus实际运行的IP地址，例如 Kubernetes 集群内部地址 http://10.233.30.214:9090/ ( :ref:`helm3_prometheus_grafana` )
- 然后点击 ``Save & Test``

Grafana读取Prometheus发生插件错误
-----------------------------------

我在配置 ``Prometheus`` 源时遇到一个报错::

   Error reading Prometheus: An error occurred within the plugin

这里需要配置 :ref:`prometheus_node_exporter` 以便Prometheus能够读取Kubernetes节点的metrics

Prometheus graph
===================

- 添加一个 ``Metrics`` ，可以使用任意一个 Prometheus 的metircs，例如，之前测试过 ``rate(node_cpu_seconds_total{mode="system"}[1m])`` （也就是节点的system负载)
