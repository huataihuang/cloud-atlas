.. _gluster_web_admin:

========================
Gluster WEB管理平台
========================

方案对比
============

Gluster目前开源WEB管理平台(监控)有:

- Red Hat Gluster Storage使用的上游开源项目 :ref:`tendrl`
- 简单管理功能采用集成到 :ref:`cockpit` (插件)
- 采用 :ref:`prometheus` 实现告警

  - `gluster / gluster-prometheus <https://github.com/gluster/gluster-prometheus>`_ gluster官方的 :ref:`prometheus` exporter
  - :ref:`mixins` 的 `mixins/gluster <https://monitoring.mixins.dev/gluster/>`_ 集成 :ref:`grafana` 和 :ref:`prometheus`

参考
=====

- `Red Hat Gluster Storage >> 3.5 >> Monitoring Guide >> Chapter 1. Overview <https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.5/html/monitoring_guide/overview>`_
