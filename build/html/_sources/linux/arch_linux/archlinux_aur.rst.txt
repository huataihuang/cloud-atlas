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

yay是使用Go编写的Arch Linux AUR helper，基于 yaourt, apacman 和 pacaur 的设计，完善地解决了AUR安装依赖，并具有以下特性:

- yay自身几乎无依赖
- 为pacman提供了一个接口
- 具有yaourt相似的搜索
- 最小化用户输入
- 在升级中能够使用git包

- 下载yay源代码并编译::

   pacman -S --needed git base-devel
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si

.. note::

   编译安装yay会相关依赖安装开发软件工具链(gcc,make,automake等)，并且安装golang，所以也是一个准备开发环境的过程。

yay-git
----------

最近有一次升级系统 ``sudo pacman -Syu`` 但是发现报错::

   error: failed to prepare transaction (could not satisfy dependencies)
   :: installing pacman (5.2.0-2) breaks dependency 'pacman<=5.1.3' required by yay

参考 `Dependency breakage with pacman and yay after pacman -Syu <https://bbs.archlinux.org/viewtopic.php?id=250197>`_ ，当前 ``yay-git`` 已经更新，但是 ``yay`` 滞后，所以修改成 ``yay-git``

安装方法参考 `Can't pacman -Syu because of yay <https://www.reddit.com/r/archlinux/comments/dlpng7/cant_pacman_syu_because_of_yay/>`_ ::

   yay -G yay #clones new yay from git
   yay -R yay #removes old yay
   sudo pacman -Syu
   cd yay/
   makepkg -si #install the yay you cloned
   yay #do your yay system upgrade you were trying to do in the first place

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

- 使用yay删除软件::

   yay -Rns package

- 加载一个包选择菜单::

   yay <search term>

- 使用yay升级已经安装的包::

   yay -Syu

.. note::

   使用 ``yay -Syu`` 升级时，有时候会看到提示::

      :: Searching AUR for updates...
       -> Out Of Date AUR Packages:  android-studio  rpm-org
       there is nothing to do

   这里表示包含的release声明中已经有最新的tar包，可以通过email通知维护者更新。如果维护者2周以后仍然没有答复，你可以发起一个orphan request(孤儿请求)，即请求原维护者放弃包属主全权限。

   在维护期内，你可以编辑本地的PKGBUILD来更新软件。

- 包含开发包::

   yay -Syu --devel --timeupdate

- 清理不需要的依赖::

   yay -Yc

- 打印系统状态::

   yay -Ps

- 生成开发包数据库用于devel升级::

   yay -Y --gendb

PKGBUILD补丁
==============

在通过AUR安装 :ref:`anbox` 时遇到编译报错，需要patch PKGBUILD。参考 `how to write a patch and how to integrate it in PKGBUILD <https://bbs.archlinux.org/viewtopic.php?id=4309>`_ 采用 `Anbox installation fail.. <https://bbs.archlinux.org/viewtopic.php?id=249747>`_ 提供的 logger.patch 。

- 在 ``~/.cache/yay/anbox-git/`` 目录下存放 ``logger.patch`` ，因为patch文件需要位于PKGBUILD相同目录。

- 编辑PKGBUILD，在 ``source=`` 的列表变量部分添加补丁文件名::

   source=("git+https://github.com/anbox/anbox.git"
           ...
           'logger.patch')

 这样，这个 ``logger.patch`` 就会复制到 ``src`` 目录中。

- 执行 ``updpkgsums`` 命令(这个工具位于 ``pacman-crontab`` 软件包)，就会更新 ``md5sums`` 这个列表变量，或者手工在 ``md5sum`` 列表中加入
 
- 在PKGBUILD文件中创建 ``prepare()`` 函数(如果还没有的话)，添加::

   cd "$srcdir/$pkgname-$pkgver"
   patch --strip=1 --input=logger.patch

- 然后执行命令::

   makepkg

在补丁自动实施了。

.. note::

   以上补丁方法我还没有实践，待后续实践验证。

参考
======

- `Arch User Repository <https://wiki.archlinux.org/index.php/Arch_User_Repository>`_
- `How to Install Deb Package in Arch Linux <https://www.maketecheasier.com/install-deb-package-in-arch-linux/>`_
- `yay – Best AUR Helper for Arch Linux / Manjaro <https://computingforgeeks.com/yay-best-aur-helper-for-arch-linux-manjaro/>`_
