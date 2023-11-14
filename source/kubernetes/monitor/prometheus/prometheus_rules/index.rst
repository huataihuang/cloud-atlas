.. _prometheus_rules:

======================
Prometheus 规则
======================

Prometheus有两种类型规则(two types of rules)需要配置:

- 记录规则(recording rules)
- 告警规则(alerting rules) :ref:`alert_manager`

要定制自己的Prometheus规则，需要创建一个包含规则的YAML文件，然后在 :ref:`prometheus_configuration` 中 ``rule_files`` 加载。

加载以后，在Prometheus的WEB界面 ``Rules`` 可以看到规则，切换到 ``Alerts`` 页面可以看到当前告警的活动状态

规则语法检查
==============

无需启动 ``prometheus`` 服务，就可以通过以下命令检查规则文件语法是否正确::

   promtool check rules /path/to/example.rules.yml

.. toctree::
   :maxdepth: 1

   prometheus_recording_rules.rst
   prometheus_alerting_rules.rst
   prometheus_monitor_apps.rst
   kube-prometheus-stack_alert_config.rst
   kube-prometheus-stack_update_rule.rst
   prometheus_etcdDatabaseHighFragmentationRatio.rst
