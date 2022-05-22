.. _fedora_dev_init:

=======================
Fedora开发环境初始化
=======================

软件包安装
============

我安装的Fedora Server版本，默认已经安装了gcc等开发工具，但是也有有些软件开发包会随着开发工作进行发现缺少，所以这里汇总需要安装的软件包::

   sudo dnf install -y git gdb openssl-devel screen tmux

桌面环境
===========

为了能够实现图形桌面，且轻量级在服务器上运行，我采用 :ref:`i3` 并且结合 :ref:`xpra` 来实现服务器负责计算运行和负载。

完整实现 :ref:`xpra_chinese_input` 配置之后，就可能在远程服务器上开始应用开发。

vs code
=============

采用 :ref:`vscode_linux` 方法安装 VS Code for Linux，同样使用上文 ``xpra`` 方式在服务器上运行

为方便在服务器(虚拟机)上远程开发，采用:

- :ref:`vscode_remote_dev_ssh`
- :ref:`vscode_in_browser`

开发环境
==============

Fredora对不同语言的支持:

- :ref:`fedora_dev_python`
- :ref:`fedora_dev_c`
- :ref:`fedora_dev_nodejs`
- :ref:`fedora_dev_rust`
