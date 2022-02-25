.. _openrc_startup:

===============================
轻量级init系统OpenRC快速起步
===============================

Alpine Linux使用 ``OpenRC`` 来管理服务。OpenRC是一个轻量级 ``init`` 系统(对比 :ref:`systemd` )，不需要对传统的类Unix系统做大型修改，就可以集成系统软件组成模块化、可伸缩的系统。OpenRC是一个快速、轻量级、容易配置以及修改的系统，只需要非常基本的依赖就可以运行在核心系统组件上。

作为现代化的 ``init`` 系统，OpenRC提供了一系列有用的功能:

- 支持 :ref:`cgroup`
- 进程监督(process supervision)
- 基于依赖的加载(dependency-based lauch)，同时提供并行启动服务
- 自动解析排序、依赖关系
- 提供硬件初始化脚本
- 通过 ``rc_ulimit`` 变量来为每个服务设置 ``ulimit`` 和 ``nice`` 值
- 允许复杂的init脚本来启动多个组件
- 模块化架构，适合现有的基础架构
- OpenRC有自己可选的 ``init系统`` 称为 :ref:`openrc-init`
- OpenRC有自己可选的进程监控 :ref:`supervise-daemon`

参考
======

- `How to enable and start services on Alpine Linux <https://www.cyberciti.biz/faq/how-to-enable-and-start-services-on-alpine-linux/>`_
- `alpine linux wiki: OpenRC <https://wiki.alpinelinux.org/wiki/OpenRC>`_
- `gentoo linux wiki: OpenRC <https://wiki.gentoo.org/wiki/OpenRC>`_
