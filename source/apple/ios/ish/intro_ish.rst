.. _intro_ish:

===============================
iSH(Linux shell for iOS) 简介
===============================

iSH 是一个运行在iOS上的Linux shell，不过这个程序并不是原生程序，而是使用了 x86 用户模式仿真和系统调用翻译转换。由于在 iOS 环境下(没有越狱)无法获得系统的shell进行操作，所以这个开源项目还是弥补了iOS系统的不足，方便实现 :ref:`mobile_work`

这个虚拟化系统中运行了一个 :ref:`alpine_linux` ，通过完整的Linux生态来实现不同的软件安装，非常类似在 :ref:`android` 上的 :ref:`termux` 系统。

.. figure:: ../../../_static/apple/ios/ish/ish.png

.. note::

   我尝试采用在iPad上运行iSH，来构建一个 :ref:`mobile_work`

初始化
=========

- :ref:`ish_ssh_server`

参考
=====

- `ish (GitHub) <https://github.com/ish-app/ish>`_
- `ish/README_ZH.md <https://github.com/ish-app/ish/blob/master/README_ZH.md>`_
