.. _sway_gentoo:

============================
在Gentoo环境安装和使用Sway
============================

Sway有一些 USE flags 可以微调:


- 通过以下命令检查当前系统的USE flag:

.. literalinclude:: ../../gentoo_linux/install_gentoo_on_mbp/emerge_info
   :caption: 检查当前系统的USE flag

- 修订 ``/etc/portage/make.conf`` 添加以下USE flag作为全局配置:

.. literalinclude:: ../../gentoo_linux/install_gentoo_on_mbp/make.conf
   :caption: 全局USE配置
   :emphasize-lines: 23

- 添加 ``/etc/portage/package.use/sway`` 内容是针对单个应用的独立配置:

.. literalinclude:: sway_gentoo/sway
   :caption: ``/etc/portage/package.use/sway`` 配置独立参数

我发现实际上不配置 ``/etc/portage/package.use/sway`` 也行，也是默认启用了 ``man swaybar swaynag``

- 安装 sway :

.. literalinclude:: sway_gentoo/emerge_sway
   :caption: 安装sway

这里有一个提示:

.. literalinclude:: sway_gentoo/emerge_sway_output
   :caption: 安装sway提示

这个提示中 sway 的 ``wallpapers`` USE flag会触发:

.. literalinclude:: sway_gentoo/emerge_sway_output
   :caption: ``wallpapers`` 的USE Flag会触发 ``swaybg`` 安装
   :emphasize-lines: 5

如果USE flags 没有使用 ``-mesa`` 就会触发以下:

.. literalinclude:: sway_gentoo/emerge_sway_output
   :caption: ``mesa`` 的USE Flag会触发 ``libglvnd`` 安装
   :emphasize-lines: 10

我最终没有配置USE flag，使用默认参数安装

配置
======

- 将系统配置文件复制:



终端模拟器
============

默认终端模拟器是 ``foot`` ，一个非常轻量级的终端，但是可能对中文支持不好。

Gentoo的wiki中推荐 ``x11-terms/alacritty`` 是原生Wayland程序，而且使用 :ref:`rust` 编写，性能卓越。

应用程序加载器
=================

默认的应用程序加载器是 ``dmeuu`` 但是这个程序依赖X，所以推荐使用 ``dev-libs/bemenu`` （原生Wayland)替代

参考
======

- `gentoo wiki: Sway <https://wiki.gentoo.org/wiki/Sway>`_
