.. _bare-metal_ingress_nginx:

==================================
裸金属(bare-metal) NGINX Ingress
==================================

在传统的云计算环境，网络负载均衡是按需提供的(你可以认为 ``LoadBalancer`` 已经在那里 **不离不弃** )，对于 Kubernetes 集群，默认就是使用云厂商的 ``LoadBalancer`` 为集群内提供服务的输出。但是，对于裸金属(bare-metal)环境，也就是你自己搭建的 :ref:`vanilla_k8s` ，没有这种商品化的产品，就需要一些不同的设置才能为外部用户提供服务:

.. figure:: ../../../../_static/kubernetes/network/ingress/nginx/cloud_overview.jpg
   :scale: 80

   云计算环境，云厂商为节点提供了Cloud LoadBalancer

纯软件解决方案: :ref:`metallb`
================================

:ref:`metallb` 为独立建立的Kubernetes近期群提供网络负载均衡，可以在任何集群中使用LoadBalaner服务:

.. figure:: ../../../../_static/kubernetes/network/ingress/nginx/metallb.jpg
   :scale: 80

   在自建的Kubernetes环境，MetalLB提供了负载均衡能力，替代了云厂商的LoadBalancer

安装 :ref:`metallb`
====================

.. note::

   实践环境: :ref:`metallb_with_kind`



参考
======

- `NGINX Ingress Controller Deployment: Bare-metal considerations <https://kubernetes.github.io/ingress-nginx/deploy/baremetal/>`_
