.. _docker_20.10:

=====================
Docker 20.10
=====================

从 Docker Engine 20.10开始支持 :ref:`cgroup_v2` ，提供了精细的io隔离功能。舍弃了之前在 cgroups v1 提供的 ``blkio-weight`` 选项，原因是 Kernel v5.0开始舍弃支持 cgroups v1 的blkio-weight选项 ( blkio.weight was removed in kernel 5.0:  `torvalds/linux@f382fb0 <https://github.com/torvalds/linux/commit/f382fb0bcef4c37dc049e9f6963e3baf204d815c>`_ )。

Docker 20.10.0 是2020年12月9日发布的，得到了CentOS 8和Fedora的支持，提供了包括 Rootless 模式的很多功能。这是自2019年7月22日发布的Docker 19.03.0以来第一个重要版本。

默认可用于CentOS firewalld
=============================

在CentOS 8上的Docker 19.03容器存在解析主机名和输出端口问题，原因是Docker 19.03不能自动设置firewalld，需要手工配置CentOS的firewalld来运行Docker。这个问题已经在Docker 20.10上得到解决，现在可以在CentOS 8上自如安装和使用Docker。

在Fedora上默认启用 :ref:`cgroup_v2`
=====================================

Docker 19.03不支持cgroup v2，而Fedora 31开始默认使用的是 :ref:`cgroup_v2` ，所以当时需要强制切换成 :ref:`cgroup_v1` 来运行Docker。而Docker 20.10支持 :ref:`cgroup_v2` ，所以可以按照Fedora默认的cgroup方式工作。

支持 :ref:`docker_rootless`
================================

:ref:`rootless_container` 指整个Docker环境，包括啊Docker Daemon和容器都是不使用root权限的。Docker 20.10开始支持Rootlesss，并且在不断改进。

Rootless模式下支持资源限制
-----------------------------

之前由于缺乏cgroup支持，Docker 19.03不能在Rootless模式下支持资源限制(如 ``docker run --cpus`` , ``docker run --memory`` , ``docker run --pids-limit`` 等等)，而现在的Docker 20.10则通过 :ref:`cgroup_v2` 支持在 :ref:`docker_rootless` 设置资源限制。

Rootless模式下支持FUSE-OverlayFS
----------------------------------

除了Ubuntu和Debian外，大多数主机操作系统都不支持没有root权限的挂载OverlayFS，这导致Rootless Docker 19.03如果运行在非Ubuntu/非Debian主机下不能使用OverlayFS来避免重复文件。

现在Dcoker 20.10支持 :ref:`fuse-overlayfs` ，这样就可以在任何内核版本 >= 4.18的主机上使用非特权OverlayFS。Docker 20.10会在 OverlayFS 不能工作但FUSE-OverlayFS可以工作的情况下自动使用FUSE-OverlayFS。

支持RPM/DEB方式安装Rootless
------------------------------

早起的Docker 19.03的RPM和DEB安装包没有包含运行Rootless模式的二进制程序，需使用 https://get.docker.com/rootless 在 ``$HOME`` 中安装Rootless Docker。而现在Docker 20.10发行版RPM/DEB包已经包含了安装rootless的脚本::

   dockerd-rootless-setuptool.sh install

这个工具不是在 ``$HOME`` 目录安装任何二进制程序，而是在 ``$HOME/.config/systemd/user`` 目录下安装 ``systemd`` unit。此时可以通过 ``$DOCKER_HOST`` 变量设置来启动一个Docker客户端::

   export DOCKER_HOST=unix://$XDR_RUNTIME_DIR/docker.sock
   docker run hello-world

Dockerfile: RUN --mount=type=(cache|secret|ssh|…) 
==================================================

Docker 20.10 已经将早期版本(18.06/18.09)引入的实验性指令 ``docker run --mount=type=cache`` / ``docker run --mount=type=secret`` 以及 ``docker run --mount=type=ssh`` 完善到接近发布阶段，不过依然需要激活 :ref:`buildkit` ( ``export DOCKER_BUILDKIT=1`` )。这些指令可以用来挂载包管理器缓存、证书和ssh凭证。

漏洞扫描
===========

Docker提供收费的镜像漏洞扫描功能，不过，开源的 :ref:`trivy` 可以实现相同功能


参考
======

- `Docker Engine 20.10 Released: Supports cgroups v2 and Dual Logging <https://www.infoq.com/news/2021/01/docker-engine-cgroups-logging>`_
- `deprecate blkio-weight options with cgroups v1 #2908 <https://github.com/docker/cli/pull/2908>`_
- `New features in Docker 20.10 (Yes, it’s alive) <https://medium.com/nttlabs/docker-20-10-59cc4bd59d37>`_
