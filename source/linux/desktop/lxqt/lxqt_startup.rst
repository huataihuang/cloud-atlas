.. _lxqt_startup:

==================
LXQt快速起步
==================

选择LXQt
=========

很久以前，我曾经有一段时间非常痴迷轻量级Linux桌面(现在也是)，曾经使用过 `LXDE <http://www.lxde.org/>`_ ，在非常古老的硬件上，能够获得不错的性能。然而LXDE基于GTK2，已经很久没有重大发展了，社区也推荐转换成基于Qt的 ``LXQt`` 。不过，我后来转换到 :ref:`xfce` 就一直持续使用xfce了，原因是xfce确实也很快速资源占用较少，当时xfce还对很多外设支持良好(如蓝牙和无线)。

不过，随着GTK3的发展越来越复杂，融入了很多GNOME的特性，xfce也渐渐变得沉重起来。最近一次安装xfce，我发现启动桌面之后，内存也已经占据了700+MB以上，已经和KDE环境相差无几了。

所以，我为了能够充分发挥硬件性能，舍弃了完整的GUI桌面，选择 :ref:`sway` 这样比较激进的平铺窗口管理器(特别是原生支持现代化的图形系统 :ref:`wayland` )，能够获得非常快速的使用体验。

但是，有获得也有失去 :ref:`sway` 所采用的 :ref:`wayland` 还没有得到广泛的支持，有很多必要的程序支持不佳(例如chrome，输入法)，并且也不能使用 :ref:`synergy` 。最近，我又需要同时操纵两台主机(以便充分利用显示屏幕，并且最重要的是能够操作 :ref:`macos` 上的商业软件)，所以准备选择一个基于传统 xorg 的轻量级桌面。想到xfce和KDE相近的体量，我想尝试一下很久以前体验过的类似 ``LXDE`` 的后继者 ``LXQt`` :

- 能够使用 :ref:`synergy` 操作多台主机
- 已经验证过 ``qterminal`` 可以很好支持中文输入，且非常轻量

底层操作系统采用 :ref:`arch_linux` ，最小化安装，逐步递进部署桌面。

LXQt简介
==========

按照 `LXQt官网 <https://lxqt-project.org/>`_ 介绍，LXQt是一个轻量级的Qt桌面环境，专注于给传统桌面带来现代的使用体验:

- 模块化组件
- 强大的文件管理器
- 可定制外观
- 提供插件和设置的面板
- Window Manager agnostic(没理解，以后再说)

LXQt精选了一系列轻量级的应用:

- PcManFm-qt - 这是从LXDE继承的轻量级文件管理器，已经Qt化
- Lximage-qt - 也是从LXDE继承的图片观看程序
- QTerminal - 终端模拟器，非常快速而且对中文输入支持良好
- Qps - 进程场刊
- Screengrab - 截屏
- LXQt-archiver - 压缩包管理
- LXQt-runner - 应用程序加载器

安装
========

- 在 :ref:`arch_linux` 平台只需要安装 ``lxqt`` 就会一起安装必要桌面组件::

   pacman -S lxqt

- 配置 ``~/.xinitrc`` 添加::

   exec startlxqt

参考
=======

- `LXQt: About <https://lxqt-project.org/about/>`_
