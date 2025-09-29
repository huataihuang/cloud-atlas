.. _intro_freebsd:

=================
FreeBSD简介
=================

FreeBSD是一种类UNIX操作系统，是由经过BSD、386BSD和4.4BSD发展而来的Unix的一个重要分支。

FreeBSD采用了宽松的 `BSD许可证 <https://zh.m.wikipedia.org/zh/BSD许可证>`_ (允许后续版本继续BSD许可也允许改为闭源软件)，所以被很多商业软件公司所采用。最著名的可能就是苹果公司的 :ref:`macos` 基于BSD Unix的内核构建的Darwin内核。

FreeBSD 非凡的特性
=====================

- 抢占式多任务与动态优先级调整确保在应用程序和用户之间平滑公正的分享计算机资源，即使工作在最大的负载之下。
- 符合业界标准的强大 TCP/IP 网络 支持， 例如 SCTP、 DHCP、 NFS、 NIS、 PPP， SLIP， IPsec 以及 IPv6。 这意味着 FreeBSD 主机可以很容易地和其他系统互联， 也可以作为企业的服务器，提供重要的功能
- 内存保护确保应用程序(或者用户)不会相互干扰。 一个应用程序崩溃不会以任何方式影响其他程序。
- 页式请求虚拟内存和"集成的 VM/buffer 缓存" 设计有效地满足了应用程序巨大的内存需求并依然保持其他用户的交互式响应。

FreeBSD 基于加州大学伯克利分校计算机系统研究组 (CSRG) 发布的 4.4BSD-Lite， 继承了 BSD 系统开发的优良传统。 除了 CSRG 优秀的工作之外， FreeBSD 项目花费了非常多的时间来优化调整系统， 使其在真实负载情况下拥有最好的性能和可靠性。

因为 FreeBSD 自身的源代码是完全公开的， 所以对于特定的应用程序或项目，可以对系统进行最大限度的定制。

FreeBSD 是一个免费使用且带有完整源代码的基于 4.4BSD-Lite 的系统， 它广泛运行于 Intel i386™、i486™、Pentium®、 Pentium® Pro、 Celeron®、 Pentium® II、 Pentium® III、 Pentium® 4(或者兼容系统)、 Xeon™、 和 Sun UltraSPARC® 的计算机系统上。 它主要以 加州大学伯克利分校 的 CSRG 研究小组的软件为基础，并加入了 NetBSD、OpenBSD、386BSD 以及来自 自由软件基金会 的一些东西。除了最基本的系统软件，FreeBSD 还提供了一个拥有成千上万广受欢迎的程序组成的软件的 Ports Collection。

组织结构
==========

FreeBSD的项目是由FreeBSD的志愿者或一些有SVN提交权限的开发者开发维护的。有几种不同类型的提交，包括提交源代码（基本操作系统），DOC提交（文件和网站的作者）和ports（第三方应用程序移植或基础程序）。每隔两年FreeBSD提交者选举9名成员组成的FreeBSD核心团队，负责整个项目的方向，项目规则的制定和实施新的 "commit bits" 或SVN提交权限的授予和批准。FreeBSD核心团队，开发团队，包括负责安全公告（安全官团队），发行（工程队）发布工程和管理的端口集合（端口管理团队），被正式分配到一些任务和责任。

分支
=======

FreeBSD的FreeBSD的开发者保持至少两个分支的同步发展。在 ``-CURRENT`` 分支的FreeBSD的开发始终代表 "流血的边缘"（bleeding edge）。一个的FreeBSD ``-STABLE`` 分支创建的每一个主版本号，从中 ``-RELEASE`` 发布大约每4-6个月一次。如果一个功能是足够稳定和成熟，它可能会和向后来的 ``-STABLE`` 分支的合并。

FreeBSD影响
==============

FreeBSD是BSD三大主要发行版中最为流行的系统(另外两个分别是OpenBSD和NetBSD)。FreeBSD大范围的应用于世界上很多公司的核心基础设施，包括NetFlix，WhataApp，Yahoo！，Juniper网络，EMC/Isilon。另外苹果公司的Darwin使用的也是FreeBSD，也就是 Mac OS X 的基础操作系统。也由于它可以构建一个非常小的系统，所以能够在嵌入式系统中的应用逐渐增多。开源界主要替代FreeBSD的还是Linux。FreeBSD的许可条款允许修改和改进系统而无需再发行，这样使得FreeBSD的许可更加的友好，无论是企业还是个人用户。Linux的许可条款要求所有的更改和改进内核进行源代码可以以最低的成本再发布。因此，若企业需要控制发行版的知识产权，那么使用FreeBSD来构建他们的产品就是不错的选择。

