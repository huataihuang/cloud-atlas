.. _alpine_install_calibre:

==============================
在Alpine Linux上安装Calibre
==============================

我在 :ref:`kindle` 和 :ref:`kobo` 上阅读电子书，需要有一个电子书管理平台来维护之前在国内亚马逊购买的大量电子书。虽然每次在 :ref:`macos` 上安装Calibre非常方便，但是我更想部署一个服务器，类似于NAS这样存储电子书，又能够随时通过浏览器访问。

选择Alpine Linux作为底层平台是因为想要追求硬件充分发挥性能，我现在特别沉迷于轻量级系统，想要把服务性能最大化。并且，我逐步把服务都迁移到类似 :ref:`raspberry_pi` 这样的小型系统上，锱铢必较在所难免。

.. note::

   Alpine Linux使用了 ``musl`` 库来代替标准 ``glibc`` ，对于 ``Calibre`` 官方二进制包无法直接使用，需要自行编译或使用alpine linux仓库方式安装。

使用软件仓库安装calibre
============================

将系统升级到 ``edge`` 版本
------------------------------

由于我实践发现无法同时并存stable和edge仓库，所以按照 :ref:`alpine_upgrade_edge` 完成升级

- 首先修订仓库

.. literalinclude:: alpine_apk/repositories_edge
   :caption: 在 ``/etc/apk/repositories`` 配置 ``edge`` 仓库
   :emphasize-lines: 4-6

- 系统升级:

.. literalinclude:: alpine_apk/upgrade_edge
   :caption: 完整升级到 ``edge`` 版本

安装
-------

- 执行安装:

.. literalinclude:: alpine_apk/install
   :caption: 安装calibre

初始化数据库
--------------

calibre服务运行需要一个 library 目录，该目录下需要有一饿 ``metadata.db`` ，有两种方式创建:

方法一: 使用 ``calibredb list`` 命令去查看一个空目录，此时会自动生成一个空的 ``metadata.db`` 

.. literalinclude:: alpine_install_calibre/calibredb
   :caption: 使用 ``calibredb`` list 目录

此时输出是空的内容

.. literalinclude:: alpine_install_calibre/calibredb_output
   :caption: 使用 ``calibredb`` list 目录是空的

但是会看到 ``/calibre/library`` 目录下创建了一个 ``metadata.db``

方法二: 导入一个电子书目录，此时会自动初始化 library 目录:

.. literalinclude:: alpine_install_calibre/calibredb_add
   :caption: 通过加入电子书来初始化

创建用户账号(可选)
----------------------

对于需要保护访问，可以创建用户账号数据库，然后启动 ``calibre`` 服务 指定使用用户数据库认证

- 管理用户数据库使用参数 ``--manage-users`` :

.. literalinclude:: alpine_install_calibre/manage-users
   :caption: 管理用户数据库

启动
------

- 以 ``/calibre/library`` 目录为工作目录，启动 ``calibre`` 服务:

.. literalinclude:: alpine_install_calibre/start
   :caption: 启动 ``calibre`` 服务


源代码编译安装
================

准备
-------

Alpine Linux是一个非常精简的系统，默认环境footprint极小，所以需要安装一些必要的编译工具和开发库:

.. literalinclude:: alpine_install_calibre/prepare
   :caption: 准备工作安装编译工具和开发库

下载Calibre源码
---------------------

Docker容器安装
==================

`Docker Hub: alpine <https://hub.docker.com/_/alpine>`_ 官方提供了 ``edge`` 版本镜像，所以可以非常容易完成安装部署:

- 定义 ``Dockerfile`` ，使用官方 ``edge`` 镜像: 需要激活 ``edge/testing`` 才能获取安装 ``calibre``

.. literalinclude:: alpine_install_calibre/Dockerfile
   :caption: Calibre Dockerfile

.. note::

   我在其他主机上完成 ``users.sqlite`` 认证数据库生成，以及初始化 ``metadata.db`` 生成，然后在运行容器时作为卷映射入docker容器，以实现数据存储在Host主机上

- 构建镜像:

.. literalinclude:: alpine_install_calibre/build_alpine-calibre_image
   :caption: 构建镜像

- 运行容器:

  - 用户认证数据库通过 ``/calibre/auth`` 目录挂载主机 ``/Users/admin/docs/calibre/auth`` 文件 ``users.sqlite``
  - 图书目录通过 ``/calibre/library`` 目录挂载主机 ``/Users/admin/docs/calibre/library``

.. literalinclude:: alpine_install_calibre/run_alpine-calibre_container
   :caption: 运行容器

容器中运行脚本 ``/calibre/run.sh`` 来运行 ``calibre-server`` ，前台运行，日志直接打印到控制台

.. note::

   实际上 Calibre 自带的 ``calibre-server`` 比较简陋，缺乏现代WEB外观，使用不便。现在非常流行的 :ref:`docker_linuxserver` 提供了基于 `GitHub: janeczku/calibre-web <https://github.com/janeczku/calibre-web>`_ 的美观页面，能够形成类似豆瓣的电子书阅读页面，提供的镜像 `GitHub: linuxserver/docker-calibre-web <https://github.com/linuxserver/docker-calibre-web>`_ 部署方便快捷，推荐使用

   我这里只是一个较为简陋的自用web，有时间再尝试 ``calibre-web``

修正
=========

``pdfinfo``
-----------------

上传pdf文档发现不能形成封面，后台日志显示:

.. literalinclude:: alpine_install_calibre/pdfinfo
   :caption: ``pdfinfo`` not found

这个 ``pdfinfo`` 工具包含在 ``poppler-utils`` 软件包中，所以通过如下方式补充安装:

.. literalinclude:: alpine_install_calibre/install_poppler-utils
   :caption: 安装 ``poppler-utils`` 获得 ``pdfinfo`` 工具

安装以后确实不再报告找不到 ``pdfinfo`` ，但是还是报告错误

.. literalinclude:: alpine_install_calibre/pdfinfo_fail
   :caption: 运行 ``pdfinfo`` 错误

这说明通常python环境缺少了类似 ``pypdf`` 命名的包，通常 ``pip install pypdf`` 能够解决这样的问题。不过，在Alpine Linux发行版中，这个软件包称为 ``py3-pypdf`` :

.. literalinclude:: alpine_install_calibre/install_py3-pypdf
   :caption: 补充安装 ``py3-pypdf`` 模块包

参考
=====

- `How to Install Calibre on Alpine Linux Latest <https://ipv6.rs/tutorial/Alpine_Linux_Latest/Calibre/>`_ 实践发现Calibre安装脚本会提示需要标准glibc库，所以需要自己从源代码编译，或者使用alpine官方仓库安装
- `The calibre Content server <https://manual.calibre-ebook.com/server.html>`_
- `Manual installation of Calibre - no calibre library found <https://www.truenas.com/community/threads/manual-installation-of-calibre-no-calibre-library-found.76176/>`_
