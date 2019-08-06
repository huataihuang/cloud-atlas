.. _ha_k8s:

==========================
高可用(HA)Kubernetes集群
==========================

Kubernetes高可用集群实现方法:

- 通过堆叠的控制平面节点(stacked control plane nodes)，即etcd节点和控制平面节点结合在一起
- 通过外部的etcd节点，即etcd节点运行在控制平面节点之外

请注意上述两种高可用部署方案各有优缺点，请仔细考虑利弊：

堆叠etcd方案
===============

堆叠etcd的HHA集群是将提供分布式数据存储的etcd集群建立在集群构建的节点上，并且由kubeadm管理和作为控制平面组件。

每个控制平面节点都是运行了 ``kube-apiserver`` , ``kube-scheduler`` 和 ``kube-controller-manager`` 实例的节点，并且 ``kube-apiserver`` 是通过负载均衡输出给集群的worker节点。

每个控制平面节点创建一个本地etcd成员，并且这个etcd成员 **只和** 这个节点的 ``kube-apiserver`` 通讯。同样的通讯模式也发生在 ``kube-controller-manager`` 和 ``kube-scheculer`` 实例上。（etcd堆叠部署在控制平面节点上，则控制平面节点上的管控组件只和本地的etcd通讯）

这种紧密结合了控制平面和etcd在同一节点上的部署拓扑简化了集群的设置（不需要部署外部etcd节点），并且也简化了复制管理。

但是，堆叠集群部署方案存在失效结合(failed coupling)的风险。如果一个节点故障，则etcd和管控平面实例同时失效，此时就存在冗灾风险。要解决这个风险，需要添加更多的管控平面节点。

在HA集群中，至少需要运行3个堆叠的管控平面节点。

这种堆叠部署管控节点是默认的kubeadm生成架构，即 ``kubeadm init`` 和 ``kubeadm join --control-plane`` 命令自动创建的管控节点就是运行一个本地etcd服务的部署方式。

.. figure:: ../../../_static/kubernetes/kubeadm-ha-topology-stacked-etcd.svg
   :scale: 50

   Figure 1: Kubeadm HA topology - stacked etcd

外部etcd部署
===============

另一种HA集群部署模式是将etcd独立出来单独部署，这样就可以控制平面节点分离。此时，etcd节点运行在独立的服务器，并且每个etcd主机和每个控制平面节点上的apiserver通讯。

采用独立的etcd集群部署可以获得更为稳定的高可用集群，即使某个控制平面实例或者etcd压力过大也不会像堆叠etcd模式那样影响整个kubernetes集群。

但是，独立外部etcd部署需要两倍的管控服务器，即至少3台控制平面节点和3台etcd节点服务器来部署高可用集群。

.. figure:: ../../../_static/kubernetes/kubeadm-ha-topology-external-etcd.svg
   :scale: 50

   Figure 1: Kubeadm HA topology - external etcd


参考
=====

- `Options for Highly Available topology <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/>`_
