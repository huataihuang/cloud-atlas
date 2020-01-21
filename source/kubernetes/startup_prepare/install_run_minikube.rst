.. _install_run_minikube:

======================
安装和运行minikube
======================

.. note::

   本章节因为是综合了我在多个平台部署minikube的实践，所以比较繁杂。实际上在Linux平台上部署minikube默认配置（使用虚拟机）非常简单。但是，如果使用了一些非标准配置，例如，btrfs作为存储驱动，裸物理机运行minikube则略微复杂。

裸机直接部署minikube(快速起步)
================================

为了追求性能，在我的测试环境采用了裸物理主机直接运行minikube，并且采用了btrfs作为存储驱动，所以配置略有复杂。详情请见下文。

.. note::

   为了快速起步，简述方法如下::

      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube
      minikube config set vm-driver none
      sudo minikube start --extra-config=kubeadm.ignore-preflight-errors=SystemVerification --extra-config=kubelet.cgroup-driver=systemd --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf

   上述安装步骤只需要具备两个前提条件就可以完成:

   - 安装好Docker CE: 请参考 :ref:`install_docker_in_studio` 
     - 注意，需要配置项 ``"exec-opts": ["native.cgroupdriver=systemd"]``
   - 架好翻墙的梯子: 请参考 :ref:`openconnect_vpn`

   启动参数说明：

   - 由于我采用btrfs，默认minikube启动验证storage driver会失败，所以添加参数 kubeadm.ignore-preflight-errors=SystemVerification
   - 由于docker配置cgroupdriver=systemd，所以对应配置参数 kubelet.cgroup-driver=systemd
   - 对于Ubuntu 18.04默认启用了 ``systemd-resolv`` ，需要绕过默认的 ``resolv.conf`` ，所以使用参数 ``kubelet.resolv-conf=/run/systemd/resolve/resolv.conf``

.. warning::

   根据 minikube文档 `vm-driver=none <https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md>`_ ，实际上裸物理机运行minikube有一些已知问题需要注意规避。

.. _minikube:

minikube
=================

最简单体验完整的Kubernetes集群功能是使用 `minikube GitHub官网 <https://github.com/kubernetes/minikube>`_ ，这是一个在单个节点上运行Kubernetes的方式，可以用于测试Kubernetes以及本地开发应用。

minikube是通常通过虚拟机来运行的，也就是说必须在主机上运行Hypervisor，可以是Virtualbox (跨平台) 也可以是 KVM (Linux) 或者 Hyper-V (Windows)，甚至可以使用非常小众的 HyperKit (macOS)。

.. note::

   之所以minikube通常需要在虚拟机中运行，是因为minikub是基于Docker容器运行的，Docker容器需要在Linux上运行，所以会先要求运行一个Linux虚拟机，然后才能在虚拟机中运行Docker以满足运行minikube的条件。

   如果你是在Linux主机上，由于Linux可以直接运行Docker，所以甚至可以不需要Hypervisor的虚拟机，直接运行在Linux物理主机的Docker中。此时使用参数 ``--vm-driver=none`` 来运行。

安装Minikube
===================

Ubuntu平台安装MiniKube
----------------------------

- 安装命令::

   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube

macOS平台安装MiniKube
--------------------------

.. note::

   macOS的minikube可以选择virtualbox作为后端，也可以选择 `xhyve <https://github.com/moby/hyperkit>`_ 作为后端，另外也可以使用VMware Fusion。我分别尝试过使用 xhyve 和 vmware 作为Hypervisor。

macOS安装hyperkit
~~~~~~~~~~~~~~~~~~~~

- 为了在块设备后端支持qcow，需要安装OCaml `OPAM <https://opam.ocaml.org/>`_ 开发环境带有qcow模块::

   brew install opam libev
   opam init
   eval `opam config env`
   opam install uri qcow.0.10.4 conduit.1.0.0 lwt.3.1.0 qcow-tool mirage-block-unix.2.9.0 conf-libev logs fmt mirage-unix prometheus-app

.. note::

   为了能够在编译hyperkit之前找到ocaml环境，必须在编译前执行一次 ``opam config env``

   可以通过以下命令移除之前旧版本的 ``mirage-block-unix`` 的 ``pin`` 或者 ``qcow`` ::

      opam update
      opam pin remove mirage-block-unix
      opam pin remove qcow

- 安装HyperKit::

   git clone https://github.com/moby/hyperkit
   cd hyperkit
   make

