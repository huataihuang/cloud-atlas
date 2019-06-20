.. _service_mesh_architecture:

==================
Service Mesh架构
==================

微服务和云原生
================

在 :ref:`introduce_docker` 中，我们介绍了微服务是由小而独立的组件组成，组件通过网络互联，能够满足横向扩展 ``scale out`` 的软件开发形式。微服务是目前主流的分布式系统架构风格：

- 服务具有可观测性 (Observability) 
  
  - 提供平台全局检测进程运行状态、CPU和内存消耗
  - 能够非常快捷对个体、批量进行操作
  - 无需复杂开发，实现资源消耗、响应、性能、异常的全链路数据采集和分析

- 基于数据分析的微服务自动编排

  - 基于实时性能数据采集和分析，按照规则自动编排微服务
  - 自动化的调度、扩展和监视
  - 平台自动检测异常，并按照声明配置进行协调纠正

Kubernetes在引入了服务网格( `Service Mesh <https://www.cncf.io/blog/2017/04/26/service-mesh-critical-component-cloud-native-stack/>`_ ) 在Pod中集成了高度抽象的网络代理 Kube-Proxy 。服务网格可以理解成集成了动态路由、服务发现、负载均衡以及性能数据跟踪的分布式网络基础设施。

.. note::

   目前我的理解 Service Mesh 还是一个正在不断完善和逐步实现的网络代理容器，集成了众多的网络功能封装，通过标准化的声明来提供应用的网络访问入口。

   通过中心化的管理平台(Service Mesh)来设置每个逻辑单元(Pod)中的特殊的 ``代理服务`` Sidecar Container提供服务输出，这样Pod之间调用以及外部调用Pod的服务都可以通过访问 ``代理服务`` 来实现。

.. figure:: ../../_static/kubernetes/soa_msa_cna.jpg
   :scale: 50

参考
=========

- `Service Mesh——后 Kubernetes 时代的微服务 <https://jimmysong.io/posts/service-mesh-the-microservices-in-post-kubernetes-era/>`_
- `SOFAMesh文档手册 <https://www.bookstack.cn/read/SOFAMesh-zh/Home.md>`_ SOFAMesh 是基于 Istio 改进和扩展而来的 Service Mesh 大规模落地实践方案
