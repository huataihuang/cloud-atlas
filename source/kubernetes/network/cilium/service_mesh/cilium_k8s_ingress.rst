.. _cilium_k8s_ingress:

===========================
Cilium Kubernetes Ingress
===========================

Cilium使用标准的Kubernetes Ingress 资源定义，采用 ``ingressClassName`` ，可用于基于路径的路由( ``path-based routing`` ) 和 TLS 终结(termination)。

.. note::

   ingress controller创建一种负载均衡类型的服务，所以环境必须支持

准备工作
============

- Cilium 必须以 ``kubeProxyReplacement`` 配置成 ``partial`` 或 ``strict`` ，这个配置我已经在 :ref:`cilium_kubeproxy_free` 完成
- 支持Ingress的Kubernetes版本至少是 1.19

.. note::

   我在部署Ingress之前，先完成了 :ref:`cilium_upgrade` 升级到最新版本 1.12.1

安装
=======

- 使用 :ref:`helm` 的参数 ``ingressController.enabled`` 激活 Cilium Ingress Controller:

.. literalinclude:: cilium_k8s_ingress/helm_cilium_ingresscontroller_enable
   :language: bash
   :caption: helm upgrade cilium激活ingress controller

输出显示:

.. literalinclude:: cilium_k8s_ingress/helm_cilium_ingresscontroller_enable_output
   :language: bash
   :caption: helm upgrade cilium激活ingress controller 输出显示

- 然后滚动重启 ``cilium-operator`` 和每个节点上的 ``cilium`` :ref:`daemonset` :

.. literalinclude:: cilium_k8s_ingress/restart_cilium-operator_cilium_daemonset
   :language: bash
   :caption: cilium激活ingress controller后重启cilium-operator和cilium ds

- 如果只想使用 :ref:`envoy` 流量管理功能但不需要Ingress支持，则只需要激活 ``--enable-envoy-config`` ( **我没有执行这个命令** ):

.. literalinclude:: cilium_k8s_ingress/helm_cilium_envoy_without_ingress
   :language: bash
   :caption: helm upgrade cilium激活envoy流量管理但不使用ingress

- 然后检查Cilium agent和operato状态::

   cilium status

- 安装最新版本的 Cilium CLI:

.. literalinclude:: ../cilium_startup/cilium_cli_install
   :language: bash
   :caption: 安装cilium cli

- 安装最新hubble客户端:

.. literalinclude:: ../observability/cilium_hubble/install_hubble_client
   :language: bash
   :caption: 安装hubble客户端

参考
=======

- `Cilium docs: Kubernetes Ingress Support <https://docs.cilium.io/en/v1.12/gettingstarted/servicemesh/ingress/>`_
