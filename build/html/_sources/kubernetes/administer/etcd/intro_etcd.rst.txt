.. _intro_etcd:

=================
etcd技术简介
=================

``etcd`` 是一个 **强一致性** 分布式 ``key-value`` 存储，为分布式系统或集群主机提供了可靠的存储数据方式。通常在Kubernetes集群中，强烈建议使用高可用模式部署 ``etcd`` 并启用 ``tls`` 认证 ( :ref:`etcd_tls` + :ref:`deploy_etcd_cluster_with_tls_auth` )

.. figure:: ../../../_static/kubernetes/administer/etcd/k8s_components.png

参考
======

- `etcd官网 <https://etcd.io/>`_
