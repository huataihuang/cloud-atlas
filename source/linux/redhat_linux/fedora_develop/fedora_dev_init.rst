.. _fedora_dev_init:

=======================
Fedora开发环境初始化
=======================

软件包安装
============

我安装的Fedora Server版本，默认已经安装了gcc等开发工具，但是也有有些软件开发包会随着开发工作进行发现缺少，所以这里汇总需要安装的软件包::

   sudo dnf install -y git openssl-devel screen tmux

桌面环境
===========

为了能够实现图形桌面，且轻量级在服务器上运行，我采用 :ref:`i3` 并且结合 :ref:`xpra` 来实现服务器负责计算运行和负载。

完整实现 :ref:`xpra_chinese_input` 配置之后，就可能在远程服务器上开始应用开发。

vs code
=============

采用 :ref:`vs_code_linux` 方法安装 VS Code for Linux，同样使用上文 ``xpra`` 方式在服务器上运行
