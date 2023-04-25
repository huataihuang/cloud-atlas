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

参考
=======

- `Prometheus docs: Alertmanager <https://prometheus.io/docs/alerting/latest/alertmanager/>`_
