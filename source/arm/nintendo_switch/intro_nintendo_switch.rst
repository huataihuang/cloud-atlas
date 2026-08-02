.. _intro_nintendo_switch:

============================
任天堂Switch简介
============================

任天堂Switch（英语：Nintendo Switch，简称NS或Switch）是日本任天堂公司出品的电子游戏机，混合了家用主机和便携式游戏机的概念，类似于平板电脑:

Switch使用了英伟达 Tegra X1 的定制系统芯片，是一种ARM架构芯片，并内置了GeForce显卡：

.. csv-table:: Switch不同版本
   :file: intro_nintendo_switch/switch_compare.csv
   :widths: 10,30,30,30
   :header-rows: 1

运行Linux
============

.. note::

   这是我的一个计，待调研

`CTCaer/hekate <https://github.com/CTCaer/hekate>`_ 提供了定制图形化的Nintendo Switch bootloader, firmware patcher, tools 等，我准备后续研究一下。

`Nintendo Switch主机使用Ubuntu系统教程一：安装系统 <https://bowen.games/archives/ePnmOzbN>`_ 这位博主详细介绍了如何在进入Recovery Mode的Nintendo Switch主机上安装Linux，但是前提条件是 **基于芯片改装进入Recovery Mode的Nintendo Switch主机**

`hekate - Nyx <https://github.com/CTCaer/hekate>`_ 图形化Nintendo Switch bootloader, firmware patcher, tools and many more.

`switchroot wiki: Android <https://wiki.switchroot.org/wiki/android>`_ 通过switchroot不仅能够安装Linux，也能够安装Android，可以方便地使用很多必要的移动软件(不过参考 `适用于 Nintendo Switch 的最佳 L4T Ubuntu（Vulkan + Citra + Cemu） <https://www.reddit.com/r/switchroot/comments/1mhnyb2/the_best_l4t_ubuntu_for_nintendo_switch_vulkan/?tl=zh-hans>`_ 提到Android系统运行有些卡顿不如Linux)


参考
=====

- `维基百科:任天堂Switch <https://zh.wikipedia.org/zh-cn/%E4%BB%BB%E5%A4%A9%E5%A0%82Switch>`_
