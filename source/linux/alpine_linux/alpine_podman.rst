.. _alpine_podman:

=========================
Alpine Linux运行Podman
=========================

:ref:`podman` 是一个 ``libpod`` 库的工具，用于创建和维护容器。Podman(Pod Manager)是全功能的容器引擎，并且在Alpine Linux上，使用 :ref:`distrobox` 会自动依赖安装和使用 ``Podman``

安装
======

- 使用 :ref:`alpine_apk` 安装 ``community`` 仓库的 ``podman`` 软件包:

.. literalinclude:: alpine_podman/install
   :caption: 安装 podman

配置
=======

- 要实现podman的全部功能，需要激活 :ref:`cgroup` v2 服务 或 **unified** 模式(默认):

.. literalinclude:: alpine_podman/cgroup
   :caption: 启动 ``cgroups`` 服务

- 在 ``/etc/containers/storage.conf`` 中默认配置的存储驱动是 ``overlay`` ，如果在 **容器内部** 或 :ref:`btrfs` 文件系统中运行 ``podman`` ，则需要修改存储驱动为 ``vfs`` 或 ``btrfs``

以root身份运行
==================

无需任何特殊步骤就可以以 ``root`` 身份运行，以下是运行案例容器:

.. literalinclude:: alpine_podman/hello-world
   :caption: 以root运行无需配置

以rootless模式运行
=====================

为避免权限问题，建议使用 rootless podman，此时容器使用 ``crun`` (一个快速且轻量级的全功能OCI运行时，替代runc)

- 设置 ``admin`` 用户能够rootless运行podman:

.. literalinclude:: alpine_podman/admin_rootless
   :caption: 设置 ``admin`` 用户能够rootless运行podman

rootless容器内 ``root`` 用户
--------------------------------

在 :ref:`distrobox_sshd` 实践中发现，当 ``podman`` 采用 ``rootless`` 模式运行容器时，在容器内部的 ``root`` 用户实际上并不等同于Host上root用户权限，无法在低于 ``1024`` 端口上启动服务。

建议 ``rootless`` 容器采用服务使用 ``1024`` 以上端口，同时在 Host 主机上 ``-p <HOST_PORT>:<CONTAINER_PORT>`` 将容器内服务端口映射到Host主机，然后在Host主机上使用 :ref:`nginx_reverse_proxy` 对外提供服务。

rootless容器用户uid/gid映射
-----------------------------

当我执行以下命令将Host主机 ``/home/admin`` 目录卷绑定到容器内部 ``/home/admin`` 以便实现类似 :ref:`distrobox` 默认将挂载Host主机用户目录。

.. literalinclude:: alpine_podman/run
   :caption: 执行标准 podman 运行镜像来实现 tini 启动多个服务，用户目录映射

但是我发现 ``rootless`` 容器内部 ``/home/admin`` 属于 ``root`` 用户。我最初以为是 ``Dockerfile`` 中创建容器 ``admin`` 用户uid/gid和Host不一致导致的，修订 ``Dockerfile`` 确保创建容器的admin用户 ``uid/gid`` 和Host主机一致。但是发现启动 ``rootless`` 容器以后，容器内映射挂载的Host主机 ``/home/admin`` 依然是属于 ``root`` 用户的。

要解决这个问题需要使用 ``--userns keep-id:uid=$uid,gid=$gid`` :

.. literalinclude:: alpine_podman/run_keep-id
   :caption: 通过 ``keep-id`` 来确保UID/GID映射
   :emphasize-lines: 4,5

.. note::

   更详细解决方案见 :ref:`podman_rootless_volumes`

获取socket
============

为了能够使用podman API或远程使用podman，需要启用 ``podman socket`` ，不过对于本地运行 podman CLI则不需要Socket:

.. literalinclude:: alpine_podman/socket
   :caption: 启动socket

默认socket位于 ``/run/podman/podman.sock``

构建镜像
=============

``podman`` 构建镜像和 :ref:`docker_images` 非常类似，甚至连命令也一样，在包含 ``Dockerfile`` 的目录中( 这里采用 :ref:`alpine_docker_image` 的 ``alpine-dev`` Dockerfile )，执行以下命令构建镜像:

.. literalinclude:: alpine_podman/build
   :caption: 构建镜像

运行容器
=============

.. literalinclude:: alpine_podman/run
   :caption: 运行容器

共享目录
===========

待实践

参考
======

- `alpine linux wiki: Podman <https://wiki.alpinelinux.org/wiki/Podman>`_
