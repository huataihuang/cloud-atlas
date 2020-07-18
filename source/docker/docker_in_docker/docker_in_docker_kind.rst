.. _docker_in_docker_kind:

=============================
Docker in Docker部署工具kind
=============================

在 :ref:`docker_in_docker_arch` 中，可以通过一个单节点Docker主机运行多个Docker容器，而在Docker容器中运行Docker容器。这种方式可以模拟出一个大规模的Kubernetes集群。

在早期的GitHub项目 `Mirantis/kubeadm-dind-cluster <https://github.com/Mirantis/kubeadm-dind-cluster>`_ 上发展出一个非常灵活的 `本地Kubernetes集群部署工具kind <https://kind.sigs.k8s.io>`_ ，简单的命令就能够在一台物理机上构建出多个Kubernetes集群，完全模拟生产环境部署。这对Kubernetes开发、测试、部署演练有非常大的帮助。

.. figure:: ../../_static/docker/docker_in_docker/docker_in_docker_kind.png
   :scale: 40

   Kind的Logo是一个非常形象化的漂流瓶里的Kubernetes/Docker集装箱船模型

运行环境准备
=============

为了达到最佳性能和功能，我在 Docker in Docker 的测试运行环境中，采用的是:

- CentOS 8 - 可以直接 :ref:`install_centos8` 或者 :ref:`upgrade_centos_7_to_8`
- Docker-CE最新版本 - :ref:`install_docker_centos8` 这里我采用docker-ce最新版本::

   dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
   dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.2.el7.x86_64.rpm
   dnf install docker-ce
   systemctl enable --now docker

- Go最新版本 - :ref:`install_golang` 源代码编译KIND需要go 1.14以上版本支持

安装kind
=========

- 对于macOS/Linux可以直接下载官方提供的执行程序::

   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
   chmod +x ./kind
   mv ./kind /some-dir-in-your-PATH/kind

- 更为方便的是通过 :ref:`homebrew` 在Mac/Lknux上安装kind::

   brew install kind

创建集群
============

通过kind，可以非常方便创建集群，只需要一条命令::

   kind create cluster

以上命令将使用一个预先构建的 `node image <https://kind.sigs.k8s.io/docs/design/node-image>`_ 来 bootstrap 一个Kubernetes集群。在 docker hub 的 `kindest/node <https://hub.docker.com/r/kindest/node/>`_ 可以找到这个预先构建的node image。

这里下载镜像可能需要较长的时间，有可能导致超时，所以在 ``create cluster`` 命令加上 ``--wait`` 参数来指定超时时间，以便在``control plane`` 达到ready状态再运行 ``create cluster`` 。

注意，上述简单的命令默认创建的集群名字是 ``kind`` ，可以通过 ``--name`` 参数来指定集群名称。

此时提示信息::

   Creating cluster "kind" ...
    ✓ Ensuring node image (kindest/node:v1.18.2)
    ✓ Preparing nodes
    ✓ Writing configuration
    ✓ Starting control-plane
    ✓ Installing CNI
    ✓ Installing StorageClass
   Set kubectl context to "kind-kind"
   You can now use your cluster with:
   
   kubectl cluster-info --context kind-kind
   
   Have a nice day!

然后你可以 :ref:`install_setup_kubectl` ，然后验证部署的测试集群::

   kubectl cluster-info

可以看到集群信息::

   Kubernetes master is running at https://127.0.0.1:13773
   KubeDNS is running at https://127.0.0.1:13773/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

并且可以看到这个集群只有一个节点::

   kubectl get nodes

输出信息::

   NAME                 STATUS   ROLES    AGE    VERSION
   kind-control-plane   Ready    master   148m   v1.18.2

.. note::

   上述简单的部署kind，默认仅部署了单机集群，并没有体现出趣味。如果你更感兴趣是部署多节点集群，则可以参考 :ref:`kind_multi_node` 来部署一个完整的集群。

参考
=======

 - `kind Quick Start <https://kind.sigs.k8s.io/docs/user/quick-start/>`_
