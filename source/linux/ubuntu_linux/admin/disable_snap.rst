.. _disable_snap:

============================
在Ubuntu 20.04中禁用Snaps
============================

在 :ref:`snap` 我介绍了Ubuntu的容器方式运行桌面应用的包管理工具 snap ，这确实是一个神奇的工具，构建了安全的应用程序运行环境，且提供了不影响操作系统的无依赖安装应用。不过，在一些情况下可能会需要禁用snap:

- 生产环境大量运行基于 :ref:`docker` 的 :ref:`kubernetes` ，docker容器实现的是和snap相似目标
- 在 :ref:`arm` 架构的 :ref:`raspberry_pi` 硬件资源非常宝贵，我发现当网络启用时， `snapd` 会始终占用一个cpu核心的30%资源，这样即使待机状态 :ref:`check_server_temp` 也看到核心问题达到50度以上。所以有必要禁用不使用的snapd。


参考
======

- `Disabling Snaps in Ubuntu 20.04 <https://www.kevin-custer.com/blog/disabling-snaps-in-ubuntu-20-04/>`_
