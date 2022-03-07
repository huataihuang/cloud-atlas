.. _fcitx:

====================
小企鹅输入法fcitx
====================

安装
========

debian/ubuntu
-----------------

配置
=======

- 配置环境变量: 如果是 :ref:`xpra` 远程桌面配置 ``~/.bashrc`` ，如果是本地终端字符环境使用 ``startx`` 启动也可以配置 ``~/.xinitrc`` ，添加以下内容:

.. literalinclude:: fcitx/fcitx_bashrc
   :language: bash
   :caption: fcitx环境变量

- 在 ``.xinitrc`` 中启动 ``VM`` 之前加上::

   exec fcitx5 -d

如果是使用 :ref:`i3` 或者 :ref:`sway` 则需要在配置文件 ``~/.config/i3/config`` 使用::

   exec --no-startup-id fcitx5 -d

dwm配置
-----------

在 :ref:`dwm` 中配置中文输入法始终是一个困难，因为切换中文输入 ``ctrl+space`` 没有相应

之前使用字符终端 :ref:`fbterm` 会提示错误::

   (process: 13727): GLib-GIO-GRITICAL &&L 09L00:00:204: g_dbus_proxy_new: assertion 'G_IS_DBUS_CONNECTION (connection)' failed

如果图形界面使用终端中输入启动 ``fcitx`` 启动，也会遇到切换时报上述错误。看来输入法依赖 ``dbus`` 连接失败。参考 `Lubuntu - G_Is_Dbus_Connection <https://unix.stackexchange.com/questions/490871/lubuntu-g-is-dbus-connection>`_ 说明，通过移除 ``fcitx-module-dbus`` 来解决`

::

   sudo apt purge fcitx-module-dbus

提示会同时移除::

   fcitx-frontend-qt5* fcitx-module-dbus* fcitx-module-kimpanel*

不过，我发现并没有解决。而另一个建议是安装 ``fcitx-dbus-status`` 以及重新安装 ``Glib`` 和 ``fcitx``

我发现安装 ``fcitx-dbus-status`` 可以使得在 ``dwm`` 图形界面 ``rxvt-unicode`` 恢复了 ``ctrl+space`` 切换功能，但是依然无法确认输入。而其他应用如 surf firefox 依然无法使用 ``ctrl+space`` 。

参考 `[Solved] Cannot switch to Chinese input method on st terminal <https://bbs.archlinux.org/viewtopic.php?id=244438>`_ 需要补丁:

- `fix-ime <https://st.suckless.org/patches/fix_ime/>`_
- `fix-keyboard-input <https://st.suckless.org/patches/fix_keyboard_input/>`_

但是我发现最可能的还是和 ``dbus`` 有关，缺少 ``dubs`` 对用的 ``socket`` 文件，例如启动后可以看到进程::

   huatai    5523  0.3  0.8  85856 32480 ?        S    09:58   0:00 fcitx
   huatai    5529  0.0  0.0   7552  2816 ?        Ss   09:58   0:00 /usr/bin/dbus-daemon --syslog --fork --print-pid 5 --print-address 7 --config-file /usr/share/fcitx/dbus/daemon.conf
   huatai    5533  0.0  0.0   5632   180 ?        SN   09:58   0:00 /usr/bin/fcitx-dbus-watcher unix:abstract=/tmp/dbus-yksljWOulR,guid=674ccb725f1c35b011e04caf620c5a5b 5529

但是却没有生成 ``/tmp/dbus-yksljWOulR`` 这个文件

类似问题在之前 ``scim`` 也遇到，怀疑是 dwm 相关没有支持 dbus


参考
======

- `arch linux: Fcitx5 <https://wiki.archlinux.org/title/Fcitx5>`_
- `arch linux: Fcitx <https://wiki.archlinux.org/title/fcitx>`_
- `Debian Wiki: Fcitx5 <https://wiki.debian.org/l18n/Fcitx5>`_
- `Fcitx官方: Install Fcitx 5 <https://fcitx-im.org/wiki/Install_Fcitx_5>`_
- `在 Ubuntu Linux 上安装 Fcitx5 中文输入法 <https://zhuanlan.zhihu.com/p/415648411>`_ 
