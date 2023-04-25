.. _prometheus_monitor_calico:

==============================
Prometheus监控Calico网络CNI
==============================

:ref:`calico` 是Kubernetes上常用的CNI，在生产环境中也有很多应用。官方提供了 `Monitor Calico component metrics <https://docs.tigera.io/calico/latest/operations/monitor/monitor-component-metrics>`_ 结合到 Prometheus 中进行监控: 通过calico的metrics获取Calico组件的健康度:

组件:

- ``Felix`` : 运行在每台实现网络策略(network policy)的主机上， ``Felix`` 是Calico的大脑
- ``Typha`` : 一组可选pod，扩展了 ``Felix`` 以扩展Calico节点和数据存储之间的流量
- ``kube-controllers`` : 控制器组件，负责各种控制平面功能，例如资源垃圾收集以及和Kubernetes API之间同步

可以配置 ``Felix`` ， ``Typha`` 和/或 ``kube-congrollers`` 来提供metrics给Prometheus

准备工作
=============

可以使用 ``kubectl`` 或 ``calicoctl`` 来修改 :ref:`calico` 配置:

- 注意，要使用 ``kubectl`` 来配置 ``calico`` ，必须在集群运行一个 ``calico`` API Server，这样 API Server会允许你管理  ``projectcalico.org/v3`` api组的资源。
- 可以任何能够访问Calico数据存储的网络节点上使用 ``calicoctl`` 来管理 ``projectcalico.org/v3`` API组

配置
=========

使用以下两个命令之一完成 ``Felix``  :ref:`metrics` 激活:

- (我没有采用该方法)使用 :ref:`kubectl` 激活 ``Felix`` metrics::

   kubectl patch felixconfiguration default --type merge --patch '{"spec":{"prometheusMetricsEnabled": true}}'

- 使用 ``calicoctl`` 激活 ``Felix`` metrics::

   calicoctl patch felixconfiguration default  --patch '{"spec":{"prometheusMetricsEnabled": true}}'

注意，直接执行 ``calicoctl get felixconfiguration`` 会提示需要明确 :ref:`etcd` endpoints ，所以实际操作应该采用以下命令检查:

.. literalinclude:: prometheus_monitor_calico/calicoctl_get_felixconfiguration
   :language: bash
   :caption: 使用calicoctl获取集群的felix配置


参考
========

- `Monitor Calico component metrics <https://docs.tigera.io/calico/latest/operations/monitor/monitor-component-metrics>`_
- `Monitoring Calico with kube-stack-prometheus <https://sbulav.github.io/kubernetes/monitoring-calico-kube-stack-prometheus/>`_
