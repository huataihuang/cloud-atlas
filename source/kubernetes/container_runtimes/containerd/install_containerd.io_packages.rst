.. _install_containerd.io_packages:

==========================
安装containerd.io软件包
==========================

最新的 Kubernetes 1.24 对 ``containerd`` 有较高的版本要求(1.6.4+/1.5.11+)，而ubuntu发行版20.04LTS提供的版本较为陈旧不能满足运行要求(见 :ref:`k8s_dnsrr` )。比较方便的方法是采用Docker官方软件仓库维护的 ``containerd.io`` 软件包，可以获得最新的 ``containerd`` 运行程序。Docker官方仓库维护了针对主要Linux发行版的安装包 (CentOS / :ref:`fedora` / Debian / :ref:`ubuntu_linux` )，而且提供了 x86 和 ARM 版本。

.. note::

   Docker 官方分发的DEB和RPM格式 ``containerd.io`` 并不是 ``containerd`` 开源项目提供的，但是提供了方便运维的软件仓库方式，所以通常运维使用可以使用这个发行渠道。

.. note::

   ``containerd.io`` 软件包包含了 ``runsc`` 但是没有包含CNI plugins

考虑到 Kubernetes 1.24 需要 ``containerd`` 以及 CNI plugins，我目前还是先采用 :ref:`install_containerd_official_binaries` 完成 :ref:`k8s_dnsrr` 所需的 :ref:`container_runtimes` ，后续根据实际需求再来做本文实践。

参考
========

- `Getting started with containerd <https://github.com/containerd/containerd/blob/main/docs/getting-started.md>`_
- `How To Setup A Three Node Kubernetes Cluster For CKA: Step By Step <https://k21academy.com/docker-kubernetes/three-node-kubernetes-cluster/>`_ 提供了使用Docker官方仓库单独安装containerd软件的方法
