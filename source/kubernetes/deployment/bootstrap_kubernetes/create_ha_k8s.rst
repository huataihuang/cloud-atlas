.. _create_ha_k8s:

============================
使用kubeadm创建高可用集群
============================

正如 :ref:`ha_k8s` 所述，构建Kubernetes高可用集群，以etcd是否独立部署来划分两种不同对HA部署架构：

- 堆叠部署etcd
- 独立部署etcd

负载均衡
==========

不管采用哪种HA部署方式，都需要使负载均衡来分发worker节点对请求和连接给后端的多个apiserver，所以构建高可用集群，首先需要构建的是管控平面的负载均衡。

.. note::

   apiserver高可用采用的是负载均衡方式实现，不论堆叠部署etcd还是分离部署etcd，集群的worker节点访问apiserver都是通过负载均衡实现的。负载均衡有多种解决方案，这里采用的是HAProxy实现，并且结合了Keepalived实现HAProxy的高可用部署。

   HAProxy虚拟机采用 :ref:`k8s_hosts` 所创建的2个 `haproxy-X` 虚拟机。

.. warning::

   由于kubelet客户端采用长连接方式访问apiserver，所以一旦kubelet通过负载均衡分发到后端到apiserver之后，除非kubelet客户端重启，一般情况下kubelete客户端会始终访问同一台apiserver。这就带来了一个均衡性问题：当apiserver由于升级重启或者crash重启，kubelet客户端连接会集中到其他正常服务器上并且不会再平衡。极端情况下，可能虽然有多个apiserver，但负载会集中到少量服务器上。

   这个在KubeCon China 2019的阿里云演讲 `Understanding Scalability and Performance in the Kubenetes Masteer <https://www.youtube.com/watch?v=1ThhTbMO1NE>`_ 有详细介绍和解决方案思路介绍(中文观看请访问 `了解 Kubernetes Master 的可扩展性和性能 <https://v.qq.com/x/page/v0906j1czvd.html>`_ )。



参考
========

- `Kubernetes cluster step-by-step: Kube-apiserver with Keepalived and HAProxy for HA <https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/>`_
  `
