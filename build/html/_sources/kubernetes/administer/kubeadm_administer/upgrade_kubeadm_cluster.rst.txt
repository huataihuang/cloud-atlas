.. _upgrade_kubeadm_cluster:

==========================
升级kubeadm集群
==========================

在 :ref:`arm_k8s_deploy` ，想要将最新安装的 :ref:`jetson_nano` 系统加入到ARM Kubernetes集群，结果发现，之前构建的Kubernetes集群版本还停留在 v1.19.4 上，最新的kubeadm已不支持加入低版本集群::

   error execution phase preflight: unable to fetch the kubeadm-config ConfigMap:
   this version of kubeadm only supports deploying clusters with the control plane version >= 1.20.0.
   Current version: v1.19.4
   To see the stack trace of this error execute with --v=5 or higher

我们需要升级集群的管控平面版本。

准备工作
==========

- 检查集群信息::

   kubectl cluster-info

输出信息::

   Kubernetes control plane is running at https://192.168.6.11:6443
   KubeDNS is running at https://192.168.6.11:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

- dump集群详细信息::

   kubectl cluster-info dump

重要信息
----------

- 务必备份所有重要组件: ``kubeadm upgrade`` 不会影响工作负载，只会涉及kubernetes内部组件，为防止万一，请完成 :ref:`k8s_backup` (演练) 
- 对kubelet做版本升级需要 :ref:`drain_node` ，对于管控面节点，可能运行 CoreDNS Pods或者其他非常重要的负载
- 升级后，因为容器spec的哈希值已经更改，所以 ``所有容器都会被重新启动``

升级控制平面节点
=====================

``控制平面节点升级过程应该每次处理一个节点`` 

选择要升级的控制面节点，该节点上必须拥有 ``/etc/kubernetes/admin.conf`` 文件

执行 ``kubeadm upgrade``
--------------------------

- 升级 ``kubeadm`` ::

   apt-mark unhold kubeadm && \
   apt update && apt install -y kubeadm=1.21.x-00 && \
   apt-mark hold kubeadm

或者::

   apt update && \
   apt install -y --allow-change-held-packages kubeadm=1.21.x-00

- 验证 ``kubeadm`` 版本::

   kubeadm version

- 验证升级计划::

   kubeadm upgrade plan

上述命令检查集群是否可以升级，并取回要升级的目标版本

版本差异困境
==============

锁定kubernetes软件版本 :ref:`bootstrap_kubernetes` 和 :ref:`arm_k8s_deploy` 有一步不起眼的步骤，锁定kubernetes软件版本 ::

   sudo apt-mark unhold kubelet kubeadm kubectl

这个步骤实际上非常重要，如果不锁定版本，在不断的系统更新中，kubernetes软件版本会不断升级，但是由于没有对应自动化升级管控平面软件功能，导致管控平面运行的软件版本始终停留在最初版本，逐渐和后续安装软件包形成较大的无法兼容的版本差异。就会导致很多意想不到的错误，例如，无法管理节点。

我在开发测试 :ref:`arm_k8s_deploy` 时解除了 ``hold`` ，原本以为开发测试环境无需太关注稳定性，但是，实践发现Kubernetes每个 ``Minor`` 版本之间是不兼容的，需要人工做版本升级才能维持稳定。

- 检查版本::

   kubectl version

可以看到输出信息显示，服务器端版本是低版本 ``1.19.4`` 而客户端版本是高版本 ``1.21.3`` ::

   Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.3", GitCommit:"ca643a4d1f7bfe34773c74f79527be4afd95bf39", GitTreeState:"clean", BuildDate:"2021-07-15T21:04:39Z", GoVersion:"go1.16.6", Compiler:"gc", Platform:"linux/arm64"}
   Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.4", GitCommit:"d360454c9bcd1634cf4cc52d1867af5491dc9c5f", GitTreeState:"clean", BuildDate:"2020-11-11T13:09:17Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/arm64"}
   WARNING: version difference between client (1.21) and server (1.19) exceeds the supported minor version skew of +/-1

- 此时，在服务器上输出加入节点命令::

   kubeadm token create --print-join-command

