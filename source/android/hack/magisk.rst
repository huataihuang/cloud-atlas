.. _magisk:

===============
Magisk
===============

Android作为开源系统，基于Linux的内核以及开源软件，形成了远比iPhone iOS开放的手机生态系统。Andorid虽然不鼓励普通用户root系统，但是对于geeker和haker还是提供了及其强大的 ``root`` 功能，你可以完全掌控Android。

不过，从Android 6.0(棉花糖)开始，Google阻断了之前流行的root方法，即直接将su守护程序放置到 ``/system`` 分区，并在启动时取得所需权限。也就是现代的Android系统已经不允许任何方式修改 ``/system`` 分区。

什么是 Magisk
===============

出于增加安全性的考虑，Google 推出了 SafetyNet 这样的检测，以确保 Android Pay 等一些 App 的安全运行。

Magisk 是出自一位台湾学生 @topjohnwu 开发的 Android 框架，是一个通用的第三方 systemless 接口，通过这样的方式实现一些较强大的功能。

Magisk通过启动时在 ``boot`` 中创建钩子，把 ``/data/magisk.img`` 挂载到 ``/magisk`` ，构建出一个在 ``system`` 基础上能够自定义替换，增加以及删除的文件系统，所有操作都在启动的时候完成，实际上并没有对 ``/system`` 分区进行修改（即 ``systemless`` 接口，以不触动 ``/system`` 的方式修改 ``/system`` ）。

安装Magisk
=============

在 :ref:`root_pixel` 中介绍了如何安装Magisk，

* 从 `Magisk GitHub release <https://github.com/topjohnwu/Magisk/releases/>`_ 下载 Magisk-v20.3.zip 和 MagiskManager-v7.5.1.apk

* 首先安装 TWRP - 见 :ref:`root_pixel`

* 进入TWRP，点击 ``Advanced => ADB Sideload``                               进入sideload模式，就可以通过sideload方式安装 Magisk::

   adb sideload Magisk-v20.3.zip

.. note::

   也可以把Magisk的zip文件push到手机的 ``/sdcard`` 目录下，然后通过 TWRP 的 ``Install`` 功能进行安装。

安装Magisk Manager
====================

* 将 MagiskManager-v7.5.0.apk 推送到手机的 ``/sdcard`` 目录::

   adb push MagiskManager-v7.5.0.apk /sdcard

* 然后在手机端通过文件管理器安装MagiskManager

Magisk安装选项
================

.. note::

   Magisk安装选项有3个，需要注意，不是所有手机环境都适合这3个选项，错误选择可能导致问题。

- Preserve AVB 2.0/dm-verity

这个选项用于禁止或保护Android Verified Boot。dm-verity是用于确保系统没有被篡改的机制。由于我们需要修改系统，所以大多数设备在安装Magisk时需要禁用这个功能。但是，也有设备需要激活dm-verity，否则不能启动。

默认启用 Preserve AVB 2.0/dm-verity

- Preserve enforced encryption

默认Android加密用户数据和激活kernel enforce，这样你必须使用加密。一些用户可能希望关闭设备加密，则需要disable这个选项。

默认启用 Preserve enforced encryption

- Recovery mode

注意Recovery mode 是在不支持A/B分区设置的Android设备上使用，此时Magisk是直接安装到system-as-root设备中。这种情况下，你需要将Magisk安装到recovery image而不是boot image。

注意这个选项和设备相关。在 :ref:`pixel` 设备上不要启用这个选项，否则安装以后会导致下次重新安装出现报错 ``Unable to detect target image`` ，见下文。

Unable to detect target image
==============================

在Magisk Manager中重新安装Magisk时遇到报错:: 

   ! Unable to detect target image
   ! Installation failed

解决方法时获取设备的stock boot image的副本。你可以从安装选项中选择 ``Select and Patch a file`` 然后浏览并找到boot image文件来打补丁。

参考
=======

- `神奇的 Magisk <https://www.jianshu.com/p/393f5e51716e>`_
- `Android 玩家不可错过的神器：Magisk Manager <https://zhuanlan.zhihu.com/p/61302392>`_
- `What is Magisk? <https://www.xda-developers.com/what-is-magisk/>`_ 官方介绍
- `How to install Magisk <https://www.xda-developers.com/how-to-install-magisk/>`_ 官方安装指南
- `Magisk - The Magic Mask for Android <https://forum.xda-developers.com/apps/magisk/official-magisk-v7-universal-systemless-t3473445>`_
- `Magisk - Installation and troubleshooting <https://www.didgeridoohan.com/magisk/Magisk>`_ - 这是非常详细的排查手册，如果你遇到Magisk安装使用问题，请参考该文档
