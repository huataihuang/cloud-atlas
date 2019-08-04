.. _single_master_k8s:

===============================
创建单一控制平面(单master)集群
===============================

初始化控制平面节点(control-plane node)
========================================

.. note::

   本段落为背景说明，实际操作命令只需要执行下一段落 :ref:`kubeadm_init`

管控平面节点(control-plane node)是指控制平面组件运行的主机节点，包括 ``etcd`` (集群数据库) 和 API 服务器(kubectl命令行工具通讯的服务器组件)。

- 规划并选择一个pod network add-on，请注意所选择CNI是否需要的任何参数传递给kubeadm初始化

我这里选择 Flannel 作为CNI，以便采用精简的网络配置和获得较好的性能。根据Flannel CNI的安装要求，是需要想 ``kubeadm init`` 传递参数 ``--pod-network-cidr=10.244.0.0/16`` 。

.. note::

   必须安装一个 pod network add-on 这样你的pod才能彼此通讯。

   在部署任何应用程序之前需要部署网络，并且网络安装之前不能启动 CoreDNS。 kubeadm 只支持 Container Network Interface (CNI) 网络(并且不支持kubenet)。

   由于有多种CNI容器网络接口，对比选择很重要，可以参考 `Choosing a CNI Network Provider for Kubernetes <https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/>`_ 和 `Kubernetes 网络模型 <https://feisky.gitbooks.io/kubernetes/network/network.html>`_

   `Kubernetes网络插件（CNI）基准测试的最新结果 <https://tonybai.com/2019/04/18/benchmark-result-of-k8s-network-plugin-cni/>`_ 一文对比测试了不同CNI的性能、易用性和高级加密特性，推荐如下:

   - 服务器硬件资源有限并且不需要安全功能，推荐 Flannel ：最精简和易用的CNI，兼容x86和ARM，自动检测MTU，无需配置。
   - 如果需要加密网络则使用WeaveNet，但是徐亚注意MTU设置，并且性能较差（加密的代价）
   - 其他常用场景推荐 Calico ，是广泛用于Kubernetes部署工具(Kops, Kubespray, Rancher等)的CNI，在资源消耗、性能和安全性有较好平衡。需要注意ConfigMap中设置MTU以适配巨型帧。

.. note::

   kubeadm默认设置了一个较为安全的集群并且使用 RBAC ，所以需要确保你选择的网络框架支持 RBAC 。

   使用的 Pod network 必须不覆盖任何主机网络，否则会导致故障。如果你发现网络插件的Pod neetowrk和物理主机网络冲突，则需要选择合适的CIDR，并且采用 ``kubeadm init`` 的 ``--pod-network-cidr`` 来指定

- (可选)从v1.14开始，kubeadm可以自动检测Linux所使用的container runtime。如果使用不同的container runtime，则指定 ``--cri-socket`` 参数传递给 ``kubeadm init``

- (可选)除非指定，否则kubeadm将使用默认网关相关的网络接口来公告master的IP。如果要使用不同的网络接口，则传递 ``--apiserver-advertise-address=<ip-address>`` 参数给 ``kubeadm init``

- (可选)可运行 ``kubeadm config images pull`` 使得 ``kubeadm init`` 验证到 ``gcr.io`` 仓库的网络连接

.. _kubeadm_init:

初始化命令执行
----------------

.. note::

   部署Kubernetes的服务需要能够解析所安装服务器的域名，通常这个工作由DNS来提供，建议在局域网内部部署一个DNSmasq服务。在初始阶段，也可以在每个主机上部署 ``/etc/hosts`` 提供静态地址解析（例如，我在Host物理主机上的 ``/etc/hosts`` 就包含了这个测试集群所有主机的域名解析，可以分发到各个虚拟机上提供基本解析）::

      pscp.pssh -h kube /etc/hosts /tmp/hosts
      pssh -ih kube 'sudo cp /tmp/hosts /etc/hosts'

::

   kubeadm init --pod-network-cidr=10.244.0.0/16

