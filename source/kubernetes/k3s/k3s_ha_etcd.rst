.. _k3s_ha_etcd:

================
K3s高可用etcd
================

.. note::

   ``K3s`` 还支持一种内嵌 ``etcd`` 模式，对应 :ref:`ha_k8s_stacked`

   本文采用的是 exteneral etcd 模式，对应 :ref:`ha_k8s_external`

.. note::

   详细部署和异常排查实践请参考 :ref:`deploy_etcd_cluster_with_tls_auth`

:ref:`etcd` 是Kuberntes主流的持久化数据存储，提供了分布式存储能力。在 ``K3s`` 的高可用部署环境，使用 ``external etcd`` 是最稳定可靠的部署模型。

在 :ref:`pi_stack` 环境采用3台 :ref:`pi_3` 硬件部署3节点 :ref:`etcd` 集群:

.. csv-table:: 树莓派k3s管控服务器
   :file: k3s_ha_etcd/hosts.csv
   :widths: 40, 60
   :header-rows: 1

下载etcd
==========

- `etcd-io / etcd Releases <https://github.com/etcd-io/etcd/releases/>`_ 提供了最新版本，当前 ``3.5.2`` :

.. literalinclude:: ../deployment/etcd/install_run_local_etcd/install_etcd.sh
   :language: bash
   :caption: 下载并安装etcd脚本 install_etcd.sh

生成和分发服务器证书
======================

使用 ``cfssl`` 签发证书，不过 :ref:`alpine_linux` 只在 ``edge`` 仓库提供了 ``cfssl`` 。当前我使用alpine linux的stable仓库，不能同时激活stable和edge。

``cfssl`` 官方提供了linux amd64版本，也可以在 macOS 上通过 brew 安装。不过我为了能够独立在 :ref:`pi_stack` 环境完成所有工作，有两种方法安装 ``cfssl`` :

- 在 :ref:`alpine_linux` 环境节点 ``x-k3s-a-0`` 

  - 建立容器运行一个开发环境 ``x-dev`` 
  - 然后 :ref:`alpine_cfssl`
  - 再按照 :ref:`etcd_tls` 方法完成 ``cfssl`` 安装

- 直接采用 :ref:`alpine_linux` 的 ``edge/testing`` 仓库 :ref:`alpine_apk` 安装::

   apk add cfssl --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

.. note::

   Red Hat :ref:`openshift` 所使用的 etcd 镜像就是采用上游 etcd镜像 (基于 Alpine Linux OS) `install: use origin-v4.0 etcd image #511 <https://github.com/openshift/machine-config-operator/pull/511>`_

完整证书创建和分发参考 :ref:`etcd_tls` 和 :ref:`deploy_etcd_cluster_with_tls_auth`

生成证书
----------

- 创建 ``cfssl`` 选项配置:

.. literalinclude:: ../deployment/etcd/etcd_tls/cfssl_options.sh
   :language: bash
   :caption: 保存默认cfssl选项脚本 cfssl_options.sh

- 修改 ``ca-config.json`` 将过期时间延长到10年:

.. literalinclude:: ../deployment/etcd/etcd_tls/ca-config.json
   :language: json
   :caption: 修订证书有效期10年 ca-config.json

- 配置CSR(Certificate Signing Request)配置文件 ``ca-csr.json`` :

.. literalinclude:: ../deployment/etcd/etcd_tls/ca-csr.json
   :language: json
   :caption: 修订CSR ca-csr.json

- 使用上述配置定义生成CA:

.. literalinclude:: ../deployment/etcd/etcd_tls/generate_ca.cmd
   :language: bash
   :caption: 生成CA

- 准备3个服务器 peer certificate 配置:

.. literalinclude:: ../deployment/etcd/etcd_tls/x-k3s-m-1.json
   :language: json
   :caption: 服务器 x-k3s-m-1.edge.huatai.me 点对点证书

.. literalinclude:: ../deployment/etcd/etcd_tls/x-k3s-m-2.json
   :language: json
   :caption: 服务器 x-k3s-m-2.edge.huatai.me 点对点证书

.. literalinclude:: ../deployment/etcd/etcd_tls/x-k3s-m-3.json
   :language: json
   :caption: 服务器 x-k3s-m-3.edge.huatai.me 点对点证书

- 对应生成3个主机的服务器证书:

.. literalinclude:: ../deployment/etcd/etcd_tls/generate_peer_certificate_private_key.sh
   :language: bash
   :caption: 生成3个主机的点对点证书

- 准备 ``client.json`` :

.. literalinclude:: ../deployment/etcd/etcd_tls/client.json
   :language: json
   :caption: client.json

