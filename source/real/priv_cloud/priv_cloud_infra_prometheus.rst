.. _priv_cloud_infra_prometheus:

======================
私有云Prometheus部署
======================

在 :ref:`prometheus_startup` 记录了zcloud安装 :ref:`Prometheus` ，步骤包括:

- ``z-b-mon-1`` 安装 Prometheus + Grafana
- 被监控的 Ceph 节点安装 Node Exporter ，并激活 ``ceph mgr prometheus`` 模块
