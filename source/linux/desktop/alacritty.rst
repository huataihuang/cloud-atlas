.. _alacritty:

=======================================
GPU加速终端模拟器alacritty
=======================================

Alacritty 是一个简单的，GPU加速的终端模拟器，使用 :ref:`rust` 语言编写

- 在 :ref:`arch_linux` 中安装Alacritty::

   pacman -S alacritty

配置
=======

Alacritty按照以下顺序查找配置文件:

- $XDG_CONFIG_HOME/alacritty/alacritty.yml
- $XDG_CONFIG_HOME/alacritty.yml
- $HOME/.config/alacritty/alacritty.yml
- $HOME/.alacritty.yml

可以将 ``/usr/share/doc/alacritty/example/alacritty.yml`` 配置文件复制到上述位置进行修改

色彩
=======

`alacritty Color schemes <https://github.com/alacritty/alacritty/wiki/Color-schemes>`_ 提供了色彩配置

- 可设置终端字体大小，在配置文件的size，opacity是设置透明度，必须有compton支持::

   pacman -S compton

字体
========

- 使用以下命令获取字体名字::

   fc-list : family style

例如，我要配置中文字体 ``文泉驿微米黑`` ::

   WenQuanYi Micro Hei,文泉驛微米黑,文泉驿微米黑:style=Regular

- 配置::

   font:
     normal:
       #family: WenQuanYi Micro Hei
       family: monospace
       style: Regular
   
     size: 18

.. note::

   在 alacritty中按下快捷键 ``ctrl -`` 缩小字体，按下 ``ctrl +`` 放大字体

中文输入法
==============

.. note::

   我使用wayland纯环境，没有激活xwayland

- alacritty中文显示需要设置::

   export LANG=zh_CN.UTF-8 #或者其他UTF-8，并且安装中文字体

- 在 :ref:`wayland` 环境需要修订成X启动，也就是在 ``/usr/share/applications/Alacritty.desktop`` 中修改带 Exec的行为::

   TryExec=env WINIT_UNIX_BACKEND=x11 alacritty
   Exec=env WINIT_UNIX_BACKEND=x11 alacritty

参考
======

- `arch linux: Alacritty <https://wiki.archlinux.org/title/Alacritty>`_
- `arch调教 <https://agvszwk.github.io/2019/09/07/arch调教/>`_ 提供了不少桌面设置经验可参考
