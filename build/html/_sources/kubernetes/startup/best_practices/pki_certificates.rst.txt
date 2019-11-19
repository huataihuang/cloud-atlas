.. _pki_certificates:

===================
Kubernetes PKI认证
===================

Kubernetes 需要PKI证书来实现基于TLS的认证。如果你使用 :ref:`kubeadm` 来安装Kubernetes，则已经自动生成了集群需要的证书。你也可以生成自己的证书，例如为了安全，避免将私钥存储在API服务器上。

集群如何使用证书
==================

Kuernetes在以下操作中需要使用PKI:

- kubelet访问API服务器需要使用客户端证书
- API服务器endpoint的服务器证书
- 访问API服务器管理集群使用管理员证书
- API服务器的客户端证书用于和kubelet通讯
- API服务器的客户端证书用于和etcd通讯
- 控制器的客户端证书/kubeconfig用于和API服务器通讯
- 调度器的客户端证书/kubeconfig用于和API服务器通讯
- 用于front-proxy的客户端和服务器端证书

.. note::

   如果通过kubeadm安装Kubernetes，则所有证书存放在 ``/etc/kubenetes/pki`` 目录下。

手工配置证书
===============

.. note::

   待实践

.. note::

   部署高可用 :ref:`ha_k8s_external` 需要配置 apiserver 访问etcd 证书，通过卷映射到容器内部，请参考

参考
=====

- `PKI certificates and requirements <https://kubernetes.io/docs/setup/best-practices/certificates/>`_
