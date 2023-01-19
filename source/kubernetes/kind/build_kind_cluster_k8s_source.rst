.. _build_kind_cluster_k8s_source:

==============================
从Kubernetes源代码构建Kind集群
==============================

我在 :ref:`debug_mobile_cloud_x86_kind_create_fail` 需要解决当前kind release版本镜像尚未加入支持 :ref:`zfs` ，但是 `GitHub: kind <https://github.com/kubernetes-sigs/kind>`_ 的最新git仓库代码已经修复。

.. warning::

   我最初以为本文方式是能够解决 :ref:`debug_mobile_cloud_x86_kind_create_fail` ，也就是将 `kind "base" image <https://kind.sigs.k8s.io/docs/design/base-image>`_ 中增加上 ``zfs`` 工具。但是实践下来发现，这个过程是自己编译 :ref:`kubernetes` 版本，基础镜像不变。也就是说，本文方法可以用来定制kind，指定 Kubernetes 版本(根据clone出来Kubernetes可以切换tag版本)，但是不解决基础镜像中添加``zfs``
   工具(没有从kind源代码编译基础镜像)

   不过，本文实践还是有意义的，了解了kind如何编译Kubernetes，后续可以用这个方法来自己测试不同版本Kubernetes

.. note::

   编译Kubernetes node镜像需要上游Kubernetes编译的所有工具，kind社区已经包装了上游build工具，也包括了Docker with buildx

   Kubernetes编译的所有工具可以参考 `Building Kubernetes with Docker <https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-with-docker>`_

.. note::

   编译Kubernetes需要8GB内存和50GB磁盘空间，我通过 :ref:`zfs_startup` 步骤将整个 ``/home`` 目录迁移到ZFS存储中来准备好足够的编译空间

.. note::

   我在2023年1月19日构建，此时Kubernetes刚刚发布了 v1.26.1

- 通过以下方式安装 ``buildx`` 插件(必须，否则build报错，见下文异常排查部分):

.. literalinclude:: build_kind_cluster_k8s_source/install_docker_buildx_plugin
   :language: bash
   :caption: 为docker安装buildx插件

- 下载Kubernetes源代码 ``$(go env GOPATH)/src/k8s.io/kubernetes`` ，然后构建镜像:

.. literalinclude:: build_kind_cluster_k8s_source/kind_build_node-image
   :language: bash
   :caption: 下载Kubernetes源代码并构建kind的node镜像

``kind build node-image`` 异常排查
=====================================

buildx插件问题
------------------

报错，显示 ``docker`` 不能识别参数 ``--load`` ::

   To retry manually, run:

   DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --load -t kube-build:build-718ad5336b-5-v1.25.0-go1.19.5-bullseye.0 --pull=false --build-arg=KUBE_CROSS_IMAGE=registry.k8s.io/build-image/kube-cross --build-arg=KUBE_CROSS_VERSION=v1.25.0-go1.19.5-bullseye.0 /home/huatai/go/src/k8s.io/kubernetes/_output/images/kube-build:build-718ad5336b-5-v1.25.0-go1.19.5-bullseye.0

   !!! [0119 19:51:00] Call tree:
   !!! [0119 19:51:00]  1: build/release-images.sh:39 kube::build::build_image(...)
   make: *** [Makefile:450: quick-release-images] Error 1
   Failed to build Kubernetes: failed to build images: command "make quick-release-images 'KUBE_EXTRA_WHAT=cmd/kubeadm cmd/kubectl cmd/kubelet' KUBE_VERBOSE=0 KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PLATFORMS=linux/amd64" failed with error: exit status 2
   ERROR: error building node image: failed to build kubernetes: failed to build images: command "make quick-release-images 'KUBE_EXTRA_WHAT=cmd/kubeadm cmd/kubectl cmd/kubelet' KUBE_VERBOSE=0 KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PLATFORMS=linux/amd64" failed with error: exit status 2
   Command Output: +++ [0119 19:51:00] Verifying Prerequisites....
   +++ [0119 19:51:00] Building Docker image kube-build:build-718ad5336b-5-v1.25.0-go1.19.5-bullseye.0
   +++ Docker build command failed for kube-build:build-718ad5336b-5-v1.25.0-go1.19.5-bullseye.0

   unknown flag: --load
   See 'docker --help'.

参考 `Fails to build 1.21.0 node image - docker buildx now required #2188 <https://github.com/kubernetes-sigs/kind/issues/2188>`_  和 `` :

buildx isn't actually part of moby, but Docker Inc. ships it as part of their Docker packages in their PPA. It's a separate tool with a separate code repo.

通过以下方式安装 ``buildx`` 插件:

.. literalinclude:: build_kind_cluster_k8s_source/install_docker_buildx_plugin
   :language: bash
   :caption: 为docker安装buildx插件

现在能够识别 ``--load`` ，开始build

.. note::

   build过程需要下载的网址很多已经被GFW屏蔽，我采用 :ref:`docker_proxy` 但是没有解决docker服务器https代理需要证书的问题，所以改为采用 :ref:`ocserv` 解决下载问题

参考
=====

- `GitHub: kubernetes-sigs / kind <https://github.com/kubernetes-sigs/kind>`_
- `Kind: Building Images <https://kind.sigs.k8s.io/docs/user/quick-start#building-images>`_
