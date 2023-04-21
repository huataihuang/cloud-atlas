.. _alertmanager_startup:

====================
Alertmanager起步
====================

.. note::

   实践环境采用 :ref:`z-k8s_gpu_prometheus_grafana` ，服务访问端口采用 ``NodePort`` 简化配置，本文测试脚本配置端口按照 ``NodePort`` 配置

.. note::

   :ref:`kube-prometheus-stack_alertmanager`

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

参考
=======

- `Prometheus docs: Alertmanager <https://prometheus.io/docs/alerting/latest/alertmanager/>`_
