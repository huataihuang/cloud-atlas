.. _gentoo_chinese_input:

========================
Gentoo Linux中文输入
========================

安装fcitx
===========

我选择 :ref:`fcitx` 以及比较轻巧的中州输入法:

.. literalinclude:: gentoo_chinese_input/fcitx
   :caption: 安装fcitx输入法以及中州输入

.. note::

   默认 fcitx 的 USE flags 包含了 ``cairo`` (2D图形库，支持多种输出如X Window,Quartz,PostScript,PDF,SVG等) 和 ``pango`` (gnome的文本布局和渲染库) ，我暂时取消掉

编译错误排查
--------------

- 默认fcitx启用的USE Flags是 ``USE="autostart enchant gtk3 introspection nls table xkb -X -cairo -debug -gtk2 -lua -opencc -pango -test" LUA_SINGLE_TARGET="lua5-1 -lua5-3 -lua5-4"`` ，我在编译时候遇到报错:

.. literalinclude:: gentoo_chinese_input/build_fail_gtk
   :caption: 因为没有gtk导致编译失败
   :emphasize-lines: 3

为了能够最轻量级，我尝试去除掉 ``gtk3`` 甚至 ``qt5`` ``qt6``

配置fcitx
============

- 配置 ``/etc/environment`` :

.. literalinclude:: ../desktop/chinese/fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment

.. note::

   根据fcitx官方文档，当没有激活gtk/gtk3以及qt USE flag时，需要将对应配置行修订成 ``xim`` ::

      export GTK_IM_MODULE=xim
      export QT_IM_MODULE=xim

- 在个人配置定制文件 ``~/.config/sway/config`` 中添加一行:

.. literalinclude:: ../desktop/chinese/fcitx_sway/config_add
   :language: bash
   :caption: 在 ~/.config/sway/config 中添加运行 fcitx5 的配置

.. note::

   Gentoo Linux的 `app-i18n/fcitx <https://packages.gentoo.org/packages/app-i18n/fcitx>`_ 目前提供的是 4.2.9.8 ，所以安装以后命令和配置是 ``fcitx`` 而不是 ``fcitx5``

.. note::

   看起来 :ref:`gentoo_dbus` 是比较重要的功能，在 fcitx 的官方文档中说明fcitx和im模块之间是通过 dbus 通讯。所以我推测 ``fcitx-rime`` 输入法和 ``fcitx`` 之间还是需要 ``dbus`` 来通讯的，并且我看到默认启动的 ``fcitx`` 进程显示::

      /usr/bin/fcitx-dbus-watcher unix:path=/tmp/dbus-TPoXVu8TM0,guid=140f65b1a3552b97ddd7e9cd6505a51b 617

   和 :ref:`gentoo_chromium` 一样，默认启动了一个 ``dbus`` socket文件，这个应该有功能影响

.. note::

   我在Gentoo Linux中为了精简，去掉了所有 ``gtk`` 和 ``qt`` USE flag，所以执行 ``fcitx-configtool`` 时，是直接使用系统默认编辑器编辑配置文件。有点难搞

chromium
===========

对于chromium/Electron，如果使用原生wayland，在需要向 ``chromium`` 传递参数 ``--enable-wayland-ime`` :

.. literalinclude:: gentoo_chinese_input/chromium_wayland-ime
   :caption: 在原生Wayland环境，chromium支持fcitx中文输入需要传递 ``--enable-wayland-ime`` 参数

参考
=======

- `gentoo linux: Fcitx <https://wiki.gentoo.org/wiki/Fcitx>`_
- `Using Fcitx 5 on Wayland <https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland>`_
