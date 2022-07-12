.. _k8s_dnsrr:

========================================
基于DNS轮询构建高可用Kubernetes
========================================

.. note::

   在 :ref:`ha_k8s_lb` 部署中，负载均衡采用的是 :ref:`haproxy` 结合keeplived实现VIP自动漂移。可以在部署基础上改造DNSRR到负载均衡模式

在完成 :ref:`priv_deploy_etcd_cluster_with_tls_auth` ，具备了扩展etcd架构，就可以开始部署本文 ``基于DNS轮询构建高可用Kubernetes`` 。后续再补充 :ref:`haproxy` 这样的负载均衡，就可以进一步改造成 :ref:`ha_k8s_lb` 架构。

准备etcd访问证书
===================

由于是访问外部扩展etcd集群，所以首先需要将etcd证书复制到管控服务器节点，以便管控服务器服务(如apiserver)启动后能够正常读写etcd:

- 在管控服务器 ``z-k8s-m-1`` / ``z-k8s-m-2`` / ``z-k8s-m-3`` 上创建 ``etcd`` 访问证书目录，并将 :ref:`priv_deploy_etcd_cluster_with_tls_auth` 准备好的证书复制过来:

``etcd`` 客户端所需要的证书可以从 :ref:`priv_deploy_etcd_cluster_with_tls_auth` 配置的 ``etctctl`` 客户端配置找到对应文件

.. literalinclude:: ../../etcd/priv_deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_env
   :language: bash
   :caption: etcd客户端配置:使用证书
   :emphasize-lines: 4-6

将上述 ``etcdctl`` 客户端配置文件和Kubernetes访问etcd配置文件一一对应如下:

.. csv-table:: kubernetes apiserver访问etcd证书对应关系
      :file: k8s_dnsrr/etcd_key.csv
      :widths: 40, 60
      :header-rows: 1

- 分发kubernetes的apiserver使用的etcd证书:

.. literalinclude:: k8s_dnsrr/deploy_k8s_apiserver_key
   :language: bash
   :caption: 分发kubernetes的apiserver使用的etcd证书

.. note::

   我是在具备密钥认证管理主机 ``z-b-data-1`` 上作为客户端，通过ssh远程登录到 ``z-k8s-m-1`` / ``z-k8s-m-2`` / ``z-k8s-m-3`` ，执行上述 ``deploy_k8s_etcd_key.sh`` 分发密钥

配置第一个管控节点(control plane ndoe)
=======================================

- 创建 ``create_kubeadm-config.sh`` 脚本 :

.. literalinclude:: k8s_dnsrr/create_kubeadm-config
   :language: bash
   :caption: 创建第一个管控节点配置 kubeadm-config.yaml

.. note::

   `Kubernetes by kubeadm config yamls <https://medium.com/@kosta709/kubernetes-by-kubeadm-config-yamls-94e2ee11244>`_ 提供了 ``kubeadm-config.yaml`` 配置案例，例如如何修订集群名，网段等。实际上可以进一步参考官方文档定制 apiserver / controller / scheduler 的配置，在这篇文档中也有介绍和引用。非常好

- 执行 ``sh create_kubeadm-config.sh`` 生成 ``kubeadm-config.yaml`` 配置文件

- 创建第一个管控节点:

.. literalinclude:: k8s_dnsrr/kubeadm_init
   :language: bash
   :caption: 初始化第一个管控节点 kubeadm init

.. note::

   实际上只要保证网络畅通(翻墙)，并且做好前置准备工作， ``kubeadm init`` 初始化会非常丝滑地完成。此时终端会提示一些非常有用地信息，例如如何启动集群，如何配置管理环境。

如果一切顺利，会有如下提示信息:

.. literalinclude:: k8s_dnsrr/kubeadm_init_output
   :language: bash
   :caption: 初始化第一个管控节点 kubeadm init 输出信息

表明集群第一个管控节点初始化成功!

- 此时根据提示，执行以下命令为自己的账户准备好管理配置

.. literalinclude:: k8s_dnsrr/kube_config
   :language: bash
   :caption: 配置个人账户的管理k8s环境

并且提供了如何添加管控平面节点的操作命令(包含密钥，所以必须保密)，以及添加工作节点的命令(包含密钥，所以必须保密)

容器没有启动问题
==================

我这里遇到一个问题，就是 ``kubeadm init`` 显示初始化成功，但是我使用 ``docker ps`` 居然看不到任何容器::

   $ docker ps
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

这怎么回事？

- 检查端口::

   netstat -an | grep 6443

