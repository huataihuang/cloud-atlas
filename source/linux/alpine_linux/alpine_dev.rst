.. _alpine_dev:

===============================
Alpine Linux软件开发环境构建
===============================

我在尝试 :ref:`pi_3` + :ref:`pi_4` 混合集群部署 :ref:`k3s` 时，读到 `Setting Up a Software Development Environment on Alpine Linux <https://www.overops.com/blog/my-alpine-desktop-setting-up-a-software-development-environment-on-alpine-linux/>`_ ，发现很有启发，也是一个有趣的挑战。在一个轻量级的ARM环境中，实现软件开发、 :ref:`devops` ，并采用 :ref:`edge_cloud` 构建一个ARM集群。

为什么会选择 ``Alpine Linux`` 来构建软件开发环境呢？

从 :ref:`introduce_alpine` 可以看到，Alpine是一个非常非常轻量级的Linux系统，并且适合运行容器( :ref:`docker` )。这对于我们开发者来说，是非常适合的 :ref:`devops` 环境。

构建思路:

- :ref:`pi_4` 上安装 :ref:`alpine_linux` ，然后安装 :ref:`docker` ，此时系统占用磁盘空间约500MB
- 所有工作环境都在 Docker 容器中构建，并进一步迁移到 :ref:`k3s` 集群环境
- 保持 :ref:`pi_4` 物理主机上运行的OS最精简模式

Docker运行环境
================

在 :ref:`alpine_docker` ，然后采用 :ref:`dockerfile`

- 使用密码登陆的ssh容器 ``Dockerfile`` :

.. literalinclude:: ../../docker/admin/dockerfile/alpine-ssh
   :language: dockerfile
   :caption: 提供ssh和sudo的alpine构建Dockerfile

- 并准备 ``entrypoint.sh`` :

.. literalinclude:: ../../docker/admin/dockerfile/entrypoint.sh
   :language: bash
   :caption: 启动ssh脚本

- 然后执行构建镜像命令::

   chmod +x -v entrypoint.sh
   docker build -t alpine-ssh .

- 使用以下命令启动容器::

   docker run -itd --hostname x-dev --name x-dev -p 122:22 alpine-ssh:latest

安装编译环境
===============

类似Ubuntu的 ``build-essential`` ， :ref:`alpine_linux` 提供了 ``build-base`` 组合安装包，可以安装大多数常用build工具，包括 ``g++`` ``make`` 和 ``binutils`` 。如果要开发 C++，则可以安装一些附加工具包，如 ``cmake`` ，以及 ``linux-headers`` 等。

- 安装编译环境 ``build-base`` (占用 204MB) ::

   sudo apk add build-base

- 安装debug工具 ``gdb`` 以及 ``strace`` ::

   sudo apk add gdb strace

golang
---------

- 通过仓库安装golang::

   sudo apk add go

参考 :ref:`go_startup` 验证

rust
-----------

- 通过仓库安装rust::

   sudo apk add rust

参考 :ref:`rust_startup` 验证

安装编辑器构建IDE
====================

我采用 :ref:`vim` 来构建开发IDE，采用 :ref:`light_vim` 来构建自己的开发环境

桌面
========

.. note::

   我采用字符界面远程开发，所以没有安装桌面。不过作为轻量级Linux发行版，你可以对应安装一个轻量级的 :ref:`xfce` 桌面。参考文档是 `alpine linux wiki: Xfce <https://wiki.alpinelinux.org/wiki/Xfce>`_

   或许以后我会尝试运行Alpine Linux桌面

原文作者采用了Xfce桌面，并且为了能够方便开发，安装了JetBrains IDE系列。原因是Alpine Linux使用musl库，如果使用 ``musl-glibc`` 兼容库非常费劲。而JetBrains是Java程序，OpenJDK(IcedTea项目)可以顺畅在Alpine Linux上运行，所以选择JetBrains全家桶可以非常方便开发工作。

此外，由于 Google 提供的 Android Studio就是基于JetBrains IDE，所以 :ref:`android_studio_in_pi` 也是可行的(只不过为了通用方便，容器内通常运行 :ref:`ubuntu_linux` )。

考虑到树莓派性能有限，并且在 :ref:`edge_cloud_infra` 我只有3台 :ref:`pi_4` (后续横向扩容)需要部署 :ref:`k3s` 以及在此基础上集成 :ref:`rancher` 系统，所以我没有部署任何桌面系统，而是将非常消耗计算资源的容器和虚拟机运行在 :ref:`hpe_dl360_gen9` 服务器部署的 :ref:`priv_cloud_infra` 中。

容器构建
=========

经过验证后，可以将上述步骤添加到 Alpine Linux 的Dockerfile，以便后续重新构建开发环境，并一步步打磨完善:

- 最终完整的 ``x-dev`` 完整 Dockerfile:

.. literalinclude:: alpine_dev/alpine-dev
   :language: dockerfile
   :caption: alpine构建开发环境的Dockerfile

- 执行以下命令构建镜像并启动容器:

.. literalinclude:: alpine_dev/alpine-dev_docker
   :language: bash
   :caption: 构建alpine开发环境docker容器

- 登陆容器::

   ssh 127.0.0.1 -p 122

node容器构建案例
------------------

- 构建运行Node的容器环境案例:

.. literalinclude:: alpine_dev/alpine-node
   :language: dockerfile
   :caption: alpine构建运行node的容器Dockerfile

- 准备一个 ``app.js`` 作为演示案例:

.. literalinclude:: alpine_dev/app.js
   :language: javascript
   :caption: nodejs Hello World

- 执行以下命令构建镜像并启动容器:

.. literalinclude:: alpine_dev/alpine-node_docker
   :language: bash
   :caption: 构建alpine运行node的容器

.. note::

   以上是构建node容器的案例，实际上通过容器运行node建议采用nodejs官方 `nodejs / docker-node <https://github.com/nodejs/docker-node>`_ 来运行

镜像制作和迁移
====================

- 在完成了容器内部应用升级和安装之后，执行以下命令保存镜像::

   docker commit x-dev local:x-dev

- 然后将镜像导出备份，以及 :ref:`transfer_docker_image_without_registry`

参考
=======

- `Setting Up a Software Development Environment on Alpine Linux <https://www.overops.com/blog/my-alpine-desktop-setting-up-a-software-development-environment-on-alpine-linux/>`_
- `Making Our Own Alpine Node.js Container <https://btholt.github.io/complete-intro-to-containers/making-our-own-alpine-nodejs-container>`_ 提供了一个构建node运行环境的容器案例，我在上文参考引用了文中Dockerfile
- `How do I start with Node.js after I installed it? <https://nodejs.org/en/docs/guides/getting-started-guide/>`_
