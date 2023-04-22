.. _ceph_dashboard_prometheus:

================================
Ceph Dashboard集成Prometheus
================================

Ceph Dashboard使用了 :ref:`grafana` 面板来实现RBD监控，数据源是从 :ref:`prometheus` 拉取数据，Ceph Prometheus Module 采用Prometheus输出格式输出(export)数据，然后由Grafana面板从Prometheus模块和 Node exporter获取metrics名字。

安装和配置
==================

Prometheus
------------

在我的 :ref:`priv_cloud_infra` 规划中，最初想采用如下独立服务器部署Prometheus，不过最终我改为集成化 :ref:`z-k8s_prometheus-stack`

- ``z-b-mon-1`` 上 :ref:`prometheus_startup` 部署
- Ceph集群的3个节点 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 安装并运行 :ref:`node_exporter`
- ``z-b-mon-1`` 上 :ref:`install_grafana` 并 :ref:`grafana_config_startup`

激活Prometheus输出
===================

- 使用以下命令激活 prometheus 模块::

   sudo ceph mgr module enable prometheus

默认Ceph Prometheus模块会监听在所有网络接口的 ``9283`` 端口，即以下配置命令是默认设置::

   ceph config set mgr mgr/prometheus/server_addr 0.0.0.0
   ceph config set mgr mgr/prometheus/server_port 9283

你可以通过上述命令修订监听IP地址和端口

配置Prometheus
=====================

- 修订 ``z-b-mon-1`` 配置 ``/etc/prometheus/promethesu.yaml`` 添加::

   scrape_configs:  
     - job_name: 'ceph'
       honor_labels: true
       static_configs:
         - targets: ['z-b-data-1:9283']
           labels:
             instance: 'ceph_cluster'
         - targets: ['z-b-data-2:9283']
           labels:
             instance: 'ceph_cluster'
         - targets: ['z-b-data-3:9283']
           labels:
             instance: 'ceph_cluster'

参考
=======

- `Ceph Manager Daemon » Ceph Dashboard <https://docs.ceph.com/en/latest/mgr/dashboard/>`_
- `Ceph Manager Daemon » Prometheus Module <https://docs.ceph.com/en/latest/mgr/prometheus/>`_
- `The Ceph monitoring challenge: Prometheus, Grafana, and Ansible rise to the task <https://www.redhat.com/en/blog/ceph-monitoring-challenge-prometheus-grafana-and-ansible-rise-task>`_
