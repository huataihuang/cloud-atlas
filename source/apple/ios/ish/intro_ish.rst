.. _intro_ish:

===============================
iSH(Linux shell for iOS) 简介
===============================

iSH 是一个运行在iOS上的Linux shell，不过这个程序并不是原生程序，而是使用了 x86 用户模式仿真和系统调用翻译转换。由于在 iOS 环境下(没有越狱)无法获得系统的shell进行操作，所以这个开源项目还是弥补了iOS系统的不足，方便实现 :ref:`mobile_work`

这个虚拟化系统中运行了一个 :ref:`alpine_linux` ，通过完整的Linux生态来实现不同的软件安装，非常类似在 :ref:`android` 上的 :ref:`termux` 系统。

.. figure:: ../../../_static/apple/ios/ish/ish.png

.. note::

   我尝试采用在iPad上运行iSH，来构建一个 :ref:`mobile_work`

iSH特点
==========

- 支持中文输入:这是最重要的最基本的特性之一，我尝试过iOS平台的各种Terminal和ssh客户端，包括 :ref:`ash` 以及 Termius 等各种iOS原生终端软件，但无一例外都无法输入中文。看起来这些iOS原生软件都使用了相同的底层组件，都不重视多国语言输入，这导致只能用于应急而不能作为日常工作终端

注意，服务器端需要设置好编码，即 ``en_US.UTF-8`` 作为 ``LC_ALL`` 设置

- 模拟器运行了完整的 :ref:`alpine_linux` 所以在iOS中可以构建完整的Linux环境，作为日常工作桌面

  - 不过我的iPad Pro是一代产品，性能极弱，在本地运行linux虚拟机的性能很差，所以为了方便使用，我实际采用aliyun的ECS虚拟机来提供统一的工作平台

初始化
=========

- :ref:`ish_ssh_server`

参考
=====

- `ish (GitHub) <https://github.com/ish-app/ish>`_
- `ish/README_ZH.md <https://github.com/ish-app/ish/blob/master/README_ZH.md>`_
