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

   .. literalinclude:: ../installation/cilium_install_with_external_etcd/cilium_status_after_install
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

这是因为安装前通过 helm 安装，所以我改为方法二是可以直接成功等。但是，实际上 ``cilium`` 客户端如果调用 ``helm`` 还是需要使用 ``kube-system/cilium-cli-helm-values`` 这个secret密钥，例如后续 ``cilium hubble port-forward`` ，所以还是需要补充完整。 参考 `Cilium connectivity test fails: unable to retrieve helm values secret kube-system/cilium-cli-helm-values #927 <https://github.com/cilium/cilium-cli/issues/927>`_ ，这个问题似乎是版本bug，所以我采用 :ref:`cilium_upgrade` 修复(我升级以后发现还是没有解决，所以最后还是采用helm方式)

- 方法二: 使用 :ref:`helm` :

.. literalinclude:: cilium_hubble/helm_enable_hubble
   :language: bash
   :caption: 使用Helm激活Hubble

我最初 :ref:`cilium_install_with_external_etcd` 安装的是 ``1.11.7`` 版本，不过上述尝试 ``cilium hubble enable`` 报错促使我先做 :ref:`cilium_upgrade` ，然后再返回过来完成激活 ``hubble``

提示信息:

.. literalinclude:: cilium_hubble/helm_enable_hubble_output
   :language: bash
   :caption: 使用Helm激活Hubble输出信息

激活 ``Hubble`` 之后，再次使用 ``cilium status`` 可以验证

.. literalinclude:: cilium_hubble/cilium_status_after_enable_hubble
   :language: bash
   :caption: cilium激活Hubble之后状态
   :emphasize-lines: 4

安装Hubble客户端
=================

.. literalinclude:: cilium_hubble/install_hubble_client
   :language: bash
   :caption: 安装hubble客户端

验证Hubble API
=================

要访问Hubble API，需要在本地主机创建一个端口转发，这样就能够让Hubble客户端通过本地 ``4245`` 访问Kubernetes集群的Hubble  Relay 服务(原理是通过 :ref:`port_forward_access_k8s_app` )

- 启动hubble端口转发::

   cilium hubble port-forward&

这里报错::

   Error: Unable to port forward: unable to retrieve helm values secret kube-system/cilium-cli-helm-values: secrets "cilium-cli-helm-values" not found

- 检查 ``kube-system`` 的 secret::

   kubectl -n kube-system get secret

可以看到::

   NAME                           TYPE                 DATA   AGE
   cilium-ca                      Opaque               2      68m
   cilium-etcd-secrets            Opaque               3      28d
   hubble-ca-secret               Opaque               2      28d
   hubble-relay-client-certs      kubernetes.io/tls    3      17m
   hubble-server-certs            kubernetes.io/tls    3      28d
   sh.helm.release.v1.cilium.v1   helm.sh/release.v1   1      28d
   sh.helm.release.v1.cilium.v2   helm.sh/release.v1   1      3d1h
   sh.helm.release.v1.cilium.v3   helm.sh/release.v1   1      2d17h
   sh.helm.release.v1.cilium.v4   helm.sh/release.v1   1      68m
   sh.helm.release.v1.cilium.v5   helm.sh/release.v1   1      17m

确实没有 ``cilium-cli-helm-values``

参考 `Cilium connectivity test fails: unable to retrieve helm values secret kube-system/cilium-cli-helm-values #927 <https://github.com/cilium/cilium-cli/issues/927>`_ 仔细看了下代码，原来是修复了即使不存在 ``cilium-cli-helm-values`` 也可以，所以需要升级 ``cilium-cli`` 客户端

再次按照 :ref:`cilium_startup` 重新安装最新的 ``cilium-cli`` : 版本从 ``v0.11.11`` 升级到 ``v0.12.1``

升级完成后，再次执行::

   cilium hubble port-forward&

就可以看到成功输出信息::

   [1] 1299844

- 验证CLI访问Hubble API::

   hubble status

输出显示::

   Healthcheck (via localhost:4245): Ok
   Current/Max Flows: 32,760/32,760 (100.00%)
   Flows/s: 52.29
   Connected Nodes: 8/8

- 现在可以查询 flow API::

   hubble observe

输出类似::

   Aug 16 09:09:35.968: 10.0.6.185:57828 (remote-node) <> 10.0.0.160:4240 (health) to-overlay FORWARDED (TCP Flags: ACK)
   Aug 16 09:09:35.969: 10.0.6.185:47590 (remote-node) <> 10.0.1.85:4240 (health) to-overlay FORWARDED (TCP Flags: ACK)
   Aug 16 09:09:35.969: 10.0.6.185:33860 (remote-node) <> 10.0.5.52:4240 (health) to-overlay FORWARDED (TCP Flags: ACK)
   ...

下一步
========

在完成了Cilium Hubble激活之后，我们就可以:

- :ref:`inspect_network_flows_with_cli`
- 通过 :ref:`cilium_service_map_hubble_ui` 观测网络

参考
=====

- `Setting up Hubble Observability <https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/>`_
