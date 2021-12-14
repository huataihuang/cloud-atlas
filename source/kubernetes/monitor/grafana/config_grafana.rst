.. _config_grafana:

========================
配置Grafana
========================

完成 :ref:`install_grafana` 之后，配置Grafana

- 使用浏览器访问 http://z-b-mon-1:3000 
- 首次登陆用户名和密码都是 ``admin`` ，会立即提示修改密码，请修改并保存密码

添加Prometheus数据源(metrics)
===============================

Prometheus是Grafana默认支持的核心组件，由于在 ``z-b-mon-1`` 上同时部署了 Prometheus 和 Grafana，所以添加数据源选择 ``Prometheus`` 类型后，访问的 http://localhost:9090

- 在导航栏，选择 ``Configuration`` 图标，然后点击 ``Data Sources``
- 点击 ``Add data source``
- 在数据源列表中，点击选择 ``Prometheus``
- 在URL栏，填写 http://localhost:9090
- 然后点击 ``Save & Test``

Prometheus graph
===================

- 添加一个 ``Metrics`` ，可以使用任意一个 Prometheus 的metircs，例如，之前测试过 ``rate(node_cpu_seconds_total{mode="system"}[1m])`` （也就是节点的system负载)