谁在使用 FreeBSD?
===================

FreeBSD 被世界上最大的 IT 公司用作设备和产品的平台， 包括:

- Apple
- Cisco
- Juniper
- NetApp

FreeBSD 也被用来支持 Internet 上一些最大的站点， 包括:

- Yahoo!
- Yandex
- Apache
- ...

硬件兼容
=========

FreeBSD的硬件支持不如 :ref:`linux` 广泛，但是主流架构的服务器端硬件支持相对较好:

- 64位 x86 (amd64) 架构
- 32位 x86 (i386)  架构
- 64位 ARM (aarch64) 架构
- 32位 ARM (armv6,armv7) 架构
- RISC-V 架构
- PowerPC 架构

其中 ``64位 ARM (aarch64) 架构`` 支持 :ref:`pi_3` 和 :ref:`pi_4` ，我恰好有这样的多个硬件，我准备在完成 :ref:`k0s` 测试之后，将我的树莓派3和4替换成FreeBSD来构建集群。

学习资料
===========

- `FreeBSD Handbook <https://docs.freebsd.org/en/books/handbook/>`_ 官方手册，全面系统且更新

- `Design and Implementation of the FreeBSD Operating System, The, 2nd Edition <https://www.informit.com/store/design-and-implementation-of-the-freebsd-operating-9780321968975>`_  `InfoQ: FreeBSD 操作系统设计与实现，内容回顾与作者采访 <https://www.infoq.cn/article/freebsd-design-implementation-review>`_ 采访作者对这本书内容对概述

- `RIP Tutorial <https://riptutorial.com/>`_ 提供了很多学习语言的资料，也汇总了一些很有用的FreeBSD资料:

  - `RIP Tutorial: FreeBSD Build from source <https://riptutorial.com/freebsd/topic/7062/build-from-source>`_
  - `RIP Tutorial: FreeBSD Jails <https://riptutorial.com/freebsd/topic/7070/freebsd-jails>`_
  - `RIP Tutorial: FreeBSD Packages and Ports management <https://riptutorial.com/freebsd/topic/7069/packages-and-ports-management>`_
  - `RIP Tutorial: FreeBSD Set up the FreeBSD development environment <https://riptutorial.com/freebsd/topic/6136/set-up-the-freebsd-development-environment>`_

- `FreeBSD中文社区「FreeBSD从入门到跑路」 <https://book.bsdcn.org/>`_ 非常详尽的中文入门学习资料，非常好

  - `FreeBSD中文社区 <https://book.bsdcn.org>`_ 最近才发现有不少有用的翻译资料和自制教程，是FreeBSD推广的良好教材，学习...

- `GaryH Tech <https://www.youtube.com/@GaryHTech>`_ YouTube上专注介绍FreeBSD技术的频道，入门可以参考

- `klara <https://klarasystems.com/>`_ 是一家开源企业外包公司，专注于FreeBSD+ZFS存储以及ARM嵌入系统开发，官网 `Klara Articles <https://klarasystems.com/articles/>`_ 提供了很多FreeBSD+ZFS的技术文档

- `zenarmor <https://www.zenarmor.com/>`_ 是一家专注于安全的开源公司，结合了安全访问、防火墙( :ref:`opnsense` )。 `zenarmor FreeBSD Tutorials <https://www.zenarmor.com/docs/category/freebsd-tutorials>`_ 提供了比较全面的教程

- `IT Notes <https://it-notes.dragas.net/>`_ 一位意大利BSD社区者Stefano Marinelli创建的一人公司，记录分享了围绕FreeBSD(和illumos)的很多技术文章

参考
=======

- `FreeBSD百度词条 <http://baike.baidu.com/item/FreeBSD>`_
- `FreeBSD操作系统设计与实现，内容回顾与作者采访 <http://www.infoq.com/cn/articles/freebsd-design-implementation-review>`_
- `FreeBSD 10 To Use Clang Compiler, Deprecate GCC <http://www.phoronix.com/scan.php?page=news_item&px=MTEwMjI>`_
