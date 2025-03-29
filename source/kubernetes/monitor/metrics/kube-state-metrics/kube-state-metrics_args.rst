.. _kube-state-metrics_args:

===================================
kube-state-metrics (KSM) 运行参数
===================================

``metric-labels-allowlist`` 运行参数
======================================

:ref:`helm3_prometheus_grafana` 时可以向 ``kube-state-metrics`` :ref:`helm` chart 添加附加参数(单独安装 ``kube-state-metrics`` chart也可以传递)

.. note::

   :ref:`kube-prometheus-stack_extraargs` 可以在 ``values`` 配置中为组件pods定制所需参数，我的实践就是定制 ``--metric-labels-allowlist`` 参数

参考
======

- `kubernetes/kube-state-metrics <https://github.com/kubernetes/kube-state-metrics>`_
- `How can we include custom labels/annotations of K8s objects in Prometheus metrics? <https://stackoverflow.com/questions/74043719/how-can-we-include-custom-labels-annotations-of-k8s-objects-in-prometheus-metric?rq=1>`_
- `kube-state-metrics docs: cli-arguments.md <https://github.com/kubernetes/kube-state-metrics/blob/main/docs/cli-arguments.md>`_
- `kube-state-metrics Installation <https://coroot.com/docs/metric-exporters/kube-state-metrics/installation>`_
- `Using prometheus-community helm chart how can I expose custom pod labels <https://stackoverflow.com/questions/71351552/using-prometheus-community-helm-chart-how-can-i-expose-custom-pod-labels>`_
