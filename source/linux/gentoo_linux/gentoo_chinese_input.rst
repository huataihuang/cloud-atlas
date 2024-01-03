.. _gentoo_chinese_input:

========================
Gentoo Linux中文输入
========================

版本选择
==========

默认的仓库提供的fcitx版本比较古早，是fcitx4系列稳定版本，而fcitx5.x则需要指定版本:

- ``fcitx5`` 支持 :ref:`wayland` ，对于我使用 :ref:`sway` 配置纯 ``wayland`` 运行环境是需要最新版本支持的

安装fcitx(归档)
====================

我选择 :ref:`fcitx` 以及比较轻巧的中州输入法:

.. literalinclude:: gentoo_chinese_input/fcitx
   :caption: 安装fcitx输入法以及中州输入

.. note::

   默认稳定版本还是 ``fcitx4`` ，要激活使用最新的 ``fcitx5`` 需要允许

.. note::

   默认 fcitx 的 USE flags 包含了 ``cairo`` (2D图形库，支持多种输出如X Window,Quartz,PostScript,PDF,SVG等) 和 ``pango`` (gnome的文本布局和渲染库) ，我暂时取消掉

安装fcitx5
==============


- 采用 :ref:`gentoo_version_specifier` 才能通过 :ref:`version_by_slot` 安装fcitx5

.. literalinclude:: gentoo_version_specifier/install_fcitx5
   :caption: 通过指定 ``:5`` SLOT来安装 fcitx5

.. note::

   对于非稳定版本，需要在 ``/etc/portage/make.conf`` 中添加 ``ACCEPT_KEYWORDS="~amd64"``

安装输入引擎
-------------

fcitx内置了非常简单的拼音输入法，所以通常会安装第三方输入法引擎:

- ``app-i18n/fcitx-cloudpinyin`` : `GitHub: fcitx-cloudpinyin <https://github.com/fcitx/fcitx-cloudpinyin>`_ 显示最近release是2019年11月8日
- ``app-i18n/fcitx-rime`` : `GitHub: fcitx-rime <https://github.com/fcitx/fcitx-rime>`_ 最近release是2017年9月15日
- ``app-i18n/fcitx-libpinyin`` : `GitHub: fcitx-libpinyin <https://github.com/fcitx/fcitx-libpinyin>`_ 最近release是2021年1月30日

总之，第三方输入法的开发不是很活跃，而且需要先自己构建 :ref:`gentoo_ebuild_repository` (自己定制ebuild) 以便通过 :ref:`gentoo_version_specifier` 指定 ``SLOT 5`` 进行安装。我在 :ref:`gentoo_ebuild_repository` 完整记录了如何针对 ``fcitx5`` 安装 ``fcitx-rime`` 。

.. note::

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

- `gentoo linux wiki: Fcitx <https://wiki.gentoo.org/wiki/Fcitx>`_
- `Using Fcitx 5 on Wayland <https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland>`_
- `Bug 760501 - app-i18n/fcitx-5 version bump <https://bugs.gentoo.org/760501>`_ 关于fcitx5的讨论
- `gentoo linux wiki: How to read and write in Chinese <https://wiki.gentoo.org/wiki/How_to_read_and_write_in_Chinese>`_ 推荐采用fcitx和fcitx-rime
