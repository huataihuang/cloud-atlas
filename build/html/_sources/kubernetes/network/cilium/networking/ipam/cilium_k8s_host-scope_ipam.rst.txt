.. _cilium_k8s_host-scope_ipam:

============================================
Cilium Kubernetes主机范围(host-scope) IPAM
============================================

``Kubernetes host-scope IPAM`` 模式是通过 ``ipam: kubernetes`` 激活 并且将IP地址分配委托给集群每个独立节点来实现的。IP地址从 ``PodCIDR`` 范围中取出分配给Kubernetes的每个节点。

.. figure:: ../../../../../_static/kubernetes/network/cilium/networking/ipam/k8s_hostscope.png
   :scale: 50

在 ``Kubernetes host-scope IPAM`` 模式中，Cilium agent在启动时会等待，直到 ``PodCIDR`` 范围通过 Kubernetes ``v1.Node`` 对象通过以下方式为所有激活地址群分配好:



参考
======

- `Cilium Networking » IP Address Management (IPAM) » Kubernetes Host Scope <https://docs.cilium.io/en/stable/concepts/networking/ipam/kubernetes/>`_
