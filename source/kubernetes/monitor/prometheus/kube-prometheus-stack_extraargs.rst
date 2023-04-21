.. _kube-prometheus-stack_extraargs:

=========================================================
``kube-prometheus-stack`` 扩展运行参数( ``extraArgs`` )
=========================================================

在使用 :ref:`helm` 完成 :ref:`z-k8s_gpu_prometheus_grafana` ，有一个需求是定制 :ref:`kube-state-metrics` 运行参数:

.. literalinclude:: kube-prometheus-stack_extraargs/kube-state-metrics.yaml
   :language: yaml
   :caption: 定制 ``kube-state-metrics`` 运行参数
   :emphasize-lines: 11

虽然可以通过 ``kubectl -n prometheus edit deploy kube-prometheus-stack-1681228346-kube-state-metrics`` 直接修订添加 ``--metric-labels-allowlist`` 运行参数，但是如果执行 :ref:`update_prometheus_config_k8s` 就会被刷掉，所以我们需要固化参数。

仔细检查 ``kube-prometheus-stack.values`` 可以看到在 ``prometheus-node-exporter`` 这个 ``subchart`` 有定制运行参数的配置:

.. literalinclude:: kube-prometheus-stack_extraargs/kube-prometheus-stack.values_prometheus-node-exporter
   :language: yaml
   :caption: ``kube-prometheus-stack.values`` 的 ``prometheus-node-exporter`` extraArgs 参数
   :emphasize-lines: 10-12

原来 ``kube-prometheus-stack.values`` 每个 subchart 都可以采用类似方法定制pod中镜像运行参数(多个container该怎么搞?)

参考 `Using prometheus-community helm chart how can I expose custom pod labels <https://stackoverflow.com/questions/71351552/using-prometheus-community-helm-chart-how-can-i-expose-custom-pod-labels>`_ 做如下定制:

.. literalinclude:: kube-prometheus-stack_extraargs/kube-prometheus-stack.values_kube-state-metrics
   :language: yaml
   :caption: 定制 ``kube-prometheus-stack.values`` 的 ``kube-state-metrics`` extraArgs 参数
   :emphasize-lines: 8-9

然后执行 :ref:`update_prometheus_config_k8s` :

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
      :language: bash
      :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

参考
=======

- `Using prometheus-community helm chart how can I expose custom pod labels <https://stackoverflow.com/questions/71351552/using-prometheus-community-helm-chart-how-can-i-expose-custom-pod-labels>`_
