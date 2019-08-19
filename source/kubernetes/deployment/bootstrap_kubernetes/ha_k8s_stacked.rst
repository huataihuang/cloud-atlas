.. _ha_k8s_stacked:

================================
堆栈型管控/etcd节点高可用集群
================================

在具备了负载均衡的集群上，进一步可以创建高可用堆栈型管控平面和etcd节点。

- 首先在 :ref:`single_master_k8s` 创建的第一个管控平面节点 ``kubemaster-`` ( ``192.168.122.11`` ) 上创建一个配置文件，命名为 ``kubeadm-config.yaml`` ::

   apiVersion: kubeadm.k8s.io/v1beta2
   kind: ClusterConfiguration
   networking:
     podSubnet: "10.244.0.0/16"
   kubernetesVersion: stable
   #controlPlaneEndpoint: "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT"
   controlPlaneEndpoint: "kubeapi.huatai.me:6443"

.. note::

   请注意DNS解析需要首先配置好，请参考 :ref:`k8s_hosts` 设置 libvirt dnsmasq。

.. note::

   ``kubeadm-config.yaml`` 配置解析:

   - ``kubernetesVersion`` 是设置使用的Kubernetes版本
   - ``controlPlaneEndpoint`` 设置管控平面访问接口地址，也就是负载均衡上的VIP地址对应的DNS域名，以及端口。注意不要直接使用IP地址，否则后续维护要调整IP地址非常麻烦。
   - 建议使用相同版本的 kubeadm, kubelet, kubectl 和 Kubernetees
   - ``upload-certs`` 参数结合 ``kubeadm init`` 则表示主控制平面的证书被较密并上传到 ``kubeadm-certs`` 加密密钥。

   如果要重新上传证书并且生成一个新的加密密钥，则在已经加入集群的控制平面节点使用以下命令::

       sudo kubeadm init phase upload-certs --upload-certs

- 初始化控制平面::

   sudo kubeadm init --config=kubeadm-config.yaml --upload-certs

提示报错::

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
      controlPlaneEndpoint: "kubeapi.huatai.me:6443"

上述工作完成之后再次执行::

   kubectl cluster-info

输出显示信息就是从负载均衡访问Kube Master的输出信息::

   Kubernetes master is running at https://kubeapi.huatai.me:6443
   KubeDNS is running at https://kubeapi.huatai.me:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

- 执行以下命令添加CNI plugin，注意按照你自己的选择来执行，不同的CNI plugin是需要使用不同的命令的::

   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

.. note::

   我的环境已经在 :ref:`single_master_k8s` 执行过上述安装CNI plugin指令，这里跳过。如果你从一开始就按照先负载均衡，后部署多节点高可用master，则需要执行上述命令。

- 检查管控平面的节点组件::

   kubectl get pod -n kube-system -w

输出显示::

   NAME                                    READY   STATUS    RESTARTS   AGE
   coredns-5c98db65d4-shg69                1/1     Running   52         18d
   coredns-5c98db65d4-x5lz4                1/1     Running   52         18d
   etcd-kubemaster-1                       1/1     Running   3          18d
   kube-apiserver-kubemaster-1             1/1     Running   4          18d
   kube-controller-manager-kubemaster-1    1/1     Running   1          17d
   kube-flannel-ds-amd64-6r7jz             1/1     Running   0          15d
   kube-flannel-ds-amd64-8v68j             1/1     Running   0          13d
   kube-flannel-ds-amd64-vv6pv             1/1     Running   161        17d
   kube-proxy-cfrgs                        1/1     Running   0          15d
   kube-proxy-qt7fg                        1/1     Running   0          13d
   kube-proxy-qtbs9                        1/1     Running   3          18d
   kube-scheduler-kubemaster-1             1/1     Running   5          18d
   kubernetes-dashboard-7d75c474bb-x5ntd   1/1     Running   52         17d

.. note::

   这里我遇到 ``kubectl get pod -n kube-system -w`` 显示输出后，会卡住一段时间再返回控制台提示符。

