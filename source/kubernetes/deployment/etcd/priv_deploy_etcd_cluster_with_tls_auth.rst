.. _priv_deploy_etcd_cluster_with_tls_auth:

============================
私有云部署TLS认证的etcd集群
============================


在部署 :ref:`k3s` 集群，我采用了 :ref:`deploy_etcd_cluster_with_tls_auth` 。在这个基础上，我部署 :ref:`priv_etcd` 时，采用本文方法实践。

实践环境
==========

服务器依然是 :ref:`priv_etcd_tls` 中使用的 通过 :ref:`priv_kvm` 构建3台虚拟机:

.. csv-table:: 私有云KVM虚拟机
   :file: priv_etcd_tls/hosts.csv
   :widths: 40, 60
   :header-rows: 1

TLS证书
==========

TLS证书采用 ``cfssl`` 工具构建，完整步骤见 :ref:`priv_etcd_tls` 。分别获得:

- CA::

   ca-key.pem
   ca.csr
   ca.pem

- 服务器证书::

   server-key.pem
   server.csr
   server.pem

- 点对点证书::

   z-b-data-1-key.pem
   z-b-data-1.csr
   z-b-data-1.pem

   z-b-data-2.csr
   z-b-data-2.json
   z-b-data-2.pem

   z-b-data-3.csr
   z-b-data-3.json
   z-b-data-3.pem

- 客户端证书::

   client-key.pem
   client.csr
   client.pem

安装软件包
===========

采用 :ref:`install_run_local_etcd` 中安装脚本下载最新安装软件包(当前版本 ``3.5.4`` )

.. literalinclude:: install_run_local_etcd/install_etcd.sh
   :language: bash
   :caption: 下载etcd的linux版本脚本 install_etcd.sh

- 在安装节点创建 etcd 目录以及用户和用户组(如果使用了 :ref:`priv_lvm` 中构建的 ``lv-etcd`` 卷，则忽略目录创建):

.. literalinclude::  deploy_etcd_cluster/useradd_etcd
   :language: bash
   :caption: useradd添加etcd用户账号

证书分发
=========

- 为方便使用ssh/scp进行管理，首先采用 :ref:`ssh_key` 的 :ref:`ssh-agent_profile` 结合 :ref:`ssh_multiplexing` ，这样可以不必输入密码就可以ssh/scp到集群服务器

- 配置好 :ref:`edge_cloud_infra` 的 :ref:`dnsmasq_domains_for_subnets` ，提供正确的域名解析，这样后面配置 ``etcd`` 可以正确获得主机名解析

- 使用 :ref:`etcd_tls` 方法完成上述证书生成后，使用以下脚本进行分发:

.. literalinclude:: priv_deploy_etcd_cluster_with_tls_auth/deploy_etcd_certificates.sh
   :language: bash
   :caption: 分发证书脚本 deploy_etcd_certificates.sh

执行脚本::

   sh deploy_etcd_certificates.sh

这样在 ``etcd`` 主机上分别有对应主机的配置文件 ``/etc/etcd`` 目录下

配置启动服务脚本
===================

:ref:`systemd` 启动etcd脚本
----------------------------

- 可以通过以下命令获得环境变量，不过后面我在构建配置文件时会结合这个环境变量

.. literalinclude:: priv_deploy_etcd_cluster_with_tls_auth/etcd_env
   :language: bash
   :caption: etcd环境变量

.. note::

   实际上很多网上部署案例或者生产环境部署etcd都不采用配置文件，而是通过命令行参数来调整 ``etcd`` 运行特性。根据 :ref:`etcd_config_rule` ，配置文件优先级最高，所以我采用所有调整参数都以配置文件为准，无命令行参数。

.. note::

   ``etcd`` 配置中有一些变量，我之前在 :ref:`deploy_etcd_cluster_with_tls_auth` 采用模版中占用符方式，然后通过 ``sed`` 去替换。虽然可行，但是不够优雅。更为简洁方便的方式是采用SHELL的 :ref:`here_document` 特性，通过一些环境变量自动从脚本中替换好变量，本文即采用此方法。

