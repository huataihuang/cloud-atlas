.. _pi_x11_slow:

========================
树莓派X11运行缓慢
========================

我在 :ref:`pi_400` 上运行 :ref:`kali_linux` 有一个明显的感觉就是图形程序运行非常缓慢:

- 即使轻量级中文输入也是有卡顿
- chromium 即使启用了 :ref:`pi_display_accelerate` 也没有改善，任何一个网页的渲染都会完全占用一个cpu核心资源，很多时候即使只开很少的窗口tab，也会导致4个cpu核心全部打爆，系统负载很高
- 如果访问网络被gfw墙掉的网站，虽然chromium似乎不占用cpu，但是Xorg会吃掉一个cpu的资源

我感觉主要是图形缓慢导致了整个系统异常: 系统完全没有iowait，所以排除访问SD卡问题(大多数程序加载到内存运行很少访问磁盘，并且我的内存空闲1.5G)

我怀疑我的系统安装存在问题，超乎异常的缓慢(我的个人帐号 ``huatai`` 在任何目录下 ``ls`` 都缓慢，但是切换到 ``root`` 帐号则没有这个问题)

采用轻量级Linux
=================

可能还是要回归Raspberry Pi官方Raspbian系统或者使用轻量级针对SBC的Linux发行版甚至自己使用 :ref:`lfs_linux` 从源代码构建。目前初步计划是重新安装一次精简系统，然后把 :ref:`kali_linux` 改到 :ref:`priv_cloud` 中作为虚拟机运行

Wayland
============

可能的解决方法是采用 wayland 替代 X11 ，但是Xfce目前的稳定版本尚未支持wayland (参考 `Debian Wayland <https://wiki.debian.org/Wayland>`_ ) 

目前已经支持Wayland的桌面系统只有 GNOME 和  KDE Plasma

我感觉如果要在非常有限的资源中加速图形，Wayland是一个可能的技术方向，但是需要自己来编译，后续准备采用 :ref:`lfs_linux` 来尝试

.. note::

   2022年4月，新冠疫情隔离在家，我开始在 :ref:`pi_400` 上采用 Raspberry Pi OS，并且选择 :ref:`run_sway` 。可以明显感觉出这种采用 :ref:`wayland` 的轻量级窗口管理器可以极大提升系统性能。即使在树莓派这样较弱的硬件上，运行也相对非常流畅。所以，我强烈推荐采用最新的 :ref:`sway` 平铺式窗口管理器以及能发挥图形性能的 :ref:`wayland` 图形协议。

参考
========

- `X11 is very slow? <https://forums.raspberrypi.com/viewtopic.php?t=291708>`_
