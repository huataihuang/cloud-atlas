.. _introduce_zfs:

==============
ZFS简介
==============

ZFS历史
===========

在很久很久以前的1980年代(计算机行业真是风云变换)，计算机行业曾经有一个技术非常超前公司Sun(提出了震撼人心的 ``网络就是计算机`` )。

这家影响了计算机行业的伟大公司，发明了JAVA和Solaris。曾经碾压Linux的Solaris操作系统，直到今天依然有着影响深远的文件系统ZFS，被移植到BSD和Linux系统，依然是众多文件系统中的翘楚。

.. note::

   John Gage 在 1980 年代提出了“网络就是计算机”宣传口号，之后被 Sun 使用了数十年，直到 2010 年被甲骨文收购。

   2019年，CDN 服务商Cloudflare 得到了这个口号，宣布它已经注册了商标。John Gage 对此到看得很开。但其他前 Sun 雇员则认为 "网络就是计算机" 永远是 Sun 的口号，无论是不是商标。  -- `Cloudflare 得到了 Sun 的“网络就是计算机”商标 <https://www.solidot.org/story?sid=61575>`_

今天(2020年)来回看ZFS文件系统，你会发现历时20年(2001年Matthew Ahrens 和 Jeff Bonwick开发出了ZFS)最初作为Sun Microsystem公司的Solaris核心文件系统，焕发出了强大的生命力：

- 2008年，ZFS被移植到FreeBSD
- 同年， `ZFS on Linux <https://zfsonlinux.org/>`_ 项目将ZFS引入Linux
- 2013年， `OpenZFS项目 <http://www.open-zfs.org/wiki/Main_Page>`_ 创建，维护和管理了核心ZFS代码，被广泛用于Unix-like系统中 (从2010年8月的OpenSolaris中Fork出代码)

ZFS集成了逻辑卷管理的文件系统，具有高扩展性，并且提供了大量保护措施防止数据损坏(存储在磁盘中数据可能会 ``腐败`` )，并且支持大存储容量、提供高性能数据压缩、卷管理也提供了快照以及写时复制、连续性完整性检查和自动修复，以及高级的RAID-Z(类似RAID5/6)，并且提供原生NFSv4 ACL等功能。

ZFS最初是Solaris平台的专有软件，虽然企业级性能非常强大，但是由于闭源，所以和BSD/Linux没有什么关系。但是随着Sun公司的商业战略调整(因为受到Linux的竞争压力)，Solaris从2005年开始开源大部分系统，使得ZFS基于CDDL协议进入开源领域，作为OpenSolaris项目的一部分。

2010年Sun被Oralce收购，Oracle停滞了OpenSolaris和ZFS开源更新，使得Oracle ZFS转为闭源。因此2013年，开源社区成立了 `illumos <https://illumos.org>`_ 项目继续维护现有开源的Solaris项目，并且在2013年成立OpenZFS继续ZFS的开源发展。OpenZFS维护了核心ZFS代码，以及相关验证和集成工作，使得OpenZFS在UNIX系统中广泛使用。

ZFS特点
==========

ZFS是 128 位文件系统，这个设计如此超前，以至于理论极限可能在当前现实中永远无法遇到 (OMG，我只能赞叹) -- 项目领导Bonwick曾说："要填满一个128位的文件系统，将耗尽地球上所有存储设备。除非你拥有煮沸整个海洋的能量，不然你不可能将其填满。"

特性:

- 写时复制
- 快照
- 克隆
- 动态条带化
- 可变块尺寸
- 轻量化文件系统创建
- 透明加密

我的实践规划
=============

我在很多年前就开始接触和使用ZFS，最早是在一家电子邮件服务商公司工作时，部署和维护 Solaris 系统，曾经学习和使用 ZFS ，对其超前的性能和功能有很深的印象(另一项Solaris杀手锏技术是zones，也就是后来大火的容器技术)。

我现在将 :ref:`kubuntu` 作为自己的一台旧笔记本 :ref:`mbp15_late_2013` 运行系统，考虑到 :ref:`ubuntu_linux` 从 20.04 LTS开始试验性引入ZFS，后续更作为主要文件系统支持，发展前景可观。加上ZFS确实是目前最先进的本地文件系统，技术上值得再次探索。

我在桌面上实践ZFS，并计划在后续 :ref:`priv_cloud_infra` 作为主要的存储架构来部署，不断增加实践经验。

参考
=======

- `What is ZFS? Why are People Crazy About it? <https://itsfoss.com/what-is-zfs/>`_
- `Wikipedia ZFS <https://en.wikipedia.org/wiki/ZFS>`_
- `Wikipedia中文 ZFS <https://zh.m.wikipedia.org/zh-hans/ZFS>`_
