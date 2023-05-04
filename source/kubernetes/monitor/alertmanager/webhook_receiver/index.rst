.. _alertmanager_webhook_receiver:

====================================
Alertmanager 通知(Webhook Receiver)
====================================

对于Alertmanager没有原生支持的通知机制(很不幸国内原生支持只有微信)，需要通过 ``Webhook Receiver`` 来集成，例如 :ref:`prometheus-webhook-dingtalk`

在官方文档 `Prometheus Integrations: Alertmanager Webhook Receiver <https://prometheus.io/docs/operating/integrations/#alertmanager-webhook-receiver>`_ 列出了所支持的第三方webhook receiver，可以选择参考。

.. toctree::
   :maxdepth: 1

   prometheus-webhook-dingtalk.rst
   prometheus-webhook-dingtalk_template.rst
