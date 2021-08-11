.. _arm_k8s_deploy:

========================
部署ARM架构Kubernetes
========================

部署环境
===========

树莓派4操作系统采用Ubuntu 20.04(Focal Fossa)，提供了64位ARM操作系统，可以非常完美运行AArch64容器镜像，这样可以避免很多32位镜像的软件问题。通过树莓派实现微型Kubernetes集群，可以充分演练新的云原生技术。

.. note::

   从技术上来说 ``AArch64`` 和 ``ARM64`` 是同一种架构，是64位系统。ARM和x86的指令集不同，所以不能在x86服务器上运行ARM65镜像，反之也不行。

准备工作
==========

- 准备3个(或更多) :ref:`raspberry_pi` ，我采用了:

  - 1台 2G 规格 :ref:`pi_4` ：用于管控 ``pi-master1`` ( 操作系统采用 :ref:`ubuntu64bit_pi` )
  - 2台 8G 规格 :ref:`pi_4` ：用于工作节点 ``pi-worker1`` 和 ``pi-worker2`` ( 操作系统采用 :ref:`ubuntu64bit_pi` )
  - 1台 4G 规格 :ref:`pi_400` : 用于工作节点 ``kali`` ( 操作系统采用 :ref:`install_kali_pi` )

在构建Kubernetes集群之前，主要需要解决树莓派访问TF卡性能低下的问题，采用 :ref:`usb_boot_ubuntu_pi_4` 可以极大提高树莓派存储IO性能。

- 我也使用了一台 :ref:`jetson_nano` 设备作为GPU工作节点
- 为了测试和验证Kubernetes混合不同架构，在ARM集群中添加一台 :ref:`thinkpad_x220` 运行 :ref:`arch_linux` 作为模拟X86异构Kubernetes工作节点

安装和配置Docker
==================

我使用 :ref:`ubuntu64bit_pi` ，使用的Ubuntu 20.04 提供了非常新的Docker版本，v19.03，可以直接通过 ``apt`` 命令安装::

   sudo apt install -y docker.io

设置systemd管理cgroups
--------------------------

安装完docker之后，需要做一些配置确保激活 cgroups (Control Groups)。cgroups是内核用用限制和隔离资源，可以让Kubernetes更好地管理容器运行时使用地资源，并且通过隔离容器来增加安全性。

- 执行 ``docker info`` 检查::

   # Check `docker info`
   # Some output omitted
   $ sudo docker info
   (...)
   Cgroup Driver: cgroups
   Cgroup Version: 1
   (...)
   WARNING: No memory limit support
   WARNING: No swap limit support
   WARNING: No kernel memory limit support
   WARNING: No kernel memory TCP limit support
   WARNING: No oom kill disable support

.. note::

   请注意默认使用 ``Cgroup Version: 1`` ，目前最新版本 :ref:`docker_cgroup_v2` ，可以提供精细的io隔离功能

这里显示 cgroups 驱动需要修改成 :ref:`systemd` 作为 cgroups 管理器，并且确保只使用一个cgroup manager。所以修改或者创建 ``/etc/docker/daemon.json`` 如下::

   $ sudo cat > /etc/docker/daemon.json <<EOF
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "overlay2"
   }
   EOF

.. note::

   在 :ref:`install_kali_pi` 上安装的最新版本 docker.io 默认已经启用了 ``systemd`` 并且支持 :ref:`cgroup_v2` ，所以 ``docker info`` 显示::

      ...
      Cgroup Driver: systemd
      Cgroup Version: 2
      ...
      WARNING: No memory limit support
      WARNING: No swap limit support
      WARNING: Support for cgroup v2 is experimental

   我暂时不调整，采用默认设置，看看能否顺利运行kubernetes

激活cgroups limit支持
-------------------------

上述 ``docker info`` 输出中显示了cgroups limit没有激活，需要修改内核来激活这些选项。对于树莓派4，需要在 ``/boot/firmware/cmdline.txt`` 文件中添加以下配置::

   cgroup_enable=cpuset
   cgroup_enable=memory
   cgroup_memory=1
   swapaccount=1

确保将上述配置添加到 ``cmdline.txt`` 文件到末尾，可以通过以下 ``sed`` 命令完成::

   sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt

接下来重启一次系统，就会看到 ``docker info`` 输出显示 ``cgroups driver`` 是 ``systemd`` 并且有关 cgroup limits 的警告消失了。

允许iptables查看bridged流量
-----------------------------

Kubernetes需要使用iptables来配置查看bridged网络流量，可以通过以下命令修改 ``sysctl`` 配置::

   cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   EOF

   sudo sysctl --system

安装Kubernetes软件包
=======================

- 添加Kubernetes repo::

   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

   cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
   deb https://apt.kubernetes.io/ kubernetes-xenial main
   EOF

.. note::

   在最新的 :ref:`kali_linux` 上执行 ``apt-key`` 命令会提示::

      Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).

