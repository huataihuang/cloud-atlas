.. _freebsd_wine:

==========================
在FreeBSD上运行WINE
==========================

准备工作
==========

安装WINE之前，需要先完成以下准备工作:

- GUI环境
- wine-gecko: 默认Windows内建的web浏览器::

   pkg install wine-gecko

上述pkg安装有可以通过编译完成::

   cd /usr/ports/emulator/wine-gecko
   make install

- wine-mono: MONO框架是开源的Microsoft .NET实现::

   pkg install wine-mono

上述pkg安装也可以通过编译完成::

   cd /usr/ports/emulator/wine-mono
   make install

安装
=========

- 执行以下命令完成软件包安装::

   pkg install wine

也可以通过编译完成::

   cd /usr/ports/emulator/wine
   make install

通过 ``pkg`` 安装会提示::

   Wine requires procfs(5) mounted on /proc. You can do so manually via
     mount -t procfs proc /proc
   or make it permanent via something like the following in /etc/fstab
     proc   /proc   procfs   rw   0 0

   Some ZFS tuning guides recommend setting KVA_PAGES=512 in your kernel
   configuration.  This is incompatible with Wine.  The maximum possible
   is KVA_PAGES=500, which should still be enough for ZFS.

所以在 ``/etc/fstab`` 中添加::

   proc                    /proc   procfs  rw              0       0

并执行一次 ``mount -t procfs proc /proc`` (或者重启一次系统)

.. note::

   WINE的很多工具依赖32位wine，所以首先要让系统具备 ``lib32`` 支持。我在 :ref:`freebsd_on_intel_mac` 时没有选择32位系统支持(lib32)，所以需要 :ref:`add_lib32_after_install_freebsd`

如果没有安装32位的wine，则运行程序时候会报错::

   winecfg

报错::

   /home/huatai/.i386-wine-pkg//usr/local/bin/wine doesn't exist!
   
   Try installing 32-bit Wine with
   	/usr/local/share/wine/pkg32.sh install wine mesa-dri
   
   If using Poudriere, please make sure your repo is setup to use FreeBSD:13:i386
   and create symlinks for
     FreeBSD:13:amd64 and
     FreeBSD:13:i386
   to the relevant output directories. See pkg.conf(5) for more info. 

以普通用户身份运行(看起来 winetricks 还是会找系统的32位wine)::

   /usr/local/share/wine/pkg32.sh install wine mesa-dri

大约占用2G磁盘空间

参考 `i386-Wine <https://wiki.freebsd.org/i386-Wine>`_ 应该按照以下方法进行::

   fetch -arRo /tmp/ https://download.freebsd.org/ftp/releases/amd64/13.1-RELEASE/lib32.txz
   tar -xpf /tmp/lib32.txz -C /
   pkg install i386-wine

.. note::

   这里提示没有找到 ``i386-wine`` ::

      pkg: No packages available to install matching 'i386-wine' have been found in the repositories

   此外和文档不同，ports中也没有找到 ``/usr/ports/emulator/i386-wine`` 

   和文档不同，也找不到 ``pkg install winetools`` 


然后就可以正常运行 ``winecfg`` 工具进行配置

winecfg配置
================

在 ``winecfg`` 配置中我主要进行以下调整:

- 调整分辨率，将默认 ``96dpi`` 调整成 ``110dpi`` 这样在MacBook Pro的高分辨率屏幕下字体较大较清晰
- 添加 ``C:`` 驱动器

完整介绍参考 `FreeBSD Handbook: 11.5.Configuring WINE Installation <https://docs.freebsd.org/en/books/handbook/wine/#configuring-wine-installation>`_

Winetricks
=================

``winetricks`` 工具是一个跨平台通用的WINE帮助程序，虽然不是WINE项目开发的，但是在GitHub上有不少贡献者维护。这个 ``winetricks`` 工具可以自动让常用程序能够在WINE上工作，主要是通过优化设置，即自动添加一些DLL库实现。

- 安装::

   #sudo pkg install i386-wine winetricks
   sudo pkg install winetricks

我已经在前文为自己账户目录安装了32位wine(并且确实找不到 ``i386-wine`` 包),所以这里只安装 ``winetricks`` 即可

使用winetricks
----------------

