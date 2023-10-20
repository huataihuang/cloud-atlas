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

.. literalinclude:: android_build_env_ubuntu/apt_intsall_build_dependencies_docker_err
   :language: bash
   :caption: 在ARM架构(aarch64)容器中安装Ubuntu编译LineageOS需要的依赖软件包报错

参考 `Hi, does anyone know why I can't install the package gcc-multilib on Ubuntu 20.04? It is absolutly necessary for starting a Yocto project. Does anyone know how I can fix this? (see DockerFile in description) Thanks for the support! <https://www.reddit.com/r/docker/comments/10uya5l/hi_does_anyone_know_why_i_cant_install_the/>`_ 原因是在 ``arm64`` 平台并不提供 ``gcc-multilib`` 软件包，如果需要使用，则应该构建一个 ``amd64`` 镜像

.. note::

   我暂时放弃在ARM架构的Docker容器中编译构建Android的编译环境

在 ``x86`` Ubuntu容器中
--------------------------

.. note::

   这段容器实践是采用 :ref:`systemd-nspawn` 一个 :ref:`debootstrap` 系统，操作是在 ``zcloud`` ( :ref:`hpe_dl360_gen9` )

- 启动 :ref:`systemd-nspawn` 容器:

.. literalinclude:: ../../linux/redhat_linux/systemd/systemd-nspawn/systemd-nspawn_ubuntu-dev_android_ccache
   :language: bash
   :caption: 执行 ``systemd-nspawn`` 启动 ``ubuntu-dev`` 容器(提供独立android和ccache目录)

实际上，在 ``x86`` 的容器环境中安装编译环境依赖包也是会报错的( :ref:`systemd-nspawn` 容器环境 ):

.. literalinclude:: android_build_env_ubuntu/apt_intsall_build_dependencies_systemd-nspawn_err
   :caption: 在X86架构容器( :ref:`systemd-nspawn` )中安装Ubuntu编译LineageOS需要的依赖软件包报错

后来参考 `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_ ，原来容器的apt配置中默认只启用了 ``main`` 仓库，要安装依赖软件包，需要修订配置添加 ``universe`` 仓库分支:

.. literalinclude:: android_build_env_ubuntu/apt_sources.list
   :caption: 修订仓库配置文件，``jammy-updates`` 和 ``jammy-security`` 仓库以及 ``universe`` 分支

- 执行更新:

.. literalinclude:: android_build_env_ubuntu/apt_update_upgrade
   :caption: 修改仓库配置后更新和升级

- 安装LineageOS编译依赖:

.. literalinclude:: android_build_env_ubuntu/apt_intsall_build_dependencies_container
   :language: bash
   :caption: 在容器中安装Ubuntu编译LineageOS需要的依赖软件包

- 添加一个普通用户账号，注意这里关闭了密码:

.. literalinclude:: android_build_env_ubuntu/adduser_admin
   :caption: 添加一个 ``admin`` 账号并切换到这个账号

- 设置缓存 50G 并且在 ``admin`` 账号配置中启动 ``ccache`` :

.. literalinclude:: android_build_env_ubuntu/ccache
   :caption: 启用 ``ccache``

下载安装 ``platform-tools``
-----------------------------

从Google下载 `最新platform-tools <https://dl.google.com/android/repository/platform-tools-latest-linux.zip>`_ 并解压缩到HOME目录:

.. literalinclude:: android_build_env_ubuntu/unzip_platform-tools
   :language: bash
   :caption: 将下载的 platform-tools 解压缩

并添加路径到 ``~/.profile`` :

.. literalinclude:: android_build_env_ubuntu/bashrc
   :language: bash
   :caption: 添加 platform-tools 工作路径

.. note::

   在虚拟机(或容器)环境中不需要 ``platform-tools`` ，这个工具主要是为了同步镜像到手机设备，编译时不需要

Java
---------

不同的LineageOS需要不同的JDK(Java Development Kit)版本:

- LineageOS 18.1+: OpenJDK 11 (included in source download)
- LineageOS 16.0-17.1: OpenJDK 1.9 (included in source download)
- LineageOS 14.1-15.1: OpenJDK 1.8 (install openjdk-8-jdk)

对于编译现代最新版本的LineageOS可以不用单独安装OpenJDK，而是由源代码下载时自动完成安装

Python
---------

不同的LineageOS需要不同的Python版本(已经在上文完成):

- LineageOS 17.1+: Python 3 (install python-is-python3)
- LineageOS 11.0-16.0: Python 2 (install python-is-python2)

至此，环境准备工作已经完成，可以 :ref:`build_lineageos_20_pixel_4`

参考
======

- `Build LineageOS for Google Pixel 4 <https://wiki.lineageos.org/devices/flame/build>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
