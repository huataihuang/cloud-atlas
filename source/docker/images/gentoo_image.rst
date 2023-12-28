.. _gentoo_image:

===================
Gentoo镜像
===================

`DockerHub Gentoo <https://hub.docker.com/u/gentoo/>`_ 提供了 :ref:`gentoo_linux` 官方镜像:

- `DockerHub gentoo/stage3 <https://hub.docker.com/r/gentoo/stage3>`_ 提供stage3 Gentoo docker镜像，包含基本的stage3镜像以及作为 ``/var/db/repos/gentoo`` (Gentoo ebuild repository)卷的镜像
- `DockerHub gentoo/portage <https://hub.docker.com/r/gentoo/portage>`_ portage快照

Gentoo使用 :ref:`openrc` 提供了轻量级的 :ref:`openrc-init` 可以在Docker容器中作为 :ref:`docker_init`

基础运行 ``gentoo-base``
===========================

和 :ref:`fedora_tini_image` 类似，我们需要一个轻量级的的 :ref:`docker_init` 。显然采用 :ref:`systemd` 对于容器过于沉重，而且容器通常是直接运行程序，无需独立的 :ref:`docker_init` 。只不过，为了适应我们的开发环境，我们构建一个通过 ``init`` 来运行多个程序的富容器。

Gentoo 默认的 :ref:`openrc` 是一个轻量级的解决方案，不仅被Gentoo作为默认进程管理器，也是轻量级发行版 :ref:`alpine_linux` 默认进程管理器。这个 ``sys-apps/openr`` 已经默认在官方镜像中提供，只不过一般不会启用(因为容器都是轻量级的单个应用运行)，常规的容器最后执行命令就是直接应用程序，例如 ``/bin/bash`` 或者 ``/usr/sbin/nginx`` 。

非常幸运的是 :ref:`openrc` 和Docker兼容性极佳，可以轻而易举在Docker中采用:

- 参考 `GitHub: gentoo/gentoo-docker-images <https://github.com/gentoo/gentoo-docker-images>`_ 构建一个非常基本的运行镜像:

.. literalinclude:: gentoo_image/base/Dockerfile
   :language: dockerfile
   :caption: 基础Gentoo镜像Dockerfile

- 构建 ``gentoo-base`` 镜像:

.. literalinclude:: gentoo_image/base/build_gentoo-base_image
   :language: bash
   :caption: 构建基础Gentoo镜像Dockerfile

- 运行 ``gentoo-base`` 镜像:

.. literalinclude:: gentoo_image/base/run_gentoo-base_container
   :language: bash
   :caption: 运行gentoo-base容器

- 连接到 ``gentoo-base`` 容器内:

.. literalinclude:: gentoo_image/base/exec_gentoo-base_container
   :language: bash
   :caption: 通过docker exec运行容器内部bash

基础运行 ``gentoo-base-plus``
===============================

在上述最为简单的 Gentoo 基础上，按照 :ref:`gentoo_on_gentoo` 的实践定制一个包含工具、本地化等配置的镜像，并启用 ``ssh`` 服务:

.. literalinclude:: gentoo_image/base-plus/Dockerfile
   :language: dockerfile
   :caption: 在基础Gentoo镜像上增加工具、更新以及部署ssh的Dockerfile

- 构建 ``gentoo-base-plus`` 镜像:

.. literalinclude:: gentoo_image/base-plus/build_gentoo-base-plus_image
   :language: bash
   :caption: 构建 ``gentoo-base-plus`` 镜像Dockerfile

- 运行 ``gentoo-base-plus`` 镜像:

.. literalinclude:: gentoo_image/base-plus/run_gentoo-base-plus_container
   :language: bash
   :caption: 运行 ``gentoo-base-plus`` 容器

- 连接到 ``gentoo-base-plus`` 容器内:

.. literalinclude:: gentoo_image/base-plus/exec_gentoo-base-plus_container
   :language: bash
   :caption: 通过docker exec运行 ``gentoo-base-plus`` 容器内部bash

开发环境 ``gentoo-dev``
===============================

.. note::

   开发环境的构建 ``Dockerfile`` 将随着我的开发学习以及工作不断调整和完善

- 在 ``gentoo-base-plus`` 增加开发工具安装的 ``Dockerfile`` (逐步完善):

.. literalinclude:: gentoo_image/dev/Dockerfile
   :language: dockerfile
   :caption: 在 ``gentoo-base-plus`` 基础上增加开发工具安装

.. note::

   墙内使用 :ref:`rvm` 需要梯子，所以结合 :ref:`docker_proxy` 和 :ref:`squid_socks_peer` 实现翻墙。上面的 ``Dockerfile`` 配置中通过添加环境变量使得容器镜像构建时可以使用代理服务器。

   如果没有GFW干扰，可以去除代理配置；请按照实际情况调整配置内容

- 构建 ``gentoo-dev`` 镜像:

.. literalinclude:: gentoo_image/dev/build_gentoo-dev_image
   :language: bash
   :caption: 构建 ``gentoo-dev`` Dockerfile镜像

- 运行 ``gentoo-dev`` 镜像:

.. literalinclude:: gentoo_image/dev/run_gentoo-dev_container
   :language: bash
   :caption: 运行 ``gentoo-dev`` 容器

- 连接到 ``gentoo-dev`` 容器内:

.. literalinclude:: gentoo_image/dev/exec_gentoo-dev_container
   :language: bash
   :caption: 通过docker exec运行 ``gentoo-dev`` 容器内部bash


参考
======

- `GitHub: gentoo/gentoo-docker-images <https://github.com/gentoo/gentoo-docker-images>`_
- `How To Test OpenRC Services with Docker-Compose <https://blog.swwomm.com/2020/10/how-to-test-openrc-services-with-docker.html>`_