.. note::

   上述 ``kubeadm init`` 要求主机已经正确安装了kubelet，否则会出现报错::

      [kubelet-check] It seems like the kubelet isn't running or healthy.
      [kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get http://localhost:10248/healthz: dial tcp 127.0.0.1:10248: connect: connection refused.
      
      Unfortunately, an error has occurred:
              timed out waiting for the condition

   可通过以下方法检查 ``kubelet`` 问题::

      systemctl status kubelet
      journalctl -xeu kubelet

集群初始化过程
------------------

在执行了 ``kubeadm init`` 指令之后，可以看到执行了一系列操作

- 下载镜像::

   [preflight] Pulling images required for setting up a Kubernetes cluster
   ...
   [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'

- kubeadm会把kubelet运行环境写入配置文件，然后启动 ``kubelet`` ::

   [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
   [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
   [kubelet-start] Activating the kubelet service

- 创建Kubernetes证书::

   [certs] Using certificateDir folder "/etc/kubernetes/pki"
   [certs] Generating "front-proxy-ca" certificate and key
   [certs] Generating "front-proxy-client" certificate and key
   [certs] Generating "etcd/ca" certificate and key
   [certs] Generating "etcd/server" certificate and key
   [certs] etcd/server serving cert is signed for DNS names [kubemaster-1 localhost] and IPs [192.168.101.81 127.0.0.1 ::1]
   [certs] Generating "etcd/peer" certificate and key
   [certs] etcd/peer serving cert is signed for DNS names [kubemaster-1 localhost] and IPs [192.168.101.81 127.0.0.1 ::1]
   [certs] Generating "etcd/healthcheck-client" certificate and key
   [certs] Generating "apiserver-etcd-client" certificate and key
   [certs] Generating "ca" certificate and key
   [certs] Generating "apiserver-kubelet-client" certificate and key
   [certs] Generating "apiserver" certificate and key
   [certs] apiserver serving cert is signed for DNS names [kubemaster-1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.101.81]
   [certs] Generating "sa" key and public key

- 创建Kubernetes配置::

   [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
   [kubeconfig] Writing "admin.conf" kubeconfig file
   [kubeconfig] Writing "kubelet.conf" kubeconfig file
   [kubeconfig] Writing "controller-manager.conf" kubeconfig file
   [kubeconfig] Writing "scheduler.conf" kubeconfig file

- 启动Kubernetes control plane控制平面(管控三大件)::

   [control-plane] Using manifest folder "/etc/kubernetes/manifests"
   [control-plane] Creating static Pod manifest for "kube-apiserver"
   [control-plane] Creating static Pod manifest for "kube-controller-manager"
   [control-plane] Creating static Pod manifest for "kube-scheduler"

- 创建etcd，然后等待control plane的三大组件正常运行(需要依赖etcd服务)::

   [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
   [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
   [apiclient] All control plane components are healthy after 23.506119 seconds

- 在集群的 ``kube-system`` 名字空间存储 ``kubeadm-config`` 配置映射::

   [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace

- 同样客户端kubelet的配置映射也需要存储到 ``kube-system`` 中::

   [kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster

- 跳过了上传certs::

   [upload-certs] Skipping phase. Please see --upload-certs

- 由于control plane已经就绪，现在把第一个master节点 ``kubemaster-1`` 标记为master节点::

   [mark-control-plane] Marking the node kubemaster-1 as control-plane by adding the label "node-role.kubernetes.io/master=''"
   [mark-control-plane] Marking the node kubemaster-1 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]

- 配置集群的RBAC角色::

   [bootstrap-token] Using token: fm9k1o.vhxmun0sriombljn
   [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
   [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
   [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
   [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
   [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace

- 最后执行基础addon::

   [addons] Applied essential addon: CoreDNS
   [addons] Applied essential addon: kube-proxy

- 最后提示Kubernetes control plane初始化成功::

   Your Kubernetes control-plane has initialized successfully!

   To start using your cluster, you need to run the following as a regular user:

     mkdir -p $HOME/.kube
     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config

   You should now deploy a pod network to the cluster.
   Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
     https://kubernetes.io/docs/concepts/cluster-administration/addons/

   Then you can join any number of worker nodes by running the following on each as root:

   kubeadm join <master-ip>:<master-port> --token <token> \
       --discovery-token-ca-cert-hash sha256:<hash>

.. note::

   请注意，上述 ``kubeadm init`` 输出信息是我在测试虚拟机集群的演示输出，隐去了token信息。

   **警告！** 这里输出的token信息和安全紧密相关，请勿将token信息泄漏。否则获得token的任何人都可以在集群添加授权节点，并且可以展示，创建和删除节点。

准备管理员工作环境
-------------------

``kubectl`` 可以用非root用户身份执行，即按照上述 ``kubeadm init`` 输出准备管理员工作环境::

   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config

当然，如果你使用 ``root`` 用户身份就可以直接访问Kubernetes管理配置文件，就只需要设置环境变量::

   export KUBECONFIG=/etc/kubernetes/admin.conf

安装Pod网络插件
===================

在Kubernetes集群中，必须安装一个po network add-on 才能使得pods彼此通讯。

.. note::

   必须在所有应用部署之前部署好网络。并且，CoreDNS只有在网络安装以后才能启动。Kubeadm只支持基于容器网络接口(Container Network Interface, CNI)的网络（并且不支持kubenet）。

注意，kubeadm设置了一个默认较为安全的集群并且增强使用RBAC，所以需要确保你选择的网络框架支持RBAC。

并且需要注意的是，Pod network必须不覆盖任何主机网络(host network)，否则会导致问题。

.. note::

   上文我参考 `Kubernetes网络插件（CNI）基准测试的最新结果 <https://tonybai.com/2019/04/18/benchmark-result-of-k8s-network-plugin-cni/>`_ 一文选择了 Flannel 网络，所以这里记录的是安装 Flannel 网络插件的实践记录。

- 安装 Flannel 网络插件之前，请先检查以下设置必须是 1 ，这可以是的IPv4流量被传递给iptables::

   cat /proc/sys/net/bridge/bridge-nf-call-iptables

如果值不是1，则执行 ``sysctl net.bridge.bridge-nf-call-iptables=1`` 修改，并参考前文设置内核sysctl。

- 允许报所有主机的网络允许 UDP端口 8285 到 8472 流量

由于我采用CentOS 7操作系统，需要设置 firewalld ，方法如下::

   firewall-cmd --zone=public --add-port=8285-8472/udp --permanent 

对于我在 :ref:`k8s_hosts` 使用pssh，则执行命令如下::

   pssh -ih kube 'sudo firewall-cmd --zone=public --add-port=8285-8472/udp --permanent'

- 安装套件::

   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

输出提示信息::

   podsecuritypolicy.policy/psp.flannel.unprivileged created
   clusterrole.rbac.authorization.k8s.io/flannel created
   clusterrolebinding.rbac.authorization.k8s.io/flannel created
   serviceaccount/flannel created
   configmap/kube-flannel-cfg created
   daemonset.apps/kube-flannel-ds-amd64 created
   daemonset.apps/kube-flannel-ds-arm64 created
   daemonset.apps/kube-flannel-ds-arm created
   daemonset.apps/kube-flannel-ds-ppc64le created
   daemonset.apps/kube-flannel-ds-s390x created

一旦安装网络成功，可以通过检查 CoreDNS pod是否运行来确认::

   kubectl get pods --all-namespaces

kube-flannel pod无法启动排查
---------------------------------

执行安装了 kube-flannel 之后，遇到coredns的pod始终创建中的问题::

   NAMESPACE     NAME                                   READY   STATUS              RESTARTS   AGE
   kube-system   coredns-5c98db65d4-shg69               0/1     ContainerCreating   0          14h
   kube-system   coredns-5c98db65d4-x5lz4               0/1     ContainerCreating   0          14h

检查节点无法running原因::

   kubectl describe pod coredns-5c98db65d4-shg69 -n kube-system

错误原因如下::

   Warning  FailedCreatePodSandBox  2m41s (x12436 over 8h)  kubelet, kubemaster-1  (combined from similar events): Failed create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "f1dbd3dc5c66b15165ec2d183d75a5c50deb4d642bf00b55d161cc081f3d779b" network for pod "coredns-5c98db65d4-shg69": NetworkPlugin cni failed to set up pod "coredns-5c98db65d4-shg69_kube-system" network: open /run/flannel/subnet.env: no such file or directory

检查发现 ``kube-flannel`` 不断出现Crash现象::

   kube-system   kube-flannel-ds-amd64-vv6pv            0/1     CrashLoopBackOff    96         8h

但是 ``kubectl describe pod kube-flannel-ds-amd64-vv6pv -n kube-system`` 仅显示::

   Warning  BackOff  72s (x2169 over 8h)  kubelet, kubemaster-1  Back-off restarting failed container

检查pod kube-flannel-ds-amd64-vv6pv日志::

   kubectl logs -n kube-system kube-flannel-ds-amd64-vv6pv

输出显示::

   E0802 02:17:32.961097       1 main.go:241] Failed to create SubnetManager: error retrieving pod spec for 'kube-system/kube-flannel-ds-amd64-vv6pv': Get https://10.96.0.1:443/api/v1/namespaces/kube-system/pods/kube-flannel-ds-amd64-vv6pv: dial tcp 10.96.0.1:443: i/o timeout

我比较疑惑，为何需要访问 ``https://10.96.0.1:443`` ，想到最初初始化阶段 ``kubeadm init`` 确实输出有提示创建接口::

   single_master_k8s.rst:   [certs] apiserver serving cert is signed for DNS names [kubemaster-1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.101.81]

.. note::

   IP ``192.168.101.81`` 是我在部署 Kubernetes 时启用了 :ref:`openconnect_vpn` 使用的 ``tun0`` 接口上IP地址，在关闭VPN之后，我通过 :ref:`change_master_ip` 重新初始化了Kubernetes集群，所以 ``/etc/kubernetes`` 配置目录中所有apiserver访问入口IP地址都修订为 ``192.168.122.11`` 。

   ``10.96.0.1`` 地址是kubernetes的内部集群IP地(在Kubernetes集群内部有一个服务CIRD网络，子网网段是 ``10.96.0.0/12`` ，分配的第一个地址就是 ``10.96.0.1`` ，这个地址是集群的Master服务求第一个IP)。这里访问端口 ``443`` 是Kubernetes的 :ref:`kubernetes_dashboard` 服务的端口。这说明在Kubernetes集群中缺少了Dashboard pod运行。

- 创建Dashboard::

   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

此时发现新创建的Dashboard也是因为Flannel的网络插件无法启动::

   kubectl describe pod kubernetes-dashboard-7d75c474bb-x5ntd -n kube-system

显示::

   Warning  FailedCreatePodSandBox  88s (x4 over 97s)    kubelet, kubemaster-1  (combined from similar events): Failed create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "7465e1499f916318d6079f25b5230a36d4c55d2ae2284bfd0cb2cf6d81d4bc18" network for pod "kubernetes-dashboard-7d75c474bb-x5ntd": NetworkPlugin cni failed to set up pod "kubernetes-dashboard-7d75c474bb-x5ntd_kube-system" network: open /run/flannel/subnet.env: no such file or directory


参考 `Flannel (NetworkPlugin cni) error: /run/flannel/subnet.env: no such file or directory #70202 <https://github.com/kubernetes/kubernetes/issues/70202>`_ 和 `Kubernetes 报错："open /run/flannel/subnet.env: no such file or directory" <https://www.jianshu.com/p/9819a9f5dda0>`_ ，看起来Node主机上缺少 ``/run/flannel/subnet.env`` ，有人建议可以手工创建该文件，内容如下::

   FLANNEL_NETWORK=10.244.0.0/16
   FLANNEL_SUBNET=10.244.0.1/24
   FLANNEL_MTU=1450
   FLANNEL_IPMASQ=true

但是我参考 `kube-dns ContainerCreating /run/flannel/subnet.env no such file #36575 <https://github.com/kubernetes/kubernetes/issues/36575>`_ 其中提到了和我类似的情况 (修改过Master IP `Changing master IP address #338 <Changing master IP address #338>`_ ) 。我发现是我 :ref:`change_master_ip` 再次 ``kubeadm init`` 时遗忘了传递参数 ``--pod-network-cidr=10.244.0.0/16`` 导致上述错误。

再次按照正确方法重新初始化，修复后就可以正常启动所有 pod ::

   $ kubectl get pods --all-namespaces
   NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE
   kube-system   coredns-5c98db65d4-shg69                1/1     Running   51         28h
   kube-system   coredns-5c98db65d4-x5lz4                1/1     Running   51         28h
   kube-system   etcd-kubemaster-1                       1/1     Running   2          25h
   kube-system   kube-apiserver-kubemaster-1             1/1     Running   3          27h
   kube-system   kube-controller-manager-kubemaster-1    1/1     Running   0          4m11s
   kube-system   kube-flannel-ds-amd64-vv6pv             1/1     Running   160        14h
   kube-system   kube-proxy-qtbs9                        1/1     Running   2          28h
   kube-system   kube-scheduler-kubemaster-1             1/1     Running   4          28h
   kube-system   kubernetes-dashboard-7d75c474bb-x5ntd   1/1     Running   51         4h14m

Kubernetes Dashboard
======================

如上文所述，在KVM虚拟机 :ref:`k8s_hosts` ，其虚拟机网络默认是NAT网络。所以对于远程访问虚拟机端口需要映射才行。对于Kubernetes集群，内部服务网络子网网段是 ``10.96.0.0/12`` ，需要使用 ``kubectl proxy`` 建立代理才可以在外部访问。

综上所述，对于远程的管理主机桌面，如果要访问虚拟机集群组建的Kubernetes Dashboard，先采用ssh端口映射命令登陆到 ``worker4`` (上面运行KVM虚拟机)物理主机上，再从物理服务器到KVM虚拟机 ``kubemaster-1`` 的端口映射，再通过 ``kubectl proxy`` 映射到Kubernetes集群内部Dashboard::

   ssh -L 8001:127.0.0.1:8001 worker4
   ssh -L 8001:127.0.0.1:8001 kubemaster-1

登陆到 ``kubemaster-1`` 虚拟机之后，执行以下命令启用kubernetes代理::

   kubectl proxy

现在就可以在自己个人电脑上使用浏览器访问:  http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ 查看集群的Dashboard。

.. note::

   这里还有一个页面报错提示待解决::

      Error: 'net/http: HTTP/1.x transport connection broken: malformed HTTP response "\x15\x03\x01\x00\x02\x02"'
      Trying to reach: 'http://10.244.0.7:8443/'

管控平面节点隔离
=================

默认情况下，由于安全原因，集群不会在管控平面节点(control-plane node)上调度pod(schedule pods)，即管控平面节点不会运行业务相关pod(调度器不会调度pod到管控服务器)。

如果你希望在管控平面节点上运行schedule pods，例如，作为开发工作使用的单主机Kubernetes集群，或者测试集群为了节约服务器资源，想让管控服务器也能够分担一部分业务pod，可以运行以下命令::

   kubectl taint nodes --all node-role.kubernetes.io/master-

此时输出类似::

   node "test-01" untainted
   taint "node-role.kubernetes.io/master:" not found
   taint "node-role.kubernetes.io/master:" not found

上述命令将从集群的所有节点上移除 ``node-role.kubernetes.io/master`` taint，包括control-plane节点。这意味着调度器可以调度pods到任何node上，也包括管控平面节点，例如 ``kubemaster-1`` 服务器。

集群加入节点
===============

按照之前 :ref:`kubeadm` 部署，我们已经在集群所有节点都部署了 ``docker kubeadm kubectl kubelet`` 软件包（对于 kubenode 节点，可以不部署 ``kubectl`` )。

添加节点到Kubernetes集群的命令在 ``kubeadm init`` 时输出提示中就有::

   kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>

如果你当时记录了提示信息，可以直接复制使用(执行时候请先登陆到node节点上，并切换到root身份)。

如果你当时错过了记录下 ``kubeadm init`` 指令输出的添加节点的命令，你可以在管控节点上再次输入如下命令获取添加节点的命令方法::

   kubeadm token create --print-join-command

此时会提示你正确的添加命令方法（包含token和sha256哈希值）。

如果执行 ``kubeadm join`` 报错显示没有授权，请再次检查上述命令输出，确保使用了正确的token和密钥::

   [preflight] Reading configuration from the cluster...
   [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
   error execution phase preflight: unable to fetch the kubeadm-config ConfigMap: failed to get config map: Unauthorized



参考
=========

- `Creating a single control-plane cluster with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/>`_
- `使用kubeadm部署k8s集群 <https://www.jianshu.com/p/d5ce8a9ecbbf>`_
- `k8s与网络--Flannel解读 <https://segmentfault.com/a/1190000016304924>`_
- `Choosing a CNI Network Provider for Kubernetes <https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/>`_
- `Kubernetes 网络模型 <https://feisky.gitbooks.io/kubernetes/network/network.html>`_