- 执行 ``winetricks`` ::

   winetricks

在显示界面选择 ``Install an application`` ，然后下一步就可以选择不同的应用程序，会自动设置好运行环境。例如而已安装 ``kindle`` ::

   You are using a 64-bit WINEPREFIX. Note that many verbs only install 32-bit versions of packages. If you encounter problems, please retest in a clean 32-bit WINEPREFIX before reporting a bug.

安装 ``kindle`` 非常顺利，最后提示::

   You may need to run with cpuset -l 0 to avoid a libX11 crash.

需要运行一次kindle，这个过程会自动安装大量的系统依赖dll，也为后续安装DingTalk程序打下基础。

wine网络问题
===================

我使用 ``winetricks`` 安装firefox并立即调用启动是能够正常使用网络访问百度，中文显示正常，而且能够使用fcitx5输入中文。

但是再次从菜单调用firefox则网络不通

似乎 ``wine cmd`` 命令显示的网络的默认网关是 ``0.0.0.0`` 没有获得本地主机的默认网关(显示的IP地址是本地网卡IP地址 192.168.1.11)

- 执行 ``wine cmd`` 进入wine的终端，尝试::

   ping xx.xx.xx.xx

提示信息::

   0348:err:winediag:IcmpCreateFile Failed to use ICMP (network ping), this requires special permissions.

这个问题是因为wine不希望作为root用户运行，但是一些特定文件需要运行权限，所以需要执行 (参考 `wine FAQ: 10.3.4 Failed to use ICMP (network ping), this requires special permissions <https://wiki.winehq.org/FAQ#Failed_to_use_ICMP_.28network_ping.29.2C_this_requires_special_permissions>`_ )::

   sudo setcap cap_net_raw+epi /usr/bin/wine-preloader

不过，在FreeBSD上没有找到这个 ``wine-preloader`` 文件。但是参考 `No internet in WINE 1.6.2 under Ubuntu 15.10 <https://askubuntu.com/questions/732436/no-internet-in-wine-1-6-2-under-ubuntu-15-10>`_ 有人提到::

   sudo setcap cap_net_raw+epi /usr/lib/wine/wine64

但是FreeBSD没有setcap?

NVIDIA
=========

使用wine时会提示::

   00f0:err:winediag:is_broken_driver Broken NVIDIA RandR detected, falling back to RandR 1.0. Please consider using the Nouveau driver instead.

参考 `wind FAQ: 10.3.6 Broken NVIDIA RandR detected, falling back to RandR 1.0 <https://wiki.winehq.org/FAQ#Broken_NVIDIA_RandR_detected.2C_falling_back_to_RandR_1.0>`_ :

RandR是一个应用程序和X server沟通修改屏幕分辨率等事项，但是nVida的驱动没有实现RandR的新版本，所以Wine抱怨

钉钉
======

`dingtalk-wine-2019: almost perfect solution found <https://github.com/recolic/dingtalk-wine-2019/issues/1>`_ 提到解决方法:

- run everything using WINEARCH=win32
- copy 32-bit riched20.dll & msftedit.dll from Windows 7 (or from Google)
- configure library override in winecfg (more specific, riched20 & msftedit change to native)
- everything works, screen shot & CJK character display in input box

Firefox
=========

- 命令行运行::

   WINEARCH=win32 wine firefox.exe

提示报错::

   wine: WINEARCH set to win32 but '/home/huatai/.wine' is a 64-bit installation.

**看来需要重新部署，把默认架构修改为32位**

参考 `How do I create a 32-bit WINE prefix? <https://askubuntu.com/questions/177192/how-do-i-create-a-32-bit-wine-prefix>`_ ::

   rm -rf ~/.wine

   WINEARCH=win32 WINEPREFIX=~/.wine wine wineboot

果然能够解决32位运行环境问题

不过，现在遇到的问题是，虽然安装时能运行firefox上网，但是安装之后再运行却不行了，页面无法打开。待继续

参考
======

- `FreeBSD Handbook: 11.3.Installing WINE on FreeBSD <https://docs.freebsd.org/en/books/handbook/wine/#installing-wine-on-freebsd>`_
- `WINE wiki: FreeBSD <https://wiki.winehq.org/FreeBSD>`_
