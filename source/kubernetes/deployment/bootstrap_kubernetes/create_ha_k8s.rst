.. _create_ha_k8s:

============================
使用kubeadm创建高可用集群
============================

正如 :ref:`ha_k8s` 所述，构建Kubernetes高可用集群，以etcd是否独立部署来划分两种不同对HA部署架构：

- 堆叠部署etcd
- 独立部署etcd

准备工作
==========

不管采用哪种HA部署方式，都需要使负载均衡来分发worker节点对请求和连接给后端的多个apiserver，所以构建高可用集群，首先需要构建的是管控平面的负载均衡。


参考
========

- `Kubernetes cluster step-by-step: Kube-apiserver with Keepalived and HAProxy for HA <https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/>`_`
  `
