.. _archlinux_docker_image:

========================
arch linux Docker镜像
========================

`dockerhub: archlinux <https://hub.docker.com/_/archlinux/>`_ 官方提供 :ref:`arch_linux` 镜像:

- 默认是 ``amd64`` 架构，官方也提供多种架构可选:

  - `ARMv6 32-bit (arm32v6) <https://hub.docker.com/u/arm32v6/>`_
  - `ARMv7 32-bit (arm32v7) <https://hub.docker.com/u/arm32v7/>`_
  - `ARMv8 64-bit (arm64v8) <https://hub.docker.com/u/arm64v8/>`_
  - `Linux x86-64 (amd64) <https://hub.docker.com/u/amd64/>`_
  - `Windows x86-64 (windows-amd64) <https://hub.docker.com/u/winamd64/>`_

直接的基础运行 ``archlinux-base``
=================================

使用 :ref:`asahi_linux` 平台上构建 :ref:`arch_linux` 镜像，最初我采用比较简单的 ``archlinux-base`` :

.. literalinclude:: archlinux_docker_image/archlinux-base/Dockerfile
   :language: dockerfile
   :caption: 简单的arch linux基础镜像

- 执行build:

.. literalinclude:: archlinux_docker_image/archlinux-base/build_archlinux-base_image
   :language: bash
   :caption: 在asahi linux(ARM)架构上build简单的arch linux基础镜像

这里会遇到报错信息显示无法匹配平台框架:

.. literalinclude:: archlinux_docker_image/archlinux-base/build_archlinux-base_image_fail
   :language: bash
   :caption: 在asahi linux(ARM)架构上build arch linux基础镜像由于架构匹配失败
   :emphasize-lines: 4
  
可以看到 ``docker build`` 框架认为是 ``linux/arm64/v8`` 架构，没有匹配上dockerhub提供的官方架构 ``arm64v8``

匹配和使用 :ref:`docker_official_multi-platform_images` 类似

参考
========

- `arch linux: Docker <https://wiki.archlinux.org/title/docker>`_
- `Dockerfile to build a docker archlinux image with ssh <MyWackoSite: Dockerfile to build a docker archlinux image with ssh>`_
