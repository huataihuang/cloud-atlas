.. _install_disabled_homebrew_package:

====================================
安装被禁止(disable)的Homebrew软件包
====================================

我在尝试 :ref:`multi_golang_with_homebrew` 遇到一个问题，就是低版本 Golang 由于被上游停止支持，所以默认在 ``homebrew`` 中是禁止(disable)的。

例如，安装低版本 :ref:`golang` 1.15:

.. literalinclude:: install_disabled_homebrew_package/brew_install_go_1.15
   :caption: 安装低版本GoLang 1.15

提示错误:

.. literalinclude:: install_disabled_homebrew_package/brew_install_go_1.15_error
   :caption: 安装低版本GoLang 1.15报错

解决方法:

.. literalinclude:: install_disabled_homebrew_package/brew_edit_disabled_package
   :caption: 使用brew edit 指定版本formula，可以去除disable标记

找到:

.. literalinclude:: install_disabled_homebrew_package/brew_disable_package_config
   :caption: 使用brew edit 指定版本formula，去除的配置行

删除这行配置，再次安装

晕倒!!!

这个方法看似没有成功，还是提示同样错误:

.. literalinclude:: install_disabled_homebrew_package/brew_install_go_1.15_error
   :caption: 安装低版本GoLang 1.15报错

.. note::

   想在Go官网下载旧版本手工安装，却发现 go1.15 没有提供 :ref:`macos` ARM版本(只有 go1.16 才提供 macOS ARM64版本)，卒...

参考
=======

- `Can you install disabled Homebrew packages? <https://stackoverflow.com/questions/73586208/can-you-install-disabled-homebrew-packages/73595534>`_




