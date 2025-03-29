.. _introduce_bsd:

===============
BSD Unix简介
===============

BSD是Berkeley Software Distribution (BSD，也称Berkeley Unix) 

.. figure:: ../_static/bsd/unix_history.webp

从 Unix 简史图可以看到，在Unix诞生的早期阶段，上个世纪1970年代末，BSD系列就诞生了。 BSD Unix对现代操作系统产生和发展有巨大的影响力，衍生出现代化的FreeBSD/NetBSD/OpenBSD，以及大名鼎鼎的Mac OS X的核心Darwin和曾经叱诧风云的 :ref:`solaris` 操作系统。

在BSD 4.3时代，由于AT&T的许可证影响无法作为纯粹的开源软件发行，不得不重新开发了部分核心代码，诞生了4.4 BSD lite。这个过程是漫长而痛苦的，也一度影响了BSD发展。而 :ref:`linux` 更为开放的开源授权，超越了BSD成长为使用更为广泛的开源软件。不过BSD严谨的开发管理和高质量的代码架构，在很多核心计算机领域，例如，网络路由设备、核心服务器领域，都有着BSD Unix的身影。

.. _choose_freebsd:

选择FreeBSD
==============

由于我准备在 :ref:`apple_silicon_m1_pro` 上安装运行 :ref:`asahi_linux` 来构建 :ref:`mobile_cloud` ，所以就考虑在古老的 :ref:`mbp15_late_2013` (9年前的设备) 上安装什么系统来探索技术。我忽然想到很久以前，我曾经学习和折腾过很久的FreeBSD系统，一个完全不同于Linux的UNIX系统。

为什么重新选择FreeBSD:

- 借用Linus的一句名言: `JUST FOR FUN <https://book.douban.com/subject/25930025/>`_
- FreeBSD是和Linux各有千秋的UNIX系统，有自己独特的技术优势: 专注于服务器领域的稳健和强大性能
- BSD系统在网络堆栈有独特的历史渊源和优势，甚至得到了Linux的借鉴
- 没有Linux这样得到众多硬件厂商的支持，所以难以在最新硬件适配；但是也带来了稳定性的传统优势
- 实践原生的 :ref:`zfs` (最早在Solaris之外移植和支持ZFS的UNIX系统，得到系统默认支持)

其实我选择还有以下几个想法:

- 多一门扩展技能的道路，或许有一天能够用上
- 学习一些通用UNIX的开发技能(c语言)

参考
=====

- `百度百科-BSD <https://baike.baidu.com/item/BSD>`_
