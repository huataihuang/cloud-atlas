.. _deploy_etcd_cluster:

===============
部署etcd集群
===============

.. note::

   `在线etcd模拟实验室 <http://play.etcd.io/install>`_ 提供了在线模拟部署etcd的实验，并且这个 `etcdlabs <https://github.com/coreos/etcdlabs>`_ 是 `etcd.io <https://etcd.io>`_ 官方开源项目，方便进行模拟学习。

本文是最基础的 ``etcd`` 集群配置，没有使用 :ref:`etcd_tls` ，所以仅作为测试使用。实际生产集群部署应采用 :ref:`deploy_etcd_cluster_with_tls_auth`

部署服务器采用 :ref:`studio_ip` 中  ``dev`` 环境的 ``etcd-1`` / ``etcd-2`` / ``etcd-3`` 这3台开发服务器（虚拟机）。 

静态etcd集群
=============

启动一个 ``静态`` (static) etcd集群是指集群的每个节点都彼此知晓，在启动时etcd初始化可以发现彼此服务。一旦一个static etcd cluster启动并运行，就可以通过 :ref:`runtime_config_etcd` 添加或移除节点。

准备安装环境
=============

- 在安装节点创建 etcd 目录以及用户和用户组:

.. literalinclude::  deploy_etcd_cluster/useradd_etcd
   :language: bash
   :caption: useradd添加etcd用户账号

- 下载etcd和etcdctl: 方法参考 :ref:`install_etcd`

由于静态etcd集群是知道所有集群节点，地址以及集群的大小，所以使用 ``initial-cluster`` 参数来使用offline bootstrap配置，每个节点可以通过环境变量或者命令行参数来启动初始化。

例如，环境变量方式::

   ETCD_INITIAL_CLUSTER="etcd1=http://192.168.122.5:2380,etcd2=http://192.168.122.6:2380,etcd3=http://192.168.122.7:2380"
   ETCD_INITIAL_CLUSTER_STATE=new

或者使用命令行参数::

   --initial-cluster etcd1=http://192.168.122.5:2380,etcd2=http://192.168.122.6:2380,etcd3=http://192.168.122.7:2380 \
   --initial-cluster-state new

.. note::

   对于创建多个集群，建议每个集群使用一个唯一的 ``initial-cluster-token`` ，这样即使集群使用了相同配置，etcd都会生成唯一的cluster ID和member ID。

启动etcd
===========

- 在3个节点上执行以下命令启动服务::

   ETCD_PEER=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
   ETCD_NAME=$(hostname -s)
   
   ETCD_TOKEN=k8s-dev-etcd
   ETCD_1=etcd-1
   ETCD_IP_1=192.168.122.5
   ETCD_2=etcd-2
   ETCD_IP_2=192.168.122.6
   ETCD_3=etcd-3
   ETCD_IP_3=192.168.122.7
   
   ETCD_DATA_DIR="/var/lib/etcd"
   
   
   sudo -u etcd \
   etcd --name ${ETCD_NAME} --initial-advertise-peer-urls http://${ETCD_PEER}:2380 \
     --listen-peer-urls http://${ETCD_PEER}:2380 \
     --listen-client-urls http://${ETCD_PEER}:2379,http://127.0.0.1:2379 \
     --advertise-client-urls http://${ETCD_PEER}:2379 \
     --initial-cluster-token ${ETCD_TOKEN} \
     --initial-cluster ${ETCD_1}=http://${ETCD_IP_1}:2380,${ETCD_2}=http://${ETCD_IP_2}:2380,${ETCD_3}=http://${ETCD_IP_3}:2380 \
     --data-dir ${ETCD_DATA_DIR} \
     --initial-cluster-state new

这里报错::

   sudo: etcd: command not found

sudo 命令的 ``$PAHT`` 没有包含 ``/usr/local/sbin`` ，这个可以通过 ``sudo env`` 查看到::

   PATH=/sbin:/bin:/usr/sbin:/usr/bin

所以建一个软链接::

   ln -s /usr/local/sbin/etcd /usr/sbin/etcd

注意，需要在服务器上开启允许访问端口，否则会报错::

   20-04-30 00:12:07.052994 W | rafthttp: health check for peer cf50a5c534b225c7 could not connect: dial tcp 192.168.122.6:2380: connect: no route to host
   2020-04-30 00:12:07.053051 W | rafthttp: health check for peer 1b7f290d9a6631b6 could not connect: dial tcp 192.168.122.7:2380: connect: no route to host

开启防火墙访问端口::

   sudo firewall-cmd --zone=public --add-port=2379-2380/tcp --permanent
   sudo firewall-cmd --reload

然后就可以看到3个节点开始正常通讯，并且终端不再报错。

systemd启动
=============

为了方便启动和管理etcd，配置systemd启动配置 ``/lib/systemd/system/etcd.service`` ::

   cat << EOF > /lib/systemd/system/etcd.service
   [Unit]
   Description=etcd service
   Documentation=https://github.com/coreos/etcd
    
   [Service]
   User=etcd
   Type=notify
   ExecStart=/usr/local/sbin/etcd \\
    --name ${ETCD_NAME} \\
    --data-dir /var/lib/etcd \\
    --initial-advertise-peer-urls http://${ETCD_PEER}:2380 \\
    --listen-peer-urls http://${ETCD_PEER}:2380 \\
    --listen-client-urls http://${ETCD_PEER}:2379,http://127.0.0.1:2379 \\
    --advertise-client-urls http://${ETCD_PEER}:2379 \\
    --initial-cluster-token ${ETCD_TOKEN} \\
    --initial-cluster ${ETCD_1}=http://${ETCD_IP_1}:2380,${ETCD_2}=http://${ETCD_IP_2}:2380,${ETCD_3}=http://${ETCD_IP_3}:2380 \\
    --initial-cluster-state new \\
    --heartbeat-interval 1000 \\
    --election-timeout 5000
   Restart=on-failure
   RestartSec=5
    
   [Install]
   WantedBy=multi-user.target
   EOF

- 然后重新加载配置并启动服务::

   systemctl daemon-reload
   systemctl enable etcd
   systemctl start etcd.service
   systemctl status -l etcd.service

这里启动服务，在第一个节点启动时会卡住不返回终端，原因应该是其他节点没有启动，所以不返回成功。但是只要后两个节点也启动，则正常返回终端。

.. note::

   ``--initial-cluster-state new`` 参数表示所有节点静态初始化或者DNS bootstrapping。如果这个参数是 ``existing`` 则etcd启动会尝试加入现有集群。如果这个参数错误设置，则etcd会尝试启动，但是安全地失败。默认参数就是 ``new`` 。

参考
===========

- `How To Setup a etcd Cluster On Linux – Beginners Guide <https://devopscube.com/setup-etcd-cluster-linux/>`_
- `etcd Clustering Guide <https://etcd.io/docs/v3.4.0/op-guide/clustering/>`_
- `etcd Configuration flags <https://etcd.io/docs/v3.4.0/op-guide/configuration/>`_
