.. _kind_startup:

=============================
Kind快速起步
=============================

安装kind
============

.. note::

   本段落安装实践在 :ref:`asahi_linux` ( :ref:`arm` 架构 )上完成，但方法是通用的，适合不同的Linux发行版

使用 :ref:`golang` 安装
--------------------------

对于 :ref:`golang` 开发人员来说，使用 ``go get`` / ``go install`` 是最方便的方法:

.. literalinclude:: kind_startup/go_install_kind
   :language: bash
   :caption: 使用go install命令安装kind

.. note::

   其实也不是 ``最方便`` ，因为有万恶的GFW存在，通过 ``go install`` 会遇到网络超时，请采用以下方法之一规避:

   - 部署 :ref:`openconnect_vpn` 或者 :ref:`deploy_wireguard`
   - :ref:`go_proxy` (socks代理) 结合 :ref:`ssh_tunneling_dynamic_port_forwarding`
   - :ref:`go_proxy` (http代理) 结合 :ref:`squid_socks_peer` (两级代理本质也是采用 ssh tunneling，但是提供了本地代理缓存，适合大规模网络)

安装目录位于 ``~/go/bin/kind`` ，可以在 ``~/.bashrc`` 中添加 golang 环境变量:

.. literalinclude:: kind_startup/go_env
   :language: bash
   :caption: 配置go环境变量以便能够使用 kind

.. note::

   可参考 `“go build” and “go install” <https://github.com/NanXiao/golang-101-hacks/blob/master/posts/go-build-vs-go-install.md>`_

完成安装后，可以直接部署 :ref:`kind_cluster` (下文的 "创建集群" 段落只是一个快速demo)

二进制安装kind(记录未实践)
---------------------------

`kind release <https://github.com/kubernetes-sigs/kind/releases>`_ 提供了不同架构下的二进制执行程序，可以直接下载使用:

- Linux x86_64平台安装:

.. literalinclude:: kind_startup/linux_install_kind_release_amd64
   :language: bash
   :caption: 在Linux x86_64平台上安装kind

- 在 :ref:`macos` 上安装:

.. literalinclude:: kind_startup/macos_install_kind_release
   :language: bash
   :caption: 在macOS平台上安装kind

安装kind(归档)
================

.. note::

   本段落安装方法是早期我的实践笔记，已废弃。当前(2022年11月)的安装方法见上文

运行环境准备
----------------

为了达到最佳性能和功能，我在 Docker in Docker 的测试运行环境中，采用的是:

- CentOS 8 - 可以直接 :ref:`install_centos8` 或者 :ref:`upgrade_centos_7_to_8`
- Docker-CE最新版本 - :ref:`install_docker_centos8` 这里我采用docker-ce最新版本::

   dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
   dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.2.el7.x86_64.rpm
   dnf install docker-ce
   systemctl enable --now docker

- Go最新版本 - :ref:`install_golang` 源代码编译KIND需要go 1.14以上版本支持

安装
------

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
