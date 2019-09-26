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

进化到Service Mesh
====================

Kubernetes在引入了服务网格( `Service Mesh <https://www.cncf.io/blog/2017/04/26/service-mesh-critical-component-cloud-native-stack/>`_ ) :

- Service Mesh的集成是透明代理，通过 sidecar proxy拦截到微服务间流量后再通过控制平面配置管理微服务的行为。
- Service Mesh将流量管理哦那个Kubernetes中解耦，Service Mesh内部的流量无需 ``kuube-proxy`` 组件的支持，通过更接近微服务应用层的抽象，管理服务间的流量、安全性和可观察性。
- Envoy xDS定义了Service Mesh配置的协议标准

服务网格可以理解成集成了动态路由、服务发现、负载均衡以及性能数据跟踪的分布式网络基础设施:

- Kubernetes的本质是通过声明式配置对以应用进行生命周期管理
- Service Mesh的本质是应用间的流量和安全性管理

.. note::

   目前我的理解 Service Mesh 还是一个正在不断完善和逐步实现的网络代理容器，集成了众多的网络功能封装，通过标准化的声明来提供应用的网络访问入口。

   通过中心化的管理平台(Service Mesh)来设置每个逻辑单元(Pod)中的特殊的 ``代理服务`` Sidecar Container提供服务输出，这样Pod之间调用以及外部调用Pod的服务都可以通过访问 ``代理服务`` 来实现。

.. figure:: ../../_static/kubernetes/soa_msa_cna.jpg
   :scale: 50

Kubernetes Native vs. Service Mesh
===================================

.. figure:: ../../_static/kubernetes/kubernetes_native_vs_service_mesh.jpg
   :scale: 40

- Kubernetes Native
  - 在每个Node部署了 ``kube-proxy`` 
  - ``kube-proxy`` 和Kubernetes API Server通讯
  - 获取集群到Service信息，并转化成 iptables 规则，将对某个service的请求发送到对应的Endpoint（属于同一组serive的Pod）。

- Istio Service Mesh
  - 沿用Kubernetes的service做服务注册
  - 通过控制平面(Control Plane)生成数据平面配置(使用CRD声明，存储在etcd中)
  - 数据平面采用 **透明代理** (transparent proxy)以sidecar容器的形式部署在每个应用服务的pod中
  - proxy通过请求Control Plane来同步代理配置

.. note::

   Service Mesh的透明代理和kube-proxy一样需要拦截流量，区别是kube-proxy只拦截进入Node的流量，而sidecar proxy拦截的是进出Pod的流量。

Service Mesh的缺点
--------------------

- 由于service mesh在每个pod都部署一个sidecar proxy，大量的pod会导致急剧增加的配置分发和同步以及最终一致性问题。
- 由于细粒度的流量管理，需要复杂的抽象，使得管理复杂、学习曲线陡峭。
- 性能消耗较大：目前的mesh实现还存在性能缺陷

Service Mesh的优点
-------------------

- Service Mesh通过sidecar proxy将kubernetes的流量控制从service层抽离，可以实现更多扩展

Kube-proxy的缺点
------------------

- Kube-proxy实现了多个pod实例间的负载平衡，但是缺乏流量的细粒度控制(例如按照一定百分比分流到不同的应用版本，实现金丝雀发布和蓝绿发布) - 当前有通过修改pod的label将不同的pod划分到Deployment的Service上( `Canary deployments <https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#canary-deployments>`_ )
- Kube-proxy只能路由Kubernetes集群内部的流量，集群外部无法直接与其通讯，所以Kubernetes使用了ingress资源对象，在边缘节点由Ingress
  Controlleer驱动，管理南北向流量(从集群外部进入Kubernetes集群的流量)。但是Ingress只适合HTTP流量，只能对service、port、http路径等有限字段匹配来路由流量，无法路由MySQL、redis和各种私有RPC等TCP流量。

xDS协议
=========

xDS协议控制了Istio Service Mesh的所有流量的具体行为，由Envoy提出。

Envoy通过查询文件或管理服务器来动态发现资源，对应的发现服务及其相应的API称为"xDS" :

- 文件订阅：监控指定路径下的文件
- gRPC流式订阅：每个xDS APII可以单独配置 ``ApiConfigSource`` ，指向对应的上游管理服务器的集群地址
- 轮询 REST-JSON 轮询订阅：单个xDS API可以对REST端点进行同步(长)轮询

xDS协议要点
------------

- CDS、EDS、LDS和RDS是最基础的xDS协议，可以分别独立更新
- 所有的发现服务(Discovery Service)可以连接不同的Management Server，即管理xDS的服务器可以是多个
- Envoy在原始的xDS协议基础上进行了扩展，增加了SDS（秘钥发现服务）、ADS（聚合发现服务）、HDS（健康发现服务）、MS（Metric 服务）、RLS（速率限制服务）等 API
- 为了保证数据一致性，若直接使用 xDS 原始 API 的话，需要保证这样的顺序更新：CDS –> EDS –> LDS –> RDS，这是遵循电子工程中的先合后断（Make-Before-Break）原则，即在断开原来的连接之前先建立好新的连接，应用在路由里就是为了防止设置了新的路由规则的时候却无法发现上游集群而导致流量被丢弃的情况，类似于电路里的断路
- CDS 设置 Service Mesh 中有哪些服务
- EDS 设置哪些实例（Endpoint）属于这些服务（Cluster）
- LDS 设置实例上监听的端口以配置路由
- RDS 最终服务间的路由关系，应该保证最后更新 RDS

.. figure:: ../../_static/kubernetes/xds.jpg
   :scale: 40

参考
=========

- `Service Mesh——后 Kubernetes 时代的微服务 <https://jimmysong.io/posts/service-mesh-the-microservices-in-post-kubernetes-era/>`_
- `SOFAMesh文档手册 <https://www.bookstack.cn/read/SOFAMesh-zh/Home.md>`_ SOFAMesh 是基于 Istio 改进和扩展而来的 Service Mesh 大规模落地实践方案
- `什么是服务网格？ <https://www.servicemesher.com/istio-handbook/concepts-and-principle/what-is-service-mesh.html>`_
