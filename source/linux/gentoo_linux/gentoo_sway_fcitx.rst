.. _gentoo_sway_fcitx:

================================
Gentoo Linux Sway fcitx中文输入
================================

.. warning::

   由于我在 ``Gentoo + Sway + fcitx`` 上折腾了一周多时间，所以本文记录比较混乱，包含我的多次探索记录。我准备在后续重新完成一次部署，预计在重新 :ref:`install_gentoo_on_mbp` 之后再次部署，撰写修订笔记。待完成...

.. note::

   sway基于 :ref:`wayland` native程序，中文输入法选择 :ref:`fcitx` ，实践中有很多坑和挫折，远比

   - :ref:`ubuntu_linux` 环境 :ref:`fcitx_sway`
   - :ref:`archlinux_sway` 环境构建 :ref:`archlinux_chinese`

   **困难很多**

   Gentoo Linux在主流软件上非常稳健，但是实验性软件(非主流)则不如 :ref:`arch_linux` 和 :ref:`ubuntu_linux` 发行版。可能主要原因是使用者、维护者相对少一些，也缺乏商业支持。

   不过，通过折腾Gentoo Linux，所有的报错和底层排障都会加深你对系统的认知，也提高你的解决能力。得失之间，需要你自己把控。

版本选择
==========

默认的仓库提供的fcitx版本比较古早，是fcitx4系列稳定版本，而fcitx5.x则需要指定版本:

- ``fcitx5`` 支持 :ref:`wayland` ，对于我使用 :ref:`sway` 配置纯 ``wayland`` 运行环境是需要最新版本支持的

安装fcitx(归档)
====================

我选择 :ref:`fcitx` 以及比较轻巧的中州输入法:

.. literalinclude:: gentoo_sway_fcitx/fcitx
   :caption: 安装fcitx输入法以及中州输入

.. note::

   默认稳定版本还是 ``fcitx4`` ，要激活使用最新的 ``fcitx5`` 需要允许

.. note::

   默认 fcitx 的 USE flags 包含了 ``cairo`` (2D图形库，支持多种输出如X Window,Quartz,PostScript,PDF,SVG等) 和 ``pango`` (gnome的文本布局和渲染库) ，我暂时取消掉

安装fcitx5
==============

.. note::

   参考 `gentoo linux wiki: Fcitx <https://wiki.gentoo.org/wiki/Fcitx>`_ 建议应用程序编译 :ref:`gentoo_use_flags` 启用 ``gtk2`` 或者 ``gtk3`` 

- 采用 :ref:`gentoo_version_specifier` 才能通过 :ref:`version_by_slot` 安装fcitx5

.. literalinclude:: gentoo_version_specifier/install_fcitx5
   :caption: 通过指定 ``:5`` SLOT来安装 fcitx5

.. note::

   对于非稳定版本， :strike:`需要在 /etc/portage/make.conf 中添加 ACCEPT_KEYWORDS="~amd64"` (不建议全局添加 ``ACCEPT_KEYWORDS="~amd64"`` )采用在 ``/etc/portage/packages.use`` 针对特定软件包添加USE关键字 ``~amd64``

安装输入引擎
-------------

fcitx内置了非常简单的拼音输入法，所以通常会安装第三方输入法引擎:

- ``app-i18n/fcitx-cloudpinyin`` : `GitHub: fcitx-cloudpinyin <https://github.com/fcitx/fcitx-cloudpinyin>`_ 显示最近release是2019年11月8日
- ``app-i18n/fcitx-rime`` : `GitHub: fcitx-rime <https://github.com/fcitx/fcitx-rime>`_ 最近release是2017年9月15日
- ``app-i18n/fcitx-libpinyin`` : `GitHub: fcitx-libpinyin <https://github.com/fcitx/fcitx-libpinyin>`_ 最近release是2021年1月30日

总之，第三方输入法的开发不是很活跃，而且需要先自己构建 :ref:`gentoo_ebuild_repository` (自己定制ebuild) 以便通过 :ref:`gentoo_version_specifier` 指定 ``SLOT 5`` 进行安装。我在 :ref:`gentoo_ebuild_repository` 完整记录了如何针对 ``fcitx5`` 安装 ``fcitx-rime`` 。

