.. _android_for_pi:

======================
树莓派运行Android方案
======================

首个树莓派运行Android 11方案
=============================

2020年10月28日， `OmniROM blog <https://omnirom.org/#blog>`_ 博客上宣布了 "Raspberry Pi 4 gets first Android R (11) builds" ，你可以根据 `android_device_brcm_rpi4/README <https://github.com/maxwen/android_device_brcm_rpi4/blob/android-11/README>`_ 自己编译一个可以运行在 :ref:`pi_4` 上完整的Android 11系统，提供了在电脑运行Android的完整体验。并且当前也提供了已经编译好的镜像，非常容易安装使用。详细的介绍可以观看 `YouTube ETA PRIME频道: Android 11 On The Raspberry Pi4 Is Awesome! OMNI Rom For The Pi 4 <https://www.youtube.com/watch?v=EGPujKKTqTA>`_ ，可以看到这个Android 11 for Raspberry Pi 4已经可以流畅运行各种Andorid应用，同时提供桌面电脑的使用体验。这对于需要使用Andorid丰富应用，同时又想作为工作电脑使用的人非常方便。

OmniROM
===========

`OmniROM <https://omnirom.org/>`_ 是一个类似 LineageOS 的Android开源移植组织，虽然不如LineageOS这么著名，但是也有其设备支持特色。

OmniROM提供了针对 :ref:`pi_4` 的 Android 12 和 11 的镜像 `OmniROM for Raspberry Pi 4 <https://dl.omnirom.org/tmp/rpi4/>`_

LineageOS 19.0(Android 12) for Raspberry Pi 4
==============================================

KonstaKANG.com 针对不同设备提供Android镜像，其中包括了 `LineageOS 19.0 (Android 12)
for Raspberry Pi 4 <https://konstakang.com/devices/rpi4/LineageOS19/>`_ 

不过，网站没有提供具体的构建方法，但至少验证可行性。

移动办公的构想之一
===================

对于 :ref:`mobile_work_think` ，我一直想采用手机来代替笔记本电脑实现随时随地的Linux开发运维工作。

不过，手机还是需要连接键盘鼠标才能实现电脑的交互操作。

我在使用 :ref:`pi_400` 时候，突然想到，树莓派400恰好完整提供了一个ARM硬件环境，同时提供了键盘配套。也就是说，只要带一个和键盘一样的 :ref:`pi_400` ，不就可以实现开发运维了么？

通过树莓派直接运行 Android 系统，就可以直接使用 Android Play Store 中海量的应用程序，特别是一些商业应用程序，弥补Linux平台的应用软件不足。

参考
======

- `Android On Raspberry Pi <https://medium.com/@budhdisharma/android-on-raspberry-pi-7795e4914dc0>`_