- 生成客户端证书:

.. literalinclude:: ../deployment/etcd/etcd_tls/generate_client_certifacate.cmd
   :language: bash
   :caption: 生成客户端证书

分发证书
---------

- 脚本进行分发:

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/deploy_etcd_certificates.sh
   :language: bash
   :caption: 分发证书脚本 deploy_etcd_certificates.sh

执行脚本::

   sh deploy_etcd_certificates.sh

这样在 ``etcd`` 主机上分别有对应主机的配置文件 ``/etc/etcd`` 目录下有(以下案例是 ``x-k3s-m-1`` ):

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/etcd_certificates_list
   :language: bash
   :caption: x-k3s-m-1 主机证书案例

:ref:`openrc` 启动etcd脚本
===========================

在 :ref:`alpine_linux` 上采用 :ref:`openrc` 服务脚本来控制 ``etcd`` ，采用配置文件来管理服务：

- 准备配置文件 ``conf.yml`` (这个配置文件是 `edge/testing仓库etcd <https://pkgs.alpinelinux.org/package/edge/testing/aarch64/etcd>`_ 的etcd 配置文件 ``/etc/etcd/conf.yml`` 基础上修订，增加配置占位符方便后续通过脚本修订):

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/conf.yml
   :language: yaml
   :caption: etcd配置文件 /etc/etcd/conf.yml

- 修订etcd配置的脚本 ``config_etcd.sh`` :

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/config_etcd.sh
   :language: bash
   :caption: 修订etcd配置的脚本 config_etcd.sh

- 执行以下部署脚本 ``deploy_etcd_config.sh`` :

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/deploy_etcd_config.sh
   :language: bash
   :caption: 执行etcd修订脚本 deploy_etcd_config.sh

::

   sh deploy_etcd_config.sh

然后验证每台管控服务器上 ``/etc/etcd/config.yml`` 配置文件中的占位符是否已经正确替换成主机名。正确情况下， ``/etc/etcd/conf.yml`` 中对应 ``占位符`` 都会被替换成对应主机的IP地址或者域名

- 准备配置文件 ``conf.d-etcd`` 和 ``init.d-etcd`` (从alpine linux软件仓库 ``etcd-openrc`` 软件包提取)

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/conf.d-etcd
   :language: bash
   :caption: openrc的etcd配置文件 /etc/conf.d/etcd

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/init.d-etcd
   :language: bash
   :caption: openrc的etcd服务配置文件 /etc/init.d/etcd

- 然后执行以下 ``deploy_etcd_service.sh`` :

.. literalinclude:: ../deployment/etcd/deploy_etcd_cluster_with_tls_auth/deploy_etcd_service.sh
   :language: bash
   :caption: 分发openrc的etcd服务脚本 deploy_etcd_service.sh

::

   sh deploy_etcd_service.sh

- 在3台管控服务器上启动服务::

   sudo service etcd start

- 配置服务器启动时自动启动::

   sudo rc-update add etcd

验证etcd集群
===============

现在 ``etcd`` 集群已经启动，我们使用以下命令检查集群是否正常工作::

   curl --cacert ca.pem --cert client.pem --key client-key.pem https://etcd.edge.huatai.me:2379/health

此时返回信息应该是::

   {"health":"true","reason":""}

为方便日常维护，为 ``etcdctl`` 配置环境变量 ``/etc/profile`` :

.. literalinclude:: k3s_ha_etcd/profile
   :language: bash
   :caption: 配置 /etc/profile 设置etcd访问环境变量

- 检查集群节点状态::

   etcdctl --write-out=table endpoint status

输出显示::

   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   |         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   | https://192.168.7.11:2379 | 7e8d94ba496c072d |   3.5.2 |  4.5 MB |     false |      false |        10 |   13295290 |           13295290 |        |
   | https://192.168.7.12:2379 | a01cb65343e64610 |   3.5.2 |  4.4 MB |      true |      false |        10 |   13295290 |           13295290 |        |
   | https://192.168.7.13:2379 |   9bfd4ef1e72d26 |   3.5.2 |  4.5 MB |     false |      false |        10 |   13295290 |           13295290 |        |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

参考
=======

- `Setting up Etcd Cluster with TLS Authentication Enabled <https://medium.com/nirman-tech-blog/setting-up-etcd-cluster-with-tls-authentication-enabled-49c44e4151bb>`_
- `etcd Security Guide <https://github.com/ericchiang/etcd-security-guide>`_
- `Generate self-signed certificates <https://github.com/coreos/docs/blob/master/os/generate-self-signed-certificates.md>`_ CoreOS官方(etcd开发公司)提供的指导文档
