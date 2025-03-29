.. _kube-prometheus-stack_hostnetwork:

==========================================
``kube-prometheus-stack`` 改为hostNetwork
==========================================

在部署 :ref:`z-k8s_gpu_prometheus_grafana` ，集群采用的CNI是 :ref:`calico` 。这是一个在云计算厂商平台常见的Kubernetes CNI解决方案，但是在实践中遇到一个奇特的问题(还没有找出根因，初步推断底层VPC网络可能有什么更改导致):

- 默认部署的 :ref:`daemonset` 使用的是Calico网络分配pod IP，没有使用 ``hostNetwork`` (和物理主机相同IP)

参考::

     # Required for use in managed kubernetes clusters (such as AWS EKS) with custom CNI (such as calico),
     # because control-plane managed by AWS cannot communicate with pods' IP CIDR and admission webhooks are not working
     ##
     hostNetwork: false
