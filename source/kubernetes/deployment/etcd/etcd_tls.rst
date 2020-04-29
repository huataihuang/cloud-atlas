.. _etcd_tls:

================
etcd集群TLS设置
================

在完成了初步的 :ref:`deploy_etcd_cluster` 之后，可以看到虽然部署了简单的etcd集群，但是etcd集群访问是完全没有安全限制的。所以我们需要将集群改造成使用TLS加密认证访问，以增强安全性。

参考
======

- `etcd/hack/tls-setup <https://github.com/etcd-io/etcd/tree/master/hack/tls-setup>`_
- `etcd Clustering Guide <https://etcd.io/docs/v3.4.0/op-guide/clustering/>`_
