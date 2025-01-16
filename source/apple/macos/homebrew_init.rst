.. _homebrew_init:

====================
Homebrew初始化
====================

我在初步完成 :ref:`homebrew` 安装之后，执行一些必要软件包安装，以便能够取代macOS操作系统默认工具:

- 使用更新的社区版本
- 为 :ref:`darwin-jail` 提供纯净的一次性打包 ``/usr/local`` 目录 :strike:`不依赖 XCode command line tools` 

.. note::

   XCode command line tools 安装在 ``/Library/Developer/CommandLineTools`` ， :ref:`darwin-jail` 构建时可i打包这个目录

初步设置和安装
=================

.. literalinclude:: homebrew_init/zprofile
   :caption: ``~/.zprofile`` 添加配置

.. literalinclude:: homebrew_init/devops
   :caption: 安装必要brew工具

注意 :ref:`macos_install_ruby` 是需要在环境中设置ruby路径的:

.. literalinclude:: ../../ruby/startup/macos_install_ruby/zshrc_ruby
   :language: bash
   :caption: 配置 ``~/.zshrc`` 添加Ruby配置路径

同样， :ref:`curl` 也需要添加配置路径，类似上面的 :ref:`macos_install_ruby`

.. literalinclude:: homebrew_init/curl_env
   :caption: 配置 curl 环境变量以便能够优先使用

不过，对于我目前只有Intel架构的 :ref:`mbp15_2018` ，上述环境配置 ``~/.zprofile`` 只需要简化成:

.. literalinclude:: homebrew_init/env
   :caption: 简化的env配置 ``~/.zprofile``

.. note::

   不过我还是需要完成 "进一步安装和设置" 后再打包，因为我需要一个方便的开发环境

完成上述安装基础工具之后 ``brew`` 命令就是自包含依赖工具，可以直接将 ``/usr/local`` 目录打包放到 :ref:`darwin-jail` 中使用了:

.. literalinclude:: homebrew_init/brew_tar
   :caption: 打包homebrew目录

进一步安装和设置
====================

安装语言支持
-----------------

.. note::

   当安装了 XCode command line tools之后，系统就已经安装了 :ref:`clang` (gcc是clang的别名)，所以不需要再在brew中安装clang(llvm) - 参考 `如何在 mac 电脑上轻量化地写C <https://zhuanlan.zhihu.com/p/58425193>`_

   甚至还包含了 swift 语言

- 安装 :ref:`nodejs` :

.. literalinclude:: homebrew_init/node
   :caption: 安装node

.. warning::

   这里在jail容器中安装node会卡住，导致有部分依赖包没有安装完整。所以建议在host主机上安装好再打包进jail(我怀疑是创建 ``darwin-jails`` 时没有安装XCode command line tools，此时缺乏一些系统级的依赖库没有复制，等后续重新实践再看看能否修复)

安装部署 :ref:`nvim`
----------------------

- :ref:`homebrew` 安装 :ref:`nvim`

.. literalinclude:: homebrew_init/nvim
   :caption: 安装 :ref:`nvim`

- 采用 :ref:`nvim_ide` 配置方法，其中配置文件位于 `GitHub: cloud-studio <https://github.com/huataihuang/cloud-studio>`_ :

.. literalinclude:: homebrew_init/nvim_config
   :caption: 配置 :ref:`nvim`

- 启动 ``nvim`` 时会自动安装插件

nvim插件安装错误排查
~~~~~~~~~~~~~~~~~~~~~

- python-lsp-server 安装失败

.. literalinclude:: homebrew_init/python-lsp-server_error
   :caption: python-lsp-server 安装报错

重新在常规环境中安装正常，上述问题没有再现

- ruby-lsp安装失败:

.. literalinclude:: homebrew_init/ruby-lsp_error
   :caption: ruby-lsp 安装报错

这个报错是因为macOS系统自带的ruby版本过低导致的，需要通过 ``ruby install ruby`` 安装社区最新版本，然后配置好环境 ``PATH`` 变量使得默认使用 :ref:`homebrew` 提供的最新版本ruby就能解决
