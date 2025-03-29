.. _intro_asahi_linux:

==========================
Asahi Linux简介
==========================

Asahi Linux是社区驱动的开源项目，目标是将Linux移植到Apple Silicon Macs，也就是从2020开始苹果自研的基于ARM架构的M系列芯片，包括Mac Mini, MacBook Air和MacBook Pro。

Asahi Linux本质上是 :ref:`arch_linux` ，所以不存在版本发布概念，而是滚动式发布，一旦安装完成，就不再需要做大版本升级，只需要跟随社区不断进行 ``pacman -Syu`` 即可...

.. note::

   2022年7月 `Linus Torvalds uses an Arm-powered M2 MacBook Air to release latest Linux kernel <https://arstechnica.com/gadgets/2022/08/linus-torvalds-uses-an-arm-powered-m2-macbook-air-to-release-latest-linux-kernel/>`_ `5.19包含了很多新功能，其中有Apple M1 NVM控制器支持 <https://www.phoronix.com/news/Linux-5.19-Features>`_ 。这次内核发布，Linus Torvalds就是使用运行了Asahi Linux的M2芯片MacBook Air。Linus Torvalds提到了Linux长期支持arm64硬件，他一直期望能arm架构能够作为一个开发平台。(大佬的背书)

支持功能
==========

从 `AsahiLinux Feature Support <https://github.com/AsahiLinux/docs/wiki/Feature-Support>`_ 可以看到当前对 Apple Silicon Macs支持程度，有赖于上游状态，特别是 :ref:`kernel` 版本。

- 屏幕背光目前不支持调整(需要DCP支持lands)，但是可以关闭和开启背光。显示屏幕亮度在主机是启动时固化设置，所以可以在macOS中调整好，然后重启到Linux来暂时解决。后续DCP发布补丁后应该能修复

Asahi Linux发布
=================

Asahi Linux 于2022年3月发布了首个Alpha版本，对Apple Silicon Macs提供了初步支持

.. _asahi-fedora:

Fedora集成Asahi Linux工具
==========================

参考 `Wow! Torvalds Modified Fedora Linux to Run on his Apple M2 Macbook <https://news.itsfoss.com/fedora-apple-torvalds/>`_ 可以看到:

- 最新的 ``Fedora 37`` 已经采用了 Kernel 6.0
- Fedora支持aarch64架构，并且提供了WEB安装(也就是可以直接使用  ``virt-instal`` 的 ``--location`` 参数)
- Fedora集成 :ref:`asahi_linux` 工具，可以以通过 `asahi-fedora-builder <https://github.com/leifliddy/asahi-fedora-builder>`_ 构建安装
- 作为 :ref:`redhat_linux` 体系的探索者，Fedora也可以支持大多数企业级软件，例如 :ref:`kubernetes` / :ref:`openshift` / :ref:`openstack`

我的计划
==========

我个人在 :ref:`raspberry_pi` 上投入了很多精力来构建 :ref:`kubernetes` 集群，并且我个人非常喜欢MacBook硬件( :ref:`macos` 也非常美观，只是无法像Linux一样更具有可玩性 )。随着Asahi Linux将Linux移植到最新的ARM架构Apple Silicon Macs，使得我有可能同时兼顾ARM架构体验以及探索在超级性能的硬件上实现 :ref:`mobile_cloud` 。我的实践是在 :ref:`apple_silicon_m1_pro` MacBook Pro笔记上进行。

不足和期待
============

根据 `The first Asahi Linux Alpha Release is here! <https://asahilinux.org/2022/03/asahi-linux-alpha-release/>`_ 目前Asahi Linux还有一些关键硬件无法工作，也是非常期待的特性:

- GPU加速: 目前图形界面还是framebuffer方式驱动，也就是没有发挥出 :ref:`apple_silicon_m1_pro` 强大的GPU性能
- 视频解码加速: 虽然看YouTube视频没有问题，但是显然硬解码会更优
- Neural Engine: 现在还不能在Linux平台玩 :ref:`machine_learning`
- 显示输出: 还不能外接显示器
- 蓝牙
- 摄像头
- CPU深度idle和睡眠模式

这里最值得关注的是GPU加速和Neural Engine，毕竟 :ref:`apple_silicon_m1_pro` 号称买GPU送CPU，没能发挥出优势硬将性能还是比较遗憾的。这部继续关注社区进展。


参考
=======

- `AsahiLinux FAQ <https://github.com/AsahiLinux/docs/wiki/FAQ>`_
