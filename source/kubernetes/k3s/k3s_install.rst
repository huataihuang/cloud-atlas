.. _k3s_install:

==================
K3s安装
==================

在完成了 :ref:`k3s_ha_etcd` 部署之后，就可以开始正式安装 ``k3s`` 。

.. note::

   实际上 ``k3s`` 的安装工具已经包含了 ``etcd`` 的构建，完全可以不必自己独立安装 :ref:`k3s_ha_etcd` 。参考 `rpi4cluster.com => K3s-Current => Kubernetes Install <https://rpi4cluster.com/k3s/k3s-kube-setting/>`_ 可以看到，使用安装脚本构建3个管控节点的集群，会自动安装3个etcd服务器。

   实际上和我的部署方案效果完全相同。

   只不过，我把 :ref:`etcd` 单独拆解出来安装，可以进一步了解etcd的搭建过程，为后期独立的etcd集群打下基础。

   如果你没有这个需求，可以完全采用 ``k3s`` 提供的安装脚本自动安装

K3s安装脚本可以通过两种方式定制:

- 命令行参数
- 环境变量

最简单的安装方式是不使用任何参数::

   curl -sfL https://get.k3s.io | sh -

可以通过传递环境变量给 ``sh`` 来定制，具体参数见 `K3s Installation Options <https://rancher.com/docs/k3s/latest/en/installation/install-options/>`_ ，例如::

   curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh -

也可以写成::

   curl -sfL https://get.k3s.io | sh - - server --install-k3s-channel=lastest

由于我采用外部独立 :ref:`k3s_ha_etcd` 所以需要传递给安装脚本外部数据库参数 ``K3S_DATASTORE_ENDPOINT`` (或者使用参数 ``--datastore-endpoint`` ) 以及对应的客户端证书

etcd客户端证书分发
======================

在 :ref:`etcd_tls` 生成了 :ref:`etcd` 所需的证书，已经在 :ref:`k3s_ha_etcd` 过程中完成了服务器端证书分发。对于 ``k3s`` 管控服务器，需要采用客户端证书进行链接。一共有3个管控服务器，则需要采用以下方法分发客户端证书，这样 ``k3s`` 组件才能启动。

安装参数
===========

- k3s安装参数列表

.. csv-table:: k3s安装参数
   :file: k3s_install/k3s_install_options.csv
   :widths: 20, 30, 50
   :header-rows: 1

.. note::

   以 ``K3S_`` 开头的环境变量保留给 :ref:`systemd` 和 :ref:`openrc`  服务使用

- 我的安装采用的参数

.. csv-table:: 我的k3s安装参数
   :file: k3s_install/k3s_install_my_options.csv
   :widths: 20, 80
   :header-rows: 1

.. note::
 
   比较简化的方式是采用 :ref:`dns` 轮询方式负载均衡，也就是一个域名对应多个real server。可以省却部署负载均衡。如果是生产环境，则建议部署 :ref:`haproxy` 或者 :ref:`nginx` 做反向代理负载均衡。

   我这里暂时采用DNS方式，后续再完善部署负载均衡。

此外，环境变量和命令航参数也可以作为配置文件来管理，变量存储在 ``/etc/rancher/k3s/config.yaml`` 用于安装

安装执行(第一个管控节点)
=========================

- 按照上述参数，采用以下命令执行安装:

.. literalinclude:: k3s_install/k3s_install_server.sh
   :language: bash
   :caption: k3s安装命令(使用etcd服务)
   :emphasize-lines: 6

.. note::

   安装第一个节点时建议添加 ``K3S_TOKEN="some_random_password"`` ，否则就需要从第一个节点获取随机生成的token::

      sudo cat /var/lib/rancher/k3s/server/node-token

   这个token用于后续节点加入

参数注解:

- ``--tls-san `hostname``` 是为了将主机名或IP添加到TLS cert作为Subject Alternative Name
- ``INSTALL_K3S_EXEC='--write-kubeconfig-mode=644'`` 是为了将kubeconfig配置文件设置为方便多用户读取

异常排查
==========

参数错误
----------

服务启动以后，检查 ``/var/log/k3s.log`` 查看是否存在错误。

我遇到一个问题是在配置时错误配置了etcd的 ``K3S_DATASTORE_KEYFILE`` 变量，导致集群初始化失败。

- 卸载 ``k3s`` ::

   /usr/local/bin/k3s-uninstall.sh

- 然后重新初始化安装

.. literalinclude:: k3s_install/k3s_install_server.sh
   :language: bash
   :caption: k3s安装命令(使用etcd服务)
   :emphasize-lines: 6

启动报错``"starting kubernetes: preparing server: bootstrap data already found and encrypted with different token"``
-------------------------------------------------------------------------------------------------------------------------

