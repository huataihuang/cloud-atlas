.. _deployment:

======================
Deployment
======================

创建Deployment
=================

- 要查看 Deployment 上线状态::

   kubectl rollout status deployment/nginx-deployment

.. note::

   实践命令参考 `kubectl rollout <https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_rollout/>`_

   `Understanding Kubernetes Deployment Strategies <https://betterprogramming.pub/understanding-kubernetes-deployment-strategies-12535c3cb379>`_ 提供了完整的解释，我后面再展开实践一下

   比较简单的可以参考NetApp的Spot产品的文档 `5 Kubernetes Deployment Strategies: Roll Out Like the Pros <https://spot.io/resources/kubernetes-autoscaling/5-kubernetes-deployment-strategies-roll-out-like-the-pros/>`_

参考
=====

- `Kubernetes 文档 概念 工作负载 工作负载资源 Deployments <https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/deployment/>`_
