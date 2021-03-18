.. _introduce_wayland:

================
Wayland简介
================

Wayland是一个显示服务器协议，目标是替代X Window System，实现一个现代、安全和简单的窗口系统。在Wayland协议中显示服务器被称为 ``compositors`` ，这是因为Wayland也作为 ``compositing window managers`` (wayland支持的窗口管理器分2类：平铺窗口管理器和堆叠窗口管理器，例如 :ref:`sway` 属于平铺窗口管理器，而KDE的KWin和Gnome的Mutter属于堆叠窗口管理器) 。主要的桌面系统，例如KDE Plasma和GNOME都已经实现了各自都Wayland compositors。

.. note::

   KDE的KWin和Gnome的Mutter同时支持Xorg和Wayland，取决于使用哪种显示服务器。例如Mutter在使用Wayland显示服务器，就运行在KMS和libinput之上，实现了Wayland核心协议的compositor，并且在运行X11应用程序时作为Xwayland。当Mutter运行在Xorg之上，则作为一个X11窗口管理器和compositing manager。

目前主流的Gnome和KDE都支持运行在Wayland上，不过 :ref:`xfce` 还没有实现Wayland（即使最新的4.16版本也不支持，但是社区计划follow gnome和kde社区迁移到Wayland。目前，我比较倾向在这个先进的显示服务器上运行 :ref:`sway` ，实现轻量级的桌面管理。

.. note::

   参考 `Enlightenment on Raspberry Pi 3 in Wayland mode is pretty smooth <http://www.rasterman.com/index.php?news=2017.12.27-Enlightenment_on_Raspberry_Pi_and_Wayland_Smoothness>`_ 可以了解到，Wayland现代化的图形显示架构，可以加速图形并降低硬件需求：

   Enlightenment with no X11 (running as a wayland compositor) at a smooth 60fps even with a live miniature pager preview updating to match, a full desktop all smooth at 60fps. Terminology running and Rage playing movies smoothly. On a stock Rasperry Pi 3 running 32bit Arch Linux with Mesa VC4 drivers.

要求
========

大多数Wayland组件只能工作在 :ref:`kms` 的系统上。这要求选择兼容的硬件，区别是两种不同的缓存API：GBM和EGLStreams。NVIDIA GPU使用EGLStreams驱动，其他显卡驱动则支持GBM。对于Wayland compositor必须支持这两种API或者其中一种API才能正常工作。例如，GNOME(使用Mutter)同时支持GBM和EGLStreams，而KDE
Plasma(使用KWin)则在所有版本中zhchiGBM，不过只从Plasma 5.16才开始支持EGLStreams。其他Compositors如果只支持GBM就不能在NVIDIA上工作。

目前除了上述GNOME和KDE，其他的Wayland compositors推荐使用 :ref:`sway` 和 enlightenment 。

参考
=====

- `Arch Linux - Wayland <https://wiki.archlinux.org/index.php/wayland>`_
- `Debian - Wayland <https://wiki.debian.org/Wayland>`_
