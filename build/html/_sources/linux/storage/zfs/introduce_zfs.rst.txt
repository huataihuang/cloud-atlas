.. _introduce_zfs:

==============
ZFS简介
==============

在很久很久以前的1980年代(计算机行业真是风云变换)，计算机行业曾经有一个技术非常超前公司Sun(提出了震撼人心的"网络就是计算机")。

这家影响了计算机行业的伟大公司，发明了JAVA和Solaris。曾经碾压Linux的Solaris操作系统，直到今天依然有着影响深远的文件系统ZFS，被移植到BSD和Linux系统，依然是众多文件系统中的翘楚。

.. note::

   John Gage 在 1980 年代提出了“网络就是计算机”宣传口号，之后被 Sun 使用了数十年，直到 2010 年被甲骨文收购。

   2019年，CDN 服务商Cloudflare 得到了这个口号，宣布它已经注册了商标。John Gage 对此到看得很开。但其他前 Sun 雇员则认为 “网络就是计算机”永远是 Sun 的口号，无论是不是商标。  -- `Cloudflare 得到了 Sun 的“网络就是计算机”商标 <https://www.solidot.org/story?sid=61575>`_

今天(2020年)来回看ZFS文件系统，你会发现历时20年(2001年Matthew Ahrens 和 Jeff Bonwick开发出了ZFS)最初作为Sun Microsystem公司的Solaris核心文件系统，焕发出了强大的生命力：

- 2008年，ZFS被移植到FreeBSD
- 同年， `ZFS on Linux <https://zfsonlinux.org/>`_ 项目将ZFS引入Linux
- 2013年， `OpenZFS项目 <http://www.open-zfs.org/wiki/Main_Page>`_ 创建，维护和管理了核心ZFS代码，被广泛用于Unix-like系统中 (从2010年8月的OpenSolaris中Fork出代码)

我的实践规划
=============

我在很多年前就开始接触和使用ZFS，最早是在一家电子邮件服务商公司工作时，部署和维护 Solaris 系统，曾经学习和使用 ZFS ，对其超前的性能和功能有很深的印象(另一项Solaris杀手锏技术是zones，也就是后来大火的容器技术)。

我现在将 :ref:`kubunut` 作为自己的一台旧笔记本 :ref:`mbp15_late_2013` 运行系统，考虑到 :ref:`ubuntu_linux` 从 20.04 LTS开始试验性引入ZFS，后续更作为主要文件系统支持，发展前景可观。加上ZFS确实是目前最先进的本地文件系统，技术上值得再次探索。

我在桌面上实践ZFS，并计划在后续 :ref:`priv_cloud_infra` 作为主要的存储架构来部署，不断增加实践经验。

参考
=======

- `What is ZFS? Why are People Crazy About it? <https://itsfoss.com/what-is-zfs/>`_
- `Wikipedia ZFS <https://en.wikipedia.org/wiki/ZFS>`_
