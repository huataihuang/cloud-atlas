.. _fcitx_sway:

==========================
sway窗口管理器使用fcitx5
==========================

我 :ref:`install_kali_pi` ，使用体验发现默认的 :ref:`xfce` 对于ARM架构的 :ref:`pi_400` 还是过于沉重，所以尝试切换到基于 :ref:`wayland` 的 :ref:`sway` ，实践下来体验非常接近完美(资源占用极小)。

:ref:`sway` 使用非常现代化的 :ref:`wayland` 显示服务，这要求应用软件进行适配，所以也带来很多不兼容的问题。根据网上资料， :ref:`fcitx` 已经支持 sway ，并且根据我以往经验，fcitx配置也较为简便，兼容性不错，性能也比较好。所以，我经过一些尝试，成功在 :ref:`sway` 环境使用 :ref:`fcitx` 进行中文输入和日常工作。

安装和配置
============

- :ref:`kali_linux` 基于debian，软件非常丰富且安装简便::

   sudo apt install fcitx5 fcitx5-chinese-addons

- 启用fcitx的输入需要配置环境变量，标准方式是修改 ``/etc/environment`` (通用于各种 :ref:`shell` )，添加以下配置

.. literalinclude:: fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment

- 按照 :ref:`sway` 配置标准方法，先复制全局配置到个人配置目录下:

.. literalinclude:: ../sway/run_sway/cp_sway_config
   :language: bash
   :caption: 复制sway个人配置 

.. note::

   ``sway`` 的全局配置文件 ``/etc/sway/config.d/50-systemd-user.conf`` 从系统用户环境导入变量，执行了以下两条命令::

      exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK

      exec hash dbus-update-activation-environment 2>/dev/null && \
              dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

- 在个人配置定制文件 ``~/.config/sway/config`` 中添加一行:

.. literalinclude:: fcitx_sway/config_add
   :language: bash
   :caption: 在 ~/.config/sway/config 中添加运行 fcitx5 的配置

- 重启系统，这样环境变量和sway配置都生效，登陆到 ``sway`` 系统中，就会看到右上角有一个 ``fcitx`` 运行图标

- 执行 ``fcitx5-configtool`` 进行配置，注意，在sway环境，这个配置工具依赖 QT 运行，但是默认由于没有安装插件，会出现报错信息如下::

   qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""
   qt.qpa.xcb: could not connect to display 
   qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
   This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.

   Available platform plugins are: eglfs, linuxfb, minimal, minimalegl, offscreen, vnc, xcb.

   zsh: abort      fcitx5-configtool

解决方法通过观察上文报错可以得知，缺少 ``wayland`` 插件和 ``xcb`` 插件支持。所以对应安装::

   sudo apt install qtwayland5 qt5dxcb-plugin

再次运行 ``fcitx5-configtool`` 就能正常配置。

其他待解决问题
===================

参考
========

- `WAY配置中文输入法 <https://zhuanlan.zhihu.com/p/379583988>`_
