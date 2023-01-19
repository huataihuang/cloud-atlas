.. _build_kind_cluster_k8s_source:

==============================
从Kubernetes源代码构建Kind集群
==============================

我在 :ref:`debug_mobile_cloud_x86_kind_create_fail` 需要解决当前kind release版本镜像尚未加入支持 :ref:`zfs` ，但是 `GitHub: kind <https://github.com/kubernetes-sigs/kind>`_ 的最新git仓库代码已经修复。解决的方法是使用kind的源代码自己构建Kind镜像

.. note::

   编译Kubernetes node镜像需要上游Kubernetes编译的所有工具，kind社区已经包装了上游build工具，也包括了Docker with buildx

   Kubernetes编译的所有工具可以参考 `Building Kubernetes with Docker <https://github.com/kubernetes/community/blob/master/contributors/devel/development.md#building-kubernetes-with-docker>`_

.. note::

   编译Kubernetes需要8GB内存和50GB磁盘空间，我通过 :ref:`zfs_startup` 步骤将整个 ``/home`` 目录迁移到ZFS存储中来准备好足够的编译空间

.. note::

   我在2023年1月19日构建，此时Kubernetes刚刚发布了 v1.26.1

- 下载Kubernetes源代码 ``$(go env GOPATH)/src/k8s.io/kubernetes`` ，然后构建镜像:

.. literalinclude:: build_kind_cluster_k8s_source/kind_build_node-image
   :language: bash
   :caption: 下载Kubernetes源代码并构建kind的node镜像

这里出现报错，显示 ``docker`` 不能识别参数 ``--load`` ::

   Starting to build Kubernetes
   +++ [0119 17:56:02] Verifying Prerequisites....
   +++ [0119 17:56:02] Building Docker image kube-build:build-718ad5336b-5-v1.26.0-go1.19.5-bullseye.0
   +++ Docker build command failed for kube-build:build-718ad5336b-5-v1.26.0-go1.19.5-bullseye.0

   unknown flag: --load
   See 'docker --help'.
   ...

参考 `Fails to build 1.21.0 node image - docker buildx now required #2188 <https://github.com/kubernetes-sigs/kind/issues/2188>`_

参考
=====

- `GitHub: kubernetes-sigs / kind <https://github.com/kubernetes-sigs/kind>`_
- `Kind: Building Images <https://kind.sigs.k8s.io/docs/user/quick-start#building-images>`_
