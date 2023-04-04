.. _prometheus_monitor_kubelet_controller-manager_scheduler:

==================================================================
Prometheus监控Kubelet, kube-controller-manager 和 kube-scheduler
==================================================================

修订 ``kubelet`` 配置
=======================

在排查 :ref:`prometheus_metrics_connect_refuse` 时可以看到，Kubelet的metrics监控采集并不是 ``connection refused`` 报错，而是 ``server returned HTTP status 403 Forbidden``

而且我也发现，并不是所有节点都出现 ``403 Forbidden`` ，管控服务器 ``control001`` 到 ``control003`` 这3台服务器的kubelet是正常监控的(实际上工作节点采用了手工安装的定制 ``kubelet`` 软件包)

.. figure:: ../../../_static/kubernetes/monitor/prometheus/prometheus_monitor_kubelet_403_forbidden.png
   :scale: 50

对比检查了生产环境，管控服务器采集没有问题:

- 比较异常节点和正常节点 ``kubelet`` 运行参数:

.. literalinclude:: prometheus_monitor_kubelet_controller-manager_scheduler/kubelet_parameter_ok
   :language: bash
   :caption: **能够** 通过 ``10250`` 端口访问 :ref:`metrics` 的 ``kubelet`` 运行参数

异常的节点采用了非常复杂的 ``kubelet`` 参数，其中影响的参数如下::

   --authorization-mode=Webhook

这个参数配置在 ``/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`` 中(如果你使用了 ``kubeadm`` 部署)，对应配置:

.. literalinclude:: prometheus_monitor_kubelet_controller-manager_scheduler/10-kubeadm.conf
   :language: bash
   :caption: 默认 ``kubeadm`` 部署 ``kubelet`` 配置了 ``--authorization-mode=Webhook``

修订添加 ``--authentication-token-webhook=true`` ，即:

.. literalinclude:: prometheus_monitor_kubelet_controller-manager_scheduler/10-kubeadm_fix.conf
   :language: bash
   :caption: 修订添加 ``--authentication-token-webhook=true``

此外，部署中可能还有如下禁止 ``cadvisor-port`` 配置，也需要移除::

   cadvisor-port=0

完成修订之后，需要重启 ``kubelet`` 服务

修复 ``kubelet`` 配置脚本
===========================

综合以上操作，可以使用如下脚本来修正:

.. literalinclude:: prometheus_monitor_kubelet_controller-manager_scheduler/fix_prometheus_monitor_configs
   :language: bash
   :caption: 修正 Kubelet, kube-controller-manager 和 kube-scheduler 配置，以便prometheus能够监控cadvisor

修订 ``kube-controller-manager`` 和 ``kube-scheduler`` 配置
============================================================

``kube-controller-manager`` 和 ``kube-scheduler`` 默认无法被 :ref:`prometheus` 监控是因为其默认 ``metrics`` 只在回环地址 ``127.0.0.1`` 上提供。由于 ``kubeadm`` 部署的管控服务都是采用 :ref:`static_pod` (通过 ``kubelet`` 确保 ``pod`` 始终运行)，所以修订 ``/etc/kubernetes/manifest/`` 目录下对应配置:

- ``/etc/kubernetes/manifest/kube-controller-manager.yaml`` ::

   ...
   - --bind-address=0.0.0.0
   ...
   - --port=10252

- ``/etc/kubernetes/manifest/kube-scheduler.yaml`` ::

  ...
  - --bind-address=0.0.0.0
  ...
  - --port=10251

参考
=======

- `Prometheus kubelet metrics server returned HTTP status 403 Forbidden <https://centosquestions.com/prometheus-kubelet-metrics-server-returned-http-status-403-forbidden/>`_ 以这篇文档为参考
- `How to Monitor the Kubelet <https://sysdig.com/blog/how-to-monitor-kubelet/>`_
- `Cadvisor metrics scraping generates - HTTP server returned HTTP status 403 Forbidden #3941 <https://github.com/prometheus-operator/prometheus-operator/issues/3941>`_
- `How To Fix "server returned HTTP status 403 Forbidden" in Prometheus <https://www.henryxieblogs.com/2018/11/how-to-fix-server-returned-http-status.html>`_
