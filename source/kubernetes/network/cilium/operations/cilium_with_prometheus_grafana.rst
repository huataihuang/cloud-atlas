.. _cilium_with_prometheus_grafana:

===============================
Cilium结合Prometheus和Grafana
===============================

Cilium提供了已经组织好的 :ref:`prometheus` 和 :ref:`grafana` ，可以通过一个简单的 ``deployment`` 完成部署。

- 安装Cilium预配置的Prometheus和Grafana:

.. literalinclude:: cilium_with_prometheus_grafana/install_prometheus_grafana_for_cilium
   :caption: 安装为Cilium配置的Prometheus和Grafana

输出信息显示:

.. literalinclude:: cilium_with_prometheus_grafana/install_prometheus_grafana_for_cilium_output
   :caption: 安装为Cilium配置的Prometheus和Grafana的输出信息

上述安装部署会自动抓取Cilium和Hubble的metrics，详细配置参考 :ref:`cilium_monitoring_metrics`

部署Cilium和Hubble的metrics激活
==================================

默认情况下 ``Cilium`` , ``Hubble`` 和 ``Cilium Operator`` 不会输出metrics。通过打开集群相应节点的 ``9962`` , ``9965`` 和 ``9963`` 端口可以激活这些服务的 metrics 。

通过以下 :ref:`helm` 参数值可以分别激活 ``Cilium`` , ``Hubble`` 和 ``Cilium Operator`` :

- ``prometheus.enabled=true`` : 激活 ``cilium-agent`` 的metrics
- ``operator.prometheus.enabled=true`` : 激活 ``cilium-operator`` 的metrics
- ``hubble.metrics.enabled`` : 激活 ``Hubble`` 的metrics

- 设置Helm仓库:

.. literalinclude:: ../installation/cilium_install_with_external_etcd/helm_repo_add_cilium
   :language: bash
   :caption: 设置cilium Helm仓库

对于第一次安装Cilium，可以直接在部署Cilium的时候就直接激活metrics:

.. literalinclude:: cilium_with_prometheus_grafana/deploy_cilium_enable_metrics
   :caption: 安装Cilium时直接激活所有metrics

由于我已经安装好Cilium，所以实际执行是采用 ``upgrade`` 更新运行参数

.. literalinclude:: cilium_with_prometheus_grafana/upgrade_cilium_enable_metrics
   :caption: 更新Cilium激活所有metrics

访问Grafana
==============

- 输出端口到本地主机:

.. literalinclude:: cilium_with_prometheus_grafana/expose_grafana
   :caption: 输出Grafana端口到本地主机

通过浏览器访问 http://localhost:3000

访问Prometheus
===============

- 输出端口到本地主机:

.. literalinclude:: cilium_with_prometheus_grafana/expose_prometheus
   :caption: 输出Grafana端口到本地主机


参考
=======

- `Cilium Getting Started Guides: Running Prometheus & Grafana <https://docs.cilium.io/en/v1.12/gettingstarted/grafana/>`_
