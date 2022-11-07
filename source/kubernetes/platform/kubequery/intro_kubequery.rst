.. _intro_kubequery:

================
kubequery简介
================

kubequery是一个 :ref:`osquery` 扩展，提供了 :ref:`kubernetes` 集群的SQL方式分析:

- kubequery是一个独立的Go执行文件，相当于Kubernetes集群和 :ref:`osquery` 之间的代理，通常打包成一个 :ref:`docker` 镜像，可以直接从 ``dockerhub`` 下载，也可以在Kubernetes集群作为每个集群一个deployment来部署。

参考
======

- `kubequery powered by Osquery <https://github.com/Uptycs/kubequery>`_
- `Kubequery brings the power of osquery to Kubernetes clusters <https://www.uptycs.com/blog/kubequery-brings-the-power-of-osquery-to-kubernetes-clusters>`_
- `Kube-Query: A Simpler Way to Query Your Kubernetes Clusters <https://blog.aquasec.com/kube-query-osquery-kubernetes-clusters>`_