可以看到端口已经监听::

   tcp        0      0 192.168.6.101:39868     192.168.6.101:6443      ESTABLISHED
   tcp        0      0 192.168.6.101:38514     192.168.6.101:6443      ESTABLISHED
   tcp        0      0 192.168.6.101:40006     192.168.6.101:6443      TIME_WAIT
   tcp        0      0 192.168.6.101:39982     192.168.6.101:6443      TIME_WAIT
   tcp        0      0 192.168.6.101:39926     192.168.6.101:6443      ESTABLISHED
   tcp        0      0 192.168.6.101:40070     192.168.6.101:6443      TIME_WAIT
   tcp6       0      0 :::6443                 :::*                    LISTEN
   tcp6       0      0 ::1:51780               ::1:6443                ESTABLISHED
   tcp6       0      0 192.168.6.101:6443      192.168.6.101:39868     ESTABLISHED
   tcp6       0      0 ::1:6443                ::1:51780               ESTABLISHED
   tcp6       0      0 192.168.6.101:6443      192.168.6.101:38514     ESTABLISHED
   tcp6       0      0 192.168.6.101:6443      192.168.6.101:39926     ESTABLISHED

难道现在真的已经不再使用docker，直接使用 ``containerd`` 这样的 :ref:`container_runtimes`

- 检查 ``top`` 输出::

   Tasks: 149 total,   1 running, 148 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  3.0 us,  1.8 sy,  0.0 ni, 92.7 id,  2.2 wa,  0.0 hi,  0.2 si,  0.2 st
   MiB Mem :   3929.8 total,   2579.8 free,    531.7 used,    818.4 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   3179.4 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
     18408 root      20   0 1173260 336344  71252 S   4.6   8.4   0:32.39 kube-apiserver
       437 root      20   0 1855336  97924  63844 S   2.0   2.4   2:49.35 kubelet
     19247 root      20   0  818924  89480  59096 S   2.0   2.2   0:02.62 kube-controller
       422 root      20   0 1296700  60624  30648 S   0.7   1.5   0:51.12 containerd
       262 root      19  -1   93020  37364  36260 S   0.3   0.9   0:07.20 systemd-journal
     18028 root      20   0       0      0      0 I   0.3   0.0   0:00.05 kworker/1:0-events

可以看到系统已经运行了 ``kube-apiserver`` 和 ``kube-controller`` ，说明Kubernetes相关容器已经运行，否则也不会有这些进程。

- 检查节点::

   kubectl get nodes -o wide

提示信息::

   Unable to connect to the server: Forbidden

why? 

想到我部署采用DNSRR，也就是解析 ``apiserver.staging.huatai.me`` 域名可能是访问目前尚未加入管控的另外2个服务器，所以我尝试把DNS解析修改成只解析到节点1，也就是第一个加入管控的节点IP。但是依然没有解决

- 检查 ``kubelet.service`` 日志::

   sudo journalctl -u kubelet.service | less

看到启动kubelet之后有报错信息，首先就是有关网络没有就绪的错误::

   Jul 11 09:06:40 z-k8s-m-1 kubelet[437]: E0711 09:06:40.420728     437 kubelet.go:2424] "Error getting node" err="node \"z-k8s-m-1\" not found"
   Jul 11 09:06:40 z-k8s-m-1 kubelet[437]: E0711 09:06:40.521709     437 kubelet.go:2424] "Error getting node" err="node \"z-k8s-m-1\" not found"
   Jul 11 09:06:40 z-k8s-m-1 kubelet[437]: E0711 09:06:40.581769     437 kubelet.go:2349] "Container runtime network not ready" networkReady="NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized"
   Jul 11 09:06:40 z-k8s-m-1 kubelet[437]: E0711 09:06:40.622654     437 kubelet.go:2424] "Error getting node" err="node \"z-k8s-m-1\" not found"
   ...
   Jul 11 09:06:41 z-k8s-m-1 kubelet[437]: I0711 09:06:41.796597     437 kubelet_node_status.go:70] "Attempting to register node" node="z-k8s-m-1"
   ...
   Jul 11 09:06:43 z-k8s-m-1 kubelet[437]: I0711 09:06:43.232192     437 kubelet_node_status.go:108] "Node was previously registered" node="z-k8s-m-1"
   Jul 11 09:06:43 z-k8s-m-1 kubelet[437]: I0711 09:06:43.232303     437 kubelet_node_status.go:73] "Successfully registered node" node="z-k8s-m-1"
   Jul 11 09:06:43 z-k8s-m-1 kubelet[437]: I0711 09:06:43.427832     437 apiserver.go:52] "Watching apiserver"
   Jul 11 09:06:43 z-k8s-m-1 kubelet[437]: I0711 09:06:43.438830     437 topology_manager.go:200] "Topology Admit Handler"
   ...
   Jul 11 09:06:43 z-k8s-m-1 kubelet[437]: E0711 09:06:43.440795     437 pod_workers.go:951] "Error syncing pod, skipping" err="network is not ready: container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized" pod="kube-system/cor
   edns-6d4b75cb6d-pf7bs" podUID=79bc049c-0f1a-4387-aeed-ccfb04dfe7ca
   Jul 11 09:06:43 z-k8s-m-1 kubelet[437]: E0711 09:06:43.440978     437 pod_workers.go:951] "Error syncing pod, skipping" err="network is not ready: container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized" pod="kube-system/cor
   edns-6d4b75cb6d-m2hf6" podUID=b2d40bb9-f431-4c53-a164-215bfcd4da47
   ...

