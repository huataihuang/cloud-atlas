.. _etcd_tls:

================
etcd集群TLS设置
================

在完成了初步的 :ref:`deploy_etcd_cluster` 之后，可以看到虽然部署了简单的etcd集群，但是etcd集群访问是完全没有安全限制的。所以我们需要将集群改造成使用TLS加密认证访问，以增强安全性。

etcd支持通过TLS协议进行加密通讯，要使用自签名证书启动一个集群，集群的每个成员需要有有一个唯一密钥对( ``member.crt`` 和 ``member.key`` )被一个共享的集群CA证书( ``ca.crt`` )签名过，这个密钥对用于彼此通讯和客户端连接。

本文实践采用 :ref:`pi_stack` 环境采用3台 :ref:`pi_3` 硬件部署3节点 :ref:`etcd` 集群:

.. csv-table:: 树莓派k3s管控服务器
   :file: ../../k3s/k3s_ha_etcd/hosts.csv
   :widths: 40, 60
   :header-rows: 1 

etcd集群证书生成
==================

编译cfssl
------------

Cloudflare提供了一个 `cfssl <https://github.com/cloudflare/cfssl>`_ 工具来帮助生成etcd集群的证书。默认生成 ECDSA-384 root和leaf证书给localhost。每个etcd节点使用相同的证书，但不需要客户端证书。

- 安装 git , go, 和 make

- 安装cfssl::

   git clone git@github.com:cloudflare/cfssl.git
   cd cfssl
   make

编译以后生成的执行文件位于 ``bin`` 目录下::

   $ tree bin
   bin
   ├── cfssl
   ├── cfssl-bundle
   ├── cfssl-certinfo
   ├── cfssl-newkey
   ├── cfssl-scan
   ├── cfssljson
   ├── mkbundle
   ├── multirootca
   └── rice

.. note::

   macOS的 :ref:`homebrew` 提供了直接安装的简便方法::

      brew install cfssl

.. note::

   也可以使用go直接安装单个命令::

      go get -u github.com/cloudflare/cfssl/cmd/cfssl

   依次类推，还可以安装cfssljson等工具::

      go get -u github.com/cloudflare/cfssl/cmd/cfssljson

.. note::

   :ref:`alpine_linux` 可以通过在 :ref:`alpine_dev` 中 :ref:`alpine_cfssl`

证书生成
==========

在设置etcd集群时需要使用3种证书：

- ``Client certificate`` 是服务器用于认证客户端的证书，例如， etcdctl, etcd proxy 或者 docker客户端都需要使用
- ``Server certificate`` 是服务器使用，客户端用来验证服务器真伪的。例如 docker服务器或者kube-apiserver使用这个证书。
- ``Peer certificate`` 是etcd服务器成员彼此通讯的证书。

初始化证书认证
------------------

- 首先需要在合适的子目录下默认 ``cfssl`` 选项:

.. literalinclude:: etcd_tls/cfssl_options.sh
   :language: bash
   :caption: 保存默认cfssl选项脚本 cfssl_options.sh

- 配置CA选项 - 修改 ``ca-config.json`` 配置文件:

  - ``profiles`` 部分: ``www`` 默认 ``server auth`` (TLS Web服务器认证) 是 X509 V3扩展，并且 ``client auth`` (TLS Web客户端认证) 是 X509 V3扩展
  - ``expiry`` : 默认是 ``8760h`` 过期(即365天)

修改延长为10年:

.. literalinclude:: etcd_tls/ca-config.json
   :language: json
   :caption: 修订证书有效期10年 ca-config.json
   :emphasize-lines: 13

.. note::

   这里CA配置中， ``"server"`` 段落必须要添加 ``"client auth"`` ，否则高版本etcd启动时会提示连接错误。详见 :ref:`deploy_etcd_cluster_with_tls_auth`

- 配置CSR(Certificate Signing Request)配置文件 ``ca-csr.json`` :

.. literalinclude:: etcd_tls/ca-csr.json
   :language: json
   :caption: 修订CSR ca-csr.json

- 使用上述配置定义生成CA:

.. literalinclude:: etcd_tls/generate_ca.cmd
   :language: bash
   :caption: 生成CA

这样将获得3个文件::

   ca-key.pem
   ca.csr
   ca.pem

.. warning::

   请确保 ``ca-key.pem`` 文件安全，该文件是CA可以创建任何证书

- 生成服务器证书::

   cfssl print-defaults csr > server.json

然后我们需要修订这个 ``server.json`` 来满足我们的配置:

.. literalinclude:: etcd_tls/server.json
   :language: json
   :caption: 修订 server.json

- 现在可以生成服务器证书和私钥:

.. literalinclude:: etcd_tls/generate_server_certifacate_private_key.cmd
   :language: bash
   :caption: 生成服务器证书和私钥

这样获得3个文件::

   server-key.pem
   server.csr
   server.pem

- 生成peer certificate (每个服务器一个，按对应主机名)::

   cfssl print-defaults csr > x-k3s-m-1.json

然后修订这个 ``x-k3s-m-1.json``

.. literalinclude:: etcd_tls/x-k3s-m-1.json
   :language: json
   :caption: 服务器 x-k3s-m-1.edge.huatai.me 点对点证书

重复上述步骤，对应创建第2和第3个主机对应配置

.. literalinclude:: etcd_tls/x-k3s-m-2.json
   :language: json
   :caption: 服务器 x-k3s-m-2.edge.huatai.me 点对点证书

.. literalinclude:: etcd_tls/x-k3s-m-3.json
   :language: json
   :caption: 服务器 x-k3s-m-3.edge.huatai.me 点对点证书

对应生成3个主机的服务器证书:

.. literalinclude:: etcd_tls/generate_peer_certificate_private_key.sh
   :language: bash
   :caption: 生成3个主机的点对点证书

此时获得对应文件是::

   x-k3s-m-1-key.pem
   x-k3s-m-1.csr
   x-k3s-m-1.pem
   ...

- 生成客户端证书::

   cfssl print-defaults csr > client.json

修订 ``client.json`` (主要是主机列表保持空):

.. literalinclude:: etcd_tls/client.json
   :language: json
   :caption: 修订 client.json

- 现在可以生成客户端证书:

.. literalinclude:: etcd_tls/generate_client_certifacate.cmd
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
