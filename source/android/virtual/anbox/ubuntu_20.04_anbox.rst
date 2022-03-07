.. _ubuntu_20.04_anbox:

=============================
Ubuntu 20.04 LTS运行Anbox
=============================

我在 :ref:`kubuntu` 20.04 LTS中安装Anbox来运行Android应用

安装Anbox
===========

- 更新软件仓库::

   sudo apt update

- 强烈建议采用 :ref:`snap` 安装Anbox以避免环境依赖问题::

   sudo snap install --devmode --beta anbox

安装adb
=========

在不使用Google Play Store时，可以通过 :ref:`adb` 安装应用。所以我们首先安装Android开发工具 ``adb`` ::

   sudo apt install android-tools-adb

使用adb安装应用
===============

安装Google Play Store
=======================

`geeks-r-us / anbox-playstore-installer <https://github.com/geeks-r-us/anbox-playstore-installer>`_ 提供了自动安装Google Playstore的脚本

- 安装依赖工具::

   sudo apt install wget curl lzip tar unzip squashfs-tools

- 下载安装脚本::

   wget https://raw.githubusercontent.com/geeks-r-us/anbox-playstore-installer/master/install-playstore.sh
   chmod +x install-playstore.sh

- 运行安装::

   ./install-playstore.sh

- 然后启动Anbox就会看到已经具备了 ``Google PlayStore`` ::

   anbox.appmgr

- 如果不能连接因特网，则运行以下命令修复::

   sudo /snap/anbox/current/bin/anbox-bridge.sh start

参考
======

- `How to install Anbox on Ubuntu 20.04 LTS focal fossa <https://www.how2shout.com/linux/how-to-install-anbox-on-ubuntu-20-04-lts-focal-fossa/>`_
