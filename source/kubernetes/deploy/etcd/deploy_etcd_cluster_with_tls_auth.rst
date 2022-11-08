.. _deploy_etcd_cluster_with_tls_auth:

======================
部署TLS认证的etcd集群
======================

分布式高可用的etcd集群，在生产环境上需要启用TLS认证来加强安全性。在完成 :ref:`deploy_etcd_cluster` 之后，我在部署 :ref:`k3s` 中，采用 :ref:`k3s_ha_etcd` 实现。

实践环境
==========

在 :ref:`pi_stack` 环境采用3台 :ref:`pi_3` 硬件部署3节点 :ref:`etcd` 集群:

.. csv-table:: 树莓派k3s管控服务器
   :file: ../../k3s/k3s_ha_etcd/hosts.csv
   :widths: 40, 60
   :header-rows: 1

TLS证书
==========

TLS证书采用 ``cfssl`` 工具构建，完整步骤见 :ref:`etcd_tls` 。分别获得:

- CA::

   ca-key.pem
   ca.csr
   ca.pem

- 服务器证书::

   server-key.pem
   server.csr
   server.pem

- 点对点证书::

   x-k3s-m-1-key.pem
   x-k3s-m-1.csr
   x-k3s-m-1.pem

   x-k3s-m-2.csr
   x-k3s-m-2.json
   x-k3s-m-2.pem

   x-k3s-m-3.csr
   x-k3s-m-3.json
   x-k3s-m-3.pem

- 客户端证书::

   client-key.pem
   client.csr
   client.pem

证书分发
=========

- 为方便使用ssh/scp进行管理，首先采用 :ref:`ssh_key` 的 :ref:`ssh-agent_profile` 结合 :ref:`ssh_multiplexing` ，这样可以不必输入密码就可以ssh/scp到集群服务器

- 配置好 :ref:`edge_cloud_infra` 的 :ref:`dnsmasq_domains_for_subnets` ，提供正确的域名解析，这样后面配置 ``etcd`` 可以正确获得主机名解析

- 使用 :ref:`etcd_tls` 方法完成上述证书生成后，使用以下脚本进行分发:

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/deploy_etcd_certificates.sh
   :language: bash
   :caption: 分发证书脚本 deploy_etcd_certificates.sh

执行脚本::

   sh deploy_etcd_certificates.sh

这样在 ``etcd`` 主机上分别有对应主机的配置文件 ``/etc/etcd`` 目录下有(以下案例是 ``x-k3s-m-1`` ):

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/etcd_certificates_list
   :language: bash
   :caption: x-k3s-m-1 主机证书案例

配置启动服务脚本
===================

:ref:`systemd` 启动etcd脚本
----------------------------

... 待完善

:ref:`openrc` 启动etcd脚本
----------------------------

.. note::

   参考alpine linux软件仓库 ``etcd`` 和 ``etcd-openrc`` 软件包配置方法，我在 :ref:`openrc` 配置etcd时，采用 ``/etc/etcd/conf.yml`` 配置文件来配置etcd。

   需要注意 :ref:`etcd_config_rule` : 如果提供配置文件，则运行参数和环境变量都不会生效!!!

   当然，也可以采用命令行参数(见上文 :ref:`systemd` 启动etcd脚本 )，或者采用环境变量。

   从惯例来看，大多数网上配置都采用命令行参数，部分采用环境变量。不过，我觉得对于固定配置，特别是不依赖 :ref:`systemd` 这样的启动器，使用配置文件是最通用的。

:ref:`alpine_linux` 的 `edge/testing仓库提供etcd-openrc <https://pkgs.alpinelinux.org/package/edge/testing/aarch64/etcd-openrc>`_ ，包含了 openrc 启动脚本以及配置:

- ``/etc/init.d/etcd``
- ``/etc/conf.d/etcd``

此外 `edge/testing仓库etcd <https://pkgs.alpinelinux.org/package/edge/testing/aarch64/etcd>`_ 包含了 etcd 配置文件 ``/etc/etcd/conf.yml`` 

所以，在测试主机 ``x-dev`` 上 :ref:`alpine_apk_add` ( ``edge/testing`` ) ::

   sudo apk add etcd-openrc etcd --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

可以在此基础上做自定义配置，

- 准备配置文件 ``conf.yml`` (这个配置文件是 `edge/testing仓库etcd <https://pkgs.alpinelinux.org/package/edge/testing/aarch64/etcd>`_ 的etcd 配置文件 ``/etc/etcd/conf.yml`` 基础上修订，增加了配置占位符方便后续通过脚本修订):

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/conf.yml
   :language: yaml
   :caption: etcd配置文件 /etc/etcd/conf.yml

- 准备一个为每个管控服务器修订etcd配置的脚本 ``config_etcd.sh`` :

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/config_etcd.sh
   :language: bash
   :caption: 修订etcd配置的脚本 config_etcd.sh

