.. _introduce_alpine:

================
Alpine Linux简介
================

Alpine Linux是针对安全目标的轻量级Linux发行版，基于musl libc和Busybox。

最初 `Alpine Linux <https://alpinelinux.org/>`_ 起源于 `LEAF <http://leaf.zetam.org/>`_ (Linux Embedded Applicance Framework)项目，而 LEAF 项目则又是从一个非常小巧的 Linux Router Project(LRP)项目fork出来的。由此可见，Alpine从一开始其核心理念就是创建一个轻量级、精简的并且运行在内存中的防火墙/代理服务器/VPN专用发行版。

.. note::

   Alpine Linux的创始人Natanael Copa在接受采访时解释Alpine Linux的构思：Alpine Linux想要实现的是从一个只读介质上启动并安装到内存中，并且一旦启动你就可以移除启动介质。你看，这是多么轻量级的适合部署在云计算的计算节点上的发行版，难怪Docker会选择Alpine作为运行Docker的基础操作系统。

   2016年当Docker把官方Docker镜像库从Ubuntu切换到Alpine，Alpine的创始人Copa加入了Docker公司。
   
   Alpine是一个技术人为技术人创造的Linux，其目的是技术人能够自己修复问题并将技能反馈给社区。除了Docker意外，Alpine也被用于很多安全相关的项目。

Alpine的一大特点是非常小巧，没有包含过多的内容。这种较小的发行版也更为安全和高效。



参考
======

- `Meet Alpine Linux, Docker’s Distribution of Choice for Containers <https://thenewstack.io/alpine-linux-heart-docker/>`_
