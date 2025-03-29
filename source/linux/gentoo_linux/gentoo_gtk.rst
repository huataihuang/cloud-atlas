.. _gentoo_gtk:

=================
Gentoo GTK
=================

GTK是GNOME的底层核心，是用于创建图形用户接口的toolkit。虽然我在 Gentoo Linux 上主要使用 :ref:`gentoo_sway` ，但是也会使用部分基于GTK的应用

.. note::

   有没有可能完全不使用 GTK / QT 来运行桌面？目前我的轻量级 :ref:`gentoo_sway` 实际上主要使用 :ref:`firefox` 和 ``foot`` (终端)，而我计划把所有桌面应用都迁移到 :ref:`docker` 和 :ref:`gentoo_flatpak` 中运行。 **待实践**

安装
======

.. note::

   目前我的图形桌面主要是 :ref:`gentoo_sway` 以及在 :ref:`gentoo_sway_fcitx` 安装依赖中相应安装的 GTK 库。所以实际上我并没有独立执行命令进行安装，以下安装命令仅供参考

- 安装 ``gtk-2`` 和 ``gtk-3`` 是通过安装 ``x11-libs/gtk+`` 完成:

.. literalinclude:: gentoo_gtk/install_gtk_2_3
   :caption: 安装GTK-2和GTK-3

- 安装 ``gtk-4`` :

.. literalinclude:: gentoo_gtk/install_gtk_4
   :caption: 安装GTK-4

配置
========

- 可以安装LXDE桌面( :ref:`lxqt` )提供的 ``lxde-base/lxappearance`` 来调整GTK toolkit显示 (目前我在 :ref:`gentoo_sway` 中运行会crash，感觉缺少一些依赖，待排查)

使用dark theme
====================

GTK3
-------

- 配置 ``~/.config/gtk-3.0/settings.ini`` (个人) 或者 ``/etc/gtk-3.0/settings.ini`` (全局) :

.. literalinclude:: gentoo_gtk/gtk_3_dark_theme_settings.ini
   :caption: 配置 ``~/.config/gtk-3.0/settings.ini`` (个人) 或者 ``/etc/gtk-3.0/settings.ini`` (全局) 设置GTK themes暗黑模式
   :emphasize-lines: 2

不过，需要注意不是所有风格启用暗黑模式都美观， ``Adwaita`` 暗黑似乎不太清晰

参考
=======

- `gentoo wik: GTK <https://wiki.gentoo.org/wiki/GTK>`_