.. note::

   Ubuntu 20.04的版本代号是Focal，Ubuntu 18.04代号是Xenial。你需要检查kubernetes.io的Apt软件仓库提供的对应Ubuntu LTS仓库版本号。当前，在 https://packages.cloud.google.com/apt/dists 中查询还仅仅有 ``kubernetes-xenial`` 尚未提供 focal 版本，所以上述配置apt源仅配置针对 Ubuntu 18.04 的 ``kubernetes-xenial`` 。后续可以关注该网站提供的软件仓库，在适当时切换到 Focal 版本。

.. note::

   如果 ``apt update`` 出现以下报错::

      Err:2 https://packages.cloud.google.com/apt kubernetes-xenial InRelease
        The following signatures couldn't be verified because the public key is not available: NO_PUBKEY FEEA9169307EA071 NO_PUBKEY 8B57C5C2836F4BEB
      ...
      W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: https://packages.cloud.google.com/apt kubernetes-xenial InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY FEEA9169307EA071 NO_PUBKEY 8B57C5C2836F4BEB
      W: Failed to fetch https://apt.kubernetes.io/dists/kubernetes-xenial/InRelease  The following signatures couldn't be verified because the public key is not available: NO_PUBKEY FEEA9169307EA071 NO_PUBKEY 8B57C5C2836F4BEB
      W: Some index files failed to download. They have been ignored, or old ones used instead.

   则需要再次执行::

      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

- 安装以下3个必要的Kubernetes软件包::

   sudo apt update && sudo apt install -y kubelet kubeadm kubectl

- 安装完成后使用 ``apt-mark hold`` 命令来锁定上述3个软件版本，因为更新Kubernetes需要很多手工处理和关注，不要使用通用的更新方式更新::

   sudo apt-mark hold kubelet kubeadm kubectl

如果要解除 ``hold`` 则使用 ``sudo apt-mark unhold kubelet kubeadm kubectl``

.. note::

   ``apt-mark hold`` 命令非常重要，如果不锁定版本任由其随系统升级，会导致管控平面运行软件版本和客户端版本形成较大gap，最终导致无法管理节点。要升级Kubernetes版本，需要手工采用 :ref:`upgrade_kubeadm_cluster` 

创建Kubernetes集群
====================

在创建Kubernetes集群前，需要确定:

- 有一个树莓派节点角色是控制平面节点(Control Plane node)，其余节点则作为计算节点。
- 需要选择一个网络的CIDR作为Kubernetes集群的pods使用，这里的案例使用 :ref:`flannel` CNI，是一种比较功能简单但是性能较为卓越的容器网络接口(Container Network Interface, CNI)。需要确保Kubernetes使用的CIDR没有被路由器或者DHCP服务器所管理的网段冲突。
  - 请确保规划足够大大网段，因为会使用大量的pods，往往超出最初的规划 - 使用 10.244.0.0/16

.. note::

   我在模拟环境中使用了树莓派的无线网卡和有线网卡，无线网段可以方便我们调试服务，所以我采用指定BSSID方式确保客户端和服务器端通过同一个无线AP，就不需要使用可路由网段，只需要确保这个Kubernetes的CIDR和路由器DHCP分配的网段不冲突就行。

初始化控制平面
----------------

Kubernetes使用bootstrap token来认证加入集群的节点，这个token需要在 ``kubeadm init`` 命令中传递来初始化控制平面节点。

- 使用 ``kubeadm token generate`` 命令创建token::

   TOKEN=$(sudo kubeadm token generate)
   echo $TOKEN

这里 ``$TOKEN`` 输出需要记录下来，后续命令行需要

- 设置 ``kubernetes-version`` 可以指定初始化的管控集群版本::

   sudo kubeadm init --token=${TOKEN} --kubernetes-version=v1.19.4 --pod-network-cidr=10.244.0.0/16

输出信息:

.. literalinclude:: arm_kubeadm_init.output
   :linenos:

- 对于管理集群用户，执行以下命令完成配置::

   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config

- 完成上述工作以后，执行节点检查::

   kubectl get nodes

可以看到节点就绪(以下输出案例是我第二次重建集群的输出信息，所以版本是 v1.22.0)::

   NAME         STATUS   ROLES                  AGE   VERSION
   pi-master1   Ready    control-plane,master   32m   v1.22.0

多网卡困扰
-----------

