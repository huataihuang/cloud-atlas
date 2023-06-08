.. _kube-prometheus-stack_alert_config:

======================================
``kube-prometheus-stack`` 告警配置
======================================

和 :ref:`prometheus_monitor_apps` 类似，通过配置 :ref:`prometheus_alerting_rules` 来实现告警通知，不过 ``kube-prometheus-stack`` 提供了 ``values`` 输入方法来简化配置，本文记录实践经验。

告警配置入口
=============

``kube-prometheus-stack`` 的 ``values.yaml`` 中可以找到如下 ``PrometheusRules`` 相关入口:

.. literalinclude:: kube-prometheus-stack_alert_config/values_default.yaml
   :language: yaml
   :caption: ``kube-prometheus-stack`` 配置 ``PrometheusRules`` 默认入口，由于这里采用独立配置文件 ``rules_disk_alert.yaml`` 所以需要注释掉 ``additionalPrometheusRulesMap: {}`` 行
   :emphasize-lines: 13

我们可以在入口上添加自定义的监控配置 :ref:`configmap` : 如果采用独立配置，则注释掉 ``additionalPrometheusRulesMap: {}`` ；如果采用合并配置，则直接在 ``additionalPrometheusRulesMap: {}`` 行下添加配置(注意要去掉 ``{}`` )

.. _prometheus_rule_diskusage:

Prometheus规则 ``DiskUsage``
==============================

- 配置 ``rules_DiskUsage.yaml`` :

.. literalinclude:: kube-prometheus-stack_alert_config/rules_disk_alert.yaml
   :language: yaml
   :caption: 添加Prometheus规则对DiskUsage告警(可以将磁盘相关告警都放到名为 ``disk_alert`` 的分组中)

上述监控目录 ``/`` 使用量，对于不同目录还要不断添加，感觉有点繁琐。改进为以下监控方式:

.. literalinclude:: kube-prometheus-stack_alert_config/rules_disk_space_alert.yaml
   :language: yaml
   :caption: 全面的主机磁盘使用空间检测，包括实例、设备和挂载点

这样就可以监视所有挂载目录，出现超过 80% 使用率报警

- 执行 :ref:`update_prometheus_config_k8s` 将上述告警配置添加:

.. literalinclude:: kube-prometheus-stack_alert_config/helm_upgrade_add_prometheus_rules
   :language: bash
   :caption: 通过 ``helm upgrade`` 添加附加的Prometheus告警规则

.. note::

   采用独立的 ``rules_disk_alert.yaml`` 需要注释掉对应 ``additionalPrometheusRulesMap: {}`` ，所以我感觉还是直接编辑 ``values.yaml`` 更为方便(只需要一个配置文件)。当然，为了能够将不同的配置归类，采用独立的配置文件也未尝不可。主要看你的运维习惯。

参考
=======

- `How are Prometheus alerts configured on Kubernetes with prometheus-community/prometheus <https://home.robusta.dev/blog/prometheus-alerts-using-prometheus-community-helm-chart>`_
- `Helm / kube-prometheus-stack: Can I create rules for exporters in values.yaml? <https://stackoverflow.com/questions/69702163/helm-kube-prometheus-stack-can-i-create-rules-for-exporters-in-values-yaml>`_
- `Prometheus: Configuring Prometheus alert rules <https://www.stackhero.io/en/services/Prometheus/documentations/Alerts/Configuring-Prometheus-alert-rules>`_ 这个告警设置非常准确可用