- 执行脚本 ``generate_etcd_service`` 生成 ``/etc/etcd/conf.yml`` 配置文件和 :ref:`systemd` 启动 ``etcd`` 配置文件  ``/lib/systemd/system/etcd.service`` :

.. literalinclude:: priv_deploy_etcd_cluster_with_tls_auth/generate_etc_config_systemd
   :language: bash
   :caption: 创建etcd启动的配置conf.yml 和 systemd脚本

.. note::

   配置文件 ``conf.yml`` 和之前实践 :ref:`deploy_etcd_cluster_with_tls_auth` 相同，只不过我采用了 :ref:`here_document` 来完成变量替换。这里无需再手工编辑配置

.. note::

   配置文件 ``conf.yml`` 中，初始化etcd绑定的url必须使用主机的IP地址，不能使用域名::

      # List of comma separated URLs to listen on for peer traffic.
      listen-peer-urls: https://192.168.6.204:2380

      # List of comma separated URLs to listen on for client traffic.
      listen-client-urls: https://192.168.6.204:2379,https://127.0.0.1:2379

   如果使用域名，如 ``z-b-data-1.staging.huatai.me`` (即使域名解析正确)，启动etcd还是会报错::

      {"level":"warn","ts":1649611005.237307,"caller":"etcdmain/etcd.go:74","msg":"failed to verify flags","error":"expected IP in URL for binding (http://z-b-data-1.staging.huatai.me:2380)"}

- 激活服务::

   sudo systemctl enable etcd.service

- 启动服务::

   sudo systemctl start etcd.service

问题排查
============

- 检查启动失败原因::

   sudo systemctl status etcd.service
   sudo journalctl -xe

初始化集群未找到对应节点名
---------------------------

