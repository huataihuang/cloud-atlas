.. _z-k8s_cilium_metallb:

==================================================
Kubernetes集群(z-k8s)配置Cilium集成MetalLB
==================================================

:ref:`metallb_with_cilium` 为裸金属服务器(虚拟机)提供了替代常规云厂商的负载均衡能力，这样就可以摆脱云厂商的依赖，完全独立构建Kubernetes集群。

.. note::

   如果Kubernetes集群不部署 :ref:`metallb` ，就会导致 :ref:`cilium_k8s_ingress` 无法分配 ``EXTERNAL-IP`` ，即无法对外服务

安装
=======

- 在集群安装MetalLB:

.. literalinclude:: ../../kubernetes/network/metallb/metallb_with_cilium/kubectl_metallb-native
   :language: bash
   :caption: kubectl apply 安装 MantalLB

配置
======

- 创建 ``z-k8s-ip-pool.yaml``

.. literalinclude:: ../../kubernetes/network/metallb/metallb_with_cilium/z-k8s-ip-pool.yaml
   :language: yaml
   :caption: 为负载均衡定义IPAddressPool CR

- 创建IP池:

.. literalinclude:: ../../kubernetes/network/metallb/metallb_with_cilium/kubectl_create_ipaddresspool
   :language: bash
   :caption: 负载均衡创建IPAddressPool

- 配置 ``z-k8s-ip-pool_announce.yaml`` :

.. literalinclude:: ../../kubernetes/network/metallb/metallb_with_cilium/z-k8s-ip-pool_announce.yaml
   :language: yaml
   :caption: 申明IP地址池的ARP公告

- 执行IP地址池ARP声明:

.. literalinclude:: ../../kubernetes/network/metallb/metallb_with_cilium/ip-pool_announce
   :language: yaml
   :caption: 申明IP地址池的ARP公告

完成 :ref:`metallb` 部署配置之后，部署 :ref:`z-k8s_cilium_ingress` 就能够实现服务输出