可以看到访问 apiserver 失败，并且网络 cni plugin 没有初始化。想起来当时在官方文档中看到过必须初始化网络之后才能正常工作。(虽然我之前在 :ref:`single_master_k8s` 经验是无需cni也至少能够看到pod运行，并且能够使用 ``docker ps`` )

此外，在 :ref:`container_runtimes` 从官方文档查到 kubernetes 1.24 之后移除了docker支持，是否不再支持使用docker ?  我检查了 :ref:`container_runtimes` 中对运行时检查 ``sockets`` 方法，确认系统只有 ``containerd`` 的sockets文件

仔细检查了 ``kubeadm init`` 输出信息，可以看到提示安装cni的方法::

   You should now deploy a pod network to the cluster.
   Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
     https://kubernetes.io/docs/concepts/cluster-administration/addons/

参考 `Troubleshooting CNI plugin-related errors <https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/>`_ 提供了排查CNI插件的建议。其中在文档开始就提出:

- 为避免CNI plugin相关错误，首先应该将 :ref:`container_runtimes` 升级到对应Kubernetes版本的已经验证正常工作的CNI plugins版本。例如，对于 Kubernetes 1.24 需要满足:

  - containerd v1.6.4 或更高版本， v1.5.11 或更高版本
  - CRI-O v1.24.0 或更新版本

我检查了一下我的 ``containerd`` 版本，发现是采用发行版安装的 ``docker.io`` ，所以版本不是最新， ``containerd`` 的版本只是 ``1.5.9`` ，所以很可能是版本过低无法适配。该文档还提示:

在Kubernetes， ``containerd`` 运行时哦人添加一个回环接口 ``lo`` 给pods作为默认特性。containerd运行时配置通过一个 CNI plugin ``loopback`` 来实现，这是 ``containerd`` 发行包默认分发的一部分，例如 ``containerd``  v1.6.0 以及更高版本就将一个CNI v1.0.0兼容loopback插件作为默认CNI plugins。

.. note::

   根据上文排查，无法正常启动 ``kubeadmin init`` 容器是因为Kubernetes 1.24，也就是我安装的最新K8s已经移除了CNI plugin，将这部分工作移交给容器运行时自带的CNI plugin来完成。这就要求配套使用最新版本(或满足版本要求)的 ``containerd`` 运行时。最新版本的 ``containerd`` 运行时默认启动 ``loopback`` 就提供了kubernetes管控平面pods运行的条件，这样从开始就可以拉起 Kubernetes 的管控pods，为下一步安装不同的 :ref:`kubernetes_network` 提供初始运行条件。当Kubernetes集群正常运行后，通过 :ref:`cilium_install_with_external_etcd` 就可以直接在运行起来的kubernetes集群上完成网络定制。

   `containerd versioning and release <https://containerd.io/releases/>`_ 提供了支持 Kubernetes 不同版本所对应当 ``containerd`` 版本，确实明确指出 Kubernetes 1.24 需要 ``containerd 1.64+，1.5.11+``

- 重试通过 :ref:`install_containerd_official_binaries` 将发行版 ``containerd`` 升级到 1.64+ 来修复
- :ref:`kubeadm_reset`



Network Plugins
==================

.. note::

   在Kubernetes 1.24之前，CNI plugins可以通过 kubelet 使用 ``cni-bin-dir`` 和 ``network-plugin`` 命令参数来管理。但是在 Kubernetes 1.24 中，这些参数已经被移除，因为CNI管理已经不属于kubelet范围。

针对不同的 :ref:`container_runtimes` ，需要采用不同的方式安装CNI plugins:

- `containerd安装CNI plugins官方文档 <https://github.com/containerd/containerd/blob/main/script/setup/install-cni>`_
- `CRI-O安装CNI plugins官方文档 <https://github.com/cri-o/cri-o/blob/main/contrib/cni/README.md>`_

containerd CNI plugins安装
--------------------------

- 一种方法是参考 `How To Setup A Three Node Kubernetes Cluster For CKA: Step By Step <https://k21academy.com/docker-kubernetes/three-node-kubernetes-cluster/>`_ 提供了通过containerd内置工具生成默认配置(实际上这个方法是Kubernetes官方文档配置containerd默认网络的方法，正确)

-  (该方法不正确)从 `containerd安装CNI plugins官方文档 <https://github.com/containerd/containerd/blob/main/script/setup/install-cni>`_ ``install-cni`` 脚本中获取生成配置部分:

.. literalinclude:: k8s_dnsrr/install-cni
   :language: bash
   :caption: 安装containerd CNI plugins脚本 install-cni 生成配置部分


安装cilium
------------

参考
========

- `Creating Highly Available Clusters with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/>`_ 官方文档综合了 :ref:`ha_k8s_stacked` 和 :ref:`ha_k8s_external` ，我在本文实践中拆解了 :ref:`ha_k8s_external`
- `Network Plugins <https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements>`_
- `cilium Quick Installation <https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/>`_
