.. _kube-prometheus-stack_persistent_nodeselector:

======================================
``kube-prometheus-stack`` 节点选择
======================================

为节点打上标签:

.. literalinclude:: kube-prometheus-stack_persistent_nodeselector/label_node
   :language: bash
   :caption: 为希望部署 ``kube-prometheus-stack`` 的节点打上表桥

- 修订 ``kube-prometheus-stack.values`` :

.. literalinclude:: kube-prometheus-stack_persistent_nodeselector/kube-prometheus-stack.values
   :language: bash
   :caption: 修订 ``kube-prometheus-stack.values`` 配置 ``nodeSelector``

- 执行更新:

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

