.. _z-k8s_cilium_istio:

==================================================
Kubernetes集群(z-k8s)配置Cilium结合Istio
==================================================

:ref:`cilium_istio_startup` 可以快速完成Cilium集成 :ref:`istio` ，使得 Cilium 获得更为强大的7层网络控制: 通过Istio sidecar代理实现的具有mTLS加密流量的HTTP L7网络策略。

设置Cilium集成Istio
=====================

.. note::

   当采用 :ref:`cilium_kubeproxy_free` 架构 ( :ref:`z-k8s_cilium_kubeproxy_free` )，就需要在 ``cilium`` CLI 传递 ``--config bpf-lb-sock-hostns-only=true`` 或者 在 :ref:`helm` 选项中使用 ``socketLB.hostNamespaceOnly`` 。如果没有这个选项，当Cilium通过socket负载均衡提供服务解析(service resolution)时，会bypass掉Istio sidecar，这就导致Istio的加密(encryption)和遥测(telemetry)功能无效。

- :ref:`helm` ``upgrade`` Cilium配置，激活 ``socketLB.hostNamespaceOnly`` 集成 :ref:`istio` :

.. literalinclude:: ../../kubernetes/network/cilium/networking/cilium_kubeproxy_free/socketlb_hostnamespaceonly_simple
   :language: bash
   :caption: 简化且正确配置方法: 更新Cilium kube-proxy free配置，激活 socketLB.hostNamespaceOnly 以集成Istio(不修改默认配置)

安装cilium-istioctl
=======================

- 检查确认cilium已经运行在集群中::

   cilium status

- 下载 ``cilium enhanced istioctl`` :

.. literalinclude:: ../../kubernetes/network/cilium/istio/cilium_istio_startup/download_cilium-istioctl
   :language: bash
   :caption: 下载cilium增强istioctl

- 部署默认istio配置到Kubernetes:

.. literalinclude:: ../../kubernetes/network/cilium/istio/cilium_istio_startup/cilium-istioctl_install
   :language: bash
   :caption: 安装cilium增强istioctl

- 添加一个namespace标签让Istio能够在部署应用时自动注入 :ref:`envoy` sidecar 代理:

.. literalinclude:: ../../kubernetes/network/cilium/istio/cilium_istio_startup/label_namespace_enable_istio-injection
   :language: bash
   :caption: 为namespace添加标签，以便istio能够自动注入sidecar proxy
