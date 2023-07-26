.. _y-k8s_kube-prometheus-stack:

==================================
y-k8s集群部署kube-prometheus-stack
==================================

在完成 :ref:`y-k8s_nvidia_gpu_operator` 之后， ``y-k8s`` 集群已经具备了GPU加速 :ref:`machine_learning` 能力。为了方便观测，部署 :ref:`prometheus` stack来实现

部署采用 :ref:`z-k8s_gpu_prometheus_grafana` 相同方法，在原有方案基础上做一些迭代改进，详细步骤记录在 :ref:`y-k8s_gpu_prometheus_grafana` ，本文做一个精简索引

安装Prometheus 和 Grafana
=============================

- 添加 Prometheus 社区helm chart:

.. literalinclude:: ../../kubernetes/monitor/prometheus/helm3_prometheus_grafana/helm_repo_add_prometheus
   :language: bash
   :caption: 添加 Prometheus 社区helm chart

待续...我需要先实现 :ref:`calico` + :ref:`istio` 再回过来完成这里的部署
