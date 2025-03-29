.. _federation_evolution:

==========================
Kubernetes Federation发展
==========================

Federation概念
===============

在Federation中，为了解决复杂的问题，将问题分解为不同部分

.. image:: ../../../_static/kubernetes/federation_concepts.png
   :scale: 75

组合(federating)抽象资源
===========================

Federation的主要目标质疑就是能够定义包含基本信条来组合(federate)任何给定的Kubernetes资源实现API和API组。这是至关重要的，也是CustomResourceDefinitions(CRD)作为扩展Kubernetes的新API的流行原因。

参考
=========

- `Kubernetes Federation Evolution <https://kubernetes.io/blog/2018/12/12/kubernetes-federation-evolution/>`_