但是在加入节点上执行上述命令输出的 ``kubeadm join 192.168.6.11:6443 --token XXXX --discovery-token-ca-cert-hash sha256:YYYY`` 会出现如下报错::

   ...
   error execution phase preflight: unable to fetch the kubeadm-config ConfigMap:
   this version of kubeadm only supports deploying clusters with the control plane version >= 1.20.0. Current version: v1.19.4
   To see the stack trace of this error execute with --v=5 or higher

每个 ``kubeadm`` ``kubectl`` ``kubelet`` 版本只支持对上一版本的升级，而不能跨版本升级。例如，现在的客户端是 ``1.21.x`` 就只能升级 ``1.20.x`` 的服务器，而不能跨版本升级 ``1.19.x`` 的服务器。

为了解决这个困境，需要将整个集群 Kubernetes 软件版本回滚到 ``1.20.x`` ，然后升级 ``1.19.x`` 管控平面版本到同样的 ``1.20.x`` ，再滚动升级kubernetes软件包版本到 ``1.21.x`` ，最后再升级服务器版本。

回滚版本
==========

- 检查版本::

   apt list kubeadm

显示::

   kubeadm/kubernetes-xenial,now 1.21.3-00 arm64 [installed]
   N: There are 214 additional versions. Please use the '-a' switch to see them.

我们可以通过 ``-a`` 参数查看到所有可用版本(以便选择)::

   apt list kubeadm -a

输出如下::

   kubeadm/kubernetes-xenial,now 1.21.3-00 arm64 [installed]
   kubeadm/kubernetes-xenial 1.21.2-00 arm64
   kubeadm/kubernetes-xenial 1.21.1-00 arm64
   kubeadm/kubernetes-xenial 1.21.0-00 arm64
   kubeadm/kubernetes-xenial 1.20.9-00 arm64
   kubeadm/kubernetes-xenial 1.20.8-00 arm64
   kubeadm/kubernetes-xenial 1.20.7-00 arm64
   kubeadm/kubernetes-xenial 1.20.6-00 arm64
   ...

- (根据需求)首先unhold软件版本::

   apt-mark unhold kubeadm kubectl kubelet

- 更新索引然后安装指定版本::

   apt update
   apt install kubeadm=1.20.9-00 kubectl=1.20.9-00 kubelet=1.20.9-00 --allow-downgrades
   apt-mark hold kubeadm kubectl kubelet

- 完成后检查节点::

   $ kubectl get nodes
   NAME         STATUS     ROLES    AGE    VERSION
   pi-master1   Ready      master   237d   v1.20.9
   pi-worker1   Ready      <none>   234d   v1.21.3
   pi-worker2   NotReady   <none>   234d   v1.21.3
   zcloud       Ready      <none>   124d   v1.21.3

可以看到 ``pi-master1`` 已经回滚到 ``1.20.9`` 版本

- 同样我们回滚worker节点到 ``1.20.9``

.. note::

   这里管控节点回滚到 ``1.20.9`` 是因为当前服务器版本是 ``1.19.3`` ，可以通过管控节点的 ``1.20.x`` 来升级管控平面服务器端软件

kubeadm upgrade
==================

现在满足升级条件，我们开始进行管控平面节点升级

- 检查 ``kubeadm`` 工作情况::

   kubeadm version

显示输出::

   kubeadm version: &version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.9", GitCommit:"7a576bc3935a6b555e33346fd73ad77c925e9e4a", GitTreeState:"clean", BuildDate:"2021-07-15T21:00:30Z", GoVersion:"go1.15.14", Compiler:"gc", Platform:"linux/arm64"}

- 验证升级计划::

   kubeadm upgrade plan

显示输出:

.. literalinclude:: upgrade_kubeadm_cluster/kubeadm_upgrade_plan.output
   :linenos:

上述命令检查集群可以升级的版本，例如上面案例显示输出支持升级到2个版本::

   kubeadm upgrade apply v1.19.13
   kubeadm upgrade apply v1.20.9

- 现在我们实际操作，升级到支持的 ``1.20.x`` 最新版本::

   sudo kubeadm upgrade apply v1.20.9