重新安装k3s之后，发现启动后 ``/var/log/k3s.log`` 日志不断滚动::

   time="2022-04-20T21:24:56+08:00" level=info msg="Starting k3s v1.22.7+k3s1 (8432d7f2)"
   time="2022-04-20T21:24:57+08:00" level=fatal msg="starting kubernetes: preparing server: bootstrap data already found and encrypted with different token"
   time="2022-04-20T21:25:05+08:00" level=info msg="Starting k3s v1.22.7+k3s1 (8432d7f2)"
   time="2022-04-20T21:25:05+08:00" level=fatal msg="starting kubernetes: preparing server: bootstrap data already found and encrypted with different token"

这样的错误一般是安装第二个节点才会出现的，例如 `lost: bootstrap data already found and encrypted with different token <https://www.reddit.com/r/k3s/comments/p3rdap/lost_bootstrap_data_already_found_and_encrypted/>`_ ，看起来是etcd中数据没有清理

参考 `rpi4cluster.com => K3s-Current => Kubernetes Install <https://rpi4cluster.com/k3s/k3s-kube-setting/>`_ 以及 `K3s High Availability with an External DB <https://rancher.com/docs/k3s/latest/en/installation/ha/>`_ 可以知道，第一个管控节点应该使用参数 ``--cluster-init`` ，这个参数会确保激活集群以及使用一个共享的密码来添加服务器到集群。也就是说，第一个节点使用 ``--cluster-init`` 可以完成集群初始化工作。

所以，我修改了第一个节点的安装脚本，改为 ``sh -s - server --cluster-init`` ，日志::

   time="2022-04-21T05:30:28+08:00" level=info msg="Acquiring lock file /var/lib/rancher/k3s/data/.lock"
   time="2022-04-21T05:30:28+08:00" level=info msg="Preparing data dir /var/lib/rancher/k3s/data/cefe7380a851b348db6a6b899546b24f9e19b38f3b34eca24bdf84853943b0bb"
   time="2022-04-21T05:30:57+08:00" level=info msg="Starting k3s v1.22.7+k3s1 (8432d7f2)"
   time="2022-04-21T05:30:57+08:00" level=info msg="generated self-signed CA certificate CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57.319000637 +0000 UTC notAfter=2032-04-17 21:3 0:57.319000637 +0000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=system:admin,O=system:masters signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-04 -20 21:30:57 +0000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=system:kube-controller-manager signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-0 4-20 21:30:57 +0000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=system:kube-scheduler signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-04-20 21:3 0:57 +0000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=kube-apiserver signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-04-20 21:30:57 +0 000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=system:kube-proxy signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-04-20 21:30:57 +0000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=system:k3s-controller signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-04-20 21:3 0:57 +0000 UTC"
   time="2022-04-21T05:30:57+08:00" level=info msg="certificate CN=k3s-cloud-controller-manager signed by CN=k3s-client-ca@1650490257: notBefore=2022-04-20 21:30:57 +0000 UTC notAfter=2023-04-20 21:30:57 +0000 UTC"
   ...重复上述certificate相关信息...
   time="2022-04-21T05:31:02+08:00" level=info msg="Active TLS secret  (ver=) (count 9): map[listener.cattle.io/cn-10.43.0.1:10.43.0.1 listener.cattle.io/cn-127.0.0.1:127.0.0.1 listener.cattle.io/cn-192.168.7.11:192.168.7.11 listener.cattle.io/cn-kubernetes:kubernetes listener.cattle.io/cn-kubernetes.default:kubernetes.default listener.cattle.io/cn-kubernetes.default.svc:kubernetes.default.svc listener.cattle.io/cn-kubernetes.default.svc.cluster.local:kubernetes.default.svc.cluster.local listener.cattle.io/cn-localhost:localhost listener.cattle.io/cn-x-k3s-m-1.edge.huatai.me:x-k3s-m-1.edge.huatai.me listener.cattle.io/fingerprint:SHA1=0E02AC910D083500F03916810FE6064C33AA4752]"
   time="2022-04-21T05:31:02+08:00" level=fatal msg="starting kubernetes: preparing server: bootstrap data already found and encrypted with different token"
   time="2022-04-21T05:31:10+08:00" level=info msg="Starting k3s v1.22.7+k3s1 (8432d7f2)"
   ...重复上述2行starting信息...

最后2行不断重复的 ``starting`` 日志实际是 ``k3s`` 不断重启，通过 ``ps aux | grep k3s`` 可以看到不断重新启动::

   24112 root      0:02 {k3s-server} /usr/local/bin/k3s

上述报错信息 ``bootstrap data already found and encrypted with different token`` 来自 `k3s代码 pkg/cluster/storage.go <https://github.com/k3s-io/k3s/blob/master/pkg/cluster/storage.go>`_ :

.. literalinclude:: k3s_install/stoage.go_snippet
   :language: go
   :caption: pkg/cluster/storage.go getBootstrapKeyFromStorage
   :emphasize-lines: 35

可以看到如果从存储中读取到Token ``getBootstrapKeyFromStorage`` ，则返回错误