.. note::

   **已改变策略** 实际我现在选择 ``fcitx-rime``

   由于安装第三方输入法涉及到大量的依赖库，并且第三方输入法开发不活跃，所以目前我考虑先使用 ``fcitx5`` 内置拼音输入法。如有必要再尝试 ``fcitx-libpinyin`` 或 ``fcitx-rime``

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

异常排查
============

fcitx5的 :ref:`gentoo_dbus` 相关报错
--------------------------------------

再次进入 ``sway`` 之后，通过 ``ps`` 命令检查可以看到 ``fcitx5`` 进程已经启动，不过没有看到有托盘图标(应该是我还没有安装托盘组件)，但是遇到一个问题，按下 ``ctrl+space`` 没有看到浮现中文输入框

我改为终端运行 ``fcitx5`` (杀掉后台进程，直接在终端执行 ``fcitx5`` ) ，看到 ``fcitx5`` 运行的终端显示报错信息似乎与 :ref:`gentoo_dbus` 有关:

.. literalinclude:: gentoo_sway_fcitx/fcitx5_dbus
   :caption: 控制台fcitx5启动时 :ref:`gentoo_dbus` 相关错误
   :emphasize-lines: 6,7

我调整 :ref:`gentoo_dbus` 的 ``/etc/portage/make.conf`` 添加:

.. literalinclude:: gentoo_dbus/dbus_make.conf
   :caption: 全局激活 ``dbus``

使用 ``--changed-use`` 选项确保更新整个系统

.. literalinclude:: gentoo_use_flags/rebuild_world_after_change_use
   :caption: 在修改了全局 USE flag 之后对整个系统进行更新

完成后检查，发现 ``fcitx5`` 运行报错依旧，这是窗口管理器 :ref:`dbus_session_bus` 没有创建，仔细看了 Gentoo Sway 文档，原来 ``sway`` 需要通过shell脚本包装 ``XDG_RUNTIME_DIR`` 变量，并且使用 ``dbus-run-session`` 命令来启动(方法一) 或者 采用 ``elogind`` 加入到启动服务中(来完成环境变量设置)，然后使用 ``dbus-run-session`` (方法二)，这样才能实现 :ref:`dbus_session_bus` (详见 :ref:`gentoo_sway` ):

**我采用方法一** :

安装 ``sys-auth/seatd`` 并且配置用户 ``huatai`` 到对应组，以及启动服务:

.. literalinclude:: gentoo_sway/seatd
   :language: bash
   :caption: 安装和配置 ``seatd`` ， ``seat`` USE flag必须添加 ``server`` 和 ``builtin``

为用户 ``huatai`` 配置 ``~/.bashrc`` 添加如下内容设置用户环境变量:

.. literalinclude:: gentoo_sway/bashrc
   :language: bash
   :caption: 配置用户环境变量 ``~/.bashrc``

最后使用 ``dbus-run-session`` 来启动 ``sway`` :

.. literalinclude:: gentoo_sway/start_sway
   :caption: 使用 ``dbus-run-session`` 启动 sway 这样能够正确获得 :ref:`dbus_session_bus`

再次前台运行 ``fcitx5`` 可以看到连接成功，但是出现了新的关于DBus调用错误:

.. literalinclude:: gentoo_sway_fcitx/fcitx5_dbus_call
   :caption: 控制台fcitx5启动时 DBus调用错误
   :emphasize-lines: 23

参考 `[Bug]: The name org.freedesktop.portal.Desktop was not provided by any .service files #5201 <https://github.com/flatpak/flatpak/issues/5201>`_ : 需要安装 ``xdg-desktop-portal`` 已经和特定桌面环境相关的后端软件，例如GNOME Shell 需要安装 ``xdg-desktop-portal-gnome`` ， KDE Plasma需要安装 ``xdg-desktop-portal-kde`` ，对于gtk环境则安装 ``xdg-desktop-portal-gtk`` 等。这个软件包是 `Flatpak <https://flatpak.org/>`_ 开发的，已经用于很多应用软件，如gimp, firefox, slack 等。:

