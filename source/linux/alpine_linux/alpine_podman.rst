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

获取socket
============

为了能够使用podman API或远程使用podman，需要启用 ``podman socket`` ，不过对于本地运行 podman CLI则不需要Socket:

.. literalinclude:: alpine_podman/socket
   :caption: 启动socket

默认socket位于 ``/run/podman/podman.sock``

共享目录
===========

待实践

参考
======

- `alpine linux wiki: Podman <https://wiki.alpinelinux.org/wiki/Podman>`_
