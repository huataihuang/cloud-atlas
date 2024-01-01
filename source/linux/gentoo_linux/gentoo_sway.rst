.. _gentoo_sway:

============================
在Gentoo环境安装和使用Sway
============================

.. note::

   由于我尝试过多次 ``sway`` ，所以本文记录包含了几次实践的排查和曲折，有一点散乱。

   完整和修订过的指南参考 :ref:`gentoo_sway_bcloud` ，也就是我最近的实践汇总

我的 ``sway`` 实践记录
==========================

Sway有一些 USE flags 可以微调:

- 通过以下命令检查当前系统的USE flag:

.. literalinclude:: install_gentoo_on_mbp/emerge_info
   :caption: 检查当前系统的USE flag

- 修订 ``/etc/portage/make.conf`` 添加以下USE flag作为全局配置:

.. literalinclude:: install_gentoo_on_mbp/make.conf
   :caption: 全局USE配置
   :emphasize-lines: 23

- 添加 ``/etc/portage/package.use/sway`` 内容是针对单个应用的独立配置:

.. literalinclude:: gentoo_sway/sway
   :caption: ``/etc/portage/package.use/sway`` 配置独立参数

我发现实际上不配置 ``/etc/portage/package.use/sway`` 也行，也是默认启用了 ``man swaybar swaynag``

- 安装 sway :

.. literalinclude:: gentoo_sway/emerge_sway
   :caption: 安装sway

这里有一个提示:

.. literalinclude:: gentoo_sway/emerge_sway_output
   :caption: 安装sway提示

这个提示中 sway 的 ``wallpapers`` USE flag会触发:

.. literalinclude:: gentoo_sway/emerge_sway_output
   :caption: ``wallpapers`` 的USE Flag会触发 ``swaybg`` 安装
   :emphasize-lines: 5

如果USE flags 没有使用 ``-mesa`` 就会触发以下:

.. literalinclude:: gentoo_sway/emerge_sway_output
   :caption: ``mesa`` 的USE Flag会触发 ``libglvnd`` 安装
   :emphasize-lines: 10

配置
======

- 先将全局配置复制到个人目录下:

.. literalinclude:: ../desktop/sway/run_sway/cp_sway_config
   :language: bash
   :caption: 复制sway个人配置

- 启动:

.. literalinclude:: gentoo_sway/run_sway
   :caption: 直接运行 ``sway``

报错处理
============

- 启动 ``sway`` 报错:

.. literalinclude:: gentoo_sway/run_sway_err
   :caption: 直接运行 ``sway`` 报错

这是因为:

  - 没有安装和配置 ``seatd``
  - 没有设置好用户的环境变量 ``XDG_RUNTIME_DIR`` (也就是每个用户需要有独立分离的运行时目录)

解决方法:

- 安装 ``sys-auth/seatd`` 并且配置用户 ``huatai`` 到对应组，以及启动服务:

.. literalinclude:: gentoo_sway/seatd
   :language: bash
   :caption: 安装和配置 ``seatd``

- 然后为用户 ``huatai`` 配置 ``~/.bashrc`` 添加如下内容设置用户环境变量:

.. literalinclude:: gentoo_sway/bashrc
   :language: bash
   :caption: 配置用户环境变量 ``~/.bashrc``

``seatd`` 需要配置为服务器
---------------------------

在上述添加用户到 ``seat`` 组时遇到报错::

   gpasswd: group 'seat' does not exist in /etc/group

并且执行添加 ``seatd`` 服务也报错::

   # rc-update add seatd default
    * rc-update: service `seatd' does not exist`

原因参考 `sys-auth/seatd does not come with initscript <https://forums.gentoo.org/viewtopic-p-8776236.html?sid=066c3d5bd9e07f98c1f5c586381a8e99>`_ 需要为 ``seat`` 添加 ``server`` 和 ``builtin`` USE flag:

.. literalinclude:: gentoo_sway/seatd_use_flags
   :caption: 为 ``sys-auth/seatd`` 配置 USE flag

foat终端
-----------

- 补充安装 ``foot`` (因为默认配置中使用了 ``foot`` 作为终端):

.. literalinclude:: gentoo_sway/install_foot
   :caption: 安装foot终端软件

.. note::

   我发现在安装 ``foot`` 的依赖包 ``dev-libs/libutf8proc`` 提供了一个 USE flag ``cjk`` 是用来支持Multi-byte character languages (Chinese, Japanese, Korean)

现在就能正常启动 ``sway`` 了，不过此时还不能充分发挥高分辨率屏幕特性，待继续优化...

高分辨率
==========

- ``swaymsg`` 可检查系统硬件，其中检查显示屏如下:

.. literalinclude:: gentoo_sway/swaymsg_outputs
   :caption: 检查当前连接显示器

例如我的笔记本显示:

.. literalinclude:: gentoo_sway/swaymsg_outputs_output
   :caption: 检查当前连接显示器输出案例(苹果笔记本内置显示器)

- 在 ``~/.config/sway/config`` 可以添加多个显示器配置，例如以下是3个并排显示器配置，且第三个显示器垂直旋转:

.. literalinclude:: gentoo_sway/sway_config_multi_display
   :caption: 配置3个显示器的案例


终端模拟器
============

默认终端模拟器是 ``foot`` ，一个非常轻量级的终端， :strike:`但是可能对中文支持不好` (我这次实践开启了 ``cjk`` :ref:`gentoo_use_flags` 发现中文显示很好)

Gentoo的wiki中推荐 ``x11-terms/alacritty`` 是原生Wayland程序，而且使用 :ref:`rust` 编写，性能卓越。

应用程序加载器
=================

默认的应用程序加载器是 ``dmenu`` 但是这个程序依赖X，所以推荐使用 ``dev-libs/bemenu`` （原生Wayland)替代

参考
======

- `gentoo wiki: Sway <https://wiki.gentoo.org/wiki/Sway>`_
- `“XDG_RUNTIME_DIR is not set in the environment. Aborting.” error reported by sway whenever I attempt to launch it. <https://www.reddit.com/r/freebsd/comments/lryw8a/xdg_runtime_dir_is_not_set_in_the_environment/>`_
- `gentoo wiki: Seatd <https://wiki.gentoo.org/wiki/Seatd>`_
