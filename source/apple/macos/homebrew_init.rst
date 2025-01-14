.. _homebrew_init:

====================
Homebrew初始化
====================

我在初步完成 :ref:`homebrew` 安装之后，执行一些必要软件包安装，以便能够取代macOS操作系统默认工具:

- 使用更新的社区版本
- 为 :ref:`darwin-jail` 提供纯净的一次性打包 ``/usr/local`` 目录，不依赖 XCode command line tools

.. literalinclude:: homebrew_init/zprofile
   :caption: ``~/.zprofile`` 添加配置

.. literalinclude:: homebrew_init/devops
   :caption: 安装必要brew工具

完成上述安装基础工具之后 ``brew`` 命令就是自包含依赖工具，可以直接将 ``/usr/local`` 目录打包放到 :ref:`darwin-jail` 中使用了:

.. literalinclude:: homebrew_init/brew_tar
   :caption: 打包homebrew目录
