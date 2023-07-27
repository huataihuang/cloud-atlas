.. _metallb_with_istio:

================================
在 :ref:`istio` 上部署Metallb
================================

在 :ref:`istio_startup` ，如果是在自建的 ``baremetal`` 服务器集群，就会出现无法自动获取 ``Exteneral-IP`` 的现象。原因无他，就是因为Kubernetes默认是在云计算厂商平台部署，采用调用云厂商的Loadbalance来实现对外服务输出。而在 ``barmetal`` 裸金属服务器上部署的应用，则需要实现一个外部负载均衡，如 :ref:`metallb` 。

安装
========

- 我在 :ref:`kubespray_startup` 采用了默认安装，也就是依然采用 ``kube-proxy`` 。按照 :ref:`install_metallb` 官方说明，必须严格激活 ``strict ARP`` ，所以编辑当前集群的 ``kube-proxy`` 配置:

.. literalinclude:: install_metallb/enable_strict_arp_mode
   :language: bash
   :caption: 通过编辑 ``kube-proxy`` 配置激活 ``strict ARP``

设置:

.. literalinclude:: install_metallb/edit_configmap_enable_strict_arp_mode
   :language: bash
   :caption: 设置 ``ipvs`` 模式中 ``strictARP: true``
   :emphasize-lines: 5

- 执行以下 ``manifest`` 完成MetalLB安装 :

.. literalinclude:: install_metallb/install_metallb_by_manifest
   :language: bash
   :caption: 使用Manifest方式安装MetalLB

上述操作在集群中的 ``metallb-system`` namespace 部署了MetalLB，在 manifest 中的组件包括:

- ``metallb-system/controller`` deployment: 这是用于处理IP地址分配的集群范围控制器
- ``metallb-system/speaker`` daemonset: 该组件负责选择可以到达服务的协议
- 用于 ``controller`` 和 ``speaker`` 的系统服务账号，归属于RBAC的功能组件

- 检查部署pods:

.. literalinclude:: metallb_with_istio/kubectl_get_metallb-system_pods
   :caption: 检查 ``metallb-system`` 中的组件pods

可以看到如下pods分布在每个节点上:

.. literalinclude:: metallb_with_istio/kubectl_get_metallb-system_pods_output
   :caption: 检查 ``metallb-system`` 中的组件pods分布情况

配置
======

在 :ref:`istio_startup` 已经部署了 :ref:`istio_bookinof_demo` 

在没有部署 ``MetalLB`` 对外IP地址池的时候，检查 Ingress 服务:

.. literalinclude:: ../../istio/istio_startup/kubectl_get_svc
   :caption: 检查 :ref:`istio_startup` 创建的 ``istio-ingressgateway`` 的service(svc)

此时看到 ``istio-ingressgateway`` 的 ``EXTERNAL-IP`` 是 ``pending`` 状态:

.. literalinclude:: ../../istio/istio_startup/kubectl_get_svc_output
   :caption: 检查上文创建的名为 ``istio-ingressgateway`` 的service(svc): 输出显示 ``EXTERNAL-IP`` 没有分配

- 创建 ``MetalLB`` 的IP资源池来对外提供服务:

.. literalinclude:: metallb_with_istio/y-k8s-ip-pool.yaml
   :language: yaml
   :caption: 创建 ``y-k8s-ip-pool.yaml`` 设置对外提供负载均衡服务的IP地址池

- 然后执行创建:

.. literalinclude:: metallb_with_istio/kubectl_create_metallb_ip-pool
   :caption: 创建名为 ``y-k8s-ip-pool`` 的MetalLB地址池

- 一旦完成 ``MetalLB`` 的负载均衡服务的IP地址池，再次检查 Ingress 服务:

.. literalinclude:: ../../istio/istio_startup/kubectl_get_svc
   :caption: 再次检查 ``istio-ingressgateway`` 的service(svc)

**Binggo** ，现在可以看到对外服务的IP地址已经分配:

.. literalinclude:: metallb_with_istio/kubectl_get_svc_metallb_ip_output
   :caption: 可以看到完成 ``MetalLB`` 地址池配置后， ``istio-ingressgateway`` 的service(svc) 正确获得了对外服务负载均衡IP

- 注意，这里我的模拟环境采用了一个内部IP地址 ``192.168.8.151`` ，我还加了一个 :ref:`nginx_reverse_proxy` 将 ``public`` 网络接口访问映射为内部IP上访问

参考
======

- `Bare metal cluster with Kubernetes, Istio & MetalLB <https://github.com/vietkubers/k8s-istio-metallb-hands-on-lab/blob/master/README.md>`_ 这是一个结合 :ref:`istio` 自带sample :ref:`istio_bookinof_demo` 的部署指南；更为复杂的生产级部署 :ref:`metallb_with_istio_mtls`
- `How to make istio-ingress working with metallb on a bare metal k8s cluster <https://discuss.istio.io/t/how-to-make-istio-ingress-working-with-metallb-on-a-bare-metal-k8s-cluster/14603>`_ 
