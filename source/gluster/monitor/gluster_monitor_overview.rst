.. _gluster_monitor_overview:

==========================
Gluster监控方案概览
==========================

Gluster目前能够整合的监控方案:

- metrics + mixins:

  - `Prometheus exporter for Gluster Metrics <https://github.com/gluster/gluster-prometheus>`_ 提供 :ref:`prometheus` 采集所需的 :ref:`metrics` 
  - `Monitoring Mixins >> gluster <https://monitoring.mixins.dev/gluster/>`_ 采用 :ref:`jsonnet` 生成 :ref:`prometheus` 和 :ref:`grafana` 配置

- Red Hat Gluster Storage 集成了 :ref:`gluster_web_admin` 实现，但是这个部署是需要订购RedHat服务才能完成。Red Hat Gluster Storage的WEB管理平台基于上游开源项目 :ref:`tendrl` ，集成管理 :ref:`gluster` 和 :ref:`ceph` 。 **上游Tendrl项目从2018年开始停滞开发**

  - 性能和负载
  - 故障和报错

我感觉个人采用的开源方案还是需要从 ``metrics + mixins`` 着手，自己组建数据采集和告警配置，这可能是一个比较折腾的历程

参考
=======

- `Red Hat Gluster Storage >> 3.5 >> Monitoring Guide <https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.5/html/monitoring_guide/index>`_
- `Monitoring Mixins >> gluster <https://monitoring.mixins.dev/gluster/>`_
