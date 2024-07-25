.. _intro_a-shell:

==================
a-shell简介
==================

当你想要在iOS环境获得Linux运行环境时，特别是对于系统运维/开发人员，需要一个远程访问服务器的终端。早期iOS平台非常封闭，需要通过Jailbreak来获得iOS终端。但是随着苹果放松了模拟器管制，涌现出 :ref:`utm` 这样全功能的 :ref:`qemu` 运行Guest操作系统(Linux/macOS/Windows)，也有同样使用 :ref:`qemu` 但是专注于精简 :ref:`alpine_linux` 系统的 :ref:`ish` 。需要注意的是，在iOS/macOS上使用全功能的qemu模拟器非常消耗资源，如果仅仅需要一个Linux终端，登录到服务器端进行开发，使用模拟器实在太沉重了。

``a-shell`` 则提供了一个原生iOS程序，来提供Unix/Linux终端，同时打包提供了一些开发程序和命令，来方便完成轻量级运维开发工作:

- 提供多种语言开发环境安装: Python, Lua, JS, C, C++ 和 TeX
- 非完整操作系统，但是你完全可以使用内置的ssh登陆到服务器开发，同时也可以在本地完成一些基础开发工作(学习语言，编写程序)

可以用a-shell做什么?
======================

显然， ``a-shell`` 不是完整的Linux系统，有诸多限制。但是它提供了性能极佳的原生程序，可以实现一个基本的本地开发环境以及方便我们进一步登录到远程服务器上完整大型开发运维工作，所以是非常优秀且必须的工具程序:

- 提供了运维开发的必要终端模拟器，为我们打开了远程服务器的窗口；最重要的是iOS原生程序，性能损耗少节约电能
- 内置了 :ref:`python` / :ref:`git` (clone程序)，也就是说，我可以用它来完成我的 Cloud-Atlas 撰写，也为一些Python开发提供了实验场所

可以说，如果是使用 iPad 作为 :ref:`mobile_work` ，那么 ``a-shell`` 就是非常趁手的 "居家旅行，杀人灭口 必备良药" ( 《 `唐伯虎点秋香 <https://movie.douban.com/subject/1306249/>`_ 》经典台词)。

参考
======

- `GitHub: holzschu/a-shell <https://github.com/holzschu/a-shell>`_
