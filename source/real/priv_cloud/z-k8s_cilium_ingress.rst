.. _z-k8s_cilium_ingress:

========================================
Kubernetes集群(z-k8s)部署Cilium Ingress
========================================

说明
=====

- 在部署 :ref:`z-k8s` 采用了 :ref:`cilium` ，并完成 :ref:`z-k8s_nerdctl` 创建 :ref:`containerd_centos_systemd` 。
- 要将运行的pod服务对外输出，需要部署 :ref:`ingress_controller` 实现 :ref:`ingress` 。
- 这里选择 :ref:`cilium` 内置支持的 :ref:`cilium_k8s_ingress` 。

.. note::

   在部署 :ref:`cilium_k8s_ingress` 并启用之前，需要先部署 :ref:`z-k8s_cilium_metallb` 才能确保SVC能够获得 ``EXTERNAL-IP``

   本文案例是将 :ref:`z-k8s_nerdctl` 部署的开发所用的 ``z-dev`` 输出服务端口 ``22 80 443`` 方便后续开发测试

安装Cilium Ingress Controller
==============================

- 使用 :ref:`helm` 的参数 ``ingressController.enabled`` 激活 Cilium Ingress Controller:

.. literalinclude:: ../../kubernetes/network/cilium/service_mesh/cilium_k8s_ingress/helm_cilium_ingresscontroller_enable
   :language: bash
   :caption: helm upgrade cilium激活ingress controller

- 滚动重启 ``cilium-operator`` 和每个节点上的 ``cilium`` :ref:`daemonset` :

.. literalinclude:: ../../kubernetes/network/cilium/service_mesh/cilium_k8s_ingress/restart_cilium-operator_cilium_daemonset
   :language: bash
   :caption: cilium激活ingress controller后重启cilium-operator和cilium ds

- 然后检查Cilium agent和operato状态::

   cilium status

部署ingress
============

- 前置工作已经在 :ref:`z-k8s_nerdctl` 部署容器 ``z-dev``

- 定义 ``z-dev`` 的SVC: ``z-dev-svc.yaml``

.. literalinclude:: z-k8s_cilium_ingress/z-dev-svc.yaml
   :language: yaml
   :caption: 定义z-dev对外服务

.. note::

   这里采用了简化的 TCP 端口，对外输出 ``22 80 443`` 方便开发测试，但是实际上 :ref:`ingress` 是对外提供HTTP服务，负载均衡和SSL卸载，也就是传统的 :ref:`nginx` 演化出来，是7层服务的虚拟机主机，直接输出TCP端口是一种简化模式。实际生产环境，应该使用 ``HTTP`` 协议

- 创建服务::

   kubectl apply -f z-dev-svc.yaml

- 准备 ``z-dev-ingress.yaml`` :

.. literalinclude:: z-k8s_cilium_ingress/z-dev-ingress.yaml
   :language: yaml
   :caption: 定义z-dev对外ingress

参考
======

- `Is it possible to expose 2 ports in Kubernetes pod? <https://serverfault.com/questions/1013402/is-it-possible-to-expose-2-ports-in-kubernetes-pod>`_
