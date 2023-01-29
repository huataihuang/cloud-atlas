.. _kind_ingress:

====================
kind Ingress
====================

通常对于 Kubernetes 集群部署:

- 对于小型部署，可以直接通过 :ref:`k8s_ingress` 对外expose服务，类似于直接使用 :ref:`nginx` 反向代理对外提供 :ref:`web`
- 对于大型部署(云计算)，需要将四层负载均衡( 如 :ref:`metallb` )和七层负载均衡( 如 :ref:`ingress` )功能分离，以便实现更高的性能和控制能力

.. note::

   :ref:`k8s_loadbalancer_ingress` 解释在Kubernetes中 ``LoadBalancer`` 是如何和 ``Ingress`` 协作

:ref:`k8s_ingress` 提供对集群中服务的外部访问进行管理，如果希望实现简化的网络模型，可以不部署 :ref:`metallb` (四层负载均衡) ，直接采用 :ref:`ingress` 对外expose :ref:`k8s_services` 。对于采用 :ref:`install_docker_macos` 需要注意，实际 :ref:`docker` 是部署在一个Linux虚拟机中，所以容器(包括 kind nodes)都只能通过 ``port-forward`` 访问，此时采用 :ref:`ingress` 部署方式，可以实现跨平台的通用解决方案(因为kind为 :ref:`ingress`
部署做了一个Patch，直接把ingress的服务端口通过kind node的 `Extra Port Mappings <https://kind.sigs.k8s.io/docs/user/configuration#extra-port-mappings>`_ 转发到kind node上)。

Kind Ingress Patch方式安装集群
================================

.. note::

   我没有采用patch方式部署kind集群( `Extra Port Mappings <https://kind.sigs.k8s.io/docs/user/configuration#extra-port-mappings>`_ )，虽然这样比较简单，但是不是通用的Kubernetes部署模式。我希望采用完整的类似 :ref:`cilium_k8s_ingress_http` 结合 :ref:`metallb` 和 :ref:`ingress_nginx` 来实现完成的 ``四层负载均衡 + 七层负载均衡`` 架构，所以我没有采用创建kind集群时结合 ``extraPortMappings`` + ``node-labels``
   ，而是采用标准部署 :ref:`ingress_nginx` 再部署 :ref:`metallb` 。

   这段仅记录

- 对于仅采用 :ref:`ingress` 部署Kind集群(删减掉 :ref:`kind_loadbalancer` )，需要结合 ``extraPortMappings`` 和 ``node-labels`` 部署集群:

  - ``extraPortMappings`` 允许本地主机在端口80和443向 :ref:`ingress` controller发起请求
  - ``node-labels`` 只允许 :ref:`ingress` controller 运行在符合标签选择(label selector)的特定节点

.. literalinclude:: kind_ingress/create_kind_cluster_extraportmappings
   :language: bash
   :caption: 创建结合 ``extraPortMappings`` 和 ``node-labels`` 的kind集群

Kind集群部署Ingress
=======================

- :ref:`kind_ingress_nginx`

参考
======

- `kind User Guide: Ingress <https://kind.sigs.k8s.io/docs/user/ingress/>`_
