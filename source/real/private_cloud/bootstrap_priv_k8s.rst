.. _bootstrap_priv_k8s:

========================
引导私有云Kubernetes
========================

集群选型
==============

部署Kubernetes，通常有3种模式：

- 单节点Kubernetes: 通过单台服务器，运行minikube，不提供任何容灾能力

- 单个master多个woker集群：管控平面只部署一台服务器，工作节点至少2台，提供了一定的工作节点容灾能力。最少3太服务器(1master2worker)


- 3个master多个worker集群：管控平面部署3台服务器，工作节点至少2台，同时具备了master和worker节点的容灾能力。最少5台服务器(3master2worker)

  - 随着规模扩大，可以水平扩展worker节点
  - 要进一步提高master节点稳定性和性能，可以将 ``etcd`` 抽取出来独立部署，则管控平面增加到6台服务器，而woker节点可以水平扩展到5000+。

.. figure:: ../../_static/kubernetes/kubeadm-ha-topology-stacked-etcd.svg
   :scale: 45

.. figure:: ../../_static/kubernetes/kubeadm-ha-topology-external-etcd.svg
   :scale: 45
    
.. note::

   详细高可用kubernetes集群部署参考 :ref:`ha_k8s`

我的私有云选型
---------------

从集群稳定性和扩展性来说，推荐采用 :ref:`ha_k8s_external` 部署模式：

- kubernetes的管控组件和etcd分别部署在不同服务器，单节点故障影响从1/3降低到1/6
- 运维管理简化，拓扑清晰
- etcd和apiserver都是管控平面非常消耗资源的组件，通过分离etcd部署提升了管控平面整体性能

但是，我的私有云由于资源限制，只有3台物理服务器，所以我采用了一种混合虚拟化和容器的部署架构：

- 管控平面服务器(kubernetes master)运行在KVM虚拟机(每个物理服务器上运行一个虚拟机)

  - 共计3台KVM虚拟机，对外提供apiserver服务
  - 物理网络连接Kubernetes worker节点，管理运行在物理节点上的worker nodes
  - 可以节约服务器占用，同时KVM虚拟机可以平滑迁移

- etcd服务器运行在物理主机上

  - etcd是整个kubernetes集群的数据存储，不仅需要保障数据安全性，而且要保证读写性能

.. note::

   最初我考虑采用OpenStack来运行Kubernetes管控服务器，但是OpenStack构建和运行复杂，Kubernetes依赖OpenStack则过于沉重，一旦出现OpenStack异常会导致整个Kubernetes不可用。

   基础服务部署着重于稳定和简洁，依赖越少越好：并不是所有基础设施都适合云化(OpenStack)或者云原生(Kubernetes)，特别是BootStrap的基础服务，使用物理裸机来运行反而更稳定更不容易出错。

- Kubernetes的worker nodes直接部署在3台物理服务器上

  - 裸物理服务器运行Docker容器，可以充分发挥物理硬件性能
  - :ref:`ceph` 直接运行在物理服务器，提供OpenStack对象存储和Kubernetes卷存储，最大化存储性能
  - 网络直通，最大化网络性能

.. note::

   整个似有网络仅使用 ``3台物理服务器`` 。如果你缺少服务器资源，也可以采用KVM虚拟机来实践部署，即采用完全的OpenStack集群(单机或多机都可以)，在OpenStack之上运行Kubernetes。

   拓扑图待补充

.. note::

   我采用这种混合OpenStack和Kubernetes的架构主要是为了充分发挥硬件性能同时节约物理服务器资源。如果是在面向公共用户的共有云环境，会采用OpenStack嵌套Kubernetes的架构：

   - 通过OpenStack KVM虚拟化提供的强隔离，避免租户之间的影响和安全隐患
   - 通过Kubernetes提供给用户轻量级和灵活的应用部署能力
   - 缺点是虚拟化对资源的消耗较大，浪费了一部分物理服务器计算资源
   - 优点是获得了高安全性，并且具备了虚拟化热迁移的高可用能力

安装Docker运行环境
====================

- 在 workerX 各服务器 (请参考 :ref:`real_prepare` 分配物理主机列表 ``hosts`` 文件) 上安装Docker环境::

   # 安装必要软件包
   yum install yum-utils device-mapper-persistent-data lvm2

   # 添加Docker仓库，注意必须是Docker-CE
   yum-config-manager \
     --add-repo \
     https://download.docker.com/linux/centos/docker-ce.repo

   # 安装Docker CE
   yum update && yum install docker-ce

.. note::

   在 :ref:`docker_btrfs_driver` 中，我是在Studio环境部署Ubuntu 18操作系统，由于内核4.x已经支持了btrfs文件系统，目前Docker官方文档仅在Ubuntu/Debian中推荐使用btrfs。但是，我实际测试发现稳定性可能还存在问题。

   CentOS/RHEL 7.x开始已经放弃了btrfs，官方推荐采用XFS。

- 设置Docker的配置::

   # 默认安装 /etc/docker 目录不存在，需要创建
   mkdir /etc/docker

   # 设置Daemon
   cat > /etc/docker/daemon.json <<EOF
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "overlay2",
     "storage-opts": [
       "overlay2.override_kernel_check=true"
     ]
   }
   EOF

   mkdir -p /etc/systemd/system/docker.service.d

- 重启Docker服务::

   # Restart Docker
   systemctl daemon-reload
   systemctl restart docker

.. note::

   如果这里docker启动失败，请使用 ``systemctl status docker`` 和 ``journalctl -xe`` 检查启动日志。我遇到的问题是 ``network controller`` 初始化失败::

      Jul 23 20:16:17 worker4.huatai.me dockerd[16518]: failed to start daemon: Error initializing c: list bridge addresses failed: PredefinedLocalScopeDefaultNetworks List: [172.17.0.0/16 172.18.0.0/16 172.19.0.0/16 172.20.0.0/1]

   参考 `Error starting daemon: Error initializing network controller: list bridge addresses failed: no available network #123 <https://github.com/docker/for-linux/issues/123#issuecomment-346546953>`_ 创建 ``docker0`` 网桥::

      ip link add name docker0 type bridge
      ip addr add dev docker0 172.17.0.1/16
   
   就可以正常启动 ``docker`` 服务。

服务器环境
===========

- 关闭SELinux::

   setenforce 0

并且修改 ``/etc/sysconfig/selinux`` 设置 ``SELINUX=disabled`` 确保操作系统重启后依然禁用SELinux。

- 执行以下命令确保iptables不会被绕过::

   cat <<EOF >  /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   EOF
   sysctl --system

- 确保 ``br_netfilter`` 模块已经加载::

   lsmod | grep br_netfilter

安装软件包
==============

- 按照服务器环境CentOS 7安装软件包::

   cat <<EOF > /etc/yum.repos.d/kubernetes.repo
   [kubernetes]
   name=Kubernetes
   baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
   EOF
   
   # Set SELinux in permissive mode (effectively disabling it)
   setenforce 0
   sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
   
   yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
   
   systemctl enable --now kubelet


.. note::

   安装会遇到GFW阻碍，所以请参考 :ref:`openconnect_vpn` 搭好翻墙梯子之后再执行安装。

配置管控节点cgroup驱动
=======================

在使用Docker的环境中，kubeadm可以为kubelet自动检测到cgroup driver，并在运行时设到 ``/var/lib/kubelet/kubeadm-flags.env`` ，所以在我们的部署环境中不需要设置 ``cgroup-driver`` 值。

参考
=======

- `Container runtimes <https://kubernetes.io/docs/setup/production-environment/container-runtimes/>`_
- 
