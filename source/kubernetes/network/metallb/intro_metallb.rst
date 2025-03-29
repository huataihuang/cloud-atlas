.. _intro_metallb:

=====================
MetalLB简介
=====================

MetalLB是用于裸金属(bare metal) Kubernetes集群的负载均衡实现，使用标准化路由协议。

MetalLB的作用
=================

Kubernetes 不为裸机集群提供网络负载均衡器（LoadBalancer 类型的服务）的实现。Kubernetes 附带的网络负载均衡器的实现都是调用各种 IaaS 平台（GCP、AWS、Azure……）的胶水代码。

如果没有在受支持的 IaaS 平台（GCP、AWS、Azure……）上运行，LoadBalancers 在创建时将始终保持在 ``pending`` (挂起)状态。

Bare-metal集群operator通常只提供了非常简陋的 ``NodePort`` 和 ``externalIPs`` 服务，这两种方式都无法满足生产需求。 :ref:`metallb` 提供了类似标准网络设备集成的网络负载均衡实现，这样 Bare-metal集群 也能用于生产环境。

参考
========

- `MetalLB 官网 <https://metallb.universe.tf>`_
