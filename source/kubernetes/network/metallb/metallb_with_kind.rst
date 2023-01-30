.. _metallb_with_kind:

============================
在 :ref:`kind` 部署MetalLB
============================

在 :ref:`kind_ingress` 采用 :ref:`ingress_nginx` 实现服务对外输出后，如果要像云计算厂商一样提供完整可控的服务，还需要部署 :ref:`metallb` 来为 :ref:`bare-metal_ingress_nginx` 提供类似云厂商的 ``LoadBalancer`` 。Kind通过安装标准的 :ref:`metallb` 就能具备完整的服务输出能力。

安装
========

:ref:`install_metallb` 有多种方法，比较简单的是采用 ``kubectl apply`` 通过Manifest方式安装:

- 通过编辑当前集群的 ``kube-proxy`` 配置实现:

.. literalinclude:: install_metallb/enable_strict_arp_mode
   :language: bash
   :caption: 通过编辑 ``kube-proxy`` 配置激活 ``strict ARP``

设置:

.. literalinclude:: install_metallb/edit_configmap_enable_strict_arp_mode
   :language: bash
   :caption: 设置 ``ipvs`` 模式中 ``strictARP: true``

- 执行以下 ``manifest`` 完成MetalLB安装:

.. literalinclude:: install_metallb/install_metallb_by_manifest
   :language: bash
   :caption: 使用Manifest方式安装MetalLB

- 执行以下命令等待 MetalLB pods (controller 和 speakers)就绪:

.. literalinclude:: metallb_with_kind/wait_metallb_pods_ready
   :language: bash
   :caption: 等待 MetalLB pods (controller 和 speakers)就绪

一切正常的话会看到以下输出:

.. literalinclude:: metallb_with_kind/wait_metallb_pods_ready_output
   :language: bash
   :caption: 等待 MetalLB pods (controller 和 speakers)就绪的输出信息

配置
============

- 首先检查 ``kind`` (bridge)网络 docker 分配的IP地址段:

.. literalinclude:: metallb_with_kind/docker_network_inspect_kind
   :language: bash
   :caption: 检查 ``kind`` (bridge)网络的IP地址段

可能类似以下输出信息(我的kind网络):

.. literalinclude:: metallb_with_kind/docker_network_inspect_kind_output
   :language: bash
   :caption: 检查 ``kind`` (bridge)网络的IP地址段输出信息

可以看到我部署的 ``kind`` 集群分配的节点网络IP地址(可路由访问外网的IP地址，也就是每个node节点分配的IP地址) 是 ``172.22.0.0/16``

- 需要 **挖** 一部分地址保留给 MetalLB 来分配作为负载均衡对外VIP的地址，所以配置 ``metallb-config.yaml`` 如下:

.. literalinclude:: metallb_with_kind/metallb-config.yaml
   :language: bash
   :caption: 分配一段IP地址保留给MetalLB用于对外VIP实例

- 应用地址:

.. literalinclude:: metallb_with_kind/apply_metallb-config
   :language: bash
   :caption: 应用MetalLB的配置

提示信息:

.. literalinclude:: metallb_with_kind/apply_metallb-config_output
   :language: bash
   :caption: 应用MetalLB的配置

应用LoadBalancer
==================

- 之前 :ref:`kind_deploy_fedora-dev-tini` 使用的 ``fedora-dev-tini-deployment.yaml`` 部署pods 和 service，当时 ``service`` 没有配置 ``LoadBalancer`` 类型，则默认是 ``ClusterIP`` :

.. literalinclude:: ../../kind/kind_deploy_fedora-dev-tini/get_services
   :language: bash
   :caption: 部署 ``fedora-dev-tini`` (未设置LoadBalancer服务类型)检查 ``kubectl get services``
   :emphasize-lines: 3

- 之前 :ref:`kind_deploy_fedora-dev-tini` 使用的 ``fedora-dev-tini-deployment.yaml`` 修订将服务类型修改成 ``LoadBalancer`` :

.. literalinclude:: metallb_with_kind/fedora-dev-tini-deployment.yaml
   :language: yaml
   :caption: 修订 :ref:`kind_deploy_fedora-dev-tini` 使用的 ``fedora-dev-tini-deployment.yaml`` 服务类型改成 ``LoadBalancer``
   :emphasize-lines: 9

- 执行修订:

.. literalinclude:: ../../kind/kind_deploy_fedora-dev-tini/deploy_fedora-dev-tini
   :language: bash
   :caption: 将修订后 ``fedora-dev-tini`` 更新部署到kind集群

检查服务，可以看到 ``fedora-dev-service`` 类型已经从 ``ClusterIP`` 改为 ``LoadBalancer`` ，并且分配了一个外部可访问IP ``172.22.255.201`` ，这个地址就是Kubernetes集群外面的用户可以访问的服务IP地址(而不是之前只能在Kubernetes集群内部访问的IP地址 ``10.96.175.32`` )

.. literalinclude:: metallb_with_kind/get_services
   :language: bash
   :caption: 配置 ``fedora-dev-tini`` 设置LoadBalancer服务类型后 ``kubectl get services`` 显示服务具备了 ``EXTERNAL-IP``
   :emphasize-lines: 3

.. note::

   这里 ``Ports`` 显示是 ``22:32440/TCP,80:31218/TCP,443:32049/TCP`` 表示什么意思？

   不过，我确实从 :ref:`kind_local_registry` 部署的 ``registry`` 容器(这个容器比较特殊，配置了 ``kind`` 网络，也配置了docker默认 ``bridge`` 网络，是一个跨网络pod，所以可以作为桥接测试)能够直接 ``ssh 172.22.255.201`` 登陆到容器 ``fedora-dev-tini`` 了，证明负载均衡转发是成功的

   接下来是如何结合 :ref:`ingress_nginx` 来构建完成的网络流量链路了(HTTP/HTTPS)

   此外，还需要解决 :ref:`docker_macos_kind_port_forwarding` 以便能够从外部访问Docker VM内部构建的 :ref:`kind` 集群输出的 LoadBalancer ( MetalLB ) 的IP对应服务(折腾^_^)

参考
=======

- `MetalLB installation <https://metallb.universe.tf/installation/>`_
- `Kind User Guide: LoadBalancer <https://kind.sigs.k8s.io/docs/user/loadbalancer/>`_