- 安装 ``xdg-desktop-portal`` :

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal
   :caption: 安装 ``xdg-desktop-portal``

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal-wlr
   :caption: 安装面向 :ref:`wayland` 的 ``xdg-desktop-portal-wlr``


还是没有解决 **控制台fcitx5启动时 DBus调用错误** 仔细看了报错信息::

   portalsettingmonitor.cpp:115] DBus call error: org.freedesktop.DBus.Error.ServiceUnknown The name org.freedesktop.portal.Desktop was not provided by any .service files

:strike:`看来这个配置确实缺乏，暂无头绪`

这个报错信息看起来是获取 Desktop 名字的，但是 ``xdg-desktop-portal-wlr`` 似乎没有提供? 但是我突然注意到 :ref:`gentoo_xdg-desktop-portal` 安装了 ``xdg-desktop-portal-wlr`` 默认配置 ``/usr/share/xdg-desktop-portal/sway-portals.conf`` 

.. literalinclude:: gentoo_xdg-desktop-portal/sway-portals.conf
   :caption: ``/usr/share/xdg-desktop-portal/sway-portals.conf``
   :emphasize-lines: 2,3

原来 ``xdg-desktop-portal-wlr`` 默认依赖 ``xdg-desktop-portal-gtk`` 来提供 ``interface`` ，所以必须得安装 

.. literalinclude:: gentoo_xdg-desktop-portal/install_xdg-desktop-portal-gtk
   :caption: ``xdg-desktop-portal-wlr`` 默认使用 ``xdg-desktop-portal-gtk`` 提供portal接口，所以同时安装 ``sys-apps/xdg-desktop-portal-gtk``

.. warning::

   还是没有解决 fcitx5 调用 DBus 的报错，😷

.. warning::

   **文档中每一句话都可能隐藏深意** ``每一句话可能都是关键``

   官方文档中提到 **Important** :

   Starting Sway with dbus requires that XDG_RUNTIME_DIR is set. elogind or systemd will set this if used. 

   **Omitting the dbus-run-session may cause runtime errors.**

.. note::

   其他启用 :ref:`dbus_session_bus` 方法可以使用 ``dbus-launch`` (这个命令可以在shell环境中以session bus方式运行程序)

   例如 `Sway 下到底怎么用输入法？ <https://emacs-china.org/t/sway/14189/4>`_ ::

      dbus-launch --exit-with-session sway

   "条条大路通罗马" 这也是确保 ``DBUS_SESSION_BUS_ADDRESS`` 方法，在 :ref:`gentoo_dbus` 官网文档 `gentoo wiki: D-Bus <https://wiki.gentoo.org/wiki/D-Bus>`_ : 为确保 X 或 Wayland 会话中具备了 D-Bus session，则可以通过 ``dbus-launch`` 来启动窗口管理器(例如 :ref:`i3` , bspwm 等)

   .. literalinclude:: gentoo_dbus/dbus-launch
      :language: bash
      :caption: 使用 ``dbus-launch`` 来加载窗口管理器，确保窗口管理器会话支持 session bus

   另外 `医学生折腾Gentoo Linux记 <https://zhuanlan.zhihu.com/p/462322143>`_  (有不少注意点)提到使用以下方法(这个方法是 `archlinux wiki: Fcitx5 <https://wiki.archlinuxcn.org/wiki/Fcitx5>`_ 文档中记录的) ::

      exec --no-startup-id fcitx5 -d

一点疑惑
-----------

:ref:`gentoo_dbus` 是重要的功能，在 fcitx 的官方文档中说明fcitx和im模块之间是通过 dbus 通讯。所以我推测 ``fcitx-rime`` 输入法和 ``fcitx`` 之间还是需要 ``dbus`` 来通讯的，并且我看到默认启动的 ``fcitx`` 进程显示::

   /usr/bin/fcitx-dbus-watcher unix:path=/tmp/dbus-TPoXVu8TM0,guid=140f65b1a3552b97ddd7e9cd6505a51b 617

和 :ref:`gentoo_chromium` 一样，默认启动了一个 ``dbus`` socket文件，这个应该有功能影响

