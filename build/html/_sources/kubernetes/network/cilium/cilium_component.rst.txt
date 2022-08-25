.. _cilium_component:

====================
Cilium组件
====================

.. figure:: ../../../_static/kubernetes/network/cilium/cilium-arch.png
   :scale: 40

在Kubernetes集群中部署Cilium和Hubble包含了以下组件:

Cilium
=======

Agent
--------

Cilium agent( ``cilium-agent`` )在集群的每个节点上运行。从高层视角来看，agent通过Kubernetes或API接受配置，这些配置描述了网络、服务负载均衡、网络策略以及可见性和监控要求。

Cilium agent从kubernetes这样的编排系统通过监听实践来了解容器或者工作负载的启动和停止。agent管理Linux内核所用的 :ref:`ebpf` 程序来控制所有进出容器的网络访问。

Client(CLI)
--------------

Cilium命令行客户端( ``cilium`` )是一个和Cilium agent交互的工具。 ``cilium`` 命令和运行在相同节点的Cilium agent的REST API交互。CLI可以检查本地agent的状态，也提供了直接访问 :ref:`ebpf` maps来验证这些agent的状态。

Operator
---------

Cilium Operator负责管理集群的任务，逻辑上为整个集群处理一次任务，而不是在集群的每个节点上处理一次。Cilium Operator不是任何转发或网络策略决策的关键路径，所以如果Operator暂时不可用，集群通常可以继续运行。

然而，根据配置， Operator不可用情况下可能会导致:

- 导致 :ref:`cilium_ipam` 延迟，进而导致新的工作负载延迟调度(如果这个操作需要分配新的IP地址)
- 不能及时更新kv存储的心跳，这回导致agent声明kv存储工作不正常并不断重启

CNI Plugin
------------

当pod调度到一个节点或者pod终止时，Kubernetes会调用CNI plugin( ``cilium-cni`` )。CNI plugin与节点的Cilium API交互以触发必要的数据路径配置，从而提供网络、负载均衡和网络策略。

Hubble
========

Server
--------

Huber server运行在每个node节点，负责采集Cilium的 :ref:`ebpf` 可视化数据。Huber Server是嵌入在Cilium agent中的，这样能够达到高性能和低资源消耗。并且Huber Server还提供一个gRPC服务用于流量检索和 :ref:`prometheus` metrics

Relay
-------

``hubble-relay`` 是一个独立组件，能够感知所有运行的Hubble Server，并且通过各自的gRPC APIs和提供一个为全集群服务器的API提供集群范围可访问。(我的理解是一个类似SSL tunnel的工具，将集群内部的服务访问代理到某个启动relay节点上提供浏览器观察)

Client(CLI)
------------

Huble命令行工具( ``hubble`` )是一个可以连接 ``hubble-relay`` 的gRPC API或者本地服务器来获取数据流事件的命令行工具

图形交互界面(GUI)
-------------------

``hubble-ui`` 通过relay可视化来提供一个图形服务依赖关系和连接地图

:ref:`ebpf`
=============

eBPF是Linux内核字节码解释器，最初是引入用于过滤网络数据包，例如 tcpdump 和 socket filters。此后eBPF被扩展添加了数据结构，例如哈希表和数组，以及支持数据包修改，转发，封装等额外操作。内核验证器(in-kernel verifier)确保eBPF程序是安全运行的，并且一个JIT编译器转换字节码到CPU架构特定指令以实现本机原生执行效率。eBPF程序可以在内核的各种挂钩点(hooking points)上运行，例如传入和传出数据包。

eBPF不断发展并随着每个新的Linux版本获得额外的功能。Cilium利用eBPF执行核心数据路径过滤、修改、监视和重定向，这个eBPF能力在Linux内核4.8.0或更高版本提供。由于 4.8.x 内核已经结束支持，并且4.9.x已经被作为稳定版本，所以建议至少运行 4.9.17 或更新的稳定版本。

Cilium能够自动侦测Linux内核提供的功能，并且自动使用能够检测到的最新功能。

数据存储
==========

Cilium需要一个数据存储来提供代理(agents)之间传播状态，支持以下数据存储:

- Kubernetes CRDs(默认): 存储任何数据和传播状态，默认采用Kubernetes自定义资源定义(Kubernetes custom resource definitions, CRDs)。Kubernetes 为集群组件提供 CRD，以通过 Kubernetes 资源表示配置和状态。

- Key-Value存储: 虽然状态存储和传播能够通过Cilium的默认配置的Kubernetes CRDs实现，但是通过选择采用Key-Value存储，可以优化性能，提高集群的可伸缩性，所以修改通知和存储要求通过直接使用Key-Value存储更为有效。

当前支持的Key-Value存储是 :ref:`etcd`

参考
=======

- `Cilium Component Overview <https://docs.cilium.io/en/latest/overview/component-overview/>`_
