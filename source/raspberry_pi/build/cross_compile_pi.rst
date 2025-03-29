.. _cross_compile_pi:

====================
交叉编译树莓派应用
====================

虽然树莓派的ARM架构应用需要特定的硬件平台编译，但是作为个人无法获得数据中心的强大ARM硬件，所以需要采用常见的X86硬件来完成交叉编译。毕竟，目前我们比较容易获得服务器级别的X86系统，但是很难获得服务器级别的ARM系统。

交叉编译实际上使用非常广泛，例如我们会在Intel的主机上 :ref:`android_build` ，其实就是交叉编译ARM架构的应用

交叉编译原理
===============

参考 `Wikipedia Cross compiler <https://en.wikipedia.org/wiki/Cross_compiler>`_

C语言交叉编译
==================

Go语言交叉编译
================

:ref:`golang` 可以通过向 ``build`` 命令传递一些环境变量来实现交叉编译，生成目标平台的二进制程序

- 编译 ARMv7 目标平台二进制程序 (适合树莓派2和3)::

   env GOOS=linux GOARCH=arm GOARM=7 go build

- 编译 ARMv6 目标平台二进制程序 (适合 :ref:`pi_1` )::

   env GOOS=linux GOARCH=arm GOARM=6 go build

Qemu模拟
=============

Qemu可以模拟ARM架构，也许可以用来测试验证，甚至直接作为编译平台。待实践...

参考
======

- `How to Cross-Compile for Raspberry Pi on Ubuntu Linux in 5 Steps <https://deardevices.com/2019/04/18/how-to-crosscompile-raspi/>`_ 街上方法以及使用Qemu模拟ARM
- `The Useful RaspberryPi Cross Compile Guide <https://medium.com/@au42/the-useful-raspberrypi-cross-compile-guide-ea56054de187>`_ 详细介绍如何跨平台编译C程序
- `Cross-Compiling for Raspberry Pi <https://www.kitware.com/cross-compiling-for-raspberry-pi/>`_ 介绍了使用 `crosstool-ng <https://github.com/crosstool-ng/crosstool-ng>`_ 交叉工具链，详细文档可参考 `crosstool-ng Documentation <https://crosstool-ng.github.io/docs/>`_
- `Go on Raspberry Pi: simple cross-compiling <https://mansfield-devine.com/speculatrix/2019/02/go-on-raspberry-pi-simple-cross-compiling/>`_
