.. _prometheus-webhook-dingtalk_body_limit:

=============================================
``prometheus-webhook-dingtalk`` 钉钉消息过长
=============================================

在配置 :ref:`prometheus-webhook-dingtalk` 接收了大量 Prometheus 告警之后，突然发现从某个时间开始，不再接收到新的告警通知，感觉不太正常。

从 Prometheus 的 ``Alerts`` 页面查看，可以看到系统是有很多 ``Firing`` 状态的告警，也就是说已经通过alertmanager发送告警。但是为何钉钉消息没有收到?

检查 :ref:`systemd_prometheus-webhook-dingtalk` ，也就是通过 :ref:`systemd` 的 :ref:`journalctl` 检查服务日志:

.. literalinclude:: prometheus-webhook-dingtalk_body_limit/journal_prometheus-webhook-dingtalk
   :language: bash
   :caption: 执行 :ref:`journalctl` 检查 ``prometheus-webhook-dingtalk`` 服务日志

可以看到服务日志显示钉钉消息过长( ``resp_status=400`` / ``respCode=460101`` )

.. literalinclude:: prometheus-webhook-dingtalk_body_limit/journal_prometheus-webhook-dingtalk_output
   :language: bash
   :caption: ``prometheus-webhook-dingtalk`` 日志显示消息体过长(超过2k)导致被钉钉服务器拒绝

消息过长主要原因:

- 大量报警，Prometheus采用group方式聚合导致消息过长
- ``inhibit_rules`` 有很多重复报警
- 默认info级别消息过多

`Error- Message is too long #30 <https://github.com/timonwong/prometheus-webhook-dingtalk/issues/30>`_ 有人提到了尝试修改 ``inhibit_rules`` 消除重复报警，我觉得可行。例如默认配置:

.. literalinclude:: prometheus-webhook-dingtalk_body_limit/inhibit_rules_default
   :language: yaml
   :caption: 默认 ``inhibit_rules``
   :emphasize-lines: 5

修改成:

.. literalinclude:: prometheus-webhook-dingtalk_body_limit/inhibit_rules_change
   :language: yaml
   :caption: ``inhibit_rules`` 修改成只抑制warning，过滤掉info级别消息
   :emphasize-lines: 5

我简化成放弃 ``InfoInhibitor`` 告警，并且只接收 ``warning`` 和 ``critical`` ( ``inhibit_rules`` 配置保持没有修改 ):

.. literalinclude:: prometheus-webhook-dingtalk_body_limit/alertmanager_warning_critical
   :language: yaml
   :caption: alertmanager告警仅接收warning和critical
   :emphasize-lines: 34-36,40-42



参考
======

- `alertmanager 发钉钉告警报400错误 <https://blog.51cto.com/u_536410/3392905>`_
- `Error- Message is too long #30 <https://github.com/timonwong/prometheus-webhook-dingtalk/issues/30>`_
