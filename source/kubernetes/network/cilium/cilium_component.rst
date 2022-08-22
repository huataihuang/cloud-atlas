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



参考
=======

- `Cilium Component Overview <https://docs.cilium.io/en/latest/overview/component-overview/>`_
