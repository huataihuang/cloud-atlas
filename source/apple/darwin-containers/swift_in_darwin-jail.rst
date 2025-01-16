.. _swift_in_darwin-jail:

==========================
在darwin-jail中运行swift
==========================

将 XCode command line tools目录 ``/Library/Developer/CommandLineTools`` 移植到 :ref:`darwin-jail` 中之后，jail中同时具备了 :ref:`clang` 和 :ref:`swift` 的运行环境。现在来尝试开发命令行swift程序

- 首先使用 SwiftPM来创建一个项目:

.. literalinclude:: swift_in_darwin-jail/mycli_project
   :caption: 初始化swift项目

此时项目目录构建完成:

.. literalinclude:: swift_in_darwin-jail/tree
   :caption: 项目目录结构

其中 ``Sources/main.swift`` 就是最简单 ``Hello, World`` 代码

.. literalinclude:: swift_in_darwin-jail/main.swift
   :language: swift
   :caption: ``Hello, World``

运行:

.. literalinclude:: swift_in_darwin-jail/run
   :caption: 运行

在jail中运行有报错:

.. literalinclude:: swift_in_darwin-jail/run_error
   :caption: 运行报错

这里 ``system.sb`` 是一个库，通过 ``import "system.sb"`` 导入，具体在哪里呢？

在 `Missing librairies in /usr/lib on Big Sur? <https://forums.developer.apple.com/forums/thread/655588>`_ 找到一个启发，提到从 macOS Big Sur 11.0.1 开始，系统附带所有系统提供的库的内置动态连接起缓存，文件系统不在保存动态库的副本。

是不是 ``darwin-jail`` 打包时候缺少了某部分缓存(还是没有安装XCode command line tools就打包导致缺少了部分)，待验证....

参考
======

- `Swift getting started: Build a Command-line Tool <https://www.swift.org/getting-started/cli-swiftpm/>`_
