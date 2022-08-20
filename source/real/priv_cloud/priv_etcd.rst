.. _priv_etcd:

===================
私有云etcd服务
===================

.. note::

   本文结合了多个实践文档的再次综合实践:

   - :ref:`priv_etcd_tls`
   - :ref:`priv_deploy_etcd_cluster_with_tls_auth`

.. note::

   本文步骤比较繁琐，主要是etcd证书生成步骤较多。我后面再部署新集群时候将改写为脚本以便快速部署。

通过 :ref:`priv_kvm` 构建3台虚拟机，并且部署 :ref:`priv_lvm` 后，就可以在独立划分的存储 ``/var/lib/etcd`` 目录之上构建etcd，这样可以为 :ref:`etcd` 提供高性能虚拟化存储。

.. csv-table:: 私有云KVM虚拟机
   :file: ../../kubernetes/deployment/etcd/priv_etcd_tls/hosts.csv
   :widths: 40, 60
   :header-rows: 1

etcd集群证书生成
==================

发行版安装cfssl
--------------------

- 安装Cloudflare 的 ``cfssl`` 工具:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/apt_install_cfssl
   :language: bash
   :caption: ubuntu发行版提供Cloudflare的cfssl工具

初始化证书认证
------------------

- 准备 ``ca-config.json`` (有效期限10年):

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/ca-config.json
   :language: json
   :caption: 修订证书有效期10年 ca-config.json
   :emphasize-lines: 13

.. note::

   这里CA配置中， ``"server"`` 段落必须要添加 ``"client auth"`` ，否则高版本etcd启动时会提示连接错误。详见 :ref:`deploy_etcd_cluster_with_tls_auth`

- 配置CSR(Certificate Signing Request)配置文件 ``ca-csr.json`` :

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/ca-csr.json
   :language: json
   :caption: 修订CSR ca-csr.json

- 使用上述配置定义生成CA:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/generate_ca.cmd
   :language: bash
   :caption: 生成CA

这样将获得3个文件::

   ca-key.pem
   ca.csr
   ca.pem

.. warning::

   请确保 ``ca-key.pem`` 文件安全，该文件是CA可以创建任何证书

- 生成服务器证书: 直接编辑 ``server.json`` :

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/server.json
   :language: json
   :caption: 修订 server.json

- 生成服务器证书和私钥:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/generate_server_certifacate_private_key.cmd
   :language: bash
   :caption: 生成服务器证书和私钥

这样获得3个文件::

   server-key.pem
   server.csr
   server.pem

- peer certificate (每个服务器一个，按对应主机名):

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/z-b-data-1.json
   :language: json
   :caption: 服务器 z-b-data-1.staging.huatai.me 点对点证书

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/z-b-data-2.json
   :language: json
   :caption: 服务器 z-b-data-2.staging.huatai.me 点对点证书

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/z-b-data-3.json
   :language: json
   :caption: 服务器 z-b-data-3.staging.huatai.me 点对点证书

对应生成3个主机的服务器证书:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/generate_peer_certificate_private_key.sh
   :language: bash
   :caption: 生成3个主机的点对点证书

此时获得对应文件是::

   z-b-data-1-key.pem
   z-b-data-1.csr
   z-b-data-1.pem
   ...

- 客户端证书 ``client.json`` (主要是主机列表保持空):

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/client.json
   :language: json
   :caption: 修订 client.json

- 现在可以生成客户端证书:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_etcd_tls/generate_client_certifacate.cmd
   :language: bash
   :caption: 生成客户端证书

获得了以下文件::

   client-key.pem
   client.csr
   client.pem

安装软etcd件包
================

- 采用 :ref:`install_run_local_etcd` 中安装脚本下载最新安装软件包(当前版本 ``3.5.4`` )

.. literalinclude:: ../../kubernetes/deployment/etcd/install_run_local_etcd/install_etcd.sh
   :language: bash
   :caption: 下载etcd的linux版本脚本 install_etcd.sh

- - 在安装节点创建 etcd 目录以及用户和用户组(如果使用了 :ref:`priv_lvm` 中构建的 ``lv-etcd`` 卷，则忽略目录创建):

.. literalinclude::  ../../kubernetes/deployment/etcd/deploy_etcd_cluster/useradd_etcd
   :language: bash
   :caption: useradd添加etcd用户账号

证书分发
=========

- 为方便使用ssh/scp进行管理，首先采用 :ref:`ssh_key` 的 :ref:`ssh-agent_profile` 结合 :ref:`ssh_multiplexing` ，这样可以不必输入密码就可以ssh/scp到集群服务器

- 使用以下脚本进行分发:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_deploy_etcd_cluster_with_tls_auth/deploy_etcd_certificates.sh
   :language: bash
   :caption: 分发证书脚本 deploy_etcd_certificates.sh

执行脚本::

   sh deploy_etcd_certificates.sh

这样在 ``etcd`` 主机上分别有对应主机的配置文件 ``/etc/etcd`` 目录下

配置etcd
===========

- 执行脚本 ``generate_etcd_service`` 生成 ``/etc/etcd/conf.yml`` 配置文件和 :ref:`systemd` 启动 ``etcd`` 配置文件  ``/lib/systemd/system/etcd.service`` :

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_deploy_etcd_cluster_with_tls_auth/generate_etc_config_systemd
   :language: bash
   :caption: 创建etcd启动的配置conf.yml 和 systemd脚本

- 激活服务::

   sudo systemctl enable etcd.service

- 启动服务::

   sudo systemctl start etcd.service

检查
===========

- 启动 ``etcd`` 之后，检查服务进程::

   ps aux | grep etcd

- 检查日志::

   journalctl -u etcd.service

验证etcd集群
===============

- 为方便维护，配置 ``etcdctl`` 环境变量，添加到用户自己的 profile中:

.. literalinclude:: ../../kubernetes/deployment/etcd/priv_deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_env
   :language: bash
   :caption: ETCDCTL_ENDPOINTS 环境变量
   :emphasize-lines: 2,3

然后可以检查

- 检查节点状态:

.. literalinclude:: ../../kubernetes/deployment/etcd/deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_status
   :language: bash
   :caption: etcdctl 检查endpoint状态(表格形式输出)

- 检查节点健康状况:

.. literalinclude:: ../../kubernetes/deployment/etcd/deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_health
   :language: bash
   :caption: etcdctl 检查endpoint健康状态(查看节点响应情况)

- (重要步骤)由于 ``etcd`` 已经完成部署，之前在 ``/etc/etcd/conf.yml`` 配置集群状态，需要从 ``new`` 改为 ``existing`` ，表明集群已经建设完成::

   # Initial cluster state ('new' or 'existing').
   initial-cluster-state: 'existing'
