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

参考
=======

- `Running Linux GUI applications in a Docker container using Xpra <https://mybyways.com/blog/running-linux-gui-applications-in-a-docker-container-using-xpra>`_
