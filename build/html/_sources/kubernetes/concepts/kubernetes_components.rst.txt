.. _kubernetes_components:

======================
Kubernetes组件
======================

Kubernetes Master
========================

kube-apiserver
-----------------

kube-controller-manager
------------------------

kube-scheduler
-------------------

Kubernetes Worker
=========================

在Kubernetes中，节点(node)是执行具体工作的机器，通常是物理主机，但也可以是虚拟机。在工作节点需要包含运行pods的必要服务，并由Master管控组件管理。在node上运行的服务有:

- 容器运行时(runtime) - 通常是docker
- kubelet
- kube-proxy

kuberlet
-----------

kubelet会不断报告节点状态，通过 ``describe node`` 可以显示节点状态和详细信息::

   kubectl describe node <node-name>

其中需要关注的输出有：

- ``conditions`` 字段记录了节点状态

   - ``OutOfDisk`` 为 True 时表示节点空闲空间不够分配新的Pod
   - ``MemoryPressure`` 

kube-proxy
------------

参考
========

- `Concepts <https://kubernetes.io/docs/concepts/>`_
