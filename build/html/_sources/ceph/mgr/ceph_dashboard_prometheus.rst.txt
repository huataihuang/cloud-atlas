.. _ceph_dashboard_prometheus:

================================
Ceph Dashboard集成Prometheus
================================

Ceph Dashboard使用了 :ref:`grafana` 面板来实现RBD监控，数据源是从 :ref:`prometheus` 拉取数据，Ceph Prometheus Module 采用Prometheus输出格式输出(export)数据，然后由Grafana面板从Prometheus模块和 Node exporter获取metrics名字。

安装和配置
==================

Prometheus
------------

在我的 :ref:`priv_cloud_infra` 规划中我采用两种部署方式:

- 独立在 ``zcloud`` 物理服务器上部署 :ref:`prometheus` 和 :ref:`grafana` 
- 在Kubernetes集群部署 :ref:`z-k8s_prometheus-stack`

此外，也尝试在两个 ``z-b-mon-1`` 和 ``z-b-mon-2`` 上部署双机:

  - ``z-b-mon-1`` 上 :ref:`prometheus_startup` 部署
  - Ceph集群的3个节点 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 安装并运行 :ref:`node_exporter`
  - ``z-b-mon-1`` 上 :ref:`install_grafana` 并 :ref:`grafana_config_startup`

激活Prometheus输出
===================

- 使用以下命令激活 prometheus 模块:

.. literalinclude:: ceph_dashboard_prometheus/ceph_mgr_prometheus
   :caption: ``ceph mgr`` 激活 :ref:`prometheus` 管理模块

默认Ceph Prometheus模块会监听在所有网络接口的 ``9283`` 端口，即以下配置命令是默认设置:

.. literalinclude:: ceph_dashboard_prometheus/ceph_mgr_prometheus_ip_port
   :caption: ``ceph config`` 可以配置 ``mgr`` 的 :ref:`prometheus` 监听IP和端口

你可以通过上述命令修订监听IP地址和端口

配置Prometheus
=====================

- 配置 ``/etc/prometheus/prometheus.yaml`` 添加:

.. literalinclude:: ceph_dashboard_prometheus/prometheus.yaml
   :language: yaml
   :caption: 配置 :ref:`prometheus` 抓取Ceph的metrics

- 重启prometheus

.. note::

   当 :ref:`install_ceph_mgr_single` 则Prometheus的抓取入口只有一个，此时上文配置3个抓取入口会有2个显示无法连接:

   .. figure:: ../../_static/ceph/mgr/ceph_mgr_single_prometheus.png

   当完成 :ref:`install_ceph_mgr_multi` 配置之后，就会看到3个prometheus抓取Endpoint都UP起来了:

   .. figure:: ../../_static/ceph/mgr/ceph_mgr_multi_prometheus.png

配置Grafana
=================

在Grafana的Dashboard网站可以搜索到很多Ceph Dashboard，基本上都是围绕 Ceph官方的 ``Ceph MGR(s) Prometheus Metrics Endpoints`` 实现:

- `Ceph Cluster (ID: 2842) <https://grafana.com/grafana/dashboards/2842-ceph-cluster/>`_ 以下是我的安装实践截图:

.. figure:: ../../_static/ceph/mgr/ceph_grafana_1.png

.. figure:: ../../_static/ceph/mgr/ceph_grafana_2.png

- `Ceph - OSD (Single) (ID: 5336) <https://grafana.com/grafana/dashboards/5336-ceph-osd-single/>`_
- `Ceph - Pools (ID: 5342) <https://grafana.com/grafana/dashboards/5342-ceph-pools/>`_
- `Ceph - Cluster (ID: 7056) <https://grafana.com/grafana/dashboards/7056-ceph-cluster/>`_

参考
=======

- `Ceph Manager Daemon » Ceph Dashboard <https://docs.ceph.com/en/latest/mgr/dashboard/>`_
- `Ceph Manager Daemon » Prometheus Module <https://docs.ceph.com/en/latest/mgr/prometheus/>`_
- `The Ceph monitoring challenge: Prometheus, Grafana, and Ansible rise to the task <https://www.redhat.com/en/blog/ceph-monitoring-challenge-prometheus-grafana-and-ansible-rise-task>`_