.. note::

   二进制执行程序位于 ``build/hyperkit`` 。为了能够让 ``docker-machine-driver-hyperkit`` 找到hyperkit可执行程序，请将这个目录加入到环境变量，例如 ``~/.bash_profile`` 。

.. note::

   升级macOS 10.14.4 之后，对应的Xcode版本升级，clang编译对于源代码的语法校验加强，遇到类型错误::

      cc src/lib/firmware/fbsd.c
      src/lib/firmware/fbsd.c:690:7: error: implicit conversion changes signedness: 'unsigned int' to 'int' [-Werror,-Wsign-conversion]

   修改 ``config.mk`` 将::

      -Weverything \

   删除

.. note::

   遇到报错::

      ocamlfind: Package `cstruct.lwt' not found

   则重新安装一次 ``cstruct-lwt`` ::

      opam reinstall cstruct-lwt

macOS安装VMware Fusion
~~~~~~~~~~~~~~~~~~~~~~~~~

请参考 :ref:`vmware_in_studio` ，我安装了VMware Fusion。使用 ``vmrun list`` 可以检查当前运行的VMware虚拟机。

macOS安装minikube
~~~~~~~~~~~~~~~~~~~

- 通过brew安装minikube(我没有使用这个方法)::

   brew cask install minikube

- 直接安装罪行版本minikube（我使用这个方法）::

   curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.35.0/minikube-darwin-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube

.. note::

   每次启动minikube默认会检查是否有可用最新版本

启动minikube
==================

- （不推荐直接）启动minikube集群::

   minikube start

Linux平台使用kvm后端
-------------------------

.. note::

   minikube默认使用Virtualbox作为驱动，所以如果简单使用上述命令，会首先下载virtulbox镜像来运行。这可能和你的安装环境不同。所以需要参考 `Driver plugin installation <https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver>`_ 来安装驱动产检，并指定驱动来启动minikube。

   ``以下案例将采用KVM作为驱动来运行minikube``

   注意：我的实验室环境已经按照 :ref:`kvm_docker_in_studio` 安装了KVM驱动所需的 ``libvirt-clients libvirt-daemon-system qemu-kvm`` ，所以只需要安装 ``docker-machine-driver-kvm2`` 就可以。

- 安装 ``docker-machine-driver-kvm2`` 驱动::

   curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 \
     && sudo install docker-machine-driver-kvm2 /usr/local/bin/

- 直接使用kvm2驱动启动的命令如下::

   minikube start --vm-driver kvm2

- 不过，更好的方法是先指定默认驱动kvm2，然后再启动就不需要传递参数了::

   minikube config set vm-driver kvm2
   minikube start

.. note::

   ``minikube config set PROPERTY_NAME`` 会在用户目录下的 ``~/.minikube/config/config.json`` 添加对应的驱动配置，例如::

      {
          "vm-driver": "kvm2"
      }

此时会下载minikube的KVM镜像，然后运行这个虚拟机，通过 ``virsh list`` 可以看到系统新启动了一个KVM虚拟机::

   Id    Name                           State
   ----------------------------------------------------
   5     minikube                       running

.. note::

   创建的minikube配置: ``CPUs=2, Memory=2048MB, Disk=20000MB``

   ``minikube start`` 运行指令显示输出::

      kubectl is now configured to use "minikube"

   这表明当前Linux主机的kubectl已经被配置直接使用刚才所安装运行的minikube

直接物理主机运行minikube
-----------------------------

前面我们在 ``xcloud`` :ref:`studio` 环境中通过KVM虚拟化运行了minikube主机，现在，我们实现一个通过物理主机直接运行minikube，以节约运行损耗。

.. note::

   对于已经采用了kvm作为后端的主机，如果使用 ``minikube config set vm-driver none`` 切换后端，会注意到再次运行 ``minikube start`` 会提示由于已经存在一个 "minikube" 虚拟机，所以会忽略参数 ``--vm-driver=none`` 而依然使用KVM来运行minikube。

   要创建第二个minikube并且使用裸机来运行，则第二个minikube需要使用明确的命令来启动另一个命名的minikube::

      minikube start -p <name> --vm-driver=none

- 设置裸物理主机运行minikube::

   minikube config set vm-driver none

- 启动minikube，命名为 ``xminikube`` 表示运行在 ``xcloud`` 物理主机上::

   sudo minikube start -p xminikube --vm-driver=none 

也可以删除掉之前通过KVM运行的minikube（例如，现在我采用只在裸物理主机运行minikube），则就不需要单独指定新的minikube实例，使用如下命令::

   minikube config set vm-driver kvm2  #切换到KVM后端
   minikube delete   #这里删除了之前我创建的KVM后端的minikube
   minikube config set vm-driver none  #切换到直接使用裸物理机
   sudo minikube start  #现在创建的minikube采用物理主机引擎

.. note::

   在物理主机上运行minikube会直接安装 ``/usr/bin/kubelet`` ，所以需要root权限，这里就需要使用 ``sudo`` 来执行命令。

   通过 `none` 驱动运行minikube会降低系统安全和可靠性，详细说明请参考 https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md

Arch Linux平台实践物理机运行minikube
--------------------------------------

- 由于minikube的物理主机运行模式必须以root身份运行，所以先配置驱动::

   sudo minikube config set vm-driver none

- 配置防火墙允许22端口连接


.. note::

   我的物理主机采用了 :ref:`kvm_docker_in_studio` ，所以默认有2个内部NAT网桥 ``docker0`` 和 ``virtbr0`` ，这两个都是内部网段

macOS平台使用hyperkit后端
-----------------------------

- 安装Hyperkit驱动::

   brew install docker-machine-driver-hyperkit

   # docker-machine-driver-hyperkit need root owner and uid 
   sudo chown root:wheel /usr/local/opt/docker-machine-driver-hyperkit/bin/docker-machine-driver-hyperkit
   sudo chmod u+s /usr/local/opt/docker-machine-driver-hyperkit/bin/docker-machine-driver-hyperkit

- (建议跳过这步，用下一步采用先配置再启动)使用Hyperkit后端启动::

   minikube start --vm-driver hyperkit

- 使用hyperkit作为默认后端::

   minikube config set vm-driver hyperkit

- 启动minikube::

   minikube start

macOS平台使用vmware后端
----------------------------------

- 安装VMware统一驱动：首先从 https://github.com/machine-drivers/docker-machine-driver-vmware/releases 下载驱动文件 ``docker-machine-driver-vmware_darwin_amd64`` ，并将其保存到 ``$PATH`` 目录，例如，我保存到 ``~/bin`` （这个目录位于环境变量设置文件 ``~/.bash_profile`` ，并且命名为 ``docker-machine-driver-vmware`` 。

也可以直接使用安装命令如下::

   export LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/machine-drivers/docker-machine-driver-vmware/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/') \
   && curl -L -o docker-machine-driver-vmware https://github.com/machine-drivers/docker-machine-driver-vmware/releases/download/$LATEST_VERSION/docker-machine-driver-vmware_darwin_amd64 \
   && chmod +x docker-machine-driver-vmware \
   && mv docker-machine-driver-vmware /usr/local/bin/

- (建议跳过这步，用下一步采用先配置再启动)使用Vmware后端启动::

   minikube start --vm-driver vmware

.. note::

   根据minikube提示，今后将使用 `统一的vmware驱动 <https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#vmware-unified-driver>`_ 来替代vmwarefusion，所以这里设置 ``--vm-driver vmware``

