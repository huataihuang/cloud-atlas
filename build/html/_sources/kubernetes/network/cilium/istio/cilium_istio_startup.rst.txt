.. _cilium_istio_startup:

==========================
Cilium Istio集成起步
==========================

.. note::

   YouTube上 `LF Live Webinar: Proxyful or Proxyless: Digging into Istio with Cilium <https://www.youtube.com/watch?v=Ong0hxfkN-Q&t=24s>`_ 对Cilium集成Istio进行了解析，视频演讲者是 ``Istio in Action`` 的作者( `solo.io <https://www.solo.io>`_ 的CTO )。

Cilium集成Istio的方案为Cilium增强了通过Istio sidecar代理实现的具有mTLS加密流量的HTTP L7网络策略。需要注意，Istio也可以独立于Ciliu集成单独部署，此时运行标准版 ``istioctl`` 。这个模式下，Cilium增强型HTTP L7策略不是通过Istio sidecar proxy实现的，虽然这个模式也能工作，但是不能使用mTLS。

设置Cilium
==============

.. note::

   如果采用 :ref:`cilium_kubeproxy_free` 架构(我部署 :ref:`z-k8s` 采用该模式)，就需要在 ``cilium`` CLI 传递 ``--config bpf-lb-sock-hostns-only=true`` 或者 在 :ref:`helm` 选项中使用 ``socketLB.hostNamespaceOnly`` 。如果没有这个选项，当Cilium通过socket负载均衡提供服务解析(service resolution)时，会bypass掉Istio sidecar，这就导致Istio的加密(encryption)和遥测(telemetry)功能无效。

我在 :ref:`cilium_kubeproxy_free` 更新 :ref:`cilium_hubproxy_free_socketlb_bypass` :

.. literalinclude:: ../networking/cilium_kubeproxy_free/socketlb_hostnamespaceonly_simple
   :language: bash
   :caption: 简化且正确配置方法: 更新Cilium kube-proxy free配置，激活 socketLB.hostNamespaceOnly 以集成Istio(不修改默认配置)

安装cilium-istioctl
=======================

- 检查确认cilium已经运行在集群中::

   cilium status

- 下载 ``cilium enhanced istioctl`` :

.. literalinclude:: cilium_istio_startup/download_cilium-istioctl
   :language: bash
   :caption: 下载cilium增强istioctl

- 部署默认istio配置到Kubernetes:

.. literalinclude:: cilium_istio_startup/cilium-istioctl_install
   :language: bash
   :caption: 安装cilium增强istioctl

提示信息::

   ✔ Istio core installed
   ✔ Istiod installed
   ✔ Ingress gateways installed
   ✔ Installation complete
   Thank you for installing Istio 1.10.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/KjkrDnMPByq7akrYA

- 添加一个namespace标签让Istio能够在部署应用时自动注入 :ref:`envoy` sidecar 代理:

.. literalinclude:: cilium_istio_startup/label_namespace_enable_istio-injection
   :language: bash
   :caption: 为namespace添加标签，以便istio能够自动注入sidecar proxy

.. note::

   `Cilium Getting Started Using Istio <https://docs.cilium.io/en/stable/gettingstarted/istio/>`_ 提供了Istio官方案例部署步骤，用于验证，我还没有实践。我准备系统学习istio，可能会补充
  

参考
======

- `Cilium Getting Started Using Istio <https://docs.cilium.io/en/stable/gettingstarted/istio/>`_
