.. _gentoo_flatpak:

================
Gentoo Flatpak
================

以前我是不愿使用 Flatpak 或者 Snap 这样独立的类似 :ref:`docker` 完全包含完整运行环境的程序包。主要是感觉每个Flatpak需要自己占用一套依赖库，消耗了大量的磁盘空间，也和Linux的精简共享库运行模式相违背。不过，我将自己的工作平台转为Gentoo之后，深感构建 :ref:`linux_desktop` 的不易，特别是:

- Gentoo相对小众，我选择的轻量级桌面管理器 :ref:`sway` 更是小众中的小众，在解决 :ref:`gentoo_sway_fcitx` 花费了大量的时间精力依然差强人意
- 我希望保持物理主机的系统精简化，力求将桌面应用缩小到GTK支持上以减少编译和折腾，但是也带来了部分应用如 :ref:`keepassxc` 无法运行(并且我也去掉了 :ref:`gentoo_sway_fcitx` 对QT的输入支持)
- 经过一个月的磨合，我已经构建了基本的轻量级 :ref:`sway` 桌面，我不再想把时间花费在桌面上，而想集中精力学习 :ref:`machine_learning` / :ref:`kubernetes` 等服务器端技术

此时， ``flatpak`` 技术为我带来桌面应用的简化:

- 和底层操作系统隔离
- 提供丰富的桌面应用
- 无需自己编译和解决安装依赖

安装
==========

USE flags
----------------

``sys-apps/flatpak`` 的一些有用的USE flags:

- ``X`` : 支持X11
- ``systemd`` : 使用 :ref:`systemd` 特定库和功能，例如socket activation 或者 session tracking

:ref:`gentoo_emerge`
----------------------

.. note::

   基于Chromium的浏览器建议禁用 ``sys-apps/bubblewrap`` 的 ``suid`` USE flag，以避免性能影响。但是一些类似 Valve Pressure Vessel(用于Steam)需要 ``suid`` 激活才能工作。当关闭 ``suid`` 时， ``bubblewrap`` 需要内核选项 ``CONFIG_USE_NS=y`` 设置。

添加 flathub 仓库
--------------------

.. note::

   ``flatpak`` 可以由用户或root来操作，对于没有系统权限的个人用户，可以使用 ``--user`` 参数来使用

.. literalinclude:: gentoo_flatpak/add_flathub
   :caption: 个人用户添加 flathub

.. note::

   可能需要 :ref:`proxychains` :ref:`across_the_great_wall`

配置
============

文件列表:

- ``/var/lib/flatpak`` : 全局flatpak状态(系统级安装应用和仓库)
- ``$HOME/.local/share/flatpak`` : 每个用户各自的flatpak状态(本地安装应用和仓库)
- ``$HOME/.var/app/`` 每个应用状态(配置文件和缓存)

基本使用
===============

Theming
-------------

Flatpak文档提供了 `Flatpak Desktop Integration <https://docs.flatpak.org/en/latest/desktop-integration.html>`_ (待实践)

GTK
------

Flatpak应用默认不跟随系统的GTK theme，所以需要找出当前 :ref:`gentoo_gtk` theme，然后在Flatpak应用中安装和使用:

.. literalinclude:: gentoo_flatpak/gtk-theme
   :caption: 安装GTK theme(这里案例是  ``Materia-dark-compact`` )

Wayland桌面集成
------------------

在使用 :ref:`gentoo_sway` 桌面，需要安装 ``xdg-desktop-portal`` 实现才能集成Flakpak，这个安装步骤我在 :ref:`gentoo_sway_fcitx` 实践中，已经安装了 :ref:`gentoo_xdg-desktop-portal` :

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal
   :caption: 安装 ``xdg-desktop-portal``

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal-wlr
   :caption: 安装面向 :ref:`wayland` 的 ``xdg-desktop-portal-wlr``

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal-gtk
   :caption: ``xdg-desktop-portal-wlr`` 默认使用 ``xdg-desktop-portal-gtk`` 提供portal接口，所以同时安装 ``sys-apps/xdg-desktop-portal-gtk``

Flathub安装应用
==================

KeepassXC
--------------

在 `Flathub <https://flathub.org/>`_ 官网上可以搜索到应用，按照安装指南进行安装。以 :ref:`keepassxc` 为例，安装如下:

.. literalinclude:: gentoo_flatpak/install_keepassxc
   :caption: 安装 Flathub 官网提供的 :ref:`keepassxc`

运行:

.. literalinclude:: gentoo_flatpak/run_keepassxc
   :caption: 运行 Flathub 官网提供的 :ref:`keepassxc`

终端运行上述命令显示输出:

.. literalinclude:: gentoo_flatpak/run_keepassxc_output
   :caption: 运行 Flathub 官网提供的 :ref:`keepassxc` 终端输出信息
   :emphasize-lines: 10

这里虽然有提示 ``qt.qpa.wayland: Wayland does not support QWindow::requestActivate()`` 但是在 :ref:`gentoo_sway` 环境运行没有影响

意外之喜:

在 ``Flatpak`` 中运行的 :ref:`keepassxc` 可以支持中文显示，而且 **支持中文输入** 。也就是说:

  - host主机我只需要安装 :ref:`gentoo_chinese_view` 和 :ref:`gentoo_sway_fcitx` 就可以支持Flatpak的程序中文显示输入
  - 并且 :ref:`fcitx` 不需要 QT 支持，也不需要 GTK 支持就可以输入中文(有待进一步实践验证)

这样的运行模式可以精简我的 :ref:`gentoo_sway` 工作环境:

  - 只需要最小化的编译安装 :ref:`gentoo_sway` 桌面
  - 由于我使用的图形软件极少，完全可以不用安装部署GTK/QT/Gnome/KDE就能够运行 `Flathub <https://flathub.org/>`_ 官网提供的图形软件，大大减轻了我的桌面部署心智负担
  - 可以专注与服务器端技术，将有限的精力投入到开发和AI

Calibre
---------------

:ref:`kindle` 需要 Calibre 协助在不同平台阅读和转换文档格式，所以我也通过Flatpak来安装这个较为复杂庞大的软件(我 :ref:`install_gentoo_on_mbp` 现在采用了非常精简的 :ref:`gentoo_use_flags` 剔除了gtk和qt的支持):

.. literalinclude:: gentoo_flatpak/install_calibre
   :caption: 安装 Flathub 官网提供的 Calibre

运行:

.. literalinclude:: gentoo_flatpak/run_calibre
   :caption: 运行 Flathub 官网提供的 Calibre

.. note::

   我在 :ref:`gentoo_sway` 环境运行不太顺利，设置 ``Perferences`` 对话框时候无法正常显示，没有更进一步使用。可能后续再自己折腾吧


Chrome
---------

Flatpak应用的配置文件
=======================

Flatpak应用的配置位于个人的 ``~/.var/app/`` 目录下，分别按照不同的应用分开。例如 chromium 和 :ref:`keepassxc` 则是::

   org.chromium.Chromium
   org.keepassxc.KeePassXC

目录下包含了应用各自的配置和缓存以及用户数据

参考
=======

- `gentoo linux: Flatpak <https://wiki.gentoo.org/wiki/Flatpak>`_
- `Can't find where Chromium flatpak keeps config files <https://forums.gentoo.org/viewtopic-p-8793427.html>`_
