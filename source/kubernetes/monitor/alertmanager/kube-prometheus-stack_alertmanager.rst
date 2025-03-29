.. _kube-prometheus-stack_alertmanager:

============================================
``kube-prometheus-stack`` 配置AlertManager
============================================

首先需要知道有两种 :ref:`prometheus_rules` :

- :ref:`prometheus_recording_rules` : 预先计算的表达式，无需每次都执行原始表达式就可以查询
- :ref:`prometheus_alerting_rules` : 告警规则使用 :ref:`promql` 编写，评估一个或多个表达式并根据解决过触发警报

``prometheus.yml`` 是 :ref:`prometheus` 的主配置文件，但是并不是定义了所有的Prometheus规则，而是命名包含实际规则的其他文件。传统上， ``alerting rules`` 和 ``recording rules`` 是拆分到单独文件中的。

虽然在 ``prometheus`` 服务器pod中

``alertmanager.config`` 定义
==============================================================

``alertmanager.config`` 提供了指定 altermanager 的配置，这样就能够自己定制一些特定的 ``receivers`` ，不过可能更方便是直接 ``apply`` 

.. literalinclude:: kube-prometheus-stack_alertmanager/kube-prometheus-stack.values
   :language: yaml
   :caption: 简单配置alertmanager的接收者就能够收到通知，这里采用 :ref:`prometheus-webhook-dingtalk`
   :emphasize-lines: 39,41,45-47

这里主要将默认配置修改如下:

- 将 ``alertmanager.config`` 配置中 ``receiver`` 从 ``null`` 替换成需要接收的 :ref:`prometheus-webhook-dingtalk` 配置中的 ``target`` 名字，这里是 ``cloud_atlas_alert`` 
- 添加 :ref:`prometheus-webhook-dingtalk` 的 ``webhook`` 配置，注意URL路径中包括了 ``target`` ( ``cloud_atlas_alert`` ) ，也就是 URL 必须是 ``http://<prometheus-webhook-dingtalk服务器IP>:8060/dingtalk/<target>/send``

结合 :ref:`prometheus-webhook-dingtalk` 部署运行的服务器，就能立即收到钉钉通知(MarkDown格式)，并且能够 @ 指定用户(根据手机号码或者工号)，类似:

.. figure:: ../../../_static/kubernetes/monitor/alertmanager/alert_dingtalk.png

参考
======

- `How are Prometheus alerts configured on Kubernetes with prometheus-community/prometheus <https://home.robusta.dev/blog/prometheus-alerts-using-prometheus-community-helm-chart>`_
- `Prometheus: Alerting <https://confluence.infn.it/display/CLOUDCNAF/3%29+Alerting>`_
- `[kube-prometheus-stack] Alertmanager does not update secret with custom configuration options #1998 <https://github.com/prometheus-community/helm-charts/issues/1998>`_ 提供了一个CRD配置思路待验证
- `How to overwrite alertmanager configuration in kube-prometheus-stack helm chart <https://stackoverflow.com/questions/71924744/how-to-overwrite-alertmanager-configuration-in-kube-prometheus-stack-helm-chart>`_
- `[kube-prometheus-stack] Alertmanager does not update secret with custom configuration options #1998 <https://github.com/prometheus-community/helm-charts/issues/1998>`_ 这个issue的 ``values.yaml`` 可以参考