.. note::

   配置文件 ``conf.yml`` 中，初始化etcd绑定的url必须使用主机的IP地址，不能使用域名::

      # List of comma separated URLs to listen on for peer traffic.
      listen-peer-urls: https://192.168.7.11:2380

      # List of comma separated URLs to listen on for client traffic.
      listen-client-urls: https://192.168.7.11:2379,https://127.0.0.1:2379

   如果使用域名，如 ``x-k3s-m-1.edge.huatai.me`` (即使域名解析正确)，启动etcd还是会报错::

      {"level":"warn","ts":1649611005.237307,"caller":"etcdmain/etcd.go:74","msg":"failed to verify flags","error":"expected IP in URL for binding (http://x-k3s-m-1.edge.huatai.me:2380)"}

- 执行以下 ``deploy_etcd_config.sh`` :

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/deploy_etcd_config.sh
   :language: bash
   :caption: 执行etcd修订脚本 deploy_etcd_config.sh

::

   sh deploy_etcd_config.sh

然后验证每台管控服务器上 ``/etc/etcd/config.yml`` 配置文件中的占位符是否已经正确替换成主机名。正确情况下， ``/etc/etcd/conf.yml`` 中对应 ``占位符`` 都会被替换成对应主机的IP地址或者域名，例如::

   # Human-readable name for this member.
   name: 'x-k3s-m-1'
   ...
   # List of comma separated URLs to listen on for peer traffic.
   listen-peer-urls: https://192.168.7.11:2380

   # List of comma separated URLs to listen on for client traffic.
   listen-client-urls: https://192.168.7.11:2379,https://127.0.0.1:2379
   ...
   # Initial cluster configuration for bootstrapping.
   initial-cluster: x-k3s-m-1=https://x-k3s-m-1.edge.huatai.me:2380,x-k3s-m-2=https://x-k3s-m-2.edge.huatai.me:2380,x-k3s-m-3=https://x-k3s-m-3.edge.huatai.me:2380
   ...

- 准备配置文件 ``conf.d-etcd`` 和 ``init.d-etcd`` (从alpine linux软件仓库 ``etcd-openrc`` 软件包提取)

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/conf.d-etcd
   :language: bash
   :caption: openrc的etcd配置文件 /etc/conf.d/etcd

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/init.d-etcd
   :language: bash
   :caption: openrc的etcd服务配置文件 /etc/init.d/etcd

- 然后执行以下 ``deploy_etcd_service.sh`` :

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/deploy_etcd_service.sh
   :language: bash
   :caption: 分发openrc的etcd服务脚本 deploy_etcd_service.sh

::

   sh deploy_etcd_service.sh

- 启动服务::

   sudo service etcd start

检查
===========

- 启动 ``etcd`` 之后，检查服务进程::

   ps aux | grep etcd

可以看到::

   5665 root      0:00 supervise-daemon etcd --start --stdout /var/log/etcd/etcd.log --stderr /var/log/etcd/etcd.log --user etcd etcd --chdir /var/lib/etcd /usr/bin/etcd -- --config-file=/etc/etcd/conf.yml
   5666 etcd      0:01 /usr/bin/etcd --config-file=/etc/etcd/conf.yml

- 检查日志::

   tail -f /var/log/etcd/etcd.log

证书错误排查
---------------

我在启动 ``etcd`` 服务之后，检查 ``etcd.log`` 发现有如下报错::

   WARNING: 2022/04/11 23:59:00 [core] grpc: addrConn.createTransport failed to connect to {127.0.0.1:2379 127.0.0.1:2379 <nil> 0 <nil>}. Err: connection error: desc = "transport: authentication handshake failed: remote error: tls: bad certificate". Reconnecting...
   {"level":"warn","ts":"2022-04-11T23:59:13.567+0800","caller":"embed/config_logging.go:169","msg":"rejected connection","remote-addr":"192.168.7.11:53050","server-name":"","error":"tls: failed to verify client certificate: x509: certificate specifies an incompatible key usage"}
   WARNING: 2022/04/11 23:59:13 [core] grpc: addrConn.createTransport failed to connect to {192.168.7.11:2379 192.168.7.11:2379 <nil> 0 <nil>}. Err: connection error: desc = "transport: authentication handshake failed: remote error: tls: bad certificate". Reconnecting...
   {"level":"warn","ts":"2022-04-11T23:59:15.891+0800","caller":"embed/config_logging.go:169","msg":"rejected connection","remote-addr":"127.0.0.1:50242","server-name":"","error":"tls: failed to verify client certificate: x509: certificate specifies an incompatible key usage"}

并且，每个服务器上都有类似对应错误