.. warning::

   我在2024年1月的实践中，采用了上述指定 ``SLOT 5`` 方式安装了 ``fcitx5`` ，但是发现一个问题，没有配套的软件包可以安装，例如，没有 ``fcitx5-data`` ，也没有 ``xcb-imkit`` ，我对比了以下 :ref:`fedora_os_images` 中 Fedora Sway (以LiveCD方式运行)，安装 ``fcitx5`` 时候会配套安装相应组件:

   .. literalinclude:: gentoo_sway_fcitx/fedora_sway_install_fcitx5
      :caption: Fedora Sway安装fctix5

   参考 `SWAY配置中文输入法 <https://zhuanlan.zhihu.com/p/379583988>`_ 提到的使用 ``gentoo-zh`` 社区overlay仓库，其中也依赖安装 ``x11-libs/xcb-imdkit`` 和 ``app-i18n/libime`` 等包

使用 ``gentoo-zh`` :ref:`gentoo_overlays` 仓库
==============================================

实在难以解决，不想再折腾中文输入，改为参考 `SWAY配置中文输入法 <https://zhuanlan.zhihu.com/p/379583988>`_ 使用 ``gentoo-zh`` :ref:`gentoo_overlays` 仓库

.. note::

   详细折腾请参考 `Bug 760501 - app-i18n/fcitx-5 version bump <https://bugs.gentoo.org/760501>`_ 在一些非常用软件维护上，Gentoo使用不如 :ref:`arch_linux`

- :ref:`gentoo_emerge` 卸载之前已经安装的 ``SLOT 5`` 的 ``fcitx`` :

.. literalinclude:: gentoo_overlays/uninstall_fcitx5
   :caption: 卸载之前已经安装的 ``SLOT 5`` 的 ``fcitx``

- 激活 ``gentoo-zh`` 仓库:

.. literalinclude:: gentoo_overlays/enable_repository
   :caption: 激活 ``gentoo-zh`` 仓库

安装步骤参考了 `Gentoo 教程：系统完善 <https://blog.csdn.net/niuiic/article/details/109151402>`_

- 使用 ``emaint`` 对新添加Portage进行软件库同步:

.. literalinclude:: gentoo_overlays/emaint_sync
   :caption: 使用 ``emaint`` 同步新添加的软件库

- 配置 ``/etc/portage/package.accept_keywords/fcitx5`` :

.. literalinclude:: gentoo_sway_fcitx/package.accept_keywords.fcitx5
   :caption: 配置 ``/etc/portage/package.accept_keywords/fcitx5``

- 执行安装:

.. literalinclude:: gentoo_sway_fcitx/emerge_fcitx5_overlay
   :caption: 安装overlay的fcitx5

安装输出信息(依赖安装包)

.. literalinclude:: gentoo_sway_fcitx/emerge_fcitx5_overlay_output
   :caption: 安装overlay的fcitx5输出信息

Error with fcitx5-config-qt
===============================

.. literalinclude:: gentoo_sway_fcitx/fcitx5-config-qt
   :caption: could'nt found fcitx5-config-qt

refer `安装fcitx5-chinese-addons遇到的问题 #512  <https://github.com/microcai/gentoo-zh/issues/512>`_ :

- fcitx5 need KDE to run ``fcitx5-config-qt`` , else must use kcm-fcitx to config; I have try install ``kcm-fcitx`` but it not include in gentoo-zh overlay, so failed
- ``kcmshell5 fcitx5`` maybe from ``kcm-fcitx5`` package? 

解决线索
=========

使用 ``gentoo-zh`` :ref:`gentoo_overlays` 确实可以安装更多相关软件包， :strike:`但是目前我还没有解决输入法唤起，所以还没有解决输入问题。` ，我最终通过了一些曲线方法来完成配置，见下文 **最终解决**

仔细看了一下 `目前大家是怎样在 wayland 中使用中文输入法的？ <https://bbs.archlinuxcn.org/viewtopic.php?id=12660>`_ (原帖是针对 :ref:`arch_linux` )，发现还有一些底层原理需要学习(可能解决的线索):

原帖问题有关 `can not show up input interface on arch linux sway wm #39 <https://github.com/fcitx/fcitx5/issues/39>`_

``q234rty`` 提到: sway 下对于 wayland native 的程序来说，有两种可能

