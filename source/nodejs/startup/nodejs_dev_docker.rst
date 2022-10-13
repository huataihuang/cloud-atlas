.. _nodejs_dev_docker:

==================================
使用Docker设置本地Node.js开发环境
==================================

:ref:`vscode` 提供了 :ref:`docker` 扩展可以方便build,管理和部署容器化应用。由于VSC可以跨平台，在 :ref:`macos` / :ref:`windows` 和 :ref:`linux` 都能一致性地使用，非常适合开发轻量级应用，特别是 :ref:`javascript` ( :ref:`nodejs` ) 

.. note::

   我的开发环境在 :ref:`apple_silicon_m1_pro` 处理器的MacBook Pro上，所以安装 Docker Desktop 来运行容器环境。在 :ref:`linux` 平台可以直接运行 :ref:`docker` 或 :ref:`kubernetes` 来构建 :ref:`mobile_cloud_infra`

安装
========

- :ref:`install_docker_macos` ，如果是在 :ref:`linux` 中安装 :ref:`docker` ，需要配置 :ref:`run_docker_without_sudo` 
- 安装 :ref:`vscode` 扩展: 按下 ``⇧⌘X`` 搜索 ``docker`` 并安装由微软开发的Docker extension:

.. figure:: ../../_static/nodejs/startup/vscode_docker_extension.png

- (推荐)按下 ``⇧⌘X`` 搜索 ``python`` / ``go`` / ``rust-analyzer`` / ``c/c++`` 扩展，获得 ``IntelliSense`` 能力( 可以从 `Extensions for Visual Studio Code <https://marketplace.visualstudio.com/vscode>`_ 查找)

- 在macOS本地系统 :ref:`install_nvm` ，然后 :ref:`nvm_install_nodejs`

创建Express Node.js应用
==========================

- 创建一个 :ref:`express` Node.js 应用::

   mkdir demo
   cd demo

   npx express-generator
   npm install

在项目中添加Docker文件
=======================

- 在 :ref:`vscode` 中打开 ``demo`` 项目目录

- 打开命令面板 ( ``⇧⌘P`` ) ，然后使用 ``Docker: Add Docker Files to Workspace...`` 命令，根据提示依次回车(默认值)

  - 对于application platform，选择 ``Node.js``
  - 对于是否包括 ``Docker Compose`` 文件(类似 :ref:`kubernetes` 的pod，可以同时运行多个容器)
  - 应用端口保持默认 ``3000``

此时 :ref:`vscode` 会自动创建如下 ``Dockerfile`` 以及一个 ``.dockerignore`` 文件:

.. literalinclude:: nodejs_dev_docker/Dockerfile
   :language: dockerfile

如果选择了包含 ``Docker Compose`` 文件，则会同时生成 ``docker-compose.yml`` 和 ``docker-compose.debug.yml`` 。最后， :ref:`vscode` 的 Docker扩展还会在 ``.vscode/tasks.json`` 中创建一系列VS Code任务用来build和run容器

在镜像中添加环境变量
======================

:ref:`vscode` 的Docker扩展是通过IntelliSense来首先自动完成和上下问帮助的，要激活这个功能，需要在服务镜像中添加一个环境变量:

- 打开 ``Dockerfile`` 文件

- 在服务镜像中添加 ``ENV`` 变量，例如 ``ENV VAR1`` (待续)

参考
=======

- `Node.js in a container <https://code.visualstudio.com/docs/containers/quickstart-node>`_ :ref:`vscode` 官方指南，如何将node.js运行到docker容器中并且通过VSC进行开发(本文主要参考)
- `Docker in Visual Studio Code <https://code.visualstudio.com/docs/containers/overview#_installation>`_ :ref:`vscode` 官方指南，首先参考这个文档完成VSC配置Docker

  - 微软提供了一个教程 `Tutorial: Create and share a Docker app with Visual Studio Code <https://learn.microsoft.com/en-us/visualstudio/docker/tutorials/docker-tutorial>`_ 可以辅助参考，文档比较清晰

- `Docker in development (with Node.js) <https://dev.to/akshaydotsh/docker-in-development-with-node-js-454k>`_ 通用的设置docker开发环境方法，包括设置Docker Volumes一级如何在开发过程中使用Volumes
- `How to Set Up Your Local Node.js Development Environment Using Docker <https://www.docker.com/blog/how-to-setup-your-local-node-js-development-environment-using-docker/>`_ Docker官方blog介绍如何用docker运行起容器中的nodes.js
