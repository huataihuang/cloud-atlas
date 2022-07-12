.. _priv_etcd:

===================
私有云etcd服务
===================

在部署了 :ref:`priv_lvm` 后，就可以在独立划分的存储 ``/var/lib/etcd`` 目录之上部署etcd，这样可以为 :ref:`etcd` 提供高性能虚拟化存储。

.. note::

   本文结合了多个实践文档的再次综合实践:

   - :ref:`priv_etcd_tls`
   - :ref:`priv_deploy_etcd_cluster_with_tls_auth`
