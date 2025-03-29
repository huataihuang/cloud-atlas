.. _k8s_nodeaffinity:

===============================
Kubernetes ``nodeAffinity``
===============================

.. note::

   在配置 :ref:`daemonset` 时候，可以采用 :ref:`daemonset_nodeaffinity` 来实现哪些节点需要部署哪些DS； ``nodeAffinity`` 可以比 ``nodeSelector`` 更灵活

参考
========

- `Assigning Pods to Nodes: Node affinity <https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity>`_
