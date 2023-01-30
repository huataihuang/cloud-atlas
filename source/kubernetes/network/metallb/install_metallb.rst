.. _install_metallb:

=====================
安装MetalLB
=====================

前提条件
===========

在安装MetalLB之前，需要检查:

- Kubernetes 1.13.0 或更高版本，并且还没有部署网络负载均衡功能
- `Kubernetes网络插件MetalLB兼容性列表 <https://metallb.universe.tf/installation/network-addons/>`_ 
- 保留部分IPv4地址给MetalLB处理
- 当使用BGP操作模式，需要有一些能够处理BGP通讯的路由器
- 当使用L2操作模式(两层交换机模式)，Kubernetes节点必须允许端口 ``7946`` 流量(TCP和UDP，也可以配置其他端口)

MetalLB的早期版本采用 ``configmap`` 配置，但是从版本 ``v0.13.0`` 开始，只能通过 ``CRs`` 进行配置。在 ``quay.io/metallb/configmaptocrs`` 提供了一个将旧有的 ``configmap`` 转换到 ``CRs`` 的工具镜像。

FRR模式
-----------

MetalLB 实现了 FRR 模式，该模式使用 FRR 容器作为处理 BGP 会话的后端。 它提供了本机 BGP 实现所不具备的功能，例如将 BGP 会话与 BFD 会话配对，以及公布 IPV6 地址。

尽管与本机 BGP 实施相比，FRR 模式的实战测试较少，但 FRR 模式目前被那些需要 BFD 或 IPV6 的用户使用，并且它是随 OpenShift 分发的 MetalLB 版本中唯一受支持的方法。 长期计划是使其成为 MetalLB 中唯一可用的 BGP 实现。

.. note::

   这个有点高深，BGP协议实现有待进一步学习，看看有没有结合 :ref:`cisco` 的实践

准备工作
===============

如果使用 ``IPVS`` 模式的 ``kube-proxy`` ，从 Kubernetes v1.14.2 开始，必须激活严格的 ARP 模式。注意，如果使用 ``kube-router`` 作为 ``service-proxy`` 饿不需要这个步骤，因为已经默认激活了 ``strict ARP``

- 通过编辑当前集群的 ``kube-proxy`` 配置实现:

.. literalinclude:: install_metallb/enable_strict_arp_mode
   :language: bash
   :caption: 通过编辑 ``kube-proxy`` 配置激活 ``strict ARP``

设置:

.. literalinclude:: install_metallb/edit_configmap_enable_strict_arp_mode
   :language: bash
   :caption: 设置 ``ipvs`` 模式中 ``strictARP: true``

.. note::

   参考 `KubeProxyIPVSConfiguration <https://kubernetes.io/docs/reference/config-api/kube-proxy-config.v1alpha1/#kubeproxy-config-k8s-io-v1alpha1-KubeProxyIPVSConfiguration>`_ :

   ``strictARP`` 配置 ``arp_ignore`` 和 ``arp_announce`` 来避免从 ``kube-ipvs0`` 网络接口响应ARP请求

.. note::

   :ref:`metallb_with_kind` 配置前，检查 :ref:`kind` 集群上述配置，发现默认是 ``strictARP: false`` ，我修订为 ``strictARP: true``

- 可以使用以下shell脚本自动完成上述 ``strictARP: true`` 配置:

.. literalinclude:: install_metallb/enable_strict_arp_mode_script
   :language: bash
   :caption: 脚本方式完成 ``kube-proxy`` 配置激活 ``strict ARP``

使用Manifest方式安装MetalLB
===============================

- 执行以下 ``manifest`` 完成MetalLB安装:

.. literalinclude:: install_metallb/install_metallb_by_manifest
   :language: bash
   :caption: 使用Manifest方式安装MetalLB

输出显示:

.. literalinclude:: install_metallb/install_metallb_by_manifest_output
   :language: bash
   :caption: 使用Manifest方式安装MetalLB的输出信息

.. note::

   使用 FRR 模式请参考原文

上述操作在集群中的 ``metallb-system`` namespace 部署了MetalLB，在 manifest 中的组件包括:

- ``metallb-system/controller`` deployment: 这是用于处理IP地址分配的集群范围控制器
- ``metallb-system/speaker`` daemonset: 该组件负责选择可以到达服务的协议
- 用于 ``controller`` 和 ``speaker`` 的系统服务账号，归属于RBAC的功能组件

安装 manifest 并不包括配置文件，此时MetalLB组件依然能够启动，但是始终是 ``idle`` 状态，直到 ``开始部署资源`` (配置MetalLB)

此外有2个一体化(all-in-one)的manifests用于集成 :ref:`prometheus` ，这2个manifest假设 prometheus operator 是部署在 ``monitoring`` namespace 并且使用了 ``prometheus-k8s`` 服务账号。

参考
======

- `MetalLB installation <https://metallb.universe.tf/installation/>`_
