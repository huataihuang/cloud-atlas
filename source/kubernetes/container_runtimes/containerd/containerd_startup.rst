.. _containerd_startup:

===================
containerd快速起步
===================

如果你开始部署 Kubernetes 1.24 ，你或许会和我一样，惊讶地发现 Kubernetes 从 1.24 开始移除了Docker支持，而直接采用原生 CRI 的container runtime，如 ``containerd`` 。这个转变带来了经验上的转变，也就是在部署Kubernetes前，不是部署Docker，而是部署 ``container runtime`` 。

containerd是常用的容器运行时，有以下3种方式安装:

- :ref:`install_containerd_official_binaries`
- :ref:`install_containerd.io_packages`
- 源代码编译安装containerd



参考
======

- `Getting started with containerd <https://github.com/containerd/containerd/blob/main/docs/getting-started.md>`_
