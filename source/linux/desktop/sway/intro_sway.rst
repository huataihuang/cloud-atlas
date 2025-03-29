.. _intro_sway:

==========================
sway平铺式窗口管理器简介
==========================

树莓派上的sway
=================

树莓派官方Raspberry Pi OS没有直接提供Sway窗口管理器，不过，第三方树莓派镜像，例如Arch Linux和基于Arch Linux的Manjaro都已经提供了Sway + Wayland，可以直接安装运行在 :ref:`pi_4` 和 :ref:`pi_400` 。

sway继承了i3简洁的窗口管理能力，并且提供了基于现代化 :ref:`wayland` 的技术。

.. figure:: ../../../_static/linux/desktop/sway/ubuntu-sway.jpg
   :scale: 30

构思
=======

我准备将性能最好的MacBook Pro A1990(2018)安装 :ref:`lfs` ，源代码编译安装 :ref:`wayland` + sway，这样能够最大程度发挥主机性能来运行虚拟化和容器。

我在多台桌面电脑上共享键盘和鼠标的 :ref:`synergy` 不能支持wayland，这是一个比较大的遗憾。由于sway几乎不需要使用鼠标(即使浏览器也可以采用 vimium 来键盘操作)，所以我采用蓝牙键盘功能键快速切换主机控制(我所使用的富勒G610键盘可以通过快捷键切换有线和蓝牙，所以我将有线连接树莓派Linux主机，蓝牙连接MacBook，通过快捷键切换主机控制，切换速度约1秒)。

参考 Arch Linux的Manjaro发行版，Manjaro Sway包含了在底部共用键盘快捷键的对话框，并且使用应用程序launcher(Wofi)来使用快捷键。可以结合一些轻量级应用来完成日常工作:

- Pamac Manager
- Firefox
- Thunar
- Ranger
- Neovim
- Foliate
- MPV Media Player

SwayOS
==========

除了Fedora社区提供了 `Fedora Sway Spin <https://fedoraproject.org/spins/sway/>`_ 发行版， `SwayOS <https://swayos.github.io/>`_ 集成了Sway桌面以及必要的配置工具和常用软件，形成了一个较为完善的发行版，其组件选择可以作为Sway平台使用的安装参考。

Sway使用要点
===============

- :strike:`Sway不支持NVIDIA闭源驱动，必须使用开源的Nouveau驱动，所以建议使用支持开源更好的AMD或Intel显卡。`
- `Sway 1.7有限支持NVIDIA显卡选项Zero-Copy Direct Scanout <https://www.phoronix.com/scan.php?page=news_item&px=Sway-1.7-rc2>`_ ， :ref:`sway_with_nvidia` 
- 部分登陆管理器支持Wayland，所以要小心选择登陆管理器。建议使用字符界面启动sway，如果要自动登陆，可以在 ``.bash_profile`` 中添加::

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
