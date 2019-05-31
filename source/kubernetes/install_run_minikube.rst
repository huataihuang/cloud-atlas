.. _install_run_minikube:

======================
安装和运行minikube
======================

minikube
=================

最简单体验完整的Kubernetes集群功能是使用 `minikube <https://github.com/kubernetes/minikube>`_ ，这是一个在单个节点上运行Kubernetes的方式，可以用于测试Kubernetes以及本地开发应用。

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

   但是参考

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
