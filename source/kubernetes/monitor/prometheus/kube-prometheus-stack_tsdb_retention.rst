.. _kube-prometheus-stack_tsdb_retention:

============================================
``kube-prometheus-stack`` tsdb数据保存时间
============================================

虽然非常简单， ``prometheus`` 运行参数 ``--storage.tsdb.retention.time=180d`` 可以配置存储保存 ``180`` 天，但是如何在 :ref:`z-k8s_gpu_prometheus_grafana` 配置 ``kube-prometheus-stack.values`` 实现呢？

在 ``vaules.yaml`` ( ``kube-prometheus-stack.values`` )中搜索 ``retention`` 关键字就可以看到 ``prometheus.prometheusSpec.retention`` 设置了这个参数:

.. literalinclude:: kube-prometheus-stack_tsdb_retention/vaules.yaml
   :language: yaml
   :caption: 配置 ``kube-prometheus-stack`` 的 tsdb 数据保留时间
   :emphasize-lines: 17

这个运行参数传递也启发了我配置 :ref:`prometheus_web.external-url`
