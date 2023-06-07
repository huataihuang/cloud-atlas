.. _kube-prometheus-stack_update_rule:

=====================================
更改 ``kube-prometheus-stack`` 规则
=====================================

.. warning::

   本文的方法还在学习和探索中，目前我暂时采用手工修订方法，实际上还不符合社区 ``kube-prometheus-stack`` 修订规范。正确的修订方法应该参考 `kube-prometheus-stack hacks <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack>`_ 使用社区提供的工具进行修订，而不是直接修改Kubernetes已经安装的对象。

.. note::

   通过 :ref:`helm` 的 ``pull`` 下载 ``kube-prometheus-stack`` :ref:`custom_helm_charts` ，可以看到社区推荐 `kube-prometheus-stack hacks <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack>`_ 修订方法

在 :ref:`helm3_prometheus_grafana` 之后，我们可以通过以下命令观察到 ``kube-prometheus-stack`` 部署了哪些对象:

.. literalinclude:: ../helm3_prometheus_grafana/helm_get_manifest
   :language: bash
   :caption: 获取 ``kube-prometheus-stack`` 安装的对象

在 :ref:`kube-prometheus-stack_alert_config` 添加了自定义规则，那么，对于 ``kube-prometheus-stack`` 提供的默认规则，我们有办法修订么？

根据 ``helm get maifest`` 输出可以看到规则对象是::

   prometheusrule.monitoring.coreos.com/kube-prometheus-stack-1681-alertmanager.rules
   ...

检查这个规则对象，可以直接编辑 ``prometheusrule`` 修订，不过这不是标准方法(后续补充)，只能临时修订

修订默认15分钟 ``pending`` 告警
==================================

在生产环境，有些告警不需要默认15分钟直接通知，因为生产中有一些自动化工具会定时清理掉 ``Error`` 状态的 pods ，所以修订 ``KubePodNotReady`` 告警通知周期(也就是允许 ``pending`` 一段状态才会发送告警)

在 ``helm pull`` 的 ``kube-prometheus-stack`` 搜索 ``KubePodNotReady`` 关键字，可以看到 ``templates/prometheus/rules-1.14/kubernetes-apps.yaml`` 配置了这个告警规则:

.. literalinclude:: kube-prometheus-stack_update_rule/kubernetes-apps.yaml
   :language: yaml
   :caption: ``KubePodNotReady`` 告警规则
   :emphasize-lines: 21

- 检查系统规则::

   kubectl -n prometheus get prometheusrule

对应 ``KubePodNotReady`` 的 ``prometheusrule`` 是 ``kube-prometheus-stack-1681-kubernetes-apps``

- 编辑::

   kubectl -n prometheus edit prometheusrule kube-prometheus-stack-1681-kubernetes-apps

当前内容就是前面 ``helm pull`` 下来 ``kube-prometheus-stack`` 的默认 ``kubernetes-apps.yaml`` 的15分钟配置，修改对应时间并保存。

.. note::

   后续我实践 :ref:`helm_customize_kube-prometheus-stack` 时会按照标准方式修订默认规则，待实践

参考
=====

- `Correct way to update rules and configuration for a Prometheus installation on a Kubernetes cluster that was setup by prometheus-operator helm chart? <https://stackoverflow.com/questions/54766301/correct-way-to-update-rules-and-configuration-for-a-prometheus-installation-on-a>`_
