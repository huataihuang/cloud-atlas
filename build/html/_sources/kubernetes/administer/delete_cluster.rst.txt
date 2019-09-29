.. _delete_cluster:

====================
删除Kubernetes集群
====================

当执行以下命令删除Kubernetes集群::

   kubectl delete cluster test-k8s

实际上被删除集群依然有很多context和相关配置没有删除，例如证书等。

集群相关证书位于集群命名的 namespace ，可以通过删除namespace来清理::

   kubectl delete namespace test-k8s

不过，对于有相关context，需要做进一步清理，有待实践。

参考
=======

- `How do I delete clusters and contexts from kubectl config? <https://stackoverflow.com/questions/37016546/how-do-i-delete-clusters-and-contexts-from-kubectl-config>`_
