.. _priv_etcd_tls:

======================
私有云etcd集群TLS设置
======================

在部署 :ref:`priv_cloud_infra` 体系中，需要构建 :ref:`priv_etcd` 为私有k8s集群提供基础服务。部署参考并基于 :ref:`etcd_tls` 改进。

etcd支持通过TLS协议进行加密通讯，要使用自签名证书启动一个集群，集群的每个成员需要有有一个唯一密钥对( ``member.crt`` 和 ``member.key`` )被一个共享的集群CA证书( ``ca.crt`` )签名过，这个密钥对用于彼此通讯和客户端连接。

通过 :ref:`priv_kvm` 构建3台虚拟机:

.. csv-table:: 私有云KVM虚拟机
   :file: priv_etcd_tls/hosts.csv
   :widths: 40, 60
   :header-rows: 1 

etcd集群证书生成
==================

发行版安装cfssl
--------------------

在 :ref:`priv_cloud_infra` 所使用的数据层3台虚拟机都是使用 :ref:`ubuntu_linux` ，ubuntu发行版提供了 ``golang-cfssl`` 软件包，直接提供了 Cloudflare 的 ``cfssl`` 工具，所以直接安装非常方便:

.. literalinclude:: priv_etcd_tls/apt_install_cfssl
   :language: bash
   :caption: ubuntu发行版提供Cloudflare的cfssl工具

证书生成
==========

在设置etcd集群时需要使用3种证书：

- ``Client certificate`` 是服务器用于认证客户端的证书，例如， etcdctl, etcd proxy 或者 docker客户端都需要使用
- ``Server certificate`` 是服务器使用，客户端用来验证服务器真伪的。例如 docker服务器或者kube-apiserver使用这个证书。
- ``Peer certificate`` 是etcd服务器成员彼此通讯的证书。

初始化证书认证
------------------

- 之前在 :ref:`etcd_tls` 实践中是产生默认 ``cfssl`` 选项，然后在此基础上修订。不过，我们既然有基础了，就直接配置 ``ca-config.json`` (有效期限10年):

.. literalinclude:: priv_etcd_tls/ca-config.json
   :language: json
   :caption: 修订证书有效期10年 ca-config.json
   :emphasize-lines: 13

.. note::

   这里CA配置中， ``"server"`` 段落必须要添加 ``"client auth"`` ，否则高版本etcd启动时会提示连接错误。详见 :ref:`deploy_etcd_cluster_with_tls_auth`

- 配置CSR(Certificate Signing Request)配置文件 ``ca-csr.json`` :

.. literalinclude:: priv_etcd_tls/ca-csr.json
   :language: json
   :caption: 修订CSR ca-csr.json

- 使用上述配置定义生成CA:

.. literalinclude:: priv_etcd_tls/generate_ca.cmd
   :language: bash
   :caption: 生成CA

这样将获得3个文件::

   ca-key.pem
   ca.csr
   ca.pem

.. warning::

   请确保 ``ca-key.pem`` 文件安全，该文件是CA可以创建任何证书

- 生成服务器证书: 直接编辑 ``server.json`` :

.. literalinclude:: priv_etcd_tls/server.json
   :language: json
   :caption: 修订 server.json

- 现在可以生成服务器证书和私钥:

.. literalinclude:: priv_etcd_tls/generate_server_certifacate_private_key.cmd
   :language: bash
   :caption: 生成服务器证书和私钥

这样获得3个文件::

   server-key.pem
   server.csr
   server.pem

- peer certificate (每个服务器一个，按对应主机名):

.. literalinclude:: priv_etcd_tls/z-b-data-1.json
   :language: json
   :caption: 服务器 z-b-data-1.staging.huatai.me 点对点证书

.. literalinclude:: priv_etcd_tls/z-b-data-2.json
   :language: json
   :caption: 服务器 z-b-data-2.staging.huatai.me 点对点证书

.. literalinclude:: priv_etcd_tls/z-b-data-3.json
   :language: json
   :caption: 服务器 z-b-data-3.staging.huatai.me 点对点证书

对应生成3个主机的服务器证书:

.. literalinclude:: priv_etcd_tls/generate_peer_certificate_private_key.sh
   :language: bash
   :caption: 生成3个主机的点对点证书

此时获得对应文件是::

   z-b-data-1-key.pem
   z-b-data-1.csr
   z-b-data-1.pem
   ...


- 客户端证书 ``client.json`` (主要是主机列表保持空):

.. literalinclude:: priv_etcd_tls/client.json
   :language: json
   :caption: 修订 client.json

- 现在可以生成客户端证书:

.. literalinclude:: priv_etcd_tls/generate_client_certifacate.cmd
   :language: bash
   :caption: 生成客户端证书

获得了以下文件::

   client-key.pem
   client.csr
   client.pem

参考
======

- `etcd/hack/tls-setup <https://github.com/etcd-io/etcd/tree/master/hack/tls-setup>`_
- `etcd Clustering Guide <https://etcd.io/docs/v3.4.0/op-guide/clustering/>`_
- `Setting up Etcd Cluster with TLS Authentication Enabled <https://medium.com/nirman-tech-blog/setting-up-etcd-cluster-with-tls-authentication-enabled-49c44e4151bb>`_ 这篇文档非常详细指导了如何使用cfssl工具来生成etcd服务器证书，以及签名客户端证书
- `etcd Security Guide <https://github.com/ericchiang/etcd-security-guide>`_
- `Generate self-signed certificates <https://github.com/coreos/docs/blob/master/os/generate-self-signed-certificates.md>`_ CoreOS官方(etcd开发公司)提供的指导文档
