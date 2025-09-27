.. _intro_freebsd_appjail:

=========================
FreeBSD AppJail简介
=========================

AppJail是一个使用POSIX shell和C开发的创建隔离、可移植以及易于部署的FreeBSD jail环境的框架。AppJail的目标是提供系统管理员和开发能够通过一个统一接口来结合基础FreeBSD工具实现自动化Jail工作流。

AppJail功能:

- 易于使用
- 并行启动(健康检查、Jails和NAT)
- 支持UFS和 :ref:`zfs`
- 支持 RACCT/RCTL
- ...
- 虚拟化网络 - 一个jail能够同时使用多个虚拟网络
- 支持brideg
- 支持VNET
- 支持Netgraph
- 支持 :ref:`linux_jail`
- 支持 :ref:`thin_jail` 和 :ref:`thick_jail`
- TinyJails
- 使用一条命令就可以通过tar备份jail或者raw images(只支持ZFS)
- Healthcheckers - 可以监控jail是否健康
- 支持镜像 - jail是一个单一文件
- **支持OCI** - 这点非常关键，也就是可以移植的容器化

.. note::

   我主要考虑AppJail支持OCI，想尝试类似 :ref:`freebsd_podman` 一样来使用容器，这个框架软件非常类似 :ref:`docker`

   待实践




参考
======

- `What is AppJail? <https://appjail.readthedocs.io/en/latest/>`_