启动日志::

   Jul 03 00:41:30 z-b-data-1 etcd[13044]: {"level":"fatal","ts":"2022-07-03T00:41:30.498+0800","caller":"etcdmain/etcd.go:204","msg":"discovery failed","error":"couldn't find local name \"z-b-data-1\" in the initial cluster configuration","stacktrace":"go.etcd.io/etcd/server/v3/etcdmain.startEtcdOrProxyV2\n\t/go/src/go.etcd.io/etcd/re>
   Jul 03 00:41:30 z-b-data-1 systemd[1]: etcd.service: Main process exited, code=exited, status=1/FAILURE"}

仔细核对了配置( 受到 `couldn't find local name "" in the initial cluster configuration when start etcd service <https://stackoverflow.com/questions/57613355/couldnt-find-local-name-in-the-initial-cluster-configuration-when-start-etcd>`_ 启发 )，原来在配置文件中有一行::

   # Initial cluster configuration for bootstrapping.
   initial-cluster: NODE1=https://192.168.6.204:2380,NODE2=https://192.168.6.205:2380,NODE3=https://192.168.6.206:2380

这行配置错误了，必须修订成::

   initial-cluster: z-b-data-1=https://192.168.6.204:2380,z-b-data-2=https://192.168.6.205:2380,z-b-data-3=https://192.168.6.206:2380

这样才能和配置文件中最初的::

   # Human-readable name for this member.
   name: z-b-data-1

对应起来。也就是必须告知 ``initial-cluster`` ， ``z-b-data-1`` 对应的是那个服务器配置，这里就是 ``https://192.168.6.204:2380``

unmarshaling JSON
---------------------

启动日志报错::

   Jul 03 20:54:56 z-b-data-1 etcd[266420]: {"level":"warn","ts":"2022-07-03T20:54:56.212+0800","caller":"etcdmain/etcd.go:75","msg":"failed to verify flags","error":"error unmarshaling JSON: while decoding JSON: json: cannot unmarshal string into Go struct field configYAML.log-outputs of type []string"}
   Jul 03 20:54:56 z-b-data-1 systemd[1]: etcd.service: Main process exited, code=exited, status=1/FAILURE
   -- Subject: Unit process exited

上述报错 ``error unmarshaling JSON: while decoding JSON`` 在很多yaml配置错误时候就会出现，例如 `Concourse get bitbucket resource error unmarshaling JSON: while decoding JSON <https://stackoverflow.com/questions/62271644/concourse-get-bitbucket-resource-error-unmarshaling-json-while-decoding-json>`_ 

不过，我经过实践检查发现，原来我配置了::

   # Specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.
   #log-outputs: [stderr]
   log-outputs: /var/log/etcd/etcd.log

是错误的，需要恢复为::

   # Specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.
   log-outputs: [stderr]

.. note::

   使用 :ref:`systemd` 管理 ``etcd`` ，日志可以通过 :ref:`journalctl` 来观察

检查
===========

- 启动 ``etcd`` 之后，检查服务进程::

   ps aux | grep etcd

可以看到::

   etcd        8556  2.1  0.2 11214264 39296 ?      Ssl  22:02   0:02 /usr/local/bin/etcd --config-file=/etc/etcd/conf.yml

- 检查日志::

   journalctl -u etcd.service

验证etcd集群
===============

- 为方便维护，配置 ``etcdctl`` 环境变量，添加到用户自己的 profile中:

.. literalinclude:: priv_deploy_etcd_cluster_with_tls_auth/etcdctl_env
   :language: bash
   :caption: etcdctl 使用的环境变量

然后可以检查::

   etcdctl member list

输出类似::

   9bfd4ef1e72d26, started, z-b-data-3, https://z-b-data-3.staging.huatai.me:2380, https://z-b-data-3.staging.huatai.me:2379, false
   7e8d94ba496c072d, started, z-b-data-1, https://z-b-data-1.staging.huatai.me:2380, https://z-b-data-1.staging.huatai.me:2379, false
   a01cb65343e64610, started, z-b-data-2, https://z-b-data-2.staging.huatai.me:2380, https://z-b-data-2.staging.huatai.me:2379, false

为方便观察，可以使用表格输出模式::

   etcdctl --write-out=table endpoint status

输出显示::

   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   |         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   | https://192.168.6.204:2379 | 7e8d94ba496c072d |   3.5.2 |   20 kB |     false |      false |         7 |        237 |                237 |        |
   | https://192.168.6.205:2379 | a01cb65343e64610 |   3.5.2 |   20 kB |     false |      false |         7 |        237 |                237 |        |
   | https://192.168.6.206:2379 |   9bfd4ef1e72d26 |   3.5.2 |   20 kB |      true |      false |         7 |        237 |                237 |        |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

检查健康状况::

   etcdctl endpoint health

输出显示::

   https://192.168.6.206:2379 is healthy: successfully committed proposal: took = 67.98523ms
   https://192.168.6.205:2379 is healthy: successfully committed proposal: took = 64.634362ms
   https://192.168.6.204:2379 is healthy: successfully committed proposal: took = 67.330493ms

参考
======

- `etcd Clustering Guide <https://etcd.io/docs/v3.4.0/op-guide/clustering/>`_
- `Setting up Etcd Cluster with TLS Authentication Enabled <https://medium.com/nirman-tech-blog/setting-up-etcd-cluster-with-tls-authentication-enabled-49c44e4151bb>`_ 这篇文档非常详细指导了如何使用cfssl工具来生成etcd服务器证书，以及签名客户端证书
- `Deploy a secure etcd cluster <https://pcocc.readthedocs.io/en/latest/deps/etcd-production.html>`_
- `How To Setup a etcd Cluster On Linux – Beginners Guide <https://devopscube.com/setup-etcd-cluster-linux/>`_ 提供了一个生成 :ref:`systemd` 配置的脚本
- `How to check Cluster status <https://etcd.io/docs/v3.5/tutorials/how-to-check-cluster-status/>`_