- 通过 GTK_IM_MODULE/QT_IM_MODULE，目前来说不需要特殊配置，只需要设置环境变量就能工作。注意 chromium 对此的支持有一定问题（electron 则暂时不支持），见 `Chrome/Chromium 今日 Wayland 输入法支持现状 <https://www.csslayer.info/wordpress/fcitx-dev/chrome-state-of-input-method-on-wayland/>`_
- 通过 wayland 的 text_input/input_method 系列协议，需要 `Implement input_method_v2 popups #5890 <https://github.com/swaywm/sway/pull/5890>`_ ，目前 archlinuxcn 有 sway-im 这个包提供打上此补丁的 sway，另 aur 也有 `sway-im-git <https://aur.archlinux.org/packages/sway-im-git>`_ 。目前来说 sway 下只有支持 text-input-v3 的程序（包括绝大部分 gtk 3/4 程序（这里同样不包括 chromium/electron）和一部分终端模拟器，如 kitty/foot）能通过这个方法进行输入。 ``<=`` **这里是重点**

参考 `can not show up input interface on arch linux sway wm #39 <https://github.com/fcitx/fcitx5/issues/39>`_ :

- maybe use Xwayland application can use input method
- compositor <-> application is using text_input (v1 v2 v3...)
- compositor <-> input method is using input method (v1 v2): v1 is included in wayland-protocols, and there is also input method v2 which contributed by prism inc, but fcitx don't support that yet
- **sway is using the v2** so fcitx can't yet work with it, also since v2 remove the input panel positioning part, fcitx developer don't yet know where to move the input method window with the protocol.

and say:

.. literalinclude:: gentoo_sway_fcitx/profile
   :caption: environment for sway (but my try is failed)

then ``exec --no-startup-id fcitx5 -d`` in sway config, and enable wayland in ``fcitx5-configtool``

**Now fcitx is support sway** : `gentoo+sway无法在WPS、foot、dingtalk应用中显示输入法候选窗口 #455 <https://github.com/fcitx/fcitx5/issues/455>`_ :

