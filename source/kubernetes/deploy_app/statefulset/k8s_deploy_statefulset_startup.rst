.. _k8s_deploy_statefulset_startup:

===================================
Kubernetes部署StatefulSet起步
===================================

调度
=====

我在部署 :ref:`z-k8s_gpu_prometheus_grafana` 时候，期望将 ``prometheus-stack`` 中的 ``StatfulSet`` pod ``prometheus-kube-prometheus-stack-1681-prometheus-0`` 调度到指定服务器 ``i-0jl8d8r83kkf3yt5lzh7`` ，而不是随机分布在集群的任意节点。
 
但是，和常规的无状态 :ref:`workload_resources` (例如 :ref:`deployment` )不同，在 ``spec`` 中添加 ``nodeSelector`` ( :ref:`k8s_nodeselector` ) 并没有作用(配置修改不报错，但是修改后配置项消失且无效):

.. literalinclude:: k8s_deploy_statefulset_startup/statefulset_nodeselector.yaml
   :language: yaml
   :caption: 配置 ``PodTemplateSpec`` 设置 ``nodeSelector`` 但是没有成功
   :emphasize-lines: 11,12

而且我尝试了 ``nodeAffinity`` 也没有成功:

.. literalinclude:: k8s_deploy_statefulset_startup/statefulset_nodeaffinity.yaml
   :language: yaml
   :caption: 配置 ``PodTemplateSpec`` 设置 ``nodeAffinity`` 但是没有成功
   :emphasize-lines: 10-18

`Modifying nodeSelector on StatefulSet doesn't reschedule Pods #57838 <https://github.com/kubernetes/kubernetes/issues/57838>`_ 提到修改StatefulSet不会触发pod调度telemetry: prometheus

.. note::

   StatefulSet 使用 ``VolumeClaimTemplate`` 来为每个pod挂载持久化卷(PV)

暂未解决，待研究

参考
========

- `StatefulSet 基础 <https://kubernetes.io/zh-cn/docs/tutorials/stateful-application/basic-stateful-set/>`_
