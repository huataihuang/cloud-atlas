.. _ibus_xpra:

======================
Xpra远程ibus中文输入
======================

.. note::

   本文实践环境在远程访问 :ref:`pi_400` 上运行的 :ref:`raspberry_pi_os` ，通过 :ref:`xpra` 图形环境访问。实践还存在问题，待后续补充完善

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