在执行 ``kubeadm init`` 初始化Kubernetes集群时，我发现对于具有2块网卡( ``wlan0`` 和 ``eth0`` )的树莓派系统， ``etcd`` 系统默认使用了 ``wlan0`` 地址 ``192.168.166.91`` ::

    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [localhost pi-         master1] and IPs [192.168.166.91 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [localhost pi-master1]   and IPs [192.168.166.91 127.0.0.1 ::1]

而 ``apiserver`` 服务则同时提供两个接口的DNS名字证书(其中 10.96.0.1 并非当前服务器网卡IP地址)::

   [certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local pi-master1]
   and IPs [10.96.0.1 192.168.166.91]

.. note::

   需要注意的是无线网卡的IP地址是DHCP分配，这导致服务器重启会出现IP变化问题，需要解决。

由于没有携带参数的 ``kubeadmin init`` 会使用默认路由的网卡IP地址，这导致和我设想的使用有线网卡上的固定IP地址不同，所以我需要重新初始化。注意，再次初始化使用 ``--apiserver-advertise-address string`` 参数来指定公告IP地址。

采用的方法请参考我之前的实践 :ref:`change_master_ip` 重新初始化

.. code-block:: bash

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

   # reinit master with data in etcd
   # add --kubernetes-version, --pod-network-cidr and --token options if needed
   # 原文使用如下命令:
   # kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd
   # 但是由于我使用的是Flannel网络，所以一定要加上参数，否则后续安装 flannel addon无法启动pod

   kubeadm init --ignore-preflight-errors=DirAvailable--var-lib-etcd --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address 192.168.6.11

- 初始化以后等待一些实践，删除掉旧的节点

.. code-block:: bash

   sleep 120
   kubectl get nodes --sort-by=.metadata.creationTimestamp

这里可以看到一个master节点存在问题::

   NAME         STATUS     ROLES    AGE     VERSION
   pi-master1   NotReady   master   2d10h   v1.19.4

- 删除问题节点

.. code-block:: bash

   kubectl delete node $(kubectl get nodes -o jsonpath='{.items[?(@.status.conditions[0].status=="Unknown")].metadata.name}')

这里提示::

   error: resource(s) were provided, but no name, label selector, or --all flag specified

检查pod

.. code-block:: bash

   # check running pods
   kubectl get pods --all-namespaces -o wide

输出信息::

   NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE     IP             NODE         NOMINATED NODE   READINESS GATES
   kube-system   coredns-f9fd979d6-gd94x              0/1     Pending   0          2d10h   <none>         <none>       <none>           <none>
   kube-system   coredns-f9fd979d6-hbqx9              0/1     Pending   0          2d10h   <none>         <none>       <none>           <none>
   kube-system   etcd-pi-master1                      1/1     Running   0          11h     192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-apiserver-pi-master1            1/1     Running   0          11h     192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-controller-manager-pi-master1   1/1     Running   1          2d10h   192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-proxy-525kd                     1/1     Running   1          2d10h   192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-scheduler-pi-master1            1/1     Running   1          2d10h   192.168.6.11   pi-master1   <none>           <none>

- 不过检查集群apiserver访问正常::

   kubectl cluster-info

显示输出::

   Kubernetes master is running at https://192.168.6.11:6443
   KubeDNS is running at https://192.168.6.11:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
   
   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

排查解决node NotReady
----------------------

- 检查 ``pending`` 的pod原因

.. code-block:: bash

   kubectl -n kube-system describe pods coredns-f9fd979d6-gd94x

可以看到是由于调度不成功导致

.. code-block:: console

   Events:
     Type     Reason            Age                    From               Message
     ----     ------            ----                   ----               -------
     Warning  FailedScheduling  58s (x215 over 5h21m)  default-scheduler  0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/not-ready: }, that the pod didn't tolerate.

- 检查节点 NotReady 的原因::

   kubectl describe nodes pi-master1

输出显示::

   Conditions:
     Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
     ----             ------  -----------------                 ------------------                ------                       -------
     MemoryPressure   False   Wed, 02 Dec 2020 22:59:43 +0800   Sun, 29 Nov 2020 23:53:52 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
     DiskPressure     False   Wed, 02 Dec 2020 22:59:43 +0800   Sun, 29 Nov 2020 23:53:52 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
     PIDPressure      False   Wed, 02 Dec 2020 22:59:43 +0800   Sun, 29 Nov 2020 23:53:52 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
     Ready            False   Wed, 02 Dec 2020 22:59:43 +0800   Sun, 29 Nov 2020 23:53:52 +0800   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized   

可以看到 ``KubeletNotReady`` 的原因是 ``runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized`` ，也就是说，我们指定使用 flannel网络的CNI没有就绪，导致docker的runtime network不能工作。

重建集群实践
--------------

我在 :ref:`delete_kubeadm_cluster` 之后重新创建集群，吸取了双网卡对集群初始化的配置要求，所以命令改为::

   sudo kubeadm init --token=${TOKEN} --kubernetes-version=v1.22.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address 192.168.6.11

输出信息:

.. literalinclude:: arm_kubeadm_init_again.output
   :linenos:

.. note::

   这里输出信息中有::

      ...
      [WARNING SystemVerification]: missing optional cgroups: hugetlb

   这是在 :ref:`cgroup_v1` 中支持的 :ref:`cgroup_v1_hugetlb`

安装CNI插件
-------------

CNI插件处理pod网络的配置和清理，这里使用最简单的flannel CNI插件，只需要下载和 ``kubeclt apply`` Flannel YAML就可以安装好::

   # Download the Flannel YAML data and apply it
   # (output omitted)
   #$ curl -sSL https://raw.githubusercontent.com/coreos/flannel/v0.12.0/Documentation/kube-flannel.yml | kubectl apply -f -

   # 从Kubernetes v1.17+可以使用以下命令
   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

- 果然，正确安装了 Flannel 网络插件之后再检查节点状态就恢复 ``Ready`` ::

   kubectl get nodes

已经恢复正常状态::

   NAME         STATUS   ROLES    AGE     VERSION
   pi-master1   Ready    master   2d23h   v1.19.4

- 同时检查pod状态::

   kubectl get pods --all-namespaces -o wide

