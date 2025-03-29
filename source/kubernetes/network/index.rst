.. _k8s_network:

======================
Kubernetes网络
======================

Kubernetes只支持基于Container Network Interface(CNI)的网络，需要通过安装network add-on来实现。网络是基础架构，需要深入学习和研究。

.. toctree::
   :maxdepth: 1

   cni.rst
   k8s_hostnetwork.rst
   k8s_network_infa.rst
   k8s_loadbalancer_ingress.rst
   dynamic_dns_loadbalancing_without_cloud_provider.rst
   k8s_hosts_file_for_pods.rst
   ingress/index
   egress/index
   flannel/index
   cilium/index
   calico/index
   weave/index
   metallb/index
