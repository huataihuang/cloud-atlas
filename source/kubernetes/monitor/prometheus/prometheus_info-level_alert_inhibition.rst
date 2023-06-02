.. _prometheus_info-level_alert_inhibition:

============================================
Prometheus ``Info-level alert inhibition``
============================================

在部署完成 :ref:`prometheus-webhook-dingtalk` 能够接收到告警通知，很方便。但是，也出现了一些困扰

不断收到 pods 出现 ``pending`` 的Info级别告警

.. literalinclude:: prometheus_info-level_alert_inhibition/info-level_alert_inhibition
   :caption: 不断收到pod pending的info级别告警

但是，检查Kubernetes集群，发现 ``pending`` 告警的pod实际上是运行状态

既然已经进入了Running状态，为何我还会不断收到告警通知呢？

InfoInhibitor
================

``inhibit info alerts`` 在info-level级别告警中有时候非常"噪音"，但是结合其他告警能够提供相关性信息:

- ``CPUThrottlingHigh`` (CPU暴涨)告警在 ``Polar Signals`` 集群( :ref:`parca` )非常常见，但是除非有其他报警触发，否则 ``CPUThrottlingHigh`` 警告将被禁止

  - 这是因为单一的CPU使用率高并不代表系统存在问题，但是结合其他异常指标则很可能是存在隐患的线索

上述Alert没有任何影响，仅仅是作为 alertmanager 中缺失功能的解决方法:

- 只要存在 ``severity="info"`` 警报，就会触发，并且在同一个命名空间上开始触发另一个具有 ``warning`` 或 ``cirtical`` 性的警报时停止触发

  - (我的)简单理解就是，如果存在 ``info`` 级别的警报，则会不断触发(即使这个状态已经结束)，这是因为Prometheus希望让你知道存在过这种状态信息
  - 当相同namespace中出现更严重级别的报警，则该 ``info`` 级别通知就会结束，因为Prometheus认为通知目的已经达成

缓解方法
==========

采用如下步骤来缓解这种(可能)不必要告警:

- 将 ``severity="info"`` 级别的inhibit alerts的接受人配置为 ``null`` 接收人

  - 注意一定要配置一个 ``recivers`` 中有一个 ``name: 'null'`` ，否个可能还会会错误发送

- 并且配置为禁止 ``severity="info"`` 的警报

详细配置可以参考 `kube-prometheus/manifests/alertmanager-secret.yaml <https://github.com/prometheus-operator/kube-prometheus/blob/main/manifests/alertmanager-secret.yaml>`_

例如，对于 :ref:`prometheus-webhook-dingtalk` 采用 ``kube-prometheus-stack`` 修订 ``vaules.yaml`` 配置:

.. literalinclude:: prometheus_info-level_alert_inhibition/kube-prometheus-stack.values
   :language: yaml
   :caption: 配置 ``kube-prometheus-stack`` 修改 ``severity="info"`` 级别的inhibit alerts的接受人配置为 ``null``
   :emphasize-lines: 41-49,53,54

参考
=======

- `kube-prometheus runbooks: InfoInhibitor <https://runbooks.prometheus-operator.dev/runbooks/general/infoinhibitor/>`_
- `Inhibition rules not inhibiting common info alerts #861 <https://github.com/prometheus-operator/kube-prometheus/issues/861>`_
