.. _pi_os_chinese:

==========================
Raspberry Pi OS中文处理
==========================

和 :ref:`xpra_chinese_input` 类似(原文是 :ref:`fedora_develop` 环境)，在 :ref:`raspberry_pi_os` (基于 ``debian`` )，需要安装中文字体和输入法来完成中文工作环境部署。

安装中文字体
===============

在Linux环境中，目前最好的中文字体是 ``文泉驿`` ，只需要安装一种微米黑字体就足够了::

   sudo apt install fonts-wqy-microhei

此时打开 :ref:`surf` 访问中文网站，已经能够看到非常漂亮的中文了。

安装输入法
============

:strike:`输入法依然使用轻量级 fcitx`

输入法选择参考 `arch linxu Input method <https://wiki.archlinux.org/title/Input_method>`_ ，目前支持中文输入主要有以下集中输入框架:

- fcitx5 轻量级输入法，目前再次活跃开发
- ibus debian默认输入框架，很多发行版默认
- scim 似乎不再活跃开发
- nimf 似乎非常小众的轻量级输入框架，韩国人开发的

fcitx
--------

- 结合 :ref:`fbterm` 安装 fcitx ::

   sudo apt install fcitx fcitx-frontend-fbterm

- 修改 ``.initrc`` :

.. literalinclude:: ../../../linux/desktop/chinese/fcitx/fcitx_bashrc
   :language: bash
   :caption: fcitx环境变量

ibus(失败)
----------

- 安装::

   sudo apt install ibus ibus-libpinyin

- 修改 ``.initrc`` ::

   export XMODIFIERS=@im=ibus
   export GTK_IM_MODULE=ibus
   export QT_IM_MODULE=ibus

   ibus-daemon -drx

   exec dwm

- 登陆系统后，可以使用 ``ibus-setup`` 进行设置

我遇到问题是可以似乎可以呼出 ibus ，但是没有浮动窗口，也无法提示

tile窗口管理器设置ibus
~~~~~~~~~~~~~~~~~~~~~~~~

- 登陆系统在终端执行::

   ibus engine

提示信息::

   No engine is set.

- 查看引擎列表::

   ibus list-engine

选择对应引擎::

   ibus engine libpinyin

.. note::

   `i3-wm gaps can't switch ibus method <https://www.reddit.com/r/i3wm/comments/jct4ti/i3wm_gaps_cant_switch_ibus_method/>`_ 提供了一个简单的切换脚本

但是，发现在终端中启动了 ``leafpad`` ，尝试切换一次中文，然后输入却没有中文，看终端显示报错::

   Process Key Event failed: GDBus.Error.org.gtk.GDBus.UnmappedGError.Quark._g_2dio_2derror_2dquark.Code18: The connection is closed.

我感觉错误应该和 dbus 相关，之前 scim 不能输入中文应该也是这个原因

结合 xpra
------------

- 修改 ``~/.bashrc`` 添加::

   export XMODIFIERS=@im=ibus
   export GTK_IM_MODULE=ibus
   export QT_IM_MODULE=ibus

重新登陆一次系统，然后检查 ``env | grep IM`` 可以看到环境变量已经生效::

   GTK_IM_MODULE=ibus
   QT_IM_MODULE=ibus
   XDG_RUNTIME_DIR=/run/user/502

- 启动 ``xpra`` 环境::

   xpra start :11 && DISPLAY=:11 screen -S xpra

- 登陆到 ``screen`` 中::

   screen -R xpra

启动 ``ibus`` 放入后台::

   ibus-daemon -drx

此时检查进程::

   ps aux | grep ibus

可以看到::

   huatai   20125  0.3  0.2  71388  8160 ?        Ssl  22:39   0:03 ibus-daemon -drx
   huatai   20129  0.0  0.1  31740  4356 ?        Sl   22:39   0:00 /usr/libexec/ibus-memconf
   huatai   20130  0.1  0.8 117776 33296 ?        Sl   22:39   0:01 /usr/libexec/ibus-ui-gtk3
   huatai   20132  0.3  0.5  67852 20104 ?        Sl   22:39   0:03 /usr/libexec/ibus-extension-gtk3
   huatai   20134  0.0  0.4  56296 17636 ?        Sl   22:39   0:01 /usr/libexec/ibus-x11 --kill-daemon
   huatai   20139  0.0  0.1  40356  4076 ?        Sl   22:39   0:00 /usr/libexec/ibus-portal
   huatai   20291  0.0  0.1  31736  4312 ?        Sl   22:39   0:00 /usr/libexec/ibus-engine-simple

`Setting the DBus address for IBus <https://github.com/ibus/ibus/issues/1969>`_ 给出了一个DBus 地址的提示::

   /run/user/<userid>/ibus.socket

可以通过配置 ``/usr/bin/ibus-daemon`` 的参数指定socket

