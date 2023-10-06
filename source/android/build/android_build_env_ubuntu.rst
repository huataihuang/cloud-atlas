.. _android_build_env_ubuntu:

==============================
构建Android编译环境(Ubuntu)
==============================

编译环境准备
================

在 :ref:`ubuntu_linux` 中编译，需要安装以下工具包:

.. literalinclude:: android_build_env_ubuntu/apt_intsall_build_dependencies
   :language: bash
   :caption: 安装Ubuntu编译LineageOS需要的依赖软件包

镜像化
=========

我在 :ref:`android_build_env_centos8` 采用比较简单的类似 :ref:`fedora_tini_image` 方式，不过现在改进为 :ref:`ubuntu_tini_image` (独立卷)

在 ``arm64`` Ubuntu容器中
----------------------------

我在 :ref:`ubuntu_tini_image` 基础上构建容器中执行安装依赖软件包报错( ``aarch64`` ):

.. literalinclude:: android_build_env_ubuntu/apt_intsall_build_dependencies_err
   :language: bash
   :caption: 在ARM架构(aarch64)容器中安装Ubuntu编译LineageOS需要的依赖软件包报错

参考 `Hi, does anyone know why I can't install the package gcc-multilib on Ubuntu 20.04? It is absolutly necessary for starting a Yocto project. Does anyone know how I can fix this? (see DockerFile in description) Thanks for the support! <https://www.reddit.com/r/docker/comments/10uya5l/hi_does_anyone_know_why_i_cant_install_the/>`_ 原因是在 ``arm64`` 平台并不提供 ``gcc-multilib`` 软件包，如果需要使用，则应该构建一个 ``amd64`` 镜像

.. note::

   我暂时放弃在ARM架构的Docker容器中编译构建Android的编译环境

:ref:`systemd-nspawn` 一个 :ref:`debootstrap` 系统
-----------------------------------------------------

参考
======

- `Build LineageOS for Google Pixel 4 <https://wiki.lineageos.org/devices/flame/build>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