- 我也是这个现象，参考了这个issue重新调整了 :ref:`gentoo_use_flags` 并重新编译( 详见 :ref:`gentoo_kde_fcitx`
- 我没有解决 foot/ :ref:`alacritty` 中中文候选窗口显示，不过在 :ref:`gentoo_kde_fcitx` 中使用 foot / alacritty 则中文候选窗口显示正常

.. note::

   `fcitx开发者CS Slayer <https://www.csslayer.info/wordpress/>`_ 个人博客围绕着fcitx提供了很多学习线索，如果要了解wayland环境下中文输入法的原理可以参考其博客

最终解决方法
===================

最终我采用了一个取巧的方法:

- 完成 :ref:`gentoo_kde_fcitx` ，将能够正确用于KDE环境的fcitx配置文件同样用于sway环境
- 经过验证，确认基本无需调整就能正常工作，唯一的缺点是 foot 等终端无法显示输入候选词窗口。这个问题的解决看来需要使用 :ref:`arch_linux` 的一个 `sway-im <https://aur.archlinux.org/packages/sway-im>`_ 补丁来解决，我尚未实践

KDE
============

:ref:`gentoo_kde` 提供了交互配置工具运行的环境，所以我尝试先安装KDE基本运行环境:

.. literalinclude:: gentoo_kde/install_plasma-desktop
   :caption: ``kde-plasma/plasma-desktop``

当运行 ``fcitx5-configtool`` 提示以下错误 :

.. literalinclude:: gentoo_sway_fcitx/fcitx5-configtool_kde_error
   :caption: run fcitx5-configtool in kde, error

``kcm-fcitx`` 是一个和KDE高度集成的配置工具, ``kcm`` 意思是 ``KDE configuration module`` , 在安装了 ``kcm-fcitx`` 之后, 可以在KDE谁知中看到 ``Input Method`` 配置:

但是 ``kcm-fcitx`` :ref:`cmake` ( either in relase 0.5.6 , or in git version ) 报错:

.. literalinclude:: gentoo_sway_fcitx/kcm-fcitx_cmake_error
   :caption: ``kcm-fcitx`` :ref:`cmake` errors

在 ``fcitx5-qt`` 源代码中, ``qt5/dbusaddons/Fcitx5Qt5DBusAddonsConfig.cmake.in`` 提供了这个cmake配置。

.. warning::

   我最终没有解决这个编译问题，似乎是 ``kcm-fcitx``  长时间不活跃开发，已经无法在最新的KDE环境编译。所以我采用了上文所述的取巧方法，在一个运行KDE的虚拟机中生成配置文件复制到 sway 环境使用。验证是可行的。

编译 ``librime-octagram`` 依赖报错处理
=======================================

2024年1月 :ref:`upgrade_gentoo` 遇到 ``librime-octagram`` 依赖编译报错:

.. literalinclude:: gentoo_sway_fcitx/librime-octagram_error
   :caption: 编译 ``app-i18n/librime-octagram`` 报错
   :emphasize-lines: 3,4

搜索关键字 ``1.7.2`` 以排查 :ref:`gentoo_sway_fcitx` 报错的软件包版本:

.. literalinclude:: gentoo_emerge/list_installed_1.7.2
   :caption: 检查系统已经安装的软件包版本包含 ``1.7.2`` 版本信息

输出显示:

.. literalinclude:: gentoo_emerge/list_installed_1.7.2_output
   :caption: 检查系统已经安装的软件包版本包含 ``1.7.2`` 版本信息输出内容
   :emphasize-lines: 3

- 配置 ``/etc/portage/package.accept_keywords/fcitx5`` 添加对应 ``~amd64`` :

.. literalinclude:: gentoo_sway_fcitx/package.accept_keywords.fcitx5
   :caption: 配置 ``/etc/portage/package.accept_keywords/fcitx5``
   :emphasize-lines: 15,16

chromium
===========

对于chromium/Electron，如果使用原生wayland，在需要向 ``chromium`` 传递参数 ``--enable-wayland-ime`` :

.. literalinclude:: gentoo_sway_fcitx/chromium_wayland-ime
   :caption: 在原生Wayland环境，chromium支持fcitx中文输入需要传递 ``--enable-wayland-ime`` 参数

奇怪，究竟 ``unwind`` 版本 ``1.7.2`` 不符合 ``1.8.0`` 要求是哪个软件包？

通过 :ref:`gentoo_emerge` 方法 ``equery`` 查询:

.. literalinclude:: gentoo_emerge/list_installed_1.7.2_output
   :caption: 检查系统已经安装的软件包版本包含 ``1.7.2`` 版本信息输出内容
   :emphasize-lines: 3

通过 ``| grep 1.7.2`` 可以找到 ``sys-libs/libunwind-1.7.2`` ，也就是需要添加 ``sys-libs/libunwind`` 的 ``~amd64`` unstable标记来安装必要的对应 1.8.0 版本

参考
=======

- `gentoo linux wiki: Fcitx <https://wiki.gentoo.org/wiki/Fcitx>`_
- `Using Fcitx 5 on Wayland <https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland>`_
- `Bug 760501 - app-i18n/fcitx-5 version bump <https://bugs.gentoo.org/760501>`_ 关于fcitx5的讨论
- `gentoo linux wiki: How to read and write in Chinese <https://wiki.gentoo.org/wiki/How_to_read_and_write_in_Chinese>`_ 推荐采用fcitx和fcitx-rime
- `Use Plasma 5.24 to type in Alacritty (Or any other text-input-v3 client) with Fcitx 5 on Wayland <https://www.csslayer.info/wordpress/linux/use-plasma-5-24-to-type-in-alacritty-or-any-other-text-input-v3-client-with-fcitx-5-on-wayland/>`_ KDE环境使用Wayland时的fcitx5
- `Chrome/Chromium 今日 Wayland 输入法支持现状 <https://www.csslayer.info/wordpress/fcitx-dev/chrome-state-of-input-method-on-wayland/>`_ fcitx开发者的blog，技术细节满满
- `Gentoo設定Overlay，從第三方軟體庫安裝最新版Fcitx5中文輸入法 <https://ivonblog.com/posts/gentoo-overlay-setup/>`_
