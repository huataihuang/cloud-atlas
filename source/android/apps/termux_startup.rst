.. _termux_startup:

=================
Termux快速起步
=================

Termux是一个移植到Android系统的终端模拟程序，集成了大量的命令行工具。Termux目标是为移动设备提供Linux命令行使用体验而无需root设备或特殊设置。

工作原理
=========

终端模拟器(terminal emulator)是通过使用系统调用 ``execve`` 来家在命令行程序的应用，并且重定向标准如数，输出以及错误的数据流到显示屏幕。大多数在Android上提供的终端应用都是功能有限，通常由操作系统提供，或者由root工具如Magisk提供。Termux则是进一步提供了大量的GNU/Linux软件给Android。

Termux不是虚拟机，也不是模拟环境。所有提供的软件包都是使用 :ref:`android_ndk` 进行交叉编译，并且采用了兼容补丁以便能够在Android上工作。由于Android操作系统不提供完全访问文件系统的权限，所以Termux不能在标准目录下安装，例如 ``/bin`` , ``/etc`` , ``/usr`` 或者 ``/var`` ，所有文件都是位于私有应用目录，位于: ``/data/data/com.termux/files/usr`` 

Termux使用了 ``$PREFIX`` 环境变量来引用上述目录，需要注意这个目录不能修改或者迁移到SD卡:

- 文件系统必须支持unix权限，以及特定的软连接或sockets
- prefix目录已经被硬编码到所有执行程序中

用户文件存储在 ``$HOME`` 环境变量设置的目录 ``/data/data/com.termux/files/home``

Termux提供的功能
====================

使用Termux可以实现很多用户侧功能:

- 使用Python处理数据
- 在开发环境进行编程
- 下载和管理文件
- 学习Linux命令行
- 运行SSH客户端
- 同步和备份文件

在Termux的仓库中提供了超过1000个软件包，并且如果没有找到需要的二进制执行程序，你甚至可以自己编译 - 因为Termux提供了各种开发软件的编译器，例如C, C++, Go, Rust等，也包含了常见的解释器语言，如 NodeJS, Python, Ruby。

需要注意，Termux不是一个root工具，也不提供root权限。

root
========

通常情况下Termux不需要Android设备root，也就是说它面向的是非root用户。

不过，也可以在root过的设备上使用，提供了更多hack功能:

- 修改设备firmware
- 维护操作系统或内核的参数
- 无需交互就可以安装和卸载APKs
- 具备访问整个系统的读写权限
- 能够直接访问硬件设备
- 在Android上通过 ``chroot`` 或容器化来安装一个Linux发行版
- 完全控制Android设备

一些Tips
=========

- 通过 ``pkg upgrade`` 可以更新系统
- 建议经常备份数据
- 在执行下载的脚本之前，务必检查: 不要运行不了解的任何程序，否则可能破坏系统
- 仔细关注屏幕输出，脚本执行的提示会帮助解决很多问题

参考
======

- `Termux Wiki: Getting started <https://wiki.termux.com/wiki/Getting_started>`_