::

   etcdctl get /bootstrap --prefix

可以看到已经存储了大量数据

我暂时没有找到好的解决方法，因为是测试环境，所以尝试完全删除etcd数据，重新初始化etcd::

   sudo service etcd stop
   sudo mv /var/lib/etcd /var/lib/etcd.bak
   sudo service etcd start

然后检查 ``etcd`` 状态::

   etcdctl --write-out=table endpoint status

确保状态正常::

   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   |         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   | https://192.168.7.11:2379 | 7e8d94ba496c072d |   3.5.2 |   20 kB |      true |      false |         2 |         10 |                 10 |        |
   | https://192.168.7.12:2379 | a01cb65343e64610 |   3.5.2 |   20 kB |     false |      false |         2 |         10 |                 10 |        |
   | https://192.168.7.13:2379 |   9bfd4ef1e72d26 |   3.5.2 |   20 kB |     false |      false |         2 |         10 |                 10 |        |
   +---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

然后重新执行创建:

.. literalinclude:: k3s_install/k3s_install_server.sh
   :language: bash
   :caption: k3s安装命令(使用etcd服务)

执行安装(第二和第三管控节点)
==============================

- 在第二和第三节点上创建管控服务，执行创建命令和第一个节点的差异有:

  - 没有 ``--cluster-init`` 参数，是因为加入一个现有集群
  - 添加了访问第一个节点apiserver的参数 ``--server https://192.168.7.11:6443`` 。注意，参考官方文档 `K3s High Availability with Embedded DB <https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/>`_ ，在添加第二和第三节点是，需要指定第一个节点的IP或者主机名，语法规则如下::

     K3S_TOKEN=SECRET k3s server --server https://<ip or hostname of server1>:6443

.. literalinclude:: k3s_install/k3s_install_server-2-3.sh
   :language: bash
   :caption: 将第二和第三个管控服务器加入集群

完成后检查集群状态::

   kubectl get nodes -o wide

可以看到::

   NAME                       STATUS   ROLES                  AGE     VERSION        INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
   x-k3s-m-1.edge.huatai.me   Ready    control-plane,master   109m    v1.22.7+k3s1   192.168.7.11   <none>        Alpine Linux v3.15   5.15.32-0-rpi    containerd://1.5.9-k3s1
   x-k3s-m-2.edge.huatai.me   Ready    control-plane,master   53m     v1.22.7+k3s1   192.168.7.12   <none>        Alpine Linux v3.15   5.15.32-0-rpi    containerd://1.5.9-k3s1
   x-k3s-m-3.edge.huatai.me   Ready    control-plane,master   3m18s   v1.22.7+k3s1   192.168.7.13   <none>        Alpine Linux v3.15   5.15.32-0-rpi    containerd://1.5.9-k3s1

执行安装(添加worker节点)
===========================

- 在每个worker节点上执行以下命令加入集群:

.. literalinclude:: k3s_install/k3s_install_worker.sh
   :language: bash
   :caption: 将worker节点加入集群

说明:

  - ``K3S_URL`` 配置 ``k3s`` 的apiserver地址，请注意端口是  ``6443`` ( ``apiserver`` )
  - 我这里配置使用了域名解析 ``apiserver.edge.huatai.me`` ，这个域名解析实际就是3台管控服务器的IP地址: ``k3s`` 使用物理主机的IP地址做了反向代理到内部的 ``apiserver`` pods ( :ref:`k3s_arch` )

- 完成安装后，在管控服务器执行检查::

   kubectl get nodes

可以看到::

   NAME                       STATUS   ROLES                  AGE     VERSION
   x-k3s-m-1.edge.huatai.me   Ready    control-plane,master   12h     v1.22.7+k3s1
   x-k3s-m-2.edge.huatai.me   Ready    control-plane,master   12h     v1.22.7+k3s1
   x-k3s-m-3.edge.huatai.me   Ready    control-plane,master   11h     v1.22.7+k3s1
   x-k3s-n-1.edge.huatai.me   Ready    <none>                 110m    v1.22.7+k3s1
   x-k3s-n-2.edge.huatai.me   Ready    <none>                 7m31s   v1.22.7+k3s1

参考
=======

- `K3s Installation Options <https://rancher.com/docs/k3s/latest/en/installation/install-options/>`_
- `K3s Cluster Datastore Options <https://rancher.com/docs/k3s/latest/en/installation/datastore/>`_
- `K3s High Availability with an External DB <https://rancher.com/docs/k3s/latest/en/installation/ha/>`_
- `K3s High Availability with Embedded DB <https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/>`_
- `Setting up a HA Kubernetes cluster using K3S <https://gabrieltanner.org/blog/ha-kubernetes-cluster-using-k3s>`_
- `rpi4cluster.com => K3s-Current => Kubernetes Install <https://rpi4cluster.com/k3s/k3s-kube-setting/>`_
