.. _kube-prometheus-stack_hostnetwork:

==========================================
``kube-prometheus-stack`` 改为hostNetwork
==========================================

在部署 :ref:`z-k8s_gpu_prometheus_grafana` ，集群采用的CNI是 :ref:`calico` 。这是一个在云计算厂商平台常见的Kubernetes CNI解决方案，但是

参考::

     # Required for use in managed kubernetes clusters (such as AWS EKS) with custom CNI (such as calico),
     # because control-plane managed by AWS cannot communicate with pods' IP CIDR and admission webhooks are not working
     ##
     hostNetwork: false