- 使用VMware fussion作为默认后端::

   minikube config set vm-driver vmware

- 启动minikube::

   minikube start

使用minikube
===============

- ssh登陆minikub方法::

   minikube ssh

minikube虚拟机默认root没有密码，从虚拟机终端可以登陆。

停止和再次启动minikube
==========================

安装了minikube之后，通过 ``minikube stop`` 可以停止，然后通过 ``minikube start`` 可以再次启动。

.. note::

   每次启动minikube，系统都会尝试重新连接Google仓库更新镜像，所以需要先搭好梯子

minikube异常排查
==================

.. _minikube_debug_cri_install:

minikube CRI安装排查
----------------------

重新在 :ref:`ubuntu_on_mbp` (重装了Ubuntu 18.04 LTS Server版本) 之后，我重新部署了 :ref:`btrfs_in_studio` 并设置 :ref:`docker_btrfs_driver` 。首次在裸主机上部署minikube，启动遇到报错::

   * Launching Kubernetes ...
   
   X Error starting cluster: cmd failed: sudo /usr/bin/kubeadm init --config /var/lib/kubeadm.yaml  --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests,DirAvailable--data-minikube,FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml,FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml,FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml,FileAvailable--etc-kubernetes-manifests-etcd.yaml,Port-10250,Swap
   
   : running command: sudo /usr/bin/kubeadm init --config /var/lib/kubeadm.yaml  --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests,DirAvailable--data-minikube,FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml,FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml,FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml,FileAvailable--etc-kubernetes-manifests-etcd.yaml,Port-10250,Swap
    output: [init] Using Kubernetes version: v1.14.3
   [preflight] Running pre-flight checks
           [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
           [WARNING Swap]: running with swap on is not supported. Please disable swap
           [WARNING FileExisting-socat]: socat not found in system path

这说明默认的 :ref:`install_docker_in_studio` 存在环境缺陷，需要参考Kubernetes官方 `CRI installation <https://kubernetes.io/docs/setup/cri/>`_ 文档进行修正。

- 修正cgroupfs通过systemd管理::

   # Setup daemon
   cat > /etc/docker/daemon.json <<EOF
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "btrfs"
   }
   EOF

   mkdir -p /etc/systemd/system/docker.service.d

