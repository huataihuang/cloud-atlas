.. _cilium_hubble:

======================
Cilium Hubble可观测性
======================

在初步完成 :ref:`cilium_install_with_external_etcd` 之后，建议部署Cilium的核心组件 Hubble 来实现网络流量的观测。

Hubble是Cilium的可观测层，用于获得集群范围观察Kubernetes集群的网络和安全层。

.. note::

   我在 :ref:`k8s_dnsrr` 采用 :ref:`cilium_install_with_external_etcd` ，完成后默认还没有激活 ``hubble`` 。此时，通过以下命令检查::

      cilium status

   输出:

   .. literalinclude:: cilium_install_with_external_etcd/cilium_status_after_install
      :language: bash
      :caption: cilium安装完成后状态验证

激活Cilium的Hubble
=====================

有两种方式可以激活Hubble:

- 方法一: 使用 ``Cilcium CLI`` :

.. literalinclude:: cilium_hubble/cilium_cli_enable_hubble
   :language: bash
   :caption: Cilium CLI激活Hubble

这里可能会出现报错::

   Error: Unable to enable Hubble: unable to retrieve helm values secret kube-system/cilium-cli-helm-values: secrets "cilium-cli-helm-values" not found

这是因为安装前通过 helm 安装，所以我改为方法二是可以直接成功等。但是，实际上 ``cilium`` 客户端如果调用 ``helm`` 还是需要使用 ``kube-system/cilium-cli-helm-values`` 这个secret密钥，例如后续 ``cilium hubble port-forward`` ，所以还是需要补充完整。 参考 `Cilium connectivity test fails: unable to retrieve helm values secret kube-system/cilium-cli-helm-values #927 <https://github.com/cilium/cilium-cli/issues/927>`_ ，这个问题似乎是版本bug，所以我采用 :ref:`cilium_upgrade` 修复

- 方法二: 使用 :ref:`helm` :

.. literalinclude:: cilium_hubble/helm_enable_hubble
   :language: bash
   :caption: 使用Helm激活Hubble

由于我之前安装的cilium版本是 1.11.7 ，当前有新版本可以更新，提示信息::

   Release "cilium" has been upgraded. Happy Helming!
   NAME: cilium
   LAST DEPLOYED: Sat Aug 13 15:18:40 2022
   NAMESPACE: kube-system
   STATUS: deployed
   REVISION: 2
   TEST SUITE: None
   NOTES:
   You have successfully installed Cilium with Hubble Relay and Hubble UI.

   Your release version is 1.11.7.

   For any further help, visit https://docs.cilium.io/en/v1.11/gettinghelp

激活 ``Hubble`` 之后，再次使用 ``cilium status`` 可以验证

.. literalinclude:: cilium_hubble/cilium_status_after_enable_hubble
   :language: bash
   :caption: cilium激活Hubble之后状态
   :emphasize-lines: 4

安装Hubble客户端
=================

.. literalinclude:: cilium_hubble/install_hubble_client
   :language: bash
   :caption: cilium激活Hubble之后状态

验证Hubble API
=================

要访问Hubble API，需要在本地主机创建一个端口转发，这样就能够让Hubble客户端通过本地 ``4245`` 访问Kubernetes集群的Hubble  Relay 服务(原理是通过 :ref:`port_forward_access_k8s_app` )

- 启动hubble端口转发::

   cilium hubble port-forward&

这里报错::

   Error: Unable to port forward: unable to retrieve helm values secret kube-system/cilium-cli-helm-values: secrets "cilium-cli-helm-values" not found



参考
=====

- `Setting up Hubble Observability <https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/>`_
