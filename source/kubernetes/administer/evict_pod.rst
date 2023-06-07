.. _evict_pod:

===================
驱逐(evicted) Pods
===================

在 :ref:`drain_node` 可以看到Kubernetes是通过 ``evict`` pods方式完成的。此外，当发生 :ref:`k8s_garbage_collecttion` ， ``kubelet`` 也会自动触发 驱逐(evicted) Pods

参考
======

- `Understanding Kubernetes Evicted Pods <https://sysdig.com/blog/kubernetes-pod-evicted/>`_
- `How to evict specific pods on the Kubernetes cluster <https://dev.to/ueokande/how-to-evict-specific-pods-on-the-kubernetes-cluster-1p44>`_
- `安全地清空一个节点 <https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/safely-drain-node/>`_
- `Node-pressure Eviction <https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/>`_ : `节点压力驱逐 <https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/node-pressure-eviction/>`_
- `A guide to Kubernetes pod eviction <https://opensource.com/article/21/12/kubernetes-pod-eviction>`_