可以看到 coredns 也恢复正航运行::

   NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE     IP             NODE         NOMINATED NODE   READINESS GATES
   kube-system   coredns-f9fd979d6-gd94x              1/1     Running   0          2d23h   10.244.0.3     pi-master1   <none>           <none>
   kube-system   coredns-f9fd979d6-hbqx9              1/1     Running   0          2d23h   10.244.0.2     pi-master1   <none>           <none>
   kube-system   etcd-pi-master1                      1/1     Running   1          23h     192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-apiserver-pi-master1            1/1     Running   1          23h     192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-controller-manager-pi-master1   1/1     Running   2          2d23h   192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-flannel-ds-arm64-5c2kf          1/1     Running   0          3m21s   192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-proxy-525kd                     1/1     Running   2          2d23h   192.168.6.11   pi-master1   <none>           <none>
   kube-system   kube-scheduler-pi-master1            1/1     Running   2          2d23h   192.168.6.11   pi-master1   <none>           <none>

将计算节点加入到集群
=====================

在完成了CNI add-on部署之后，就可以向集群增加计算节点

- 登陆到工作节点，例如 ``pi-worker1`` 上使用命令 ``kubeadm join`` ::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<DISCOVERY-TOKEN>

这里出现了报错::

   [preflight] Running pre-flight checks
       [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
       [WARNING SystemVerification]: missing optional cgroups: hugetlb
   
   error execution phase preflight: couldn't validate the identity of the API Server: could not find a JWS signature in the cluster-info ConfigMap for token ID "8pile8"
   To see the stack trace of this error execute with --v=5 or higher

这个问题参考 `Kubernetes: unable to join a remote master node <https://stackoverflow.com/questions/61352209/kubernetes-unable-to-join-a-remote-master-node>`_ 原因是token已经过期或者已经移除，所以可以通过以下方法重新创建并提供命令::

   kubeadm token create --print-join-command

输出可以看到::

   W1203 11:50:33.907625  484892 kubelet.go:200] cannot automatically set CgroupDriver when starting the Kubelet: cannot execute 'docker info -f {{.CgroupDriver}}': exit status 2
   W1203 11:50:33.918553  484892 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
   kubeadm join 192.168.6.11:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<DISCOVERY-TOKEN>

.. note::

   默认生成的token都有一个有效期，所以导致上述token过期无法使用的问题。

   可以通过以下命令生成一个无期限的token(但是存在安全风险)::

      kubeadm token create --ttl 1

   查看token的方法如下::

      kubeadm token list

   然后根据token重新生成证书摘要(即hash)::

      openssl x509 -pubkey -in /etc/kubenetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

   这样就能拼接出一个添加节点的join命令::

      kubeadm join 192.168.6.11:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<DISCOVERY-TOKEN>

- 根据提示重新在 ``pi-worker1`` 上执行节点添加::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<DISCOVERY-TOKEN>

