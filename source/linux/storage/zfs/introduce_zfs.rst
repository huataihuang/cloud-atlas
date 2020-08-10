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

参考
=======

- `What is ZFS? Why are People Crazy About it? <https://itsfoss.com/what-is-zfs/>`_
- `Wikipedia ZFS <https://en.wikipedia.org/wiki/ZFS>`_
