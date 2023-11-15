.. _alertmanager_startup:

====================
Alertmanager起步
====================

.. note::

   实践环境采用 :ref:`z-k8s_gpu_prometheus_grafana` ，服务访问端口采用 ``NodePort`` 简化配置，本文测试脚本配置端口按照 ``NodePort`` 配置

   :ref:`kube-prometheus-stack_alertmanager`

Prometheus 通常与处理警报和警报路由的 AlertManager 结合使用: 

- AlertManager 支持各种报警传输(例如电子邮件或 ``slack`` )
- AlertManager 报警功能可以通过自定义 ``webhookss`` 扩展，也就是企业可以开发自己的告警平台，然后结合到 AlertManager 的 webhook

.. note::

   `Swatto/promtotwilio <https://github.com/Swatto/promtotwilio>`_ 提供了一个从 :ref:`prometheus` 接收webooks然后通过 `Twilio <https://www.twilio.com/>`_ 发送短信告警

架构
=======

Alertmanager是一个告警服务器，用于处理从一系列客户端(例如 :ref:`prometheus` )提供的告警，并且分发给预先定义的接收者组(Slack, email 或 Pagerduty)。Alertmanager是Prometheus Stack的一部分，但是也可以作为独立的服务器运行。

通常 :ref:`prometheus` 被配置成直接发送告警给Alertmanager，不过，也可以采用不同的客户端，此时AlertManager提供一个REST路口来提供fire alerts功能.

.. figure:: ../../../_static/kubernetes/monitor/alertmanager/alert-manager-works.png

   AlertManager 工作原理图

安装
======

和 :ref:`prometheus_startup` 类似，采用 :ref:`zcloud_host_install_prometheus` 类似方法完成部署 ``Alertmanger`` : 共用部分 :ref:`prometheus_startup` 配置(运行用户设置为 ``prometheus`` )

- 准备用户账号(已完成过):

.. literalinclude:: ../prometheus/prometheus_startup/add_prometheus_user
   :language: bash
   :caption: 在操作系统中添加 prometheus 用户

- 安装和初始配置复制:

.. literalinclude:: alertmanager_startup/init_alertmanager
   :language: bash
   :caption: 复制和初始化alertmanager

- 配置 :ref:`systemd` 服务 ``/etc/systemd/system/alertmanager.service`` :

.. literalinclude:: alertmanager_startup/alertmanager.service
   :caption: Alertmanager :ref:`systemd` 服务管理配置文件 ``/etc/systemd/system/alertmanager.service``

- 启动服务:

.. literalinclude:: alertmanager_startup/start_alertmanager
   :caption: 启动Alertmanager

测试alert
===========

- 向 ``Altermanager`` 发送一个测试告警:

.. literalinclude:: alertmanager_startup/test_alert
   :language: bash
   :caption: 测试alertmanager

如果正常，终端会收到::

   {"status":"success"}

检查 ``AlertManager`` 管理WEB页面可以看到添加了如下一条信息:

.. figure:: ../../../_static/kubernetes/monitor/alertmanager/test_alert.png

.. note::

   :ref:`curl_post_json` 是通用的 ``curl`` 方法，在 ``alertmanager`` 上可以用来测试数据路由

配置 ``alertmanager.yml``
===========================

Alertmanager的配置主要包含两个部分:

- 路由(route)
- 接收器(receivers)

参考
=======

- `Prometheus docs: Alertmanager <https://prometheus.io/docs/alerting/latest/alertmanager/>`_
- `AlertManager and Prometheus Complete Setup on Linux <https://devconnected.com/alertmanager-and-prometheus-complete-setup-on-linux/>`_
- `How to Install and Configure Prometheus and Alert Manager on CentOS 7?  <https://medium.com/@Dylan.Wang/how-to-install-and-configure-prometheus-and-alert-manager-on-centos-7-78095c2de356>`_
- `prometheus告警流程及相关时间参数说明 <https://blog.csdn.net/ifenggege/article/details/125456836>`_
- `AlertManager and Prometheus Complete Setup on Linux <https://devconnected.com/alertmanager-and-prometheus-complete-setup-on-linux/>`_ 这篇文章比较详尽，并且有一个系列文章 `The complete Prometheus and Grafana installation <https://devconnected.com/how-to-setup-grafana-and-prometheus-on-linux/>`_
