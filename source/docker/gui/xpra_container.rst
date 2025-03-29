.. _xpra_container:

============================
Xpra Docker容器运行图形应用
============================

通过 :ref:`xpra_startup` 结合 :ref:`xpra_chinese_input` 可以在远程服务器上运行大型图形程序，使用轻量级桌面(例如 :ref:`dwm` )来完成运维和开发工作。

不过，对于部署服务器应用和环境，显然是一个重复而单调的工作。既然 :ref:`docker` 提供了我们统一的容器技术，那么使用容器来构建一个可以不断重复和迭代的运行环境，对于自己的日常工作是有很大帮助的。此外，我也想挑战一下无缝的迁移开发环境，制作镜像，实现分发构建不同的多个开发环境。

构思
=========

- Docker容器中运行 :ref:`xpra` 以及图形程序
- 通过 Xpra 的WEB功能释放给桌面使用，桌面只需要一个浏览器，例如 :ref:`surf`

`Running Linux GUI applications in a Docker container using Xpra <https://mybyways.com/blog/running-linux-gui-applications-in-a-docker-container-using-xpra>`_ 是一个基于 `JAremko / docker-x11-bridge <https://github.com/JAremko/docker-x11-bridge>`_ 的实践文档:

- 一个 :ref:`xpra` 容器
- 一个或多个应用容器运行Linux GUI程序

优点
-----

- 通过 xpra 的 WEB 网关方式输出，这样无需安装任何客户端，仅仅使用浏览器就可以访问
- 可以使用不同的发行版来构建容器，例如 :ref:`ubuntu_linux` 或 :ref:`alpine_linux`

缺点
------

- 比RDP和原生X11应用要慢，并且稳定性差 (对网络延迟敏感)
- 重定向声音可能比较难搞定

替代方案
==========

在Linux桌面，可以使用原生X11服务器和window manager，可以使用 :ref:`x11docker` 和容器中的应用进行交互。如果是 :ref:`macos` ，需要安装 ``XQuartz`` X11应用程序

参考
=======

- `Running Linux GUI applications in a Docker container using Xpra <https://mybyways.com/blog/running-linux-gui-applications-in-a-docker-container-using-xpra>`_
