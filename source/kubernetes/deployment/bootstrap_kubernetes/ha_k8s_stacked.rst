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

CoreDNS组件crash排查
=====================

升级系统并重启了操作系统，发现CoreDNS不断crash，检查日志::

   kubectl logs coredns-5c98db65d4-9xt9c -n kube-system

日志显示是控制器无法访问apiserver服务器获得list::

   E0927 01:29:33.763789       1 reflector.go:134] github.com/coredns/coredns/plugin/kubernetes/controller.go:322: Failed to list *v1.Namespace: Get https://10.96.0.1:443/api/v1/namespaces?limit=500&resourceVersion=0: dial tcp 10.96.0.1:443: connect: no route to host
   E0927 01:29:33.763789       1 reflector.go:134] github.com/coredns/coredns/plugin/kubernetes/controller.go:322: Failed to list *v1.Namespace: Get https://10.96.0.1:443/api/v1/namespaces?limit=500&resourceVersion=0: dial tcp 10.96.0.1:443: connect: no route to host
   log: exiting because of error: log: cannot create log: open /tmp/coredns.coredns-5c98db65d4-9xt9c.unknownuser.log.ERROR.20190927-012933.1: no such file or directory

使用 ``get pods -o wide`` 可以看到，实际上 ``coredns`` 没有获得IP地址分配::

   kubectl get pods -n kube-system -o wide

显示::

   NAME                                   READY   STATUS    RESTARTS   AGE   IP               NODE           NOMINATED NODE   READINESS GATES
   coredns-5c98db65d4-9xt9c               0/1     Error     4          62m   <none>           kubenode-5     <none>           <none>
   coredns-5c98db65d4-cgqlj               0/1     Error     3          61m   <none>           kubenode-2     <none>           <none>

由于coredns是随着flannel网络部署的，尝试升级::

   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

显示升级::

   podsecuritypolicy.policy/psp.flannel.unprivileged configured
   clusterrole.rbac.authorization.k8s.io/flannel unchanged
   clusterrolebinding.rbac.authorization.k8s.io/flannel unchanged
   serviceaccount/flannel unchanged
   configmap/kube-flannel-cfg configured
   daemonset.apps/kube-flannel-ds-amd64 configured
   daemonset.apps/kube-flannel-ds-arm64 configured
   daemonset.apps/kube-flannel-ds-arm configured
   daemonset.apps/kube-flannel-ds-ppc64le configured
   daemonset.apps/kube-flannel-ds-s390x configured

升级了flannel网络之后::

   kube-flannel-ds-amd64-5d2wm            1/1     Running            0          5m4s
   kube-flannel-ds-amd64-cp428            1/1     Running            0          3m40s
   kube-flannel-ds-amd64-csxnm            1/1     Running            0          3m4s
   kube-flannel-ds-amd64-f259d            1/1     Running            0          5m50s
   kube-flannel-ds-amd64-hbqx6            1/1     Running            0          4m18s
   kube-flannel-ds-amd64-kjssh            1/1     Running            0          6m34s
   kube-flannel-ds-amd64-qk5ww            1/1     Running            0          7m11s
   kube-flannel-ds-amd64-rk565            1/1     Running            0          2m24s

就看到coredns获得了IP地址::

   $kubectl get pods -n kube-system -o wide
   NAME                                   READY   STATUS             RESTARTS   AGE     IP               NODE           NOMINATED NODE   READINESS GATES
   coredns-5c98db65d4-cgqlj               0/1     CrashLoopBackOff   8          80m     10.244.4.3       kubenode-2     <none>           <none>
   coredns-5c98db65d4-kd9cn               0/1     CrashLoopBackOff   4          2m38s   10.244.6.2       kubenode-4     <none>           <none>

但是发现依然出现crash。

coredns分配到地址是 flannel网络 ``10.244.x.x`` 而不是其他pod显示的 ``192.168.122.x`` (实际上其他pod有第二块flannel网卡分配了 ``10.244.x.x`` 地址 ) ::

   $kubectl get pods -n kube-system -o wide
   NAME                                   READY   STATUS             RESTARTS   AGE     IP               NODE           NOMINATED NODE   READINESS GATES
   coredns-5c98db65d4-cgqlj               0/1     CrashLoopBackOff   8          80m     10.244.4.3       kubenode-2     <none>           <none>
   coredns-5c98db65d4-kd9cn               0/1     CrashLoopBackOff   4          2m38s   10.244.6.2       kubenode-4     <none>           <none>
   etcd-kubemaster-1                      1/1     Running            0          85m     192.168.122.11   kubemaster-1   <none>           <none>
   etcd-kubemaster-2                      1/1     Running            0          83m     192.168.122.12   kubemaster-2   <none>           <none>
   etcd-kubemaster-3                      1/1     Running            0          82m     192.168.122.13   kubemaster-3   <none>           <none>
   kube-apiserver-kubemaster-1            1/1     Running            0          85m     192.168.122.11   kubemaster-1   <none>           <none>
   kube-apiserver-kubemaster-2            1/1     Running            0          83m     192.168.122.12   kubemaster-2   <none>           <none>
   kube-apiserver-kubemaster-3            1/1     Running            0          82m     192.168.122.13   kubemaster-3   <none>           <none>

