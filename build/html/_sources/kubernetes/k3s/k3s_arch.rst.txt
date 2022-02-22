.. _k3s_arch:

==============
K3s架构
==============

在k3s集群中，一个节点运行控制平面的节点被称为 ``server`` ，而一个节点只运行 ``kubelet`` 则被称为 ``agent`` 。

在 ``server`` 和 ``agent`` 上都有容器运行时( ``container runtime`` ) 和对应 ``kubeproxy`` 来管理集群见的网络流量和tunneling。

.. figure:: ../../_static/kubernetes/k3s/k3s.png
   :scale: 60

不过，和传统的 :ref:`kuberntes` 架构不同，在K3s中没有清晰区别 ``master`` 和 ``worker`` 节点。Pods可以调度到任何能运行的角色的节点上进行管理。所以在K3s集群中，通常不命名 ``master`` 节点和 ``worker`` 节点，而是统称为 ``node`` 。

.. note::

   也就是说，对于 K3s 这样面向有限硬件的 :ref:`edge_cloud` 集群，要构建高可用Kubernetes集群，理论上只需要3个节点的硬件。

   后续我将尝试在3个节点上构建 :ref:`pi_rack` ，部署3节点 ``k3s`` 实现最小化高可用集群。

K3s为了实现轻量级的Kubernetes，对Kubernetes的大量可选组件做了裁剪，然后添加了一些基础组件，也就是 :ref:`introduce_k3s` 所述的基础依赖:

- :ref:`containerd`
- :ref:`flannel`
- :ref:`coredns`
- :ref:`cni`
- 主机工具
- 本地存储提供
- :ref:`traefik` Ingress控制器
- 内嵌服务负载均衡
- 内嵌网络策略控制器

所有上述组件都被打包到一个单一二进制运行程序中，并且以一个相同进程运行。



参考
======

- `K3s Architecture <https://rancher.com/docs/k3s/latest/en/architecture/>`_
