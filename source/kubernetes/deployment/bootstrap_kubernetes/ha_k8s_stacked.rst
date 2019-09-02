.. _ha_k8s_stacked:

================================
堆叠型管控/etcd节点高可用集群
================================

在具备了负载均衡的集群上，进一步可以创建高可用堆栈型管控平面和etcd节点。

第一个管控平面节点(Master)
===========================

- 首先在 :ref:`single_master_k8s` 创建的第一个管控平面节点 ``kubemaster-1`` ( ``192.168.122.11`` ) 上创建一个配置文件，命名为 ``kubeadm-config.yaml`` ::

   apiVersion: kubeadm.k8s.io/v1beta2
   kind: ClusterConfiguration
   networking:
     podSubnet: "10.244.0.0/16"
   kubernetesVersion: stable
   #controlPlaneEndpoint: "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT"
   controlPlaneEndpoint: "kubeapi.test.huatai.me:6443"

.. note::

   请注意DNS解析需要首先配置好，请参考 :ref:`k8s_hosts` 设置 libvirt dnsmasq。

.. note::

   ``kubeadm-config.yaml`` 配置解析:

   - ``kubernetesVersion`` 是设置使用的Kubernetes版本
   - ``controlPlaneEndpoint`` 设置管控平面访问接口地址，也就是负载均衡上的VIP地址对应的DNS域名，以及端口。注意不要直接使用IP地址，否则后续维护要调整IP地址非常麻烦。
   - ``networking:`` 段落是因为我使用了 Flannel 网络插件，所以必须增加 CIDR 配置，详见 :ref:`single_master_k8s` ; 子网参数必须通过配置文件传递，命令行会显示冲突，见下文。
   - 建议使用相同版本的 kubeadm, kubelet, kubectl 和 Kubernetees
   - ``upload-certs`` 参数结合 ``kubeadm init`` 则表示主控制平面的证书被较密并上传到 ``kubeadm-certs`` 加密密钥。

   如果要重新上传证书并且生成一个新的加密密钥，则在已经加入集群的控制平面节点使用以下命令::

       sudo kubeadm init phase upload-certs --upload-certs

- 初始化控制平面::

   sudo kubeadm init --config=kubeadm-config.yaml --upload-certs

.. note::

   请记录下初始化集群之后的输出信息，其中包含了如何将其他master节点和worker节点加入集群的命令。当然，即使没有记录，后续通过查询系统以及配置也能组合出 ``kubeadm join`` 指令，但是对初学者来说比较麻烦。

- 按照提示信息，将配置文件复制到管控主机用户目录下::

   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config

- 上述工作完成之后执行检查::

   kubectl cluster-info

输出显示信息就是从负载均衡访问Kube Master的输出信息::

   Kubernetes master is running at https://kubeapi.test.huatai.me:6443
   KubeDNS is running at https://kubeapi.test.huatai.me:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

- 如果要重新上传证书和生成新的解密密钥，在已经加入集群的一个管控节点上使用以下命令::

   sudo kubeadm init phase upload-certs --upload-certs

- 可以生成一个认证密钥::

   sudo kubeadm init phase upload-certs --upload-certs

然后这个密钥就可以在以后加入节点的初始化时通指定 ``--certificate-key`` 来使用。

重置集群初始化遇到的问题
=========================

