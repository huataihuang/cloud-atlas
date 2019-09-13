.. _archlinux_aur:

================
Arch Linux AUR
================

.. note::

   :ref:`archlinux_on_thinkpad_x220` ，除了发行版仓库安装软件，Arch Linux的社区维护的AUR软件仓库是重要的来源。很多第三方软件都是通过AUR才能方便快捷安装在Arch Linux中。所以，在初始设置好Arch Linux之后，推荐部署AUR并进一步定制系统。

Arch User Repository (AUR)是社区驱动的软件仓库，包含了软件包描述(PKGBUILDs)以帮助你从源代码使用makepkg来编译软件并通过pacman安装。

使用AUR有两种方式：

- AUR helper - 有多种 `AUR helpers <https://wiki.archlinux.org/index.php/AUR_helpers>`_ 可供使用，方便自动完成AUR操作
- 直接从AUR网站搜索软件包，并下载对应的 ``snapshot`` 

AUR helper
===============

.. note::

   `为什么一个个的AUR helper停止了开发？ <https://zhuanlan.zhihu.com/p/60874343>`_ 提到了著名的AUR helper yaourt停止维护的信息，以及推荐 `yay - Yet another Yogurt - An AUR Helper written in Go <https://github.com/Jguer/yay>`_ 作为AUR helper。使用方法可以参考 `Manjaro 使用基础 <https://www.cnblogs.com/kirito-c/p/11181978.html>`_ 。

- 下载yay源代码并编译::

   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si

.. note::

   编译安装yay会相关依赖安装开发软件工具链(gcc,make,automake等)，并且安装golang，所以也是一个准备开发环境的过程。

通过snapshot安装
==================

.. note::

   这里举例安装alien，用于转换deb软件包文件的工具。

- 下载并解压缩 alien_package_converter.tar.gz

- 进入目录执行::

   makepkg -si

.. note::

   这里出现报错::

      ==> Checking runtime dependencies...
      ==> Missing dependencies:
        -> debhelper
        -> cpio
        -> rpm-org

- 可以通过yay自动完成安装::

   yay -S alien_package_converter

.. note::

   yay 不建议使用root/sudo执行，所有操作命令类似pacman，非常方便。

参考
======

- `Arch User Repository <https://wiki.archlinux.org/index.php/Arch_User_Repository>`_
- `How to Install Deb Package in Arch Linux <https://www.maketecheasier.com/install-deb-package-in-arch-linux/>`_
