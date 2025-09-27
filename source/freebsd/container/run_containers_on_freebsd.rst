.. _run_containers_on_freebsd:

=================================
在FreeBSD上运行Container容器
=================================

.. note::

   可以在 :ref:`macos` 上通过 :ref:`lima` 来运行FreeBSD虚拟机

   但是在FreeBSD上可能更自由，所以有了本文的实践

Linux容器
==========

- 如果能够通过 Linux emulation 运行 ``runj`` 来实现在 :ref:`freebsd_jail` 中运行Docker容器以及网络，那么就有可能直接运行 :ref:`kind` ，而不需要 :ref:`bhyve` 来虚拟化(可以降低主机资源消耗)
- 实在不行还是可以通过运行一个 :ref:`bhyve` 虚拟机来运行 :ref:`kind` ，虽然比较挫，但是 :ref:`kind` 也是通过这种方式运行在 :ref:`macos` 上的
- 可以找到通过 :ref:`bhyve` 运行多个虚拟机来部署 :ref:`kubernetes` 的案例:

  - `Deploy Kubernetes cluster on FreeBSD/bhyve (CBSD) <https://www.bsdstore.ru/en/articles/cbsd_k8s_part1.html>`_
  - `Kubernetes on FreeBSD with Linux worker nodes and Cilium <https://medium.com/@norlin.t/kubernetes-on-freebsd-with-linux-worker-nodes-and-cilium-a87c50daef03>`_

FreeBSD原生容器
=================

之所以无法在FreeBSD上直接运行 :ref:`docker` 是因为Docker使用的一些技术如 :ref:`cgroup` 和 kernel namespaces 都没有在FreeBSD内核中实现，并且 :ref:`linuxulator` 兼容层并没有在 :ref:`freebsd_jail` 环境提供这些底层功能。

但是在FreeBSD系统中，也有一些原生技术提供了相似的功能，并且也有非常接近于Docker的 :ref:`podman` 被移植到FreeBSD架构:

- 在FreeBSD环境中，Podman使用了一种称为 ``ocijail`` 的FreeBSD原生运行时来管理容器，底层使用的是FreeBSD Host主机的 :ref:`freebsd_jail` 架构
- 通过简单的 ``pkg install sysutils/podman-suite`` 就可以轻易地完成部署
- 移植到FreeBSD架构的 Podman 使用了FreeBSD :ref:`zfs` snapshots 来有效管理存储

此外 :ref:`freebsd_appjail` 也提供了类似 :ref:`docker` 的使用体验，通过提供OCI接口实现了镜像化，也值得尝试

OCI Containers on FreeBSD
-----------------------------

FreeBSD从 14.2-RELEASE 开始，提供了OCI兼容镜像， :ref:`freebsd_podman` 可以直接使用该镜像，包括amd64系统和arm64系统，能够实现标准的容器化运行。在每个RELEASE下载中都提供了 `FreeBSD OCI-IMAGES <https://download.freebsd.org/releases/OCI-IMAGES/>`_ 下载，并且分别提供3种 ``base.txz`` 包:

.. literalinclude:: run_containers_on_freebsd/freebsd_oci_image
   :caption: 每个RELEASE提供了3种OCI镜像

- ``static`` 镜像是最小化工作系统，如果你使用静态编译的二进制程序，则只能运行使用static镜像

  - 只有最基础系统
  - TLS证书
  - 最小化termcap
  - tzdata文件
  - 只能够运行静态编译二进制程序

- ``dynamic`` 镜像是在 ``static`` 镜像作为父级层，然后添加了足够运行共享库和libc的执行程序

  - 能够运行大多数二进制程序和工具
  - 但是不包括shell，也没有包管理器(意味着适合作为容器来运行服务程序，但不适合日常使用)

- ``minimal`` 镜像则在 ``dynamic`` 层上添加了普通用户所需要的 UNIX shell 以及包管理器

参考
=====

- `Fun with FreeBSD: Run Linux Containers on FreeBSD <https://productionwithscissors.run/2022/09/04/containerd-linux-on-freebsd/>`_
- `Docker-style networking for FreeBSD jails with runj <https://samuel.karp.dev/blog/2022/12/docker-style-networking-for-freebsd-jails-with-runj/>`_
- `A Brief Introduction to OCI Containers on FreeBSD <https://people.freebsd.org/~dch/posts/2024-12-04-freebsd-containers/>`_
