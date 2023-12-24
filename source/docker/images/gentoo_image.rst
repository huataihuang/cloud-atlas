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

openrc运行ssh ``gentoo-ssh``
===============================

和 :ref:`fedora_tini_image` 类似，我们需要一个轻量级的的 :ref:`docker_init` 。显然采用 :ref:`systemd` 对于容器过于沉重，而且容器通常是直接运行程序，无需独立的 :ref:`docker_init` 。只不过，为了适应我们的开发环境，我们构建一个通过 ``init`` 来运行多个程序的富容器。

Gentoo 默认的 :ref:`openrc` 是一个轻量级的解决方案，不仅被Gentoo作为默认进程管理器，也是轻量级发行版 :ref:`alpine_linux` 默认进程管理器。



参考
======

- `GitHub: gentoo/gentoo-docker-images <https://github.com/gentoo/gentoo-docker-images>`_
- `How To Test OpenRC Services with Docker-Compose <https://blog.swwomm.com/2020/10/how-to-test-openrc-services-with-docker.html>`_
