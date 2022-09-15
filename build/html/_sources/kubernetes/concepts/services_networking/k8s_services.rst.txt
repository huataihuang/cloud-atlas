.. _k8s_services:

============================
Kubeernetes服务(services)
============================

在 :ref:`cilium_k8s_ingress_http` 我困扰于如何给Ingress配置External-IP，这需要理解Kubernetes对 ``公开为网络服务的抽象方法`` :

- 在 Kubernetes 中，通常使用 ``deployment`` 来部署应用，此时会使用 ``pod`` 。但是需要注意 ``pod`` 是一个有生命周期的非永久性资源，会被动态创建和销毁
- ``pod`` 的生生死死，分配的IP地址不同，所以需要使用一种方式来管理提供工作负载的后端(也就是 ``workload`` 概念)
- ``services`` 资源就是定义一组 ``pod`` 的访问策略 (也就是微服务) ， ``service`` 针对的 ``pod`` 集合通常是使用 :ref:`labels_and_selectors` 来确定

  - 在 ``deployment`` 中，后端的 ``pod`` 是可以互换(不区分)的，前端不应该也不必知道后端，而是通过 ``service`` 来管理
  - 当 ``service`` 中的 ``pod`` 集合发生变化(pod的创建和销毁)，则 ``kube-apiserver`` 提供的 ``Endpoints`` 资源就会更新，以提供查询(Kubernetes API 服务发现)

例如，我在 :ref:`z-k8s_nerdctl` 定义了 ``deployment`` :

.. literalinclude:: ../../../real/priv_cloud/z-k8s_nerdctl/z-dev-depolyment.yaml
   :language: yaml
   :caption: z-dev部署配置z-dev-depolyment.yaml，定义了pod输出的3个服务端口 22,80,443

.. note::

   在构建 ``deployment`` 中定义 ``labels`` 可以配合后面的 ``service`` 中的 ``selector`` ，也就把 ``pod`` 和 ``service`` 关联了起来，这就是 :ref:`labels_and_selectors` 的秘密

然后，我又可以针对上述 ``worklod`` ( ``deployment`` ) 来定义 ``service`` :

.. literalinclude:: ../../../real/priv_cloud/z-k8s_cilium_ingress/z-dev-svc.yaml
   :language: yaml
   :caption: 定义z-dev对外服务

.. note::

   定义 ``service`` 中的 ``port`` 可以映射到任意 ``targetPort`` ，而默认情况下， ``targetPort`` 设置成与 ``port`` 相同值



参考
======

- `Kubernetes Concept - Service <https://kubernetes.io/docs/concepts/services-networking/service/>`_
- `Kubernetes 文档/概念/服务、负载均衡和联网/服务(Service) <https://kubernetes.io/zh-cn/docs/concepts/services-networking/service>`_
