.. _kube-prometheus-stack_persistent_volume:

========================================
``kube-prometheus-stack`` 持久化卷
========================================

:ref:`helm3_prometheus_grafana` 默认部署的监控采用了内存储存，我当时找到 `Deploying kube-prometheus-stack with persistent storage on Kubernetes Cluster <https://blog.devops.dev/deploying-kube-prometheus-stack-with-persistent-storage-on-kubernetes-cluster-24473f4ea34f>`_ 参考，想构建一个PV/PVC来用于Prometheus，但是没有成功。

手工编辑 :ref:`statefulset` prometheus，添加存储 PV/PVC 实际上不能成功，包括我想编辑 ``nodeSelector`` 来指定服务器，也完全无效。正在绝望的时候，找到 `[kube-prometheus-stack] [Help] Persistant Storage #186 <https://github.com/prometheus-community/helm-charts/issues/186>`_ 和 `[prometheus-kube-stack] Grafana is not persistent #436 <https://github.com/prometheus-community/helm-charts/issues/436>`_ ，原来 ``kube-prometheus-stack`` 使用了 `Prometheus Operator
<https://github.com/prometheus-operator/prometheus-operator>`_ 来完成部署，实际上在最初生成 ``kube-prometheus-stack.values`` 这个文件中已经包含了大量的配置选项(包括存储)以及注释:

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/helm_inspect_values_prometheus-stack
   :language: bash
   :caption: ``helm inspect values`` 输出Prometheus Stack的chart变量值

检查生成的 ``kube-prometheus-stack.values`` 可以看到如下配置内容:

.. literalinclude:: kube-prometheus-stack_persistent_volume/kube-prometheus-stack.values
   :language: yaml
   :caption: ``kube-prometheus-stack.values`` 包含的持久化存储配置模版

``hostPath`` 存储卷
=====================

我实现简单的 :ref:`k8s_hostpath` :

.. literalinclude:: kube-prometheus-stack_persistent_volume/kube-prometheus-stack.values_hostpath
   :language: yaml
   :caption: ``kube-prometheus-stack.values`` 配置简单的本地 ``hostPath`` 存储卷

- 更新:

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

参考
======

- `Deploying kube-prometheus-stack with persistent storage on Kubernetes Cluster <https://blog.devops.dev/deploying-kube-prometheus-stack-with-persistent-storage-on-kubernetes-cluster-24473f4ea34f>`_ 这个持久化卷的配置方法不成功，但是持久化卷应用方法不通
- `[kube-prometheus-stack] how to use persistent volumes instead of emptyDir <https://github.com/prometheus-community/helm-charts/issues/2816>`_ 提供yaml配置定制helm安装
- `[prometheus-kube-stack] Grafana is not persistent #436 <https://github.com/prometheus-community/helm-charts/issues/436>`_ 提供了设置存储的案例，采用 StorageClass 会自动创建存储卷，不需要预先创建
