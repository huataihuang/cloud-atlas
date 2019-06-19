.. _ingress_controller:

============================
Ingress控制器(controller)
============================

为了能够使得Ingress资源工作，集群需要运行一个ingress controller。

其他类型的controller是作为 ``kube-controller-manager`` 的一部分一起运行的，而Ingress Contrroller默认并不会随着集群启动而启动，你需要选择指定恰当的Ingress Controller实现以便能够最适合你的集群。

.. note::

   由于有众多的Ingress Controller实现，不同的Ingress Controller有相同之处也有各自的侧重，所以并没有一种放之四海而皆准的解决方案。例如，同样的负载均衡，既有Nginx也有HAProxy。

Ingress Controller
========================

在 `Kubernetes Concept: Ingress controller <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers>`_ 文档中介绍了很多种Ingress Controller。在kubernetes集群可以同时运行任意数量的ingress controller。当你创建了一个ingress，你需要申明ingress相应的 ``ingress.class`` 来指定使用哪个 ingress controller。

参考
========

- `Kubernetes Concept: Ingress controller <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers>`_
