.. _z-k8s_cilium_ingress:

========================================
Kubernetes集群(z-k8s)部署Cilium Ingress
========================================

在部署 :ref:`z-k8s` 采用了 :ref:`cilium` ，并完成 :ref:`z-k8s_nerdctl` 创建 :ref:`containerd_centos_systemd` 。此时，要将运行的pod服务对外输出，需要部署 :ref:`ingress_controller` 实现 :ref:`ingress` 。这里选择 :ref:`cilium` 内置支持的 :ref:`cilium_k8s_ingress` 。
