.. _archlinux_chinese:

===================
arch linux中文环境
===================

在 arch linux 中，我使用 :ref:`archlinux_sway` 桌面，并且使用 :ref:`fcitx` 结合 :ref:`linux_chinese_view` 来完成工作环境:

中文显示
===========

- 设置字符集支持 :ref:`locale_env` ， 配置 ``/etc/locale.gen`` 和 ``/etc/locale.conf`` :

.. literalinclude:: archlinux_chinese/archlinux_locale
   :language: bash
   :caption: 字符集支持UTF-8

- 安装文泉驿中文字体:

.. literalinclude:: archlinux_chinese/archlinux_fonts_wqy
   :language: bash
   :caption: arch linux安装文泉驿中文字体

中文输入法
============

- ( **我现在不使用** )安装 :ref:`fcitx` + 中文addons (依赖安装 fcitx5-qt ，所以安装软件非常大，有321MB):

.. literalinclude:: archlinux_chinese/archlinux_fcitx_chinese-addons
   :language: bash
   :caption: arch linux安装fcitx5和chinese-addons

- ( **如果在x86平台，我现在就使用这个rime输入法** 当前在 :ref:`archlinux_on_mba` 实践就使用这个方法) 使用 :ref:`fcitx` + Rime引擎(比较小巧，112MB) （ArchLinux没有提供ARM版本Rime，只有x86版本):

.. literalinclude:: archlinux_chinese/archlinux_fcitx_rime
   :language: bash
   :caption: arch linux安装fcitx5和rime输入引擎

- 安装 ``fcitx5-gtk`` 支持firefox输入，见下文:

.. literalinclude:: archlinux_chinese/archlinux_fcitx_gtk
   :caption: 为支持 ``firefox`` 中文输入框，需要安装 ``fcitx5-gtk``
   
配置中文输入法
=================

- 启用fcitx的输入需要配置环境变量，标准方式是修改 ``/etc/environment`` (通用于各种 :ref:`shell` )，添加以下配置

.. literalinclude:: ../desktop/chinese/fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment

- 按照 :ref:`sway` 配置标准方法，先复制全局配置到个人配置目录下:

.. literalinclude:: ../desktop/sway/run_sway/cp_sway_config
   :language: bash
   :caption: 复制sway个人配置

- 在个人配置定制文件 ``~/.config/sway/config`` 中添加一行:

.. literalinclude:: ../desktop/chinese/fcitx_sway/config_add
   :language: bash
   :caption: 在 ~/.config/sway/config 中添加运行 fcitx5 的配置

- 安装fcitx5-configtool::

   pacman -S fcitx5-configtool 

.. note::

   我觉得只要做好依次配置调整，将配置文件保存备用就可以了。配置文件是 ``.config/fcitx5`` 目录下文件

   目前 :ref:`archlinux_on_mba` 实践我是安装了这个软件包，然后通过 ``fcitx5-configtool`` 配置添加 ``rime`` 输入法，就可以使用 ``ctrl+space`` 切换中文输入法

配置
=======

- 执行 ``fcitx5-configtool`` 配置，有可能报错: 找不到 ``wayland`` 和 ``xcb`` 的QT插件，这是因为QT程序需要:

  - 安装 ``qt5-wayland``
  - 设置 ``/etc/environment`` ::

     QT_QPA_PLATFORM=wayland

使用
=======

- 使用 ``qterminal`` 较为方便，fcitx5对于QT5输入支持很完美，所以在sway环境使用qterminal输入中文还是很顺利的

- chromium依然没有解决中文输入，所以还是如 :ref:`run_sway` 一样使用firefox来支持中文输入。 :strike:`但是这次遇到奇怪问题，就是fcitx5的候选字不显示`
- 需要安装 ``fcitx5-gtk`` 才能在firefox中使用fcitx5输入法时候显示"候选字符"，否则看不到候选字词就只能盲打输入中文

- ``foot`` 终端没有输入框，根据 `arch linux: Fcitx5 <https://wiki.archlinux.org/title/Fcitx5>`_ 说明，目前arch linux稳定版本还没有集成 ``sway-im`` 包所提供的补丁，这个包需要通过 :ref:`archlinux_aur` 安装:

.. literalinclude:: archlinux_aur/install_yay
   :caption: 编译安装yay

.. note::

   需要翻墙否则:

   - :ref:`go_proxy`
   - :ref:`git_proxy`

.. literalinclude:: archlinux_chinese/sway-im
   :caption: 安装 ``sway-im``

.. note::

   ``sway-im`` 是用来取代 ``sway`` 的，所以最后提示 ``sway-im-1:1.9-2 and sway-1:1.9-5 are in conflict. Remove sway? [y/N]`` 回答 **y**

   替换以后，再次使用 ``sway`` (也就是补丁过的 ``sway-im`` )，就可以在 ``foot`` 中看到中文输入候选词框了，非常方便

alacritty
----------------

alacritty 虽然非常轻量级并且速度很快，但是fcitx5中文输入时无法显示选词，只能盲打输入中文 - 中文显示和输入是支持的，就是无法选词非常懊恼。

.. note::

   `Fcitx5 and Terminal <https://www.reddit.com/r/swaywm/comments/wirg48/fcitx5_and_terminal/>`_ 讨论了终端支持的配置，其中提到 ``sway`` 不支持选词框(除非程序在Xwayland中显示选词框)。QT应用不支持Wayland text-input-v3协议，所以需要使用DBus(设置 ``QT_IM_MODULE=fcitx5`` )。类似chromium也不使用text-input-v3。

参考 `alacritty无法使用输入法问题 <https://openwares.net/2020/01/14/alacritty-use-im/>`_ 提供了解决思路，就是将alacritty执行命令修订成::

   env WINIT_UNIX_BACKEND=x11 alacritty

这样渲染后端改为x11就行切换出中文输入法

此时提示::

   thread 'main' panicked at 'Failed to initialize X11 backend: XOpenDisplayFailed', /build/.cargo/registry/src/github.com-1ecc6299db9ec823/winit-0.27.4/src/platform_impl/linux/mod.rs:684:26
   note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

我没有近一步实践，而是改为使用 ``qterminal``

chrome
--------

我一直没有解决chrome中文输入问题，不过参考 `Fcitx Wayland(Sway) Support #292 <https://github.com/fcitx/fcitx5/issues/292>`_ 说明:

- chrome在sway(wayland)不能输入中文的bug和fcitx5无关，是由于chrome在ozone wayland平台不支持gtk im模块导致的: `Issue 1183262: Add support for gtk im module on ozone wayland platform <https://bugs.chromium.org/p/chromium/issues/detail?id=1183262>`_

- 参考 `无法在Chrome(Wayland)中使用fcitx5 #263 <https://github.com/fcitx/fcitx5/issues/263>`_ 提供的workroudn方法:

  - 系统安装 ``gtk4`` ，然后运行 chrome/chromium 时使用参数 ``--gtk-version=4`` ::

     chromium -enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4

  - **不过我尝试没有成功** 由于可以使用firefox作为主力浏览器，需求不高，我暂时放弃尝试

  - 有提示chrome安装kimpanel扩展，然后就能够在Gnome环境输入(感觉这个可能可以，但未尝试)

参考
=====

- `arch linux: Localization/Chinese <https://wiki.archlinux.org/title/Localization/Chinese>`_
- `arch linux: Fcitx5 <https://wiki.archlinux.org/title/Fcitx5>`_
- `arch linux: Rime <https://wiki.archlinux.org/title/Rime>`_ 使用 Rime输入引擎
