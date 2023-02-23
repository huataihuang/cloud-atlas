.. _intro_tendrl:

=================
Tendrl简介
=================

Tendrl是开源的管理软件定义存储SDS的解决方案，提供了Ceph和Gluster存储的安装，存储提供，生命周期管理，监控，告警和趋势分析。Tendrl也是 `Red Hat Gluster Storage 3.5 (Overview) <https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.5/html/monitoring_guide/overview>`_ 目前Web管理的上游开源项目。

.. note::

   `GitHub:Tendrl <https://github.com/Tendrl>`_ 采用了 :ref:`ruby` :ref:`python` :ref:`javascript` 混合的开发语言，但是似乎已经不再活跃开发。不过，其方案和思路可以借鉴

思考
===========

- 从 Red Hat Gluster Storage 文档来看，早期3.1版本采用了集成Nagios的告警方式。不过现在3.5版本已经没有相关资料，而是采用了Gluster社区的Volume监控(命令行)，但是没有提供进一步的WEB集成信息
- 随着 :ref:`kubernetes` 云原生快速发展，大多数基于K8S的集群监控都转向了 :ref:`prometheus` 这样的metrics监控模式，所以建议从这个角度来部署

参考
======

- `Tendrl官方网站 <http://tendrl.org/>`_
- `Tendrl – The Unified Storage <https://a2batic.wordpress.com/2018/01/09/tendrl-the-unified-storage/>`_
