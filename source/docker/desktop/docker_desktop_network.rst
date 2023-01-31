.. _docker_desktop_network:

=========================
Docker Desktop网络
=========================

Docker Desktop通用平台功能
===========================

在 Docker Desktop for :ref:`windows` / :ref:`linux` / ref:`macos` 各个平台都有一些共有的网络功能：

VPN 直通
----------

Docker Desktop 网络可以直接附加到一个VPN上，此时 Docker Desktop 拦截来自容器的流量并将其注入主机，就好像他是来自Docker应用程序一样。在外部看来，就是Docker应用程序在使用VPN，外部不知道Dcoker应用程序中还运行了不同的容器。

端口映射(Port Mapping)
------------------------

在运行容器时使用 ``-p`` 参数可以映射端口::

   docker run -p 80:80 -d nginx

Docker Desktop 将物理主机的 ``localhost`` 端口80和容器端口80做了端口映射(Port Mapping)，这样访问物理主机的 ``localhost:80`` 就能直接访问容器的 ``80`` 端口。当然，如果物理主机的 ``80`` 端口事先已经被其他应用占用，则可以使用其他本地主机端口，例如 ``localhost:8080`` 映射到容器端口 ``80`` ::

   docker run -p 8080:80 -d nginx

:ref:`docker_proxy`
---------------------

Docker Desktop for Mac 和 Liinux的特定功能
============================================

SSH agent转发
--------------

在 Mac 和 Linux 上的 Docker Desktop 允许在容器内部使用host主机的 SSH agent，也就是将host主机的SSH agent socket 绑定到容器内部::

   docker run ... --mount type=bind,src=/run/host-services/ssh-auth.sock,target=/run/host-services/ssh-auth.sock

然后在容器内部添加一个 ``SSH_AUTH_SCOCK`` 环境变量::

   -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock"

Docker Desktop的限制
======================

host主机没有 ``docker0`` 网桥
-------------------------------

由于 ``Docker Desktop`` 实际是一个Linux 虚拟机，所以在host主机上是看不到 ``docker0`` 网桥的，这个网桥在Linux虚拟机内部( :ref:`docker_macos_vm` )

尴尬: 不能ping容器
---------------------

正因为 host主机没有 ``docker0`` 网桥，所以在host主机上其实无法直接访问Linux虚拟机内部的容器(包括我构建的 :ref:`kind` 各个工作节点(容器) )。

**解决** Docker Desktop网络限制
================================

要像常规Linux上运行Docker容器一样访问Docker容器的服务，唯一的方法是使用 ``端口映射(Port Mapping)`` ，例如 :ref:`docker_macos_kind_port_forwarding`

参考
======

- `docker docs: Docker Desktop >> Additional resources >> Explore networking features <https://docs.docker.com/desktop/networking/>`_
