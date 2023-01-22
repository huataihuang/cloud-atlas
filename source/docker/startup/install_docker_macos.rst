.. _install_docker_macos:

===================
macOS安装Docker
===================

.. note::

   现在已经全面使用 Docker Desktop ，当前在 :ref:`apple_silicon_m1_pro` MacBook Pro笔记本上的 macOS 运行Docker Desktop实际上是在一个 :ref:`qemu` 虚拟机中 ``qemu-system-aarch64``

Docker Desktop on Mac vs. Docker Toolbox
=========================================

Docker Toolbox
----------------

早期在Mac OS X上运行Docker实际上是先在OS X上安装运行VirtualBox，然后在VirtualBox中运行一个Linux虚拟机，最后Docker实际上是运行在Linux虚拟机中。而在Mac OS X上执行的 ``docker`` 指令则通过虚拟网络访问远程虚拟机内的Docker服务来实现管理。这种运行模式，在Mac上的 ``/usr/local/bin`` 目录下安装了 ``docker`` ， ``docker-compose`` 和 ``docker-machine`` 。Toolbox会使用
``docker-machine`` 来提供VirtualBox VM，虚拟机命名为 ``default`` ，并运行一个 ``boot2docker`` 的Linux发行版。

在执行 ``docker`` 和 ``docker-compose`` 命令之前，通常已经执行了环境设置命令 ``eval $(docker-machine env default)`` ，这样 ``docker`` 或 ``docker-compose`` 就知道如何与VirtualBox中的Docker Engine通讯。

.. figure:: ../../_static/docker/startup/toolbox-install.png
   :scale: 50

Docker Desktop on Mac
------------------------

现在推荐采用Docker Desktop on Mac模式来运行Mac-native模式的Docker，也就是安装在 ``/Applications`` 中，实际上是创建了一个完整的application bundle，位于 ``/Applications/Docker.app/Contents/Resources/bin`` 。

Docker Desktop on Mac的关键技术:

- 使用 `Docker HyperKit <https://github.com/docker/HyperKit/>`_ 代替了 VirtualBox。Hyperkit是轻量级的macOS虚拟化解决方案，基于macOS 10.10 Yosemite或更高版本的Hypervisor.framework。
- Docker Desktop不再使用 ``docker-machine`` 来构建VM，而Docker Engine API是直接在Mac主机的 ``/var/run/docker.sock`` 提供socket，这也是默认的Docker和Docker Compose客户端使用连接到Docker dameon的连接。

.. figure:: ../../_static/docker/startup/docker-for-mac-install.png
   :scale: 50

安装Docker Desktop on Mac
===========================

从Docker Hub登陆账号后下载 `Docker Desktop <https://download.docker.com/mac/stable/Docker.dmg>`_ : `Download from Docker Hub <https://hub.docker.com/?overlay=onboarding>`_

- 通过拖放将Docker安装到Applications

.. figure:: ../../_static/docker/startup/docker-app-drag.png
   :scale: 50

- 点击启动Docker应用，此时会提示需要权限

.. figure:: ../../_static/docker/startup/docker_privileged_access.png
   :scale: 50

确认权限之后，docker进入启动

.. figure:: ../../_static/docker/startup/docker_starting.png
   :scale: 50

完成启动后，可以按照提示执行以下命令验证::

   docker info
   docker version
   docker images
   docker run hello-world
   docker ps

- Docker Hub官方提供了一个验证案例，可以参考以下命令验证::

   git clone https://github.com/docker/doodle.git
   # 构建docker镜像(请查看Dockerfile)
   cd doodle/cheers2019 && docker build -t huataihuang/cheers2019 .
   # 运行容器
   docker run -it --rm huataihuang/cheers2019
   # 登陆docker Hub并将自己的镜像推送入仓库
   docker login && docker push huataihuang/cheers2019

.. note::

   查看目录下的 ``Dockerfile`` 可以看到这是一个简单绘制ASCII图形的Go程序，提供了一个运行案例。上述案例完整体现了一个如何构建自己的Docker程序并推送到Docker Hub的实例，也是今后构建自己的应用程序的一个良好模版，简单高效。

通过 :ref:`homebrew` 安装Docker Desktop on Mac
================================================

- 我在 :ref:`macos_studio` 采用 :ref:`homebrew` 完整整个工作环境构建，也包括使用 ``brew`` 安装 ``docker`` :

.. literalinclude:: install_docker_macos/brew_install_docker
   :language: bash
   :caption: 通过Homebrew安装Docker Desktop for macOS

.. note::

   使用 :ref:`homebrew` 安装 Docker Desktop on Mac 实际上也是从Docker官方下载安装包进行安装，但是 ``brew`` 包装了所有交互过程，可以用一条命令完成软件包

- 依然需要如上文方式，在 :ref:`macos` 的LaunchPad上点击 ``Docker`` 图标启动Docker虚拟机来运行容器，然后本地会增加 ``docker`` CLI，并且能够连接到Docker虚拟机内部访问 ``docker`` 服务

工作原理
=============

Docker Desktop on Mac 本质上是在 :ref:`macos` 上运行了一个 :ref:`xhyve` Hypervisor，然后运行基于 :ref:`alpine_linux` 虚拟机，这样就能完整实现一个 :ref:`linux` 环境来运行Docker容器。巧妙的是，Docker Desktop on Mac 很好地包装了多个开源技术，方便完成部署，你甚至不知道在macOS上执行 ``docker ps`` 是连接到虚拟机内部运行的docker服务(相当于远程网络调用)。

此外，Docker Desktop on Mac还提供集成 :ref:`minikube` 来模拟 :ref:`kubernetes` 开发环境。不过，我为了能够更好模拟Kubernetes集群，采用 :ref:`kind` 

参考
=======

- `Install Docker Desktop on Mac <https://docs.docker.com/docker-for-mac/install/>`_
- `Docker Desktop on Mac vs. Docker Toolbox <https://docs.docker.com/docker-for-mac/docker-toolbox/>`_
- `Enter Docker VM on MacOS Catalina (SSH, xhyve) <https://ekartco.com/2019/12/enter-docker-vm-on-macos-catalina-ssh-xhyve/>`_
- `Docker on Mac with Homebrew: A Step-by-Step Tutorial <https://www.cprime.com/resources/blog/docker-for-mac-with-homebrew-a-step-by-step-tutorial/>`_ 非常详细的步骤