检查出现crash的coredns的日志::

   $kubectl logs coredns-5c98db65d4-cgqlj -n kube-system
   E0927 02:48:02.036323       1 reflector.go:134] github.com/coredns/coredns/plugin/kubernetes/controller.go:317: Failed to list *v1.Endpoints: Get https://10.96.0.1:443/api/v1/endpoints?limit=500&resourceVersion=0: dial tcp 10.96.0.1:443: connect: no route to host
   E0927 02:48:02.036323       1 reflector.go:134] github.com/coredns/coredns/plugin/kubernetes/controller.go:317: Failed to list *v1.Endpoints: Get https://10.96.0.1:443/api/v1/endpoints?limit=500&resourceVersion=0: dial tcp 10.96.0.1:443: connect: no route to host
   log: exiting because of error: log: cannot create log: open /tmp/coredns.coredns-5c98db65d4-cgqlj.unknownuser.log.ERROR.20190927-024802.1: no such file or directory

尝试登陆 ``kube-apiserver-kubemaster-1`` 检查，可以看到这个容器分配的地址::

   kubectl -n kube-system exec -ti kube-apiserver-kubemaster-1 -- /bin/sh

在容器内部检查IP::

   ip addr

可以看到::

   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
       link/ether 52:54:00:40:8e:71 brd ff:ff:ff:ff:ff:ff
       inet 192.168.122.11/24 brd 192.168.122.255 scope global noprefixroute eth0
          valid_lft forever preferred_lft forever
       inet6 fe80::5054:ff:fe40:8e71/64 scope link
          valid_lft forever preferred_lft forever
   3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
       link/ether 02:42:89:c3:f5:ea brd ff:ff:ff:ff:ff:ff
       inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
          valid_lft forever preferred_lft forever
   4: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default
       link/ether 86:5f:75:3b:48:e5 brd ff:ff:ff:ff:ff:ff
       inet 10.244.0.0/32 scope global flannel.1
          valid_lft forever preferred_lft forever
       inet6 fe80::845f:75ff:fe3b:48e5/64 scope link
          valid_lft forever preferred_lft forever   

由于 coredns 是部署在node节点的，检查所有部署在node节点的pod::

   $kubectl get pods -n kube-system -o wide | grep node
   coredns-5c98db65d4-cgqlj               0/1     CrashLoopBackOff   11         94m   10.244.4.3       kubenode-2     <none>           <none>
   coredns-5c98db65d4-kd9cn               0/1     CrashLoopBackOff   7          16m   10.244.6.2       kubenode-4     <none>           <none>
   kube-flannel-ds-amd64-cp428            1/1     Running            0          18m   192.168.122.16   kubenode-2     <none>           <none>
   kube-flannel-ds-amd64-csxnm            1/1     Running            0          17m   192.168.122.15   kubenode-1     <none>           <none>
   kube-flannel-ds-amd64-f259d            1/1     Running            0          20m   192.168.122.17   kubenode-3     <none>           <none>
   kube-flannel-ds-amd64-qk5ww            1/1     Running            0          21m   192.168.122.18   kubenode-4     <none>           <none>
   kube-flannel-ds-amd64-rk565            1/1     Running            0          16m   192.168.122.19   kubenode-5     <none>           <none>
   kube-proxy-8g2xp                       1/1     Running            3          24d   192.168.122.19   kubenode-5     <none>           <none>
   kube-proxy-hptg4                       1/1     Running            3          24d   192.168.122.17   kubenode-3     <none>           <none>
   kube-proxy-jtfds                       1/1     Running            4          24d   192.168.122.15   kubenode-1     <none>           <none>
   kube-proxy-mgvlp                       1/1     Running            3          24d   192.168.122.18   kubenode-4     <none>           <none>
   kube-proxy-plxvq                       1/1     Running            3          24d   192.168.122.16   kubenode-2     <none>           <none>

可以看到在节点上 ``kube-proxy`` 没有重建过，可能是这个原因导致无法提供通讯，所有根据 coredns 所在节点，重建对应 ``kbuenode-2`` 和 ``kubenode-4`` 上的 ``kube-proxy`` ::

   kubectl -n kube-system delete pods kube-proxy-plxvq
   ...

不过，依然没有解决。参考 `kubedns container cannot connect to apiserver #193 <kubedns container cannot connect to apiserver #193>`_ 解决思路是客户端kubelet的NAT网络问题，需要确保::

   # 确保IP forward
   sysctl net.ipv4.conf.all.forwarding = 1
   # 确保Docker转发
   sudo iptables -P FORWARD ACCEPT
   # 确保 kube-proxy 参数具备 --cluster-cidr=

不过我检查了kubenode节点，发现是满足上述要求的
   
重新刷新::

   systemctl stop kubelet
   systemctl stop docker
   iptables --flush
   iptables -tnat --flush
   systemctl start kubelet
   systemctl start docker

果然，kubenode客户端处理过iptables转发之后，能够正常运行cordns了

参考
========

- `Creating Highly Available clusters with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/>`_
