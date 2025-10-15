.. _introduce_alpine:

================
Alpine Linux简介
================

Alpine Linux是针对安全目标的轻量级Linux发行版，基于musl libc和Busybox。

最初 `Alpine Linux <https://alpinelinux.org/>`_ 起源于 `LEAF <http://leaf.zetam.org/>`_ (Linux Embedded Applicance Framework)项目，而 LEAF 项目则又是从一个非常小巧的 Linux Router Project(LRP)项目fork出来的。由此可见，Alpine从一开始其核心理念就是创建一个轻量级、精简的并且运行在内存中的防火墙/代理服务器/VPN专用发行版。

.. note::

   Alpine Linux的创始人Natanael Copa在接受采访时解释Alpine Linux的构思：Alpine Linux想要实现的是从一个只读介质上启动并安装到内存中，并且一旦启动你就可以移除启动介质。你看，这是多么轻量级的适合部署在云计算的计算节点上的发行版，难怪Docker会选择Alpine作为运行Docker的基础操作系统。

   2016年当Docker把官方Docker镜像库从Ubuntu切换到Alpine，Alpine的创始人Copa加入了Docker公司。
   
   Alpine是一个技术人为技术人创造的Linux，其目的是技术人能够自己修复问题并将技能反馈给社区。除了Docker，Alpine也被用于很多安全相关的项目。

Alpine的一大特点是非常小巧，没有包含过多的内容:

- 使用了 ``musl`` C语言库，比常规发行版使用的 ``glibc`` 更高效，但兼容性差一些
- 使用 :ref:`busybox` 替代了大量的常用工具软件，提供核心功能，避免引入过多攻击面
- 由于其系统精简，所以攻击面较小，通常被认为更安全
- 磁盘空间和内存使用都非常小，适合容器、微服务、IoT以及安全敏感都应用场景

特性
=======

- 轻量级: alpine linux主要用于嵌入式系统和服务器应用程序，所以采用了 busybox(替代大量的GNU程序) 、OpenRC(代替 :ref:`systemd` ) 以及musl 库(用于替代glibc)，通过这种简化使得操作系统非常小巧，避免浪费宝贵的系统资源。不过，这也带来了兼容性不足和功能缺乏。如果你的系统是自己完全掌控，只运行特定目标的应用，这种精简环境会带来性能提升和安全性加强。
- 稳定性和滚动升级: Alpine Linux使用2种发布模式:

  - ``edge`` 是滚动模式，相对稳定(可能一个周期中有些小问题)
  - ``stable`` 是每6个月一个发布周期，发布周期内保持稳定修复
  - ``edge`` 和 ``stable`` 都会得到安全升级，并且 ``stable`` 有2年的支持

- 独特的打包方式: Alpine包管理器是 :ref:`alpine_apk` ，执行效率很高的软件包管理器，有点类似 :ref:`arch_linux` 的 :ref:`pacman` ，使用 ``APKBUILD`` 打包脚本完成(类似Arch Linux的 ``PKGBUILD`` )
- 社区驱动: Alpine社区相对其他发行版较小，主要的核心开发者沟通在 ``#alpine-linux`` 和 ``#alpine-devel`` IRC
- 安全: Alpine的主要特点之一就是安全，通过精简系统使得受攻击面减小，特别适合嵌入系统和特定服务器领域。 ( :ref:`alpine_install_pi` )

.. note::

   `Top 23 alpine-linux Open-Source Projects <https://www.libhunt.com/topic/alpine-linux>`_ 提供不少可以在alpine linux上借鉴的项目:

   - :ref:`termux_alpine`
   - :ref:`firefox_sync_server`

参考
======

- `Meet Alpine Linux, Docker’s Distribution of Choice for Containers <https://thenewstack.io/alpine-linux-heart-docker/>`_
- `Setting Up a Software Development Environment on Alpine Linux <https://www.overops.com/blog/my-alpine-desktop-setting-up-a-software-development-environment-on-alpine-linux/>`_
- `Alpine Linux, why no one is using it? <https://www.reddit.com/r/linux/comments/3mqqtx/alpine_linux_why_no_one_is_using_it/>`_