输出信息::

   [preflight] Running pre-flight checks
           [WARNING SystemVerification]: missing optional cgroups: hugetlb
   [preflight] Reading configuration from the cluster...
   [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
   [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
   [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
   [kubelet-start] Starting the kubelet
   [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
   
   This node has joined the cluster:
   * Certificate signing request was sent to apiserver and a response was received.
   * The Kubelet was informed of the new secure connection details.
   
   Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

- 等待一会，在管控节点上检查::

   kubectl get nodes -o wide

输出信息如下::

   NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   pi-master1   Ready    master   3d12h   v1.19.4   192.168.6.11   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker1   Ready    <none>   2m10s   v1.19.4   192.168.6.15   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8

jetson节点(GPU)
----------------

我在 :ref:`arm_k8s` 说明了我部署ARM架构的设备中还有一个 :ref:`jetson_nano` 设备，用来实现验证GPU容器在Kubernetes的部署，并学习 :ref:`machine_learning` 。

jetson nano使用的Ubuntu 18.04定制版本L4T默认已经安装了Docker 19.03版本，满足了运行kubernetes要求，不过，也同样需要做Cgroup Driver调整:

- 通过 ``docker info`` 检查显示

.. literalinclude:: jetson_docker_info.output
   :linenos:

- 注意，Jetson Nano的Docker激活了 ``nvidia`` runtime，所以默认的 ``daemon.json`` 配置如下

.. literalinclude:: jetson_daemon.json_default
   :linenos:

修订成:

.. literalinclude:: jetson_daemon.json_systemd
   :linenos:

然后重启docker服务::

   systemctl restart docker

并通过 ``docker info`` 验证确保 ``Cgroup Driver: systemd`` 。

- 上述 ``docker info`` 中显示有2个WARNING::

   WARNING: No blkio weight support
   WARNING: No blkio weight_device support

.. note::

   最初Ubuntu 20/18 提供的docker版本(19.x)都没有出现上述WARNING，但是最近升级docker到 ``20.10.2`` 出现。原因是Docker 从 Docker Engine 20.10开始，支持 :ref:`cgroup_v2` 。 :ref:`docker_cgroup_v2` 提供了更好的io隔离。如果非生产环境，可以暂时忽略上述警告。

- Jetson的L4T系统内核 ``sysctl`` 配置默认已经启动允许iptables查看bridge流量::

   sysctl -a | grep net.bridge.bridge-nf-call-ip

可以看到::

   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1

- 添加Kubernetes repo::

   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

   cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
   deb https://apt.kubernetes.io/ kubernetes-xenial main
   EOF

- Kubernetes软件包::

   sudo apt update && sudo apt install -y kubelet kubeadm kubectl

.. note::

   安装Kubernetes需要直接访问google服务，在墙内需要使用 :ref:`openconnect_vpn` 翻墙，或者 :ref:`squid_socks_peer` 构建代理。

- 锁定Kubernetes版本(可选，对于测试验证集群没有业务连续性要求，可以跳过)::

   sudo apt-mark hold kubelet kubeadm kubectl

- 关闭swap::

   # 关闭系统默认启动的4个zram swap文件
   for i in {0..3};do swapoff /dev/zram${i};echo $i > /sys/class/zram-control/hot_remove;done

   # 禁用启动swap
   systemctl disable nvzramconfig.service

.. note::

   Jetson的定制L4T操作系统使用了 :ref:`zram` 来构建swap，详细参考 :ref:`jetson_swap` 。

- 在管控服务器获取当前添加节点命令::

   kubeadm token create --print-join-command

- 回到Jetson服务器节点执行添加节点命令::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<HASH_TOKEN>

.. note::

   随着 ``kubeadm`` 软件版本不断升级，新安装的worker节点的版本可能高于原先构建 :ref:`kubernetes` 集群，这导致无法加入集群,需要按照 :ref:`upgrade_kubeadm_cluster` 。

- 完成以后执行命令检查节点::

   kubectl get nodes

我们会看到如下输出::

   NAME         STATUS   ROLES    AGE     VERSION
   jetson       Ready    <none>   2m47s   v1.19.4
   pi-master1   Ready    master   5d21h   v1.19.4
   pi-worker1   Ready    <none>   2d9h    v1.19.4
   pi-worker2   Ready    <none>   2d9h    v1.19.4

.. note::

   注意如果worker主机有多个网卡接口，kubelet执行 ``kubeadm join`` 命令时候有可能注册采用了默认有路由的网卡接口，也可能使用和apiserver指定IP所在相同网段的IP。这点让我很疑惑，例如上述注册worker节点，3个树莓派注册的 ``INTERNAL-IP`` 是正确的内网IP地址 ``192.168.6.x`` ，但是 ``jetson`` 就注册成了外网无线网卡上的IP地址 ``192.168.0.x`` 。

   这个问题修订，请参考 :ref:`set_k8s_worker_internal_ip` 明确配置worker的 ``INTERNAL-IP`` 避免出现混乱。

kali linux节点(kali)
-----------------------

:ref:`kali_linux` 也是基于 :ref:`ubuntu_linux` 的操作系统，所以安装和管理Kubernetes非常相似。不过，需要注意的是，默认安装::

   apt install docker.io

然后执行 ``docker info`` 可以看到已经启用了 ``systemd`` 和 :ref:`cgroup_v2` ::

   ...
   Cgroup Driver: systemd
   Cgroup Version: 2
   ...
   WARNING: No memory limit support
   WARNING: No swap limit support
   WARNING: Support for cgroup v2 is experimental

不过默认的docker配置是无法安装Kubernetes的，会提示报错:

.. literalinclude:: arm_k8s_deploy/kail_kubeadm_init.output
   :linenos:
   
可以看到，必须要设置 ``CGROUPS_MEMORY`` ，所以也如前设置：

- 修订 :ref:`kali_linux` for Raspberry Pi的配置文件 ``/boot/cmdline.txt`` (原先只有一行配置，在配置行最后添加)::

   ... cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1

- 然后重启系统，再检查 ``docker info`` 后，只在最后提示::

   ...
   WARNING: Support for cgroup v2 is experimental

- 然后重新开始将节点加入集群

kali linux节点添加失败排查
~~~~~~~~~~~~~~~~~~~~~~~~~~~

在解决了kali linux节点的docker版本配置问题后，就可以执行 ``kubeadm join`` 指令了，但是发现添加的节点始终是 ``NotReady`` ，检查pod创建::

   kubectl -n kube-system get pods

可以看到kali linux节点上容器没有正确启动::

   kube-flannel-ds-pkhch                0/1     Init:0/1            0          42m    30.73.167.10    kali         <none>           <none>
   kube-proxy-6jt64                     0/1     ContainerCreating   0          42m    30.73.167.10    kali         <none>           <none>

- 检查pod::

   kubectl -n kube-system describe pods kube-flannel-ds-pkhch

可以看到报错原因::

   Warning  FailedCreatePodSandBox  2m29s (x186 over 42m)  kubelet            Failed to create pod sandbox: open /run/systemd/resolve/resolv.conf: no such file or directory

- 检查kali linux节点，发现确实没有这个文件::

   # ls /run/systemd/resolve/resolv.conf
   ls: cannot access '/run/systemd/resolve/resolv.conf': No such file or directory

对比正常节点，则有这个文件，这说明kali linux默认没有激活 :ref:`systemd_resolved` ::

   systemctl enable systemd-resolved
   systemctl start systemd-resolved

然后再次检查就可以看到文件::

   # ls /run/systemd/resolve/resolv.conf
   /run/systemd/resolve/resolv.conf

- 等待kali linux节点上kube-system namespace对应的pod创建成功，就可以看到该worker节点正常Ready了
   
arch linux节点(zcloud)
-----------------------

- 安装docker::

   panman -Sy docker

- 启动docker::

   systemctl start docker
   systemctl enable docker

- 检查 ``docker info`` 输出信息，可以看到 ``Cgroup Driver: cgroupsf`` 不是 ``systemd`` ，所以修订成 :ref:`systemd` 作为 cgroups 管理器，并且确保只使用一个cgroup manager。修改或者创建 ``/etc/docker/daemon.json`` 如下::

   $ sudo cat > /etc/docker/daemon.json <<EOF
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "overlay2"
   }
   EOF

- 然后再次检查 ``docker info`` 可以看到还有一个报错::

   WARNING: bridge-nf-call-iptables is disabled
   WARNING: bridge-nf-call-ip6tables is disabled

修复::

   cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   EOF

   sudo sysctl --system

.. note::

   arch linux安装kubernetes参考 `arch linux文档 - Kubernetes <https://wiki.archlinux.org/index.php/Kubernetes>`_

- 安装软件包::

   pacmsn -Syu && pacman -Sy kubelet kubeadm kubectl

- 关闭swap

- 在管控服务器获取当前添加节点命令::

   kubeadm token create --print-join-command

- 回到Jetson服务器节点执行添加节点命令::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<HASH_TOKEN>

.. note::

   如果遇到节点一直 ``NotReady`` ，请在节点上执行检查kubelet日志命令::

      journalctl -xeu --no-pager kubelet

   我遇到的问题是无法下载镜像，提示错误::

      Mar 23 00:25:15 zcloud kubelet[3682]: E0323 00:25:15.851566    3682 pod_workers.go:191] Error syncing pod 062199e4-6351-4ff9-9e55-91db9ac8884f ("kube-proxy-jms58_kube-system(062199e4-6351-4ff9-9e55-91db9ac8884f)"), skipping: failed to "CreatePodSandbox" for "kube-proxy-jms58_kube-system(062199e4-6351-4ff9-9e55-91db9ac8884f)" with CreatePodSandboxError: "CreatePodSandbox for pod \"kube-proxy-jms58_kube-system(062199e4-6351-4ff9-9e55-91db9ac8884f)\" failed: rpc error: code = Unknown desc = failed pulling image \"k8s.gcr.io/pause:3.2\": Error response from daemon: Get \"https://k8s.gcr.io/v2/\": dial tcp: lookup k8s.gcr.io: no such host"

   这个问题是因为我启动主机时候未连接无线网络，导致没有默认路由可以访问internet，此时启动的dnsmasq无法解析地址。虽然后面用手工脚本命令启动了wifi，但是dnsmasq依然无法提供本地主机域名解析。我是通过重启dnsmasq解决的，你的情况可能和我不同。不过，观察 kubelet 日志是一个比较好的排查问题方法。

再次添加zcloud节点(arch linux)
-------------------------------

我在重建了Kubernetes集群之后，发现当前google提供的kubernetes软件版本，也就是我构建的管控平面，已经是最新的 ``v1.22.0`` ，但是在 zcloud 节点使用的Arch Linux，则提供的是 ``v1.21.3`` 。

- 尝试执行节点添加::

   kubeadm join 192.168.6.11:6443 --token <TOKEN> \
       --discovery-token-ca-cert-hash sha256:<HASH_TOKEN>

出现报错::

   ...
   error execution phase preflight: unable to fetch the kubeadm-config ConfigMap: failed to decode cluster configuration data: no kind "ClusterConfiguration" is registered for version "kubeadm.k8s.io/v1beta3" in scheme "k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/scheme/scheme.go:31"
   To see the stack trace of this error execute with --v=5 or higher

看来低版本节点无法加入高版本集群(兼容性实在太差了)

- 检查 `arch linux kubeadm package <https://archlinux.org/packages/?name=kubeadm>`_ 可以看到当前:

  - ``1.21.3-1`` 为社区版本(正式)
  - ``1.22.0-1`` 为社区测试版本

- 修订 ``/etc/pacman.conf`` 配置文件，激活 ``commuity-testing`` 仓库::

   [community-testing]
   Include = /etc/pacman.d/mirrorlist

- 然后执行指定版本安装::

   # 同步 community-testing 仓库信息
   pacman -Sy

   # 安装指定版本
   pacman -S kubelet=1.22.0-1 kubeadm=1.22.0-1 kubectl=1.22.0-1

- 锁定版本是修改 ``/etc/pacman.conf`` ::

   IgnorePkg   = kubelet kubeadm kubectl

这样就不会升级上述版本。

- 再次修订 ``/etc/pacman.conf`` 将 ``community-testing`` 仓库注释掉，避免其他软件版本升级到测试版本。


最终结果
==========

- 最终节点如下::

   kubectl get nodes -o wide

显示如下::

   NAME         STATUS   ROLES                  AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME
   jetson       Ready    <none>                 2d1h   v1.22.0   30.73.165.36    <none>        Ubuntu 18.04.5 LTS       4.9.201-tegra        docker://20.10.7
   kali         Ready    <none>                 63m    v1.22.0   30.73.167.10    <none>        Kali GNU/Linux Rolling   5.4.83-Re4son-v8l+   docker://20.10.5+dfsg1
   pi-master1   Ready    control-plane,master   2d2h   v1.22.0   192.168.6.11    <none>        Ubuntu 20.04.2 LTS       5.4.0-1041-raspi     docker://20.10.7
   pi-worker1   Ready    <none>                 2d1h   v1.22.0   192.168.6.15    <none>        Ubuntu 20.04.2 LTS       5.4.0-1041-raspi     docker://20.10.7
   pi-worker2   Ready    <none>                 2d1h   v1.22.0   192.168.6.16    <none>        Ubuntu 20.04.2 LTS       5.4.0-1041-raspi     docker://20.10.7
   zcloud       Ready    <none>                 21m    v1.22.0   192.168.6.200   <none>        Arch Linux               5.13.9-arch1-1       docker://20.10.8

.. note::

   注意到有两个节点 ``jetson`` 和 ``kali`` 节点 ``INTERNAL-IP`` 采用了无线网卡上的IP地址，需要修订

- 现在，我们终于可以拥有一个混合架构的Kubernetes集群::

   kubectl get nodes --show-labels

可以看到 ARM 节点的标签有 ``kubernetes.io/arch=arm64`` ，而 X86 节点标签有 ``kubernetes.io/arch=amd64`` ::

   NAME         STATUS   ROLES                  AGE    VERSION   LABELS
   jetson       Ready    <none>                 2d1h   v1.22.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=jetson,kubernetes.io/os=linux
   kali         Ready    <none>                 61m    v1.22.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=kali,kubernetes.io/os=linux
   pi-master1   Ready    control-plane,master   2d2h   v1.22.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-master1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
   pi-worker1   Ready    <none>                 2d1h   v1.22.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-worker1,kubernetes.io/os=linux
   pi-worker2   Ready    <none>                 2d1h   v1.22.0   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-worker2,kubernetes.io/os=linux
   zcloud       Ready    <none>                 20m    v1.22.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=zcloud,kubernetes.io/os=linux

后面我们部署应用，所使用的镜像需要区分不同架构。我将实践异构应用部署。

验证集群
===========

现在一个基于ARM的Kubernetes集群已经部署完成，可以运行pods，创建deployments和jobs。

为了验证集群的正确运行，可以执行验证步骤：

- 创建新的namespace
- 创建deployment
- 创建serice
- 验证运行在deployment中的pods能够正确响应

.. note::

   这里使用的验证镜像是从RED HAT维护的 quay.io 镜像仓库提供的，你也可以使用其他镜像仓库，例如Docker Hub提供的镜像进行验证。

- 创建一个名为 ``kube-verify`` 的namespace::

   kubectl create namespace kube-verify

提示信息::

   namespace/kube-verify created

- 检查namespace::

   kubectl get namespaces

显示输出::

   NAME              STATUS   AGE
   default           Active   5d21h
   kube-node-lease   Active   5d21h
   kube-public       Active   5d21h
   kube-system       Active   5d21h
   kube-verify       Active   36s

- 创建一个deployment用于这个新的namespace:

.. literalinclude:: arm_k8s_deploy/create_deployment.sh
   :language: bash
   :linenos:

此时提示信息::

   deployment.apps/kube-verify created

上述deployment配置了3个副本 ``replicas: 3`` pods，每个pod都运行了 ``quay.io/clcollins/kube-verify:01`` 镜像。

- 检查在 ``kube-verify`` 中的所有资源::

   kubectl get all -n kube-verify

输出显示::

   NAME                               READY   STATUS    RESTARTS   AGE
   pod/kube-verify-69dd569645-nvnhl   1/1     Running   0          2m8s
   pod/kube-verify-69dd569645-s5qb5   1/1     Running   0          2m8s
   pod/kube-verify-69dd569645-v9zxt   1/1     Running   0          2m8s

   NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/kube-verify   3/3     3            3           2m8s

   NAME                                     DESIRED   CURRENT   READY   AGE
   replicaset.apps/kube-verify-69dd569645   3         3         3       2m8s

可以看到有一个新的deployment ``deployment.apps/kube-verify`` ，这个deployment配置 ``replicas: 3`` 的请求下有3个pods被创建。

- 创建服务来输出 Nginx 应用，这个操作是一个单一入口 ``single endpoint`` :

.. literalinclude:: arm_k8s_deploy/create_service.sh
   :language: bash
   :linenos:

提示::

   service/kube-verify created

- 现在服务已经创建，我们可以检查新服务的IP地址::

   kubectl get -n kube-verify service/kube-verify

显示输出::

   NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
   kube-verify   ClusterIP   10.107.123.31   <none>        80/TCP    90s

你可以看到 ``kube-verify`` 服务被设置到一个 ClusterIP ``10.107.123.31`` 上，但是这个IP地址是集群内部使用的，所以你可以在集群的任何node节点上访问，但是在集群外部就不能访问。

- 选择一个集群节点，执行以下命令验证deployment的容器是正常工作的::

   curl 10.107.123.31

你会看到一个完整输出的html文件内容。

访问服务
============

到这里，你已经完整部署和验证了Kubernetes on Raspberry Pi集群，只是当前在集群外部还不能访问到集群pod提供的服务。

你可以有多种方法：

- 输出部署( ``expose deployments`` )通过简单的负载均衡方式(指定 ``external-ip``)将服务映射输出到集群外部
- 部署 :ref:`ingress` 来管理外部访问集群的服务，例如， :ref:`nginx_ingress` 对外提供服务

这里我们采用最简单的方法，使用 ``expose deployments`` 方法输出服务：

- 检查 ``kube-verify`` namespace的服务::

   kubectl get services -n kube-verify

输出可以看到当前服务有内部 ``cluster-ip`` 但是没有 ``external-ip`` ::

   NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
   kube-verify   ClusterIP   10.107.123.31   <none>        80/TCP    19h

- 我们的woker工作节点如下::

   kubectl get nodes -o wide

显示::

   NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready    <none>   19h     v1.19.4   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6
   pi-master1   Ready    master   6d17h   v1.19.4   192.168.6.11   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker1   Ready    <none>   3d5h    v1.19.4   192.168.6.15   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker2   Ready    <none>   3d5h    v1.19.4   192.168.6.16   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8

问题来了，我们需要把服务输出到外部无线网卡上，该如何实现？实际上 ``pi-worker1`` 上无线网卡上IP地址 192.168.0.81:

- 无线网卡的外网地址是动态的，假设我直接输出到这个无线网卡IP地址，则下次主机重启如果获取到不同IP地址，则有可能和局域网其他IP地址冲突

  - 我考虑到解决方法是采用一个自己控制的IP地址段作为演示，然后需要访问的客户机也绑定同一个网段，这样只要连接到相同的无线AP上，就可以访问服务


当前我简化这个配置，暂时先使用有线网络网段 ``192.168.6.x``

- 检查当前service::

   kubectl get service -n kube-verify

可以看到::

   NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
   kube-verify   ClusterIP   10.107.123.31   <none>        80/TCP    26h

- 删除掉这个service::

   kubectl delete service kube-verify -n kube-verify

- 然后重建一个负载均衡类型的输出::

   kubectl expose deployments kube-verify -n kube-verify --port=80 --protocol=TCP --target-port=8080 \
       --name=kube-verify --external-ip=192.168.6.10 --type=LoadBalancer

提示信息::

   service/kube-verify exposed

.. note::

   注意，这里负载均衡类型的输出 ``target-ports`` 和之前 service 是一样的，只不过多了一个 ``EXTERNAL-IP`` 对外

- 现在我们检查 ``kubectl get service -n kube-verify`` 显示::

   NAME          TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
   kube-verify   LoadBalancer   10.96.31.186   192.168.6.10   80:30586/TCP   61s

奇怪，这里 ``--target-port=8080`` 怎么没有生效么？怎么显示 ``PORT(S)`` 是 ``80:30586/TCP`` ，但是直接对该IP地址访问 ``curl http://192.168.6.10`` 是能够正常获取到页面输出的。

现在我们得到的验证环境::

   kubectl get all -n kube-verify

输出显示::

   NAME                           READY   STATUS    RESTARTS   AGE
   kube-verify-69dd569645-q9hzc   1/1     Running   0          33h
   kube-verify-69dd569645-s5qb5   1/1     Running   0          2d12h
   kube-verify-69dd569645-v9zxt   1/1     Running   0          2d12h
   ubuntu@pi-master1:~$ kubectl get all -n kube-verify
   NAME                               READY   STATUS    RESTARTS   AGE
   pod/kube-verify-69dd569645-q9hzc   1/1     Running   0          33h
   pod/kube-verify-69dd569645-s5qb5   1/1     Running   0          2d12h
   pod/kube-verify-69dd569645-v9zxt   1/1     Running   0          2d12h

   NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
   service/kube-verify   LoadBalancer   10.96.31.186   192.168.6.10   80:30586/TCP   32h

   NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/kube-verify   3/3     3            3           2d12h

   NAME                                     DESIRED   CURRENT   READY   AGE
   replicaset.apps/kube-verify-69dd569645   3         3         3       2d12h

参考
=====

- `Build a Kubernetes cluster with the Raspberry Pi <https://opensource.com/article/20/6/kubernetes-raspberry-pi>`_ - 完整的部署指南，作者 Chris Collins 撰写了一系列在Raspberry Pi上构建homelab的文章，可以实现基于K8s的NFS服务；另外，如果需要通过Kubernetes对外提供HTTP路由和反向代理(ingress)，可以参考 `Try this Kubernetes HTTP router and reverse proxy <https://opensource.com/article/20/4/http-kubernetes-skipper>`_
- `解决k8s执行kubeadm join遇到could not find a JWS signature的问题 <https://segmentfault.com/a/1190000023107314>`_
