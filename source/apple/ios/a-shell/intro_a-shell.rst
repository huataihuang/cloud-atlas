.. _intro_a-shell:

==================
a-shell简介
==================

当你想要在iOS环境获得Linux运行环境时，特别是对于系统运维/开发人员，需要一个远程访问服务器的终端。早期iOS平台非常封闭，需要通过Jailbreak来获得iOS终端。但是随着苹果放松了模拟器管制，涌现出 :ref:`utm` 这样全功能的 :ref:`qemu` 运行Guest操作系统(Linux/macOS/Windows)，也有同样使用 :ref:`qemu` 但是专注于精简 :ref:`alpine_linux` 系统的 :ref:`ish` 。需要注意的是，在iOS/macOS上使用全功能的qemu模拟器非常消耗资源，如果仅仅需要一个Linux终端，登录到服务器端进行开发，使用模拟器实在太沉重了。

``a-shell`` 是一个iOS/iPadOS上的终端模拟器，提供了一些Unix命令以及开发语言，方便完成轻量级运维开发工作:

- 提供多种语言开发环境安装: Python, Lua, JS, C, C++ 和 TeX
- **非** 完整操作系统，但是你完全可以使用内置的ssh登陆到服务器开发，同时也可以在本地完成一些基础开发工作(学习语言，编写程序)
- 包含了 `ios_system <https://github.com/holzschu/ios_system/>`_ ecosystem 所有命令:

  - :ref:`shell` 命令(ls, cp, rm ...)
  - 归档命令 (curl, scp, sftp, tar, gzip, compress ...)
  - 交互语言 ( :ref:`python` , :ref:`lua` , Tex)
  - 一些网络命令 (nslookup, dig, host, ping, telnet)

.. note::

   当Unix工具被port到iOS(vim,TeX,Python...)，一些源代码执行系统命令会使用 ``system()`` 调用，此时变异会出现报错 ``error: 'system' is unavailable: not available on iOS`` 

   `ios_system <https://github.com/holzschu/ios_system/>`_ 项目提供了一个 ``system()`` 替代，在源代码头文件中添加以下内容::

      extern int ios_system(char* cmd);
      #define system ios_system

   来链接到 ``ios_system.framework`` ，这样调用 ``system()`` 将由这个框架处理

``a-shell`` 可以运行多个窗口，每个窗口有自己的上下文(context)，外观，命令行历史以及当前目录: ``newWindow`` 命令可以打开一个新窗口，然后 ``exit`` 可以关闭当前窗口。

可以用a-shell做什么?
======================

显然， ``a-shell`` 不是完整的Linux系统，有诸多限制。但是它提供了性能极佳的原生程序，可以实现一个基本的本地开发环境以及方便我们进一步登录到远程服务器上完整大型开发运维工作，所以是非常优秀且必须的工具程序:

- 提供了运维开发的必要终端模拟器，为我们打开了远程服务器的窗口；最重要的是iOS原生程序，性能损耗少节约电能
- 内置了 :ref:`python` / :ref:`git` (clone程序)，也就是说，我可以用它来完成我的 Cloud-Atlas 撰写，也为一些Python开发提供了实验场所

可以说，如果是使用 iPad 作为 :ref:`mobile_work` ，那么 ``a-shell`` 就是非常趁手的 "居家旅行，杀人灭口 必备良药" ( 《 `唐伯虎点秋香 <https://movie.douban.com/subject/1306249/>`_ 》经典台词)。

使用体验
===========

我主要想使用 :ref:`ssh` ，但是在 ``a-shell`` 中还是有很大的限制:

- 由于是容器化运行，登陆后的 ``$HOME`` 路径非常长，导致如果使用 :ref:`ssh_multiplexing` 会提示 ``ControlPath`` 过长超过104字符限制:

.. literalinclude:: intro_a-shell/contralpath_too_long
   :caption: ``ControlPath`` 过长报错

- 无法建立 Unix Domain Socket，提示 ``Too Long for Unix Domain Socket`` ( `Overcoming 'Too Long for Unix Domain Socket' Errors in SSH Git Cloning <https://shihtiy.com/posts/too-long-for-Unix-domain-socket/>`_
- 端口转发无效

目前还没有探索出可行的方法，待解决

参考
======

- `GitHub: holzschu/a-shell <https://github.com/holzschu/a-shell>`_
- `A guide to a-Shell <https://bianshen00009.gitbook.io/a-guide-to-a-shell>`_