提示::

   [upgrade/config] Making sure the configuration is correct:
   [upgrade/config] Reading configuration from the cluster...
   [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
   [preflight] Running pre-flight checks.
   [upgrade] Running cluster health checks
   [upgrade/version] You have chosen to change the cluster version to "v1.20.9"
   [upgrade/versions] Cluster version: v1.19.4
   [upgrade/versions] kubeadm version: v1.20.9
   [upgrade/confirm] Are you sure you want to proceed with the upgrade? [y/N]:

输入 ``y`` 开始升级

提示信息::

   [upgrade/prepull] Pulling images required for setting up a Kubernetes cluster
   [upgrade/prepull] This might take a minute or two, depending on the speed of your internet connection
   [upgrade/prepull] You can also perform this action in beforehand using 'kubeadm config images pull'

.. note::

   这里有一个跨GFW的网络要求，所以网络畅通非常重要

提示信息报错::

   [upgrade/apply] Upgrading your Static Pod-hosted control plane to version "v1.20.9"...
   Static pod: kube-apiserver-pi-master1 hash: 1403dda53affdfee1130475a6d9609da
   Static pod: kube-controller-manager-pi-master1 hash: f967039ea08836f2188442530d3d465a
   Static pod: kube-scheduler-pi-master1 hash: 02dab51e35a1d6fc74e5283db75230f5
   [upgrade/apply] FATAL: failed to create etcd client: error syncing endpoints with etcd: context deadline exceeded
   To see the stack trace of this error execute with --v=5 or higher

- 重新执行，并添加 ``--v=5`` 参数观察详细日志:

.. literalinclude:: upgrade_kubeadm_cluster/kubeadm_upgrade_apply.output_err
   :linenos:

报错依旧，我推测是跨版本升级可能不能从较低的 ``1.19.x`` 升级到较高到 ``1.20.x`` ，所以转为先升级到 ``1.19.13`` ，然后再尝试升级到 ``1.20.9`` 。

- ``kubeadm-1.20.9`` 工具不支持升级 ``1.19.x`` ，所以还需要回滚版本到 ``1.19.13`` ::

   apt-mark unhold kubeadm kubectl kubelet
   apt update
   apt install kubeadm=1.19.13-00 kubectl=1.19.13-00 kubelet=1.19.13-00 --allow-downgrades
   apt-mark hold kubeadm kubectl kubelet
   
- 再次执行升级报错依旧

- 参考 `kubeadm join is not fault tolerant to etcd endpoint failures #1432 <https://github.com/kubernetes/kubeadm/issues/1432>`_ 我推测etcd版本是否存在兼容性bug？

etcd排查
----------

- 检查 ``etcd`` 日志::

   kubectl -n kube-system logs etcd-pi-master1

可以看到报错信息::

   2021-07-27 08:41:14.208723 I | embed: rejected connection from "192.168.6.11:55660" (error "remote error: tls: bad certificate", ServerName "")
   2021-07-27 08:41:17.326582 I | embed: rejected connection from "192.168.6.11:55694" (error "remote error: tls: bad certificate", ServerName "")
   2021-07-27 08:41:17.911939 I | etcdserver/api/etcdhttp: /health OK (status code 200)
   2021-07-27 08:41:18.476309 I | embed: rejected connection from "192.168.6.11:55704" (error "remote error: tls: bad certificate", ServerName "")
   ...

在 `etcd 3.2.x upgrade fails with tls: bad certificate"; please retry. #910 <https://github.com/kubernetes/kubeadm/issues/910>`_ 说明:

etcd配置了从内建的grpc gateway尝试按照客户端在和etcd交互时候使用服务器证书

在 `ETCD with TLS showing warning "transport: authentication handshake failed: remote error: tls: bad certificate" #9785 <https://github.com/etcd-io/etcd/issues/9785>`_ 说明:

这是由于服务器配置没有输出证书，导致客户端认证失败，参考 `cfssl.txt <https://github.com/cloudflare/cfssl/blob/master/doc/cmd/cfssl.txt>`_ ，解决的方法(参考 KIVagant 的解决方法)，即:

- 重新生成etcd证书(包含server和client的profile)
- 设置 ``client_cert_auth=ture`` 运行参数(使用etcd启动环境变量指定) 
- 运行 ``etcd`` 时参数 ``--peer-auto-tls=true``

不过，这个方法由于较为复杂(主要时证书我还没有搞清楚)，所以我采用上述issue中 JinsYin 的解决方法，即传递给etcd运行参数 ``--client-cert-auth=false`` ，见下文排查和解决方法

.. note::

   目前我对kubernetes和etcd的证书了解不够，后续准备参考 `kubernetes-the-hard-way <https://github.com/kelseyhightower/kubernetes-the-hard-way>`_ 的文档 `Provisioning a CA and Generating TLS Certificates <https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md>`_ 具体实践证书制作。

尝试仅升级小版本
------------------

由于当前服务器版本是 ``1.19.4`` ，所以尝试仅升级到 ``1.19.5`` 看看是否可以绕开这个问题::

   apt-mark unhold kubeadm kubectl kubelet
   apt update
   apt install kubeadm=1.19.5-00 kubectl=1.19.5-00 kubelet=1.19.5-00 --allow-downgrades
   apt-mark hold kubeadm kubectl kubelet

- 此时检查服务器版本::

   kubectl version

显示::

   Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.5", GitCommit:"e338cf2c6d297aa603b50ad3a301f761b4173aa6", GitTreeState:"clean", BuildDate:"2020-12-09T11:18:51Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/arm64"}
   Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.4", GitCommit:"d360454c9bcd1634cf4cc52d1867af5491dc9c5f", GitTreeState:"clean", BuildDate:"2020-11-11T13:09:17Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/arm64"}

- 检查节点::

   kubectl get nodes

显示::

   NAME         STATUS   ROLES    AGE    VERSION
   pi-master1   Ready    master   240d   v1.19.5
   pi-worker1   Ready    <none>   237d   v1.20.9
   pi-worker2   Ready    <none>   237d   v1.21.3
   zcloud       Ready    <none>   127d   v1.21.3

- 再次尝试小版本升级::

   kubeadm upgrade apply v1.19.5
   
.. warning::

   很不幸，尝试失败，基本可以确定是etcd证书问题，解决方法也要从证书入手。不过，证书还没失效，因为etcd能够启动，并且apiserver连接有效

尝试修订参数
----------------

我检查了 ``/etc/kubernetes/manifests`` 目录下配置 ``etcd.yaml`` 都是2020-12-01创建配置::

   -rw------- 1 root root 2.1K Dec  1  2020 etcd.yaml
   -rw------- 1 root root 3.8K Dec  1  2020 kube-apiserver.yaml
   -rw------- 1 root root 3.5K Dec  1  2020 kube-controller-manager.yaml
   -rw------- 1 root root 1.4K Dec  1  2020 kube-scheduler.yaml

考虑修订 ``etcd.yaml`` 配置，强制将客户端证书忽略，见上文

- 修改 ``/etc/kubernetes/manifests/etcd.yaml`` ，将启动运行参数::

   ...
   spec:
     containers:
     - command:
       - etcd
       - --advertise-client-urls=https://192.168.6.11:2379
       - --cert-file=/etc/kubernetes/pki/etcd/server.crt
       - --client-cert-auth=true
   ...
       - --peer-client-cert-auth=true

最后一行修订成::

   ...
       - --client-cert-auth=false
   ...
       - --peer-client-cert-auth=false

- 重启 pod ::

   kubectl -n kube-system delete pods etcd-pi-master1

然后检查启动情况::

   kubectl -n kube-system get pods -o wide | grep etcd

可以看到重启后pods配置没有改变( ``ps aux | grep etcd`` ) ::

   etcd --advertise-client-urls=https://192.168.6.11:2379 ... --client-cert-auth=true ... --peer-client-cert-auth=true ...

- 直接修改pod配置::

   kubectl -n kube-system edit pods etcd-pi-master1

但是这个pod是不能直接修改(没有deployment?)

修订etcd证书
----------------

- 检查 ``etcd`` 如何使用证书目录挂载::

   kubectl -n kube-system get pods etcd-pi-master1 -o yaml

可以看到::

     volumes:
     - hostPath:
         path: /etc/kubernetes/pki/etcd
         type: DirectoryOrCreate
       name: etcd-certs
     - hostPath:
         path: /var/lib/etcd
         type: DirectoryOrCreate
       name: etcd-data

上述主机目录 ``/etc/kubernetes/pki/etcd`` 挂载到容器内部作为证书，所以需要修订物理主机该目录

- 检查 etcd 运行进程参数::

   etcd --advertise-client-urls=https://192.168.6.11:2379 --cert-file=/etc/kubernetes/pki/etcd/server.crt --client-cert-auth=true --data-dir=/var/lib/etcd --initial-advertise-peer-urls=https://192.168.6.11:2380 --initial-cluster=pi-master1=https://192.168.6.11:2380 --key-file=/etc/kubernetes/pki/etcd/server.key --listen-client-urls=https://127.0.0.1:2379,https://192.168.6.11:2379 --listen-metrics-urls=http://127.0.0.1:2381 --listen-peer-urls=https://192.168.6.11:2380 --name=pi-master1 --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt --peer-client-cert-auth=true --peer-key-file=/etc/kubernetes/pki/etcd/peer.key --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt --snapshot-count=10000 --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

需要重新生成 ``/etc/kubernetes/pki/etcd/server.crt`` ( ``--cert-file=/etc/kubernetes/pki/etcd/server.crt`` )

- 安装 ``cfssl`` 工具::

   apt install -y golang-cfssl

- 备份证书目录::

   cp -r /etc/kubernetes/pki/etcd /etc/kubernetes/pki/etcd.bak

- 编辑配置文件 ``ca-config.json`` 

.. literalinclude:: upgrade_kubeadm_cluster/ca-config.json
   :linenos:
 
- 执行::

   cfssl gencert -ca=/etc/kubernetes/pki/etcd/ca.crt -ca-key=/etc/kubernetes/pki/etcd/ca.key -config=ca-config.json -profile=server ca-config.json | cfssljson -bare server

则在当前目录下会生成::

   server-key.pem    server.csr   server.pem

复制 ``server-key.pem`` ( ``ETCD_KEY_FILE`` ) 即可::

   cp server-key.pem /etc/kubernetes/pki/etcd/server.key

- 然后重启etce::

   kubectl -n kube-system delete pods etcd-pi-master1

- 检查运行::

   kubectl -n kube-system get pods -o wide | grep etcd

- 重新升级系统::

   apt-mark unhold kubeadm kubectl kubelet
   apt update
   apt install kubeadm=1.20.9-00 kubectl=1.20.9-00 kubelet=1.20.9-00 --allow-downgrades
   apt-mark hold kubeadm kubectl kubelet

   kubeadm upgrade plan
   kubeadm upgrade apply v1.20.9

- 注意，这次 etcd 日志报错::

   2021-07-28 15:15:19.691882 I | embed: rejected connection from "192.168.6.11:36982" (error "tls: private key type does not match public key type", ServerName "")

- 重启一次apiserver::

    kubectl -n kube-system delete pods kube-apiserver-pi-master1
    kubectl -n kube-system delete pods kube-controller-manager-pi-master1
    kubectl -n kube-system delete pods coredns-f9fd979d6-dlv9c
    kubectl -n kube-system delete pods coredns-f9fd979d6-wvfvc
    kubectl -n kube-system delete pods kube-scheduler-pi-master1

失败，应该还是没有掌握证书原理和关系，有待重新实践

.. warning::

   这次升级失败，目前推测是早期部署集群的证书问题在版本升级中可能有什么兼容性问题，目前无法恢复。所以，我改为 :ref:`delete_k8s_cluster` 然后重建

参考
=======

- `升级 kubeadm 集群 <https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/>`_
- `How To Install CloudFlare CFSSL on Linux | macOS <https://computingforgeeks.com/how-to-install-cloudflare-cfssl-on-linux-macos/>`_
