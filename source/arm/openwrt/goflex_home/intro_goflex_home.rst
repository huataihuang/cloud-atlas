.. _intro_goflex_home:

=======================
希捷GoFlex Home存储简介
=======================

我怎么会购买GoFlex Home
=========================

我在10年前购买过 `希捷Seagate GoFlex Home <https://www.seagate.com/cn/zh/support/external-hard-drives/network-storage/goflex-home/>`_ (2011年产品)，这是一款已经停产的家用NAS设备。我当时对 :ref:`gluster` 存储系统非常着迷，并且也在折腾 :ref:`raspberry_pi` 设备，我发现这款NAS设备能够刷Linux，就想到用它来构建基于GlusterFS的分布式存储，实现永不丢失数据的个人存储系统。

虽然10年前GoFlex Home硬件非常弱，但是 `archliux ARM <https://archlinuxarm.org/>`_ 当时提供了发行版支持(现在硬件列表似乎溢出了支持)，所以当时我花费了很多时间精力构建起基于 :ref:`arch_linux` 的双设备 :ref:`gluster` 分布式稳健系统，能够较为稳定地为Windows/macOS提供存储服务。

硬件规格
===========

- 电源: 12伏2安培 单线 5.5mm x 2.5mm 极性：中心正极

今天的再次挑战
===============

10年后的今天(2022年)，我又翻出抽屉里闲置N年的希捷GoFlex Home，想要备份照片。这时我发现，可能需要合适的发行版才能复活GoFlex Home: `archliux ARM <https://archlinuxarm.org/>`_ 官方网站已经移除了GoFlex Home设备支持。不过，在 `Dave Eckhardt's Seagate GoFlex Home Arch Linux page <https://www.cs.cmu.edu/~davide/howto/GoFlexHomeArch.html>`_ 还能找到方法文档(但可能已经无效)，我记得当年我也曾经如此实践过。

参考 `Hacking – Seagate FreeAgent GoFlex Net as NAS with Debian or OpenWRT <https://dwaves.de/2015/03/30/hacking-seagate-freeagent-goflex-net-as-nas-with-debian-or-openwrt/>`_ 可以看到:

- :ref:`openwrt` 持续在当前版本提供 `OpenWrt Seagate GoFlexHome Support <https://openwrt.org/toh/seagate/goflexhome>`_ ，这种嵌入式特定版本Linux更适合这种小型硬件设备

所以我决定采用 :ref:`openwrt` 来实践重新构建 :ref:`gluster` 以及NAS系统


参考
=====

- `希捷Seagate GoFlex Home <https://www.seagate.com/cn/zh/support/external-hard-drives/network-storage/goflex-home/>`_ 官方网站
- `Seagate 产品电源适配器规格 <https://www.seagate.com/cn/zh/support/kb/power-adapter-specifications-for-seagate-products/>`_
- `Hacking – Seagate FreeAgent GoFlex Net as NAS with Debian or OpenWRT <https://dwaves.de/2015/03/30/hacking-seagate-freeagent-goflex-net-as-nas-with-debian-or-openwrt/>`_
