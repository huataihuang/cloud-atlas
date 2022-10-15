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

- 安装 :ref:`fcitx` + 中文addons (依赖安装 fcitx5-qt ，所以安装软件非常大，有321MB):

.. literalinclude:: archlinux_chinese/archlinux_fcitx_chinese-addons
   :language: bash
   :caption: arch linux安装fcitx5和chinese-addons

- (可选，如果在x86平台) 使用 :ref:`fcitx` + Rime引擎: （ArchLinux没有提供ARM版本Rime，只有x86版本):

.. literalinclude:: archlinux_chinese/archlinux_fcitx_rime
   :language: bash
   :caption: arch linux安装fcitx5和rime输入引擎
   
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

配置
=======

- 执行 ``fcitx5-configtool`` 配置，有可能报错: 找不到 ``wayland`` 和 ``xcb`` 的QT插件，这是因为QT程序需要:

  - 安装 ``qt5-wayland``
  - 设置 ``/etc/environment`` ::

     QT_QPA_PLATFORM=wayland

使用
=======

- alacritty 虽然非常轻量级并且速度很快，但是fcitx5中文输入时无法显示选词，只能盲打输入中文 - 中文显示和输入是支持的，就是无法选词非常懊恼。或许fcitx还有什么配置?

.. note::

   `alacritty无法使用输入法问题 <https://openwares.net/2020/01/14/alacritty-use-im/>`_ 提供了解决思路，就是将alacritty执行命令修订成::

      env WINIT_UNIX_BACKEND=x11 alacritty

   这样渲染后端改为x11就行切换出中文输入法。不过这样需要运行 xwayland ，需要另外安装

- 使用 ``qterminal`` 较为方便，fcitx5对于QT5输入支持很完美，所以在sway环境使用qterminal输入中文还是很顺利的

- chromium依然没有解决中文输入，所以还是如 :ref:`run_sway` 一样使用firefox来支持中文输入。但是这次遇到奇怪问题，就是fcitx5的候选字不显示，有点类似 alacritty

参考
=====

- `arch linux: Localization/Chinese <https://wiki.archlinux.org/title/Localization/Chinese>`_
- `arch linux: Fcitx5 <https://wiki.archlinux.org/title/Fcitx5>`_
- `arch linux: Rime <https://wiki.archlinux.org/title/Rime>`_ 使用 Rime输入引擎
