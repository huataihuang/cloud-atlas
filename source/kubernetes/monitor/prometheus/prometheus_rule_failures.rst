.. _prometheus_rule_failures:

=========================================
Prometheus "PrometheusRuleFailures" 告警
=========================================

在 :ref:`prometheus_info-level_alert_inhibition` 后，inhibition alert 消除，但是我发现收到了 ``PrometheusRuleFailures`` 告警:

.. literalinclude:: prometheus_rule_failures/PrometheusRuleFailures
   :caption: ``PrometheusRuleFailures`` 告警

点击 Graph 链接可以看到Query语句是:

.. literalinclude:: prometheus_rule_failures/PrometheusRuleFailures_query
   :caption: ``PrometheusRuleFailures`` 查询语句

查询有两条记录:

.. literalinclude:: prometheus_rule_failures/PrometheusRuleFailures_query_output
   :caption: ``PrometheusRuleFailures`` 查询结果

那么，这里提示有2条规则评估错误:

是什么规则？

登录到 ``prometheus-kube-prometheus-stack-1681-prometheus-0`` pods 中检查上述两个规则，非别对应 ``kubelet`` 规则:

- ``/etc/prometheus/rules/prometheus-kube-prometheus-stack-1681-prometheus-rulefiles-0/default-kube-prometheus-stack-1681-kubelet.rules-9b578b57-68f0-4d5e-9899-f1f747f2040f.yaml``

.. literalinclude:: prometheus_rule_failures/kubelet.rules
   :language: yaml
   :caption: ``/etc/prometheus/rules/prometheus-kube-prometheus-stack-1681-prometheus-rulefiles-0/default-kube-prometheus-stack-1681-kubernetes-system-kubelet-c8833e9e-9fe3-4187-a8c3-9bdc00a245d3.yaml`` 规则

输入到 Prometheus 中验证:

结果提示错误:

.. literalinclude:: prometheus_rule_failures/kubelet.rules_output
   :language: yaml
   :caption: 规则查询输出报错

- ``/etc/prometheus/rules/prometheus-kube-prometheus-stack-1681-prometheus-rulefiles-0/default-kube-prometheus-stack-1681-kubernetes-system-kubelet-c8833e9e-9fe3-4187-a8c3-9bdc00a245d3.yaml``

.. literalinclude:: prometheus_rule_failures/kubenetes-system-kubelet.rules
   :language: yaml
   :caption: ``/etc/prometheus/rules/prometheus-kube-prometheus-stack-1681-prometheus-rulefiles-0/default-kube-prometheus-stack-1681-kubernetes-system-kubelet-c8833e9e-9fe3-4187-a8c3-9bdc00a245d3.yaml``

这个rules文件有多条查询，其中也有一条比较奇怪，验证查询报错:

.. literalinclude:: prometheus_rule_failures/kubenetes-system-kubelet.rules_output
   :language: yaml
   :caption: ``/etc/prometheus/rules/prometheus-kube-prometheus-stack-1681-prometheus-rulefiles-0/default-kube-prometheus-stack-1681-kubernetes-system-kubelet-c8833e9e-9fe3-4187-a8c3-9bdc00a245d3.yaml``




待续...
