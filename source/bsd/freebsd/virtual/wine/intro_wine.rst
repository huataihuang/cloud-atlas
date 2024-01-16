.. _intro_wine:

=====================
WINE简介
=====================

`WineHQ <https://www.winehq.org/>`_ 是一个Windows应用程序运行环境，可以让Windows程序运行在Linux/BSD系统上。Wine最初是 ``Wine is Not an Emulator`` 的首字母缩写。Wine并不是一个完整的模拟Windows虚拟机，而是将Windows API调用实时翻译成POSIX调用，这样可以比其他虚拟化方法降低性能和内存损失，并且可以将Windows应用程序集成到Linux/BSD系统桌面。

有趣的项目
============

- `GitHub: huan/docker-wechat <https://github.com/huan/docker-wechat>`_ 在 :ref:`docker` 容器中运行 :ref:`wine` ，从而实现在Linux平台运行一个微信Windows客户端，结合了多个技术堆栈，值得学习

参考
=======

- `FreeBSD Handbook: Chapter 11.WINE <https://docs.freebsd.org/en/books/handbook/wine/>`_