我在实践中，遇到过提示报错::

   W0818 22:54:20.162134   15717 version.go:98] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable.txt": Get https://dl.k8s.io/release/stable.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
   W0818 22:54:20.162326   15717 version.go:99] falling back to the local client version: v1.15.1
   [init] Using Kubernetes version: v1.15.1
   [preflight] Running pre-flight checks
       [WARNING Firewalld]: firewalld is active, please ensure ports [6443 10250] are open or your cluster may not function correctly
       [WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.1. Latest validated version: 18.09
   error execution phase preflight: [preflight] Some fatal errors occurred:
       [ERROR Port-6443]: Port 6443 is in use
       [ERROR Port-10251]: Port 10251 is in use
       [ERROR Port-10252]: Port 10252 is in use
       [ERROR FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml]: /etc/kubernetes/manifests/kube-apiserver.yaml already exists
       [ERROR FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml]: /etc/kubernetes/manifests/kube-controller-manager.yaml already exists
       [ERROR FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml]: /etc/kubernetes/manifests/kube-scheduler.yaml already exists
       [ERROR FileAvailable--etc-kubernetes-manifests-etcd.yaml]: /etc/kubernetes/manifests/etcd.yaml already exists
       [ERROR Port-10250]: Port 10250 is in use
       [ERROR Port-2379]: Port 2379 is in use
       [ERROR Port-2380]: Port 2380 is in use
       [ERROR DirAvailable--var-lib-etcd]: /var/lib/etcd is not empty
   [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`

由于我是在已经构建 :ref:`single_master_k8s` 基础上执行，所以出现上述报错。参考 :ref:`change_master_ip` 重新做一次初始化需要改成如下命令::

   systemctl stop kubelet docker
   cd /etc/

   # backup old kubernetes data
   mv kubernetes kubernetes-backup
   mv /var/lib/kubelet /var/lib/kubelet-backup

   # restore certificates
   mkdir -p kubernetes
   cp -r kubernetes-backup/pki kubernetes
   rm kubernetes/pki/{apiserver.*,etcd/peer.*}

   systemctl start docker
   
   # 配置文件 kubeadm-config.yaml 包含 podSubnet: "10.244.0.0/16"
   kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --config=kubeadm-config.yaml --upload-certs

   # update kubectl config
   cp kubernetes/admin.conf ~/.kube/config

.. note::

   注意：如果执行::

      kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --pod-network-cidr=10.244.0.0/16 --config=kubeadm-config.yaml --upload-certs

   会提示::

      can not mix '--config' with arguments [pod-network-cidr]

   按照官方文档，由于不能混合 ``--config`` 和参数 ``pod-network-cidr`` ，所以修改 ``kubeadm-config.yaml`` 内容::

      apiVersion: kubeadm.k8s.io/v1beta2
      kind: ClusterConfiguration
      networking:
        podSubnet: "10.244.0.0/16"
      kubernetesVersion: stable
      controlPlaneEndpoint: "kubeapi.test.huatai.me:6443"

配置CNI plugin
=================

- 执行以下命令添加CNI plugin，注意按照你自己的选择来执行，不同的CNI plugin是需要使用不同的命令的::

   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

.. note::

   我的环境已经在 :ref:`single_master_k8s` 执行过上述安装CNI plugin指令，这里跳过。如果你从一开始就按照先负载均衡，后部署多节点高可用master，则需要执行上述命令。

- 检查管控平面的节点组件::

   kubectl get pod -n kube-system

输出显示::

   NAME                                   READY   STATUS    RESTARTS   AGE
   coredns-5c98db65d4-bnbmj               1/1     Running   0          168m
   coredns-5c98db65d4-xbsmf               1/1     Running   0          168m
   etcd-kubemaster-1                      1/1     Running   0          168m
   kube-apiserver-kubemaster-1            1/1     Running   0          168m
   kube-controller-manager-kubemaster-1   1/1     Running   0          168m
   kube-flannel-ds-amd64-wq62v            1/1     Running   0          103s
   kube-proxy-hfw4c                       1/1     Running   0          168m
   kube-scheduler-kubemaster-1            1/1     Running   0          167m

.. note::

   按照官方文档，这里执行应该是 ``kubectl get pod -n kube-system -w`` ，但是我遇到显示输出后，会卡住一段时间再返回控制台提示符。但是 ``kubectl get pod -n kube-system`` 则毫无停滞问题。不过，加不加 ``-w`` 输出内容相同，没有搞清楚原因。

- 可以通过以下命令检查配置文件::

   kubectl -n kube-system get cm kubeadm-config -oyaml

输出显示::

   apiVersion: v1
   data:
     ClusterConfiguration: |
       apiServer:
         extraArgs:
           authorization-mode: Node,RBAC
         timeoutForControlPlane: 4m0s
       apiVersion: kubeadm.k8s.io/v1beta2
       certificatesDir: /etc/kubernetes/pki
       clusterName: kubernetes
       controlPlaneEndpoint: kubeapi.test.huatai.me:6443
       controllerManager: {}
       dns:
         type: CoreDNS
       etcd:
         local:
           dataDir: /var/lib/etcd
       imageRepository: k8s.gcr.io
       kind: ClusterConfiguration
       kubernetesVersion: v1.15.3
       networking:
         dnsDomain: cluster.local
         podSubnet: 10.244.0.0/16
         serviceSubnet: 10.96.0.0/12
       scheduler: {}
     ClusterStatus: |
       apiEndpoints:
         kubemaster-1:
           advertiseAddress: 192.168.122.11
           bindPort: 6443
       apiVersion: kubeadm.k8s.io/v1beta2
       kind: ClusterStatus
   kind: ConfigMap
   metadata:
     creationTimestamp: "2019-09-02T09:20:27Z"
     name: kubeadm-config
     namespace: kube-system
     resourceVersion: "148"
     selfLink: /api/v1/namespaces/kube-system/configmaps/kubeadm-config
     uid: 8e5f8028-cae5-4fd3-a6d0-8355ef2e226c

此时可以看到，集群只有一个 ``kubemaster-1`` 管控节点。下面我们来添加更多管控节点提供冗灾。

其余管控平面节点
==================

在其余的管控平面节点( ``kubemaster-2`` 和 ``kubemaster-3`` ) 上执行以下命令初始化::

   sudo kubeadm join kubeapii.test.huatai.me:6443 --token <TOKEN> --discovery-token-ca-cert-hash <DISCOVERY-TOKEN-CA-CERT-HASH> --control-plane --certificate-key <CERTIFICATE-KEY>

.. note::

   这里 ``--token <TOKEN> --discovery-token-ca-cert-hash <DISCOVERY-TOKEN-CA-CERT-HASH>`` 部分可以通过如下命令获得(如果你没有在初始化时候记录下来)::

      kubeadm token create --print-join-command

   但是，如果你在部署多节点集群初始化时候( ``sudo kubeadm init --config=kubeadm-config.yaml --upload-certs`` ) 没有记录下 ``certificate-key`` 信息，则使用以下命令生成一个key:

      kubeadm alpha certs certificate-key

   这样就可以拼接成完整命令来添加新的管控Master节点。上文也提到了这个命令。

.. note::

   根据 ``kubeadm join`` 命令提示，需要注意以下要点：

   - 确保 ``6443 10250`` 端口在Master节点已经打开

   - 可以通过 ``kubeadm config images pull`` 提前下载好镜像，这样部署可以加快

- 依次添加好新增的master节点，我们的集群将具备3个master节点，使用 ``kubectl get nodes`` 可以看到如下输出::

   NAME           STATUS   ROLES    AGE     VERSION
   kubemaster-1   Ready    master   4h44m   v1.15.3
   kubemaster-2   Ready    master   17m     v1.15.3
   kubemaster-3   Ready    master   5m6s    v1.15.3

- 检查配置 ``kubectl -n kube-system get cm kubeadm-config -oyaml`` 可以看到集群管控的完整配置如下::

   apiVersion: v1
   data:
     ClusterConfiguration: |
       apiServer:
         extraArgs:
           authorization-mode: Node,RBAC
         timeoutForControlPlane: 4m0s
       apiVersion: kubeadm.k8s.io/v1beta2
       certificatesDir: /etc/kubernetes/pki
       clusterName: kubernetes
       controlPlaneEndpoint: kubeapi.test.huatai.me:6443
       controllerManager: {}
       dns:
         type: CoreDNS
       etcd:
         local:
           dataDir: /var/lib/etcd
       imageRepository: k8s.gcr.io
       kind: ClusterConfiguration
       kubernetesVersion: v1.15.3
       networking:
         dnsDomain: cluster.local
         podSubnet: 10.244.0.0/16
         serviceSubnet: 10.96.0.0/12
       scheduler: {}
     ClusterStatus: |
       apiEndpoints:
         kubemaster-1:
           advertiseAddress: 192.168.122.11
           bindPort: 6443
         kubemaster-2:
           advertiseAddress: 192.168.122.12
           bindPort: 6443
         kubemaster-3:
           advertiseAddress: 192.168.122.13
           bindPort: 6443
       apiVersion: kubeadm.k8s.io/v1beta2
       kind: ClusterStatus
   kind: ConfigMap
   metadata:
     creationTimestamp: "2019-09-02T09:20:27Z"
     name: kubeadm-config
     namespace: kube-system
     resourceVersion: "21267"
     selfLink: /api/v1/namespaces/kube-system/configmaps/kubeadm-config
     uid: 8e5f8028-cae5-4fd3-a6d0-8355ef2e226c

重新生成certificate-key
==========================

在第三个master节点上执行 ``kubeadm join`` 遇到报错::

   [download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
   error execution phase control-plane-prepare/download-certs: error downloading certs: error downloading 
   the secret: Secret "kubeadm-certs" was not found in the "kube-system" Namespace. 
   This Secret might have expired. Please, run `kubeadm init phase upload-certs --upload-certs` 
   on a control plane to generate a new one

.. note::

   默认情况下，用于解密的密钥只有2小时有效期，所以过了2小时之后，执行初始化master节点就会报上述错误。此时需要重新生成密钥，然后在使用新的密钥结合 ``--certificate-key`` 参数来初始化master节点。

则回到之前已经加入的master节点 ``kubemaster-2`` 上重新生成 certificate-key ::

   sudo kubeadm init phase upload-certs --upload-certs

将输出显示的新 ``certificate-key`` 替换 ``kubeadm join`` 参数再次执行则添加成功。

添加worker节点
=================

在完成了master节点部署之后，可以将工作节点加入到集群，同样也使用 ``kubeadm join`` 命令，不过，和添加master节点不同的是，没有 ``--control-plane`` 参数（表示是管控节点）和 ``--certificate-key`` 参数（解密密钥)::

   kubeadm join kubeapi.test.huatai.me:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<DISCOVERY-TOKEN-CA-CERT-HASH>

添加worker节点故障排查
------------------------

在添加了第一个 ``kubenode-1`` 节点之后，使用 ``kubectl get node`` 检查发现节点处于 ``NotReady`` ::

   kubenode-1     NotReady   <none>   3m26s   v1.15.3

要排查节点 ``NotReady`` 原因，通常需要使用 ``describe node`` 命令，就可以检查节点日志。例如这里看到::

   Conditions:
     Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
       ----             ------  -----------------                 ------------------                ------                       -------
   ...
     Ready            False   Mon, 02 Sep 2019 22:37:15 +0800   Mon, 02 Sep 2019 22:33:43 +0800   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized

这里可以看到docker的错误消息是::

   message:docker: network plugin is not ready: cni config uninitialized

参考 `network plugin is not ready: cni config uninitialized #48798 <https://github.com/kubernetes/kubernetes/issues/48798>`_ ，上述报错是因为kubelet使用网络插件没有就绪，有人建议重新apply plugin，例如 ``kubectl apply --filename https://git.io/weave-kube-1.6`` 。但是，我实际上已经在初始集群master节点时候做过这个操作，不可能每个node节点加入都需要我重新apply一次CNI plugin。

检查 ``kubenode-1`` 节点的CNI配置目录，可以看到 ``/etc/cni/net.d/`` 目录下已经有了一个 ``10-flannel.conflist`` 配置文件，说明master已经分发了CNI配置，但是没有生效。所以怀疑是 ``kubelet`` 原因，重启kubelet::

   sudo systemctl restart kubelet

果然，重启了 ``kubelet`` 服务之后，再次检查节点，就看到节点已经Ready了。

.. note::

   在Master节点上，有 ``/etc/cni/net.d/10-flannel.conflist`` ，可用于复制到worker节点来修复上述CNI网络配置问题。

接下来，可以一次添加集群的其他节点，例如 ``kubenode-2`` 等等。

此外，我也遇到节点 ``kubenode-2`` 上没有自动创建 ``/etc/cni/net.d/10-flannel.conflist`` ，手工从正常节点 ``kubenode-1`` 复制过来配置文件，重启kubelet修复。

完成上述worker节点添加之后，在管控节点上执行 ``kubectl get nodes`` 输出应该类似如下::

   NAME           STATUS   ROLES    AGE     VERSION
   kubemaster-1   Ready    master   6h13m   v1.15.3
   kubemaster-2   Ready    master   107m    v1.15.3
   kubemaster-3   Ready    master   94m     v1.15.3
   kubenode-1     Ready    <none>   60m     v1.15.3
   kubenode-2     Ready    <none>   19m     v1.15.3
   kubenode-3     Ready    <none>   5m45s   v1.15.3
   kubenode-4     Ready    <none>   72s     v1.15.3
   kubenode-5     Ready    <none>   24s     v1.15.3

手工分发证书
=============

如果在Master上执行 ``kubeadm init`` 没有使用 ``--upload-ceerets`` 参数，则需要手工从第一个主管控节点想所有加入的管控节点复制证书，包括以下文件::

   /etc/kubernetes/pki/ca.crt
   /etc/kubernetes/pki/ca.key
   /etc/kubernetes/pki/sa.key
   /etc/kubernetes/pki/sa.pub
   /etc/kubernetes/pki/front-proxy-ca.crt
   /etc/kubernetes/pki/front-proxy-ca.key
   /etc/kubernetes/pki/etcd/ca.crt
   /etc/kubernetes/pki/etcd/ca.key

参考
========

- `Creating Highly Available clusters with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/>`_