这个问题在 `ETCD出现：certificate specifies an incompatible key usage 解决方案 <https://blog.csdn.net/IT_DREAM_ER/article/details/107007186>`_ 提供了解决思路: 原因参考 `3.2/3.3 etcd server with TLS would start with error "tls: bad certificate" #9398 <https://github.com/etcd-io/etcd/issues/9398>`_ ，是因为在 :ref:`etcd_tls` 时使用的 ``ca-config.json`` 采用了::

   ...
            "server": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            }, 
   ...

没有添加 ``"client auth"`` ，这在早期etcd版本中不是问题，但是在 3.2 版本之后，需要添加，也就是::

   ...
            "server": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }, 
   ...

然后重新生成证书

验证etcd集群
===============

现在 ``etcd`` 集群已经启动，我们使用以下命令检查集群是否正常工作::

   curl --cacert ca.pem --cert client.pem --key client-key.pem https://etcd.edge.huatai.me:2379/health

此时返回信息应该是::

   {"health":"true","reason":""}

注意，这里访问的域名是 ``etcd.edge.huatai.me`` ，原因是 :ref:`etcd_tls` 配置 ``server.json`` 时在证书中指定访问域名是 ``etcd.edge.huatai.me`` (或IP)

.. literalinclude:: etcd_tls/server.json
   :language: json
   :caption: server.json 配置 hosts 部分指定服务器访问域名是 etcd.edge.huatai.me
   :emphasize-lines: 4

所以不能使用 ``x-k3s-m-1.edge.huatai.me`` 这样的 real server 域名，但是可以使用 ``192.168.7.11`` 的IP地址，因为IP地址也配置在证书中

上述 ``server.json`` 非常巧妙使用了可以同时解析为多个real server的域名 ``etcd.edge.huatai.me`` ，也就是生产环境上，可以配置这个域名轮转到这3台服务器的IP上，或者使用一个 :ref:`load_balancer` 分发到这3个real server上，域名解析绑定到负载均衡的VIP上。

- 为方便维护，配置 ``etcdctl`` 环境变量，添加到用户自己的 profile中:

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/etcdctl_env
   :language: bash
   :caption: etcdctl 使用的环境变量

然后可以检查:

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/etcdctl_member_list
   :language: bash
   :caption: etcdctl 检查集群成员列表(member list)

输出类似::

   9bfd4ef1e72d26, started, x-k3s-m-3, https://x-k3s-m-3.edge.huatai.me:2380, https://x-k3s-m-3.edge.huatai.me:2379, false
   7e8d94ba496c072d, started, x-k3s-m-1, https://x-k3s-m-1.edge.huatai.me:2380, https://x-k3s-m-1.edge.huatai.me:2379, false
   a01cb65343e64610, started, x-k3s-m-2, https://x-k3s-m-2.edge.huatai.me:2380, https://x-k3s-m-2.edge.huatai.me:2379, false

为方便观察，可以使用表格输出模式:

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_status
   :language: bash
   :caption: etcdctl 检查endpoint状态(表格形式输出)

输出显示::

   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   |         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   | https://192.168.7.11:2379 | 7e8d94ba496c072d |   3.5.2 |   20 kB |     false |      false |         7 |        237 |                237 |        |
   | https://192.168.7.12:2379 | a01cb65343e64610 |   3.5.2 |   20 kB |     false |      false |         7 |        237 |                237 |        |
   | https://192.168.7.13:2379 |   9bfd4ef1e72d26 |   3.5.2 |   20 kB |      true |      false |         7 |        237 |                237 |        |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

检查健康状况:

.. literalinclude:: deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_health
   :language: bash
   :caption: etcdctl 检查endpoint健康状态(查看节点响应情况)

输出显示::

   https://192.168.7.13:2379 is healthy: successfully committed proposal: took = 67.98523ms
   https://192.168.7.12:2379 is healthy: successfully committed proposal: took = 64.634362ms
   https://192.168.7.11:2379 is healthy: successfully committed proposal: took = 67.330493ms

参考
======

- `etcd Clustering Guide <https://etcd.io/docs/v3.4.0/op-guide/clustering/>`_
- `Setting up Etcd Cluster with TLS Authentication Enabled <https://medium.com/nirman-tech-blog/setting-up-etcd-cluster-with-tls-authentication-enabled-49c44e4151bb>`_ 这篇文档非常详细指导了如何使用cfssl工具来生成etcd服务器证书，以及签名客户端证书
- `Deploy a secure etcd cluster <https://pcocc.readthedocs.io/en/latest/deps/etcd-production.html>`_
- `How To Setup a etcd Cluster On Linux – Beginners Guide <https://devopscube.com/setup-etcd-cluster-linux/>`_ 提供了一个生成 :ref:`systemd` 配置的脚本
- `How to check Cluster status <https://etcd.io/docs/v3.5/tutorials/how-to-check-cluster-status/>`_
