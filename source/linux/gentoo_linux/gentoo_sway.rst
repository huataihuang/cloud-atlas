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

- :strike:`启动` 测试( **注意单纯sway命令会有环境配置问题，需要仔细设置** ):

.. literalinclude:: gentoo_sway/run_sway
   :caption: 直接运行 ``sway``

``XDG_RUNTIME_DIR``
=======================

- 启动 ``sway`` 报错:

.. literalinclude:: gentoo_sway/run_sway_err
   :caption: 直接运行 ``sway`` 报错

这是因为:

  - 没有安装和配置 ``seatd``
  - 没有设置好用户的环境变量 ``XDG_RUNTIME_DIR`` (也就是每个用户需要有独立分离的运行时目录)

解决方法一
--------------

解决方法:

- 安装 ``sys-auth/seatd`` 并且配置用户 ``huatai`` 到对应组，以及启动服务:

.. literalinclude:: gentoo_sway/seatd
   :language: bash
   :caption: 安装和配置 ``seatd``

在上述添加用户到 ``seat`` 组时遇到报错::

   gpasswd: group 'seat' does not exist in /etc/group

并且执行添加 ``seatd`` 服务也报错::

   # rc-update add seatd default
    * rc-update: service `seatd' does not exist`

原因参考 `sys-auth/seatd does not come with initscript <https://forums.gentoo.org/viewtopic-p-8776236.html?sid=066c3d5bd9e07f98c1f5c586381a8e99>`_ 需要为 ``seat`` 添加 ``server`` 和 ``builtin`` USE flag:

.. literalinclude:: gentoo_sway/seatd_use_flags
   :caption: 为 ``sys-auth/seatd`` 配置 USE flag

然后重新编译安装 ``seat``

- 然后为用户 ``huatai`` 配置 ``~/.bashrc`` 添加如下内容设置用户环境变量:

.. literalinclude:: gentoo_sway/bashrc
   :language: bash
   :caption: 配置用户环境变量 ``~/.bashrc``

还有一个类似脚本，可以参考:

.. literalinclude:: gentoo_sway/bashrc_xdg
   :language: bash
   :caption: 配置用户环境变量 ``~/.bashrc`` 的另一个脚本

- 最后(手工)执行启动命令中添加 ``dbus-run-session`` :

.. literalinclude:: gentoo_sway/start_sway
   :caption: 使用 ``dbus-run-session`` 启动 sway 这样能够正确获得 :ref:`dbus_session_bus`

解决方法二
------------

.. note::

   我理解 ``elogind`` 是为了帮助设置DBUS环境的，上文通过环境变量和脚本设置了 ``XDG_RUNTIME_DIR`` ，则这段不用执行

``elogind`` 需要添加到 boot 运行级别:

``/etc/portage/make.conf`` 添加:

.. literalinclude:: gentoo_sway/elogind_make.conf
   :caption: 配置关闭 ``systemd`` 启用 ``elogind``

执行USE修订后重新更新系统

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

.. literalinclude:: gentoo_sway/elogind
   :caption: 对于 :ref:`openrc` 环境支持运行 强依赖 :ref:`systemd` 的应用程序(KDE或GNOME)需要部署 ``elogind`` 来代替 ``systemd logind``

.. note::

   当 :ref:`gentoo_dbus` 使用了 ``USE="elogind"`` 参数，则系统启动 ``elogind`` 会自动触发启动 ``dbus``

.. note::

   当使用了 ``elogind`` 或 ``systemd`` ，则会自动设置 ``XDG_RUNTIME_DIR`` ，否则就要自己手工设置

   **没有 dbus-run-session 支持，sway 运行可能出现运行时错误**

.. warning::

   我最终没有使用这段方案，即没有安装 ``elogind`` ，而是采用上文手工命令方式(方案一)

系统程序
============

安装和 ``sway`` 底层系统相关的一些基础实用程序:

``bemenu``
----------------

由于常用的 ``dmenu`` 使用X，所以现在基于 :ref:`wayland` 的 :ref:`sway` 推荐使用 ``dev-libs/bemenu`` :

.. literalinclude:: gentoo_sway/install_bemenu
   :caption: 安装 ``bemenu`` 代替 ``dmenu``

然后配置 ``~/.config/sway/config`` 将默认的 ``dmenu`` 行替换成 ``bemenu`` :

.. literalinclude:: gentoo_sway/sway_config_bemenu
   :caption: 配置 ``~/.config/sway/config`` 将 ``dmenu`` 替换成 ``bemenu``
   :emphasize-lines: 4,5

``swaylock``
-----------------

``gui-apps/swaylock`` 用于锁定当前会话

.. literalinclude:: gentoo_sway/install_swaylock
   :caption: 安装 ``swaylock``

然后配置 ``~/.config/sway/config`` 将 ``$mod + l`` 作为锁屏快捷键:

.. literalinclude:: gentoo_sway/sway_config_swaylock
   :caption: ``~/.config/sway/config`` 配置锁屏快捷键

``swayidle``
----------------

``gui-apps/swayidle`` 可以在系统进入idle一段时间后运行一个命令，典型的如锁定屏幕或者关闭显示屏:

.. literalinclude:: gentoo_sway/install_swayidle
   :caption: 安装swayidle

然后将 ``~/.config/sway/config`` 中有关 ``swayidle`` 的功能恢复出来(去除行首的 ``#`` ):

.. literalinclude:: gentoo_sway/sway_config_swayidle
   :caption: ``~/.config/sway/config`` 中有关 ``swayidle`` 激活
   :emphasize-lines: 5-8

应用程序
=============

foat终端
-----------

- 补充安装 ``foot`` (因为默认配置中使用了 ``foot`` 作为终端):

.. literalinclude:: gentoo_sway/install_foot
   :caption: 安装foot终端软件

.. note::

   我发现在安装 ``foot`` 的依赖包 ``dev-libs/libutf8proc`` 提供了一个 USE flag ``cjk`` 是用来支持Multi-byte character languages (Chinese, Japanese, Korean)

现在就能正常启动 ``sway`` 了，不过此时还不能充分发挥高分辨率屏幕特性，待继续优化...

终端模拟器
--------------

默认终端模拟器是 ``foot`` ，一个非常轻量级的终端， :strike:`但是可能对中文支持不好` (我这次实践开启了 ``cjk`` :ref:`gentoo_use_flags` 发现中文显示很好)

Gentoo的wiki中推荐 ``x11-terms/alacritty`` 是原生Wayland程序，而且使用 :ref:`rust` 编写，性能卓越。

应用程序加载器
---------------------

默认的应用程序加载器是 ``dmenu`` 但是这个程序依赖X，所以推荐使用 ``dev-libs/bemenu`` （原生Wayland)替代

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

参考
======

- `gentoo wiki: Sway <https://wiki.gentoo.org/wiki/Sway>`_
- `“XDG_RUNTIME_DIR is not set in the environment. Aborting.” error reported by sway whenever I attempt to launch it. <https://www.reddit.com/r/freebsd/comments/lryw8a/xdg_runtime_dir_is_not_set_in_the_environment/>`_
- `gentoo wiki: Seatd <https://wiki.gentoo.org/wiki/Seatd>`_