然后重启docker::

   # Restart docker.
   systemctl daemon-reload
   systemctl restart docker

- 关闭swap::

   swapoff /swap.img
   # 删除 /etc/fstab 中swap配置

- 修订 ``/etc/hosts`` 添加 ``minikube`` 的地址解析::

   192.168.101.81  minikube

.. note::

   添加IP解析可能不需要，待测试。不过默认 ``minikube start`` 有 WARNING 关于不能解析 minikube 提示

- 然后重新执行一次minikube安装::

   sudo minikube delete
   sudo minikube start

.. _minikube_debug_btrfs:

minikube btrfs安装排查
------------------------

再次启动minikube出现报错::

   [WARNING Hostname]: hostname "minikube" could not be reached
   [WARNING Hostname]: hostname "minikube": lookup minikube on 8.8.8.8:53: no such host
   [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
   error execution phase preflight: [preflight] Some fatal errors occurred:
   [ERROR SystemVerification]: unsupported graph driver: btrfs
   [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
   : running command: sudo /usr/bin/kubeadm init --config /var/lib/kubeadm.yaml  --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests,DirAvailable--data-minikube,FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml,FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml,FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml,FileAvailable--etc-kubernetes-manifests-etcd.yaml,Port-10250,Swap
   .: exit status 1

这里可以参考 `Kubernetes on Ubuntu 16.04 <https://marc.wäckerlin.ch/computer/kubernetes-on-ubuntu-16-04>`_ 增加一个启动参数 ``--skip-preflight-checks`` ::

   sudo kubeadm init --skip-preflight-checks

参考 `Support for 1.12.1 #42 <https://github.com/kairen/kubeadm-ansible/issues/42>`_ 对于minikube传递参数是 ``--ignore-preflight-errors`` 就对等于 kubeadmin 参数 ``--skip-preflight-checks``

.. note::

   参考minikube文档 `vm-driver=none <https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md>`_ :

   Some versions of Linux have a version of docker that is newer then what Kubernetes expects. To overwrite this, run minikube with the following parameters: ``sudo -E minikube start --vm-driver=none --kubernetes-version v1.11.8 --extra-config kubeadm.ignore-preflight-errors=SystemVerification``

即执行::
 
   sudo minikube start --extra-config kubeadm.ignore-preflight-errors=SystemVerification

.. note::

   我为了能够免去这个参数输入，参考 :ref:`install_docker_in_studio` 中 ``/etc/docker/dameon.json`` 配置方法，尝试修订 ``~/.minikube/config/config.json`` ::
   
      {
          "extra-config": ["kubeadm.ignore-preflight-errors=SystemVerification"],
          "vm-driver": "none"
      }   
   
   但是，这个方法无效。参考 ``minikube config -h`` 输出提示可用的 ``Configurable fields`` 并没有包含 ``extra-config`` 。
   
   参考 `On Minikube Profiles <https://medium.com/faun/using-minikube-profiles-def2477e968a>`_ ，可以minikube的profile是 ``~/.minikube/profiles/minikube/config.json`` ，这个配置是minikube初始化根据系统环境自动配置的环境变量。例如，包含了检测出我的主机的网卡接口IP地址是 ``192.168.101.81`` 。
   
   根据上述信息启发，搜索看到 ``~/.minikube/machines/minikube/config.json`` 包含了主机的配置信息，其中包含了 ``HostOptions`` 中就有一个配置项是 ``"StorageDriver": "",`` ，会不会这个配置项就是可以设置 ``btrfs`` 呢？
   
   但是这个 ``~/.minikube/machines/minikube/config.json`` 每次 ``minikube delete`` 会清理掉。实在没有办法，只好老老实实按照官方文档操作。

启动kubelet失败
-----------------

- 在忽略了 SystemVerification 之后，启动发现 kubelet 失败::

   [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
   [kubelet-check] Initial timeout of 40s passed.
   [kubelet-check] It seems like the kubelet isn't running or healthy.
   [kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get http://localhost:10248/healthz: dial tcp 127.0.0.1:10248: connect: connection refused.

检查kubelet::

   systemctl status kubelet
   journalctl -xeu kubelet

关键报错如下::

   Jun 11 14:01:52 xcloud kubelet[21142]: F0611 14:01:52.353546   21142 server.go:266] failed to run Kubelet: 
   failed to create kubelet: 
   misconfiguration: kubelet cgroup driver: "cgroupfs" is different from docker cgroup driver: "systemd"

参考 `kubelet failed with kubelet cgroup driver: “cgroupfs” is different from docker cgroup driver: “systemd” <https://stackoverflow.com/questions/45708175/kubelet-failed-with-kubelet-cgroup-driver-cgroupfs-is-different-from-docker-c>`_  只需要再增加一个参数 ``--extra-config=kubelet.cgroup-driver=systemd`` 来启动 minikube 就可以::

   sudo minikube start --extra-config kubeadm.ignore-preflight-errors=SystemVerification --extra-config kubelet.cgroup-driver=systemd

也可以修订 ``/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`` 将 ``ExecStart=`` 启动行配置 中的 ``--cgroup-driver=cgroupfs`` 修改成 ``--cgroup-driver=systemd`` ::

   ExecStart=/usr/bin/kubelet --allow-privileged=true --authorization-mode=Webhook --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --cgroup-driver=systemd --client-ca-file=/var/lib/minikube/certs/ca.crt --cluster-dns=10.96.0.10 --cluster-domain=cluster.local --container-runtime=docker --fail-swap-on=false --hostname-override=minikube --kubeconfig=/etc/kubernetes/kubelet.conf --pod-manifest-path=/etc/kubernetes/manifests 

然后再次执行::
 
   sudo systemctl start kubelet.service

就能启动 kubelet 成功。

不过，请注意，由于 ``minikube start`` 首次初始化时候会重新生成新的 ``/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`` ，所以第一次启动还是需要传递参数的，即::

   sudo minikube start --extra-config kubeadm.ignore-preflight-errors=SystemVerification --extra-config kubelet.cgroup-driver=systemd

使用 ``systemd-resolv`` 配置传递
-----------------------------------

根据 minikube文档 `vm-driver=none <https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md>`_ 说明，运行在 Ubuntu 18.04 或其他默认配置了 ``systemd-resolve`` 的系统，需要绕过默认的 ``resolv.conf`` ，所以启动参数需要增加 ``--extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf`` 。

完整启动命令修订成::

   sudo minikube start --extra-config kubeadm.ignore-preflight-errors=SystemVerification --extra-config kubelet.cgroup-driver=systemd --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf

操作系统启动时启动minikube
=============================

安装了minikube的系统，默认会激活 ``kubelet.service`` ，即在启动操作系统时会自动启动服务器上所有kubernetes的容器，也就是自动启动minikube。但是，由于我们上述配置的裸物理机运行minikube，并且使用btrfs文件系统，所以需要定制一些参数传递给kubelet，否则启动后会发现自动启动的minikube无法工作。

参考 `Cconfigure kubelets using kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/#configure-kubelets-using-kubeadm>`_ 修订kubelet配置文件 ``/var/lib/kubelet/kubeadm-flags.env`` ，将默认的配置内容::

   KUBELET_KUBEADM_ARGS=--cgroup-driver=systemd --hostname-override=minikube --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1 --resolv-conf=/run/systemd/resolve/resolv.conf

修订成::

   KUBELET_KUBEADM_ARGS=--cgroup-driver=systemd --hostname-override=minikube --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1 --resolv-conf=/run/systemd/resolve/resolv.conf --ignore-preflight-errors=SystemVerification 

然后重启系统就可以看到随着操作系统启动，systemd可以正确启动minikube。
   
.. _minikube_dashboard:

启动dashboard
=================

:ref:`kubernetes_dashboard` 可以帮助我们管理集群，在minikube上也可以启用方便管理。

- 执行以下命令启用dashboard::

   minikube dashboard

.. note::

   出现报错::

      ...
      Verifying proxy health ...
      http://127.0.0.1:49983/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ is not responding properly: Temporary Error: unexpected response code: 503
      ...

    这个报错是因为没有启动代理导致的，所以在执行 ``minikube dashboard`` 之前，需要先执行 ``kubectl proxy`` 指令，这样就能打开正确的监控页面。
