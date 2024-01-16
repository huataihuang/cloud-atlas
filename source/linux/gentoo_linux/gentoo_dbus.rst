.. _gentoo_dbus:

=================
Gentoo D-Bus
=================

:strike:`安装 firefox 时发现需要 dbus USE flag支持(现在默认不需要了)，不过 chromium 安装没有这个需求(我在考虑作为精简系统是否确实需要这个参数?)` ，在 :ref:`gentoo_sway_chinese_input` 可以看到 ``fcitx`` 是通过 ``dbus`` 和应用通讯的，所以修订 :ref:`install_gentoo_on_mbp` 配置。

D-Bus
=======

D-Bus是应用程序的一个进程间通讯(interprocess communication, ``IPC`` )系统。软件使用D-Bus实现服务间通讯。

.. note::

   有两种不同的 D-Bus 总线:

   - ``system bus`` : 和操作系统整体有关的消息总线，例如硬件连接和断开
   - ``session bus`` : 和特定用户会话有关的消息，例如 X 或 Wayland session

USE flags
============

全局 ``dbus`` USE flag 支持D-Bus。激活这个参数会自动拉取 ``sys-apps/dbus`` ，这也是 ``desktop`` profile默认激活的USE flag。(我在 :ref:`install_gentoo_on_mbp` 实践采用 ``no-multilib (stable)`` profile，构建轻量级服务器系统，则默认没有启用dbus)

- 编辑 ``/etc/protage/make.conf`` 激活全局D-Bus

.. literalinclude:: gentoo_dbus/dbus_make.conf
   :caption: 全局激活 ``dbus`` 

针对 ``sys-apps/dbus`` 应用有一些可能常用参数:

- ``X`` : 支持X11
- ``elogind`` : 登陆管理器增强版，用于提供 multiseat 增强，适合非 :ref:`systemd` 的init系统，但是也在KDE和GNOME环境中的一些流行程序中使用(例如可以实现普通用户关机和重启系统)
- ``systemd`` : 和 ``sys-apps/systemd`` at_console 支持一起编译

在修订了 ``dbus`` 全局参数之后，使用以下命令的 ``--changed-use`` 选项确保更新整个系统

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

配置
======

- 主要的配置文件有2个:

  - ``/usr/share/dbus-1/system.conf`` 用于 system bus
  - ``/usr/share/dbus-1/session.conf`` 用于 session bus

.. _dbus_system_bus:

D-Bus system bus: ``dbus`` 服务
=================================

D-Bus服务，也就是 OpenRC服务配置的 ``dbus`` service，是只负责 system bus 但不负责 session bus。

- 对于OpenRC，需要使用如下命令启动和激活 ``dbus`` 服务:

.. literalinclude:: gentoo_dbus/openrc_dbus
   :caption: 在OpenRC中激活和启动dbus服务

.. _dbus_session_bus:

D-Bus session bus
======================

对于 KDE 和 GNOME 桌面环境，需要自动启动一个session bus。不过，这个session bus一般没有自动启动，例如可能需要配置到 ``.xinitrc`` 中(假设终端登陆使用 ``startx`` 启动桌面)

- 检查在X或Wayland session 是否启动了 session bus，可以在桌面环境中启动一个终端，然后执行以下命令检查:

.. literalinclude:: gentoo_dbus/check_session_bus
   :language: bash
   :caption: 通过环境变量确认session bus是否支持

如果支持 session bus，则会显示一个 ``unix:path=`` 开头的字符串

- 为确保 X 或 Wayland 会话中具备了 D-Bus session，则可以通过 ``dbus-launch`` 来启动窗口管理器(例如 :ref:`i3` , bspwm 等)

.. literalinclude:: gentoo_dbus/dbus-launch
   :language: bash
   :caption: 使用 ``dbus-launch`` 来加载窗口管理器，确保窗口管理器会话支持 session bus

另外，在 :ref:`gentoo_sway` (参考官方 `gentoo wiki: Sway <https://wiki.gentoo.org/wiki/Sway>`_ )，采用 ``dbus-run-session`` 命令来运行 ``sway`` 应该也是确保 ``session bus`` 的方法:

.. literalinclude:: gentoo_sway/start_sway
   :caption: 使用 ``dbus-run-session`` 启动 sway 这样能够正确获得 :ref:`dbus_session_bus`

使用dbus案例
=============

- 一些有用的命令

  - ``dbus-monitor --system`` 监控system bus的活动
  - ``dbus-monitor --session`` 监控session bus的活动
  - ``dbus-send <PARAMETER>`` 发送消息

- 观察dbus服务::

   dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames

- 当使用elogind时候作为普通用户关机或重启系统::

   dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.PowerOff boolean:false
   dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.Reboot boolean:false

参考
=======

- `gentoo wiki: D-Bus <https://wiki.gentoo.org/wiki/D-Bus>`_
