.. _alpinelinux_docker:

============================
Alpine Linux Docker
============================

安装
========

- ``docker`` 软件包位于 ``community`` 仓库:

.. literalinclude:: alpinelinux_docker/install
   :caption: 在Alpine Linux上安装Docker

注意，如果没有安装 ``fuse-overlayfs`` 则会出现运行报错:

.. literalinclude:: alpinelinux_docker/fuse_error.log
   :caption: 由于缺少 ``fuse-overlayfs`` 支持导致无法挂载存储

注意，如果没有安装 ``ip6tables`` 则会出现无法添加NAT表错误，并导致docker进程退出:

.. literalinclude:: alpinelinux_docker/iptables_error.log
   :caption: 由于缺少iptables支持导致进程退出

Docker as root
==================

使用OpenRC设置Docker服务在系统启动时启动:

.. literalinclude:: alpinelinux_docker/openrc
   :caption: 设置启动

将自己(普通用户)添加到 ``docker`` 组以便连接Docker服务:

.. literalinclude:: alpinelinux_docker/addgroup
   :caption: 设置组

.. warning::

   将用户添加到 ``docker`` 组相当于完全授权控制整个服务器

Docker rootless
==================

参考
=======

- `Alpine Linux Wiki: Docker <https://wiki.alpinelinux.org/wiki/Docker>`_
