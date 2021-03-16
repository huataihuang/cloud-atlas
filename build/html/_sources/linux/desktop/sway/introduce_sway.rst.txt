.. _introduce_sway:

==========================
sway平铺式窗口管理器简介
==========================

树莓派上的sway
=================

树莓派官方Raspberry Pi OS没有直接提供Sway窗口管理器，不过，第三方树莓派镜像，例如Arch Linux和基于Arch Linux的Manjaro都已经提供了Sway + Wayland，可以直接安装运行在 :ref:`pi_4` 和 :ref:`pi_400` 。

sway继承了i3简洁的窗口管理能力，并且提供了基于现代化 :ref:`wayland` 的技术。

.. figure:: ../../../_static/linux/desktop/sway/ubuntu-sway.jpg
   :scale: 30

参考 Arch Linux的Manjaro发行版，Manjaro Sway包含了在底部共用键盘快捷键的对话框，并且使用应用程序launcher(Wofi)来使用快捷键。可以结合一些轻量级应用来完成日常工作:

- Pamac Manager
- Firefox
- Thunar
- Ranger
- Neovim
- Foliate
- MPV Media Player

Sway使用要点
===============

- Sway不支持NVIDIA闭源驱动，必须使用开源的Nouveau驱动，所以建议使用支持开源更好的AMD或Intel显卡。
- 部分登陆管理器支持Wayland，所以要小心选择扽路管理器。建议使用字符界面启动sway，如果要自动登陆，可以在 ``.bash_profile`` 中添加::

   # If running from tty1 start sway
   if [ "$(tty)" = "/dev/tty1"  ]; then
    exec sway
   fi

- 个人配置文件位于 ``~/.config/sway`` ，建议从全局配置复制过来进行修改::

   mkdir -p ~/.config/sway
   cp /etc/sway/config ~/.config/sway/
   $EDITOR ~/.config/sway/config

参考
========

- `Manjaro Sway | Tiling WM For Wayland <https://tylerstech.me/2021/01/27/manjaro-sway-tiling-wm-for-wayland/>`_