我检查了 ``~/.config/ibus/bus/`` 目录下似乎有对应配置，例如 ``3f31fd0b2aec4b6792f96a3fc0213821-unix-11`` 内容就是::

   # This file is created by ibus-daemon, please do not modify it.
   # This file allows processes on the machine to find the
   # ibus session bus with the below address.
   # If the IBUS_ADDRESS environment variable is set, it will
   # be used rather than this file.
   IBUS_ADDRESS=unix:abstract=/home/huatai/.cache/ibus/dbus-yQB7GtBl,guid=7a2a254f4e414d6d2683edea6206751d
   IBUS_DAEMON_PID=20125

这里的 ``IBUS_DAEMON_PID=20125`` 通过检查 ``ibus-daemon`` 就可以看到::

   ps aux | grep ibus

显示::

   huatai   20125  0.3  0.2  71388  8160 ?        Ssl  22:39   0:03 ibus-daemon -drx
   ...

但是，很奇怪，找不到 ``IBUS_ADDRESS`` 对应的socket地址::

   /home/huatai/.cache/ibus/dbus-yQB7GtBl

也许是这个原因导致我无法呼出中文输入？

不过，我在macOS的状态托盘中，是可以看到 ``ibus`` 的图标的，有时候居然还能看到中文图标。或许和 xpra 兼容性还是存在问题。后续在主机上直接操作看是否能够正常工作。

`Using modifier key combinations to switch layouts <https://wiki.archlinux.org/title/IBus#Using_modifier_key_combinations_to_switch_layouts>`_ 可以通过 ``gsettings`` 设置快捷键(就无需 ``ibus-setup`` )::

   gsettings set org.freedesktop.ibus.general.hotkey triggers "['VALUE']"

例如，这里 ``<Alt>Shift_R`` 来配置右shift快捷键

fcitx5(失败)
----------------

- 安装::

   sudo apt install fcitx5 fcitx5-chinese-addons

但是，尝试安装 ``fcitx5-chinese-addons`` 出现报错::

   The following packages have unmet dependencies:
    fcitx5-chinese-addons : Depends: fcitx5-chinese-addons-bin but it is not installable
                            Depends: fcitx5-pinyin but it is not installable
                            Depends: fcitx5-table but it is not installable
   E: Unable to correct problems, you have held broken packages. 

检查了一下，发现仓库并没有提供上述3个软件包

由于我想尝试 :ref:`fbterm` ，但是终端中文输入 ``fcitx-fbterm`` 在最新的 ``fcitx5`` 中已经不再提供，加上安装 ``fcitx5`` 失败，所以我改为安装旧版本 ``fcitx`` 系列

scim(失败)
------------

fcitx5需要安装大量软件包，对于我的轻量级系统过于沉重，所以尝试采用 ``scim输入法```

- 基础安装::

   sudo apt install scim scim-sunpinyin

也可以安装 ``scim-pinyin`` ，不过历史上 ``sunpinyin`` 基于统计调整输入，可能更好一些

- 配置: 在 ``~/.xinitrc`` 中添加以下配置::

   export XMODIFIERS=@im=SCIM
   export GTK_IM_MODULE="scim"
   export QT_IM_MODULE="scim"
   scim -d
   exec dwm

.. note::

   注意，这里我使用的窗口管理器是 :ref:`dwm`

- 重新登陆一次X Window系统，然后通过 ``ctrl+space`` 就可以呼出 ``scim`` 输入法。不过，我发现此时只显示2种键盘 ``English/Keyboard`` 和 ``English/European`` ，怎么能够把安装的 ``sunpinyin`` 添加上去呢？

``scim-setup`` 无法启动，我发现将鼠标聚焦到输入位置，然后按下 ``[ctrl]+[space]`` ，如果该图形程序支持中文输入，则会自动出现 ``sunpinyin`` ，然后可以通过 ``[shift]`` 按键切换。

不过，存在问题是输入几个中文以后，无法继续，切换也无法恢复中文输入。实在折腾不动...

.. note::

   但是反复尝试，发现 ``scim`` 设置过于复杂了，我实在难以搞定切换，虽然也能输入，但是莫名卡顿并中断中文输入。所以最后还是退守使用 fcitx 

参考
=====

- `Debian Wiki: Fcitx5 <https://wiki.debian.org/l18n/Fcitx5>`_
- `Fcitx官方: Install Fcitx 5 <https://fcitx-im.org/wiki/Install_Fcitx_5>`_
- `Gentoo IBus <https://wiki.gentoo.org/wiki/IBus>`_
- `i3-wm gaps can't switch ibus method <https://www.reddit.com/r/i3wm/comments/jct4ti/i3wm_gaps_cant_switch_ibus_method/>`_
- `Getting Ibus working with tiling window manager <https://unix.stackexchange.com/questions/277692/getting-ibus-working-with-tiling-window-manager>`_
