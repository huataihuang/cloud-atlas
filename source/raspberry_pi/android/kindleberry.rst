.. _kindleberry:

====================
Kindle和树莓派合体
====================

Kindle使用电子墨水技术，这是一种非常节约电能的显示技术，仅在屏幕刷新时需要消耗电能，对于静止的影像则几乎不消耗电能。对于文字和静态黑白图片显示，电子墨水是非常好的显示技术。

`Kindleberry – the economic ultraportable laptop with Kindle and Raspberry Pi <https://www.meccanismocomplesso.org/en/kindleberry-the-economic-ultraportable-laptop-with-kindle-and-raspberry-pi/>`_ 采用了一个巧妙的jailbreak方法，通过在越狱后kindle上安装kterm远程网络ssh登陆到一个由移动电源提供电能的树莓派Zero W，实现树莓派终端交互。

.. figure:: ../../_static/raspberry_pi/android/kindleberry-Pi-zero-W.jpg
   :scale: 75


`Mobile Read论坛提供了JailBreak Kindle方法 <https://www.mobileread.com/forums/showthread.php?t=186645>`_ 可以在Kindle Touch/PaperWhite 上安装第三方软件，并且使用 USBNetwork 对外通讯。 

.. note::

   对于Kindle Fire这样的平板设备，实际上已经是完全的Android设备，连接访问树莓派完全就是Android远程访问，没有什么特别难度。主要思路就是在Kindle Fire/Andorid上安装远程桌面软件（例如rdp client），然后远程访问就可以了。甚至可以安装Android上的Term客户端。总之，没有什么技术难度，就只是一个思路而已。

   不过，本文专注的是Kindle电子墨水设备。我个人感觉电子墨水设备更有复古风格，能够完全模拟远程字符终端，实现一剑走天涯的梦想。


我的实践
==========

.. note::

   目前我因为条件限制，暂时还没有做这个实践。但是我梳理了一下文档，觉得还是比较可行并且有一定可玩性。预计我会在原文基础上做一些调整来完成。

   我计划对原文步骤做一些调整:

   - Raspberry Pi Zero提供了无线功能，实际上可以在运行Linux上构建AP，这样可以省却一个无线路由器。另一种方式是采用手机提供热点(毕竟手机是大家最随身的设备了)
   - 原文使用的HHKB机械键盘太pro了，价格感人，我只能使用我的富勒G610机械键盘

   OMG，Qnyx 和 PocketBook 都已经发布了支持4096色6寸彩色电子墨水屏阅读器，就等Kindle发力彩色电子墨水设备了，令人期待!!!


另一种kindleberry
===================

其他树莓派电子墨水显示方案：

- 采用Raspberry Pi HAT(硬件堆叠在顶部)，将显示屏通过 GPIO pin 连接，使用 212x104 三色电子墨水屏，可以展示简单图形和crisply渲染文字。不过，需要安装Inky库才能工作。例如 `Inky pHAT <https://shop.pimoroni.com/products/inky-phat?variant=12549254217811>`_ 
- `papirus <https://uk.pi-supply.com/search?type=product&q=papirus>`_ 电子墨水显示。

.. note::

   淘宝上也有 `微雪树莓派 W/WH 墨水屏开发套件 <https://detail.tmall.com/item.htm?id=606443763425>`_ 能够实现相同功能。

参考
========

- `Using E Ink displays with a Raspberry Pi <https://www.raspberrypi.org/blog/using-e-ink-raspberry-pi/>`_
- `Kindleberry – the economic ultraportable laptop with Kindle and Raspberry Pi <https://www.meccanismocomplesso.org/en/kindleberry-the-economic-ultraportable-laptop-with-kindle-and-raspberry-pi/>`_
- `Kindleberry Pi Zero W <http://blog.yarm.is/kindleberry-pi-zero-w.html>`_
