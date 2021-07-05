.. _magisk:

===============
Magisk
===============

.. warning::

   由于Andorid技术进展，在Pixel设备上，采用了动态分区以及双启动分区技术，特别是Android 10开始采用了内核安全加强，导致 :ref:`twrp` 已经无法在Pixel的Android 10上工作。所以，我会在

.. note::

   本文是汇总网络上撰写较好的几篇文档，我整理汇总是为了方便自己今后参考:

   - `神奇的 Magisk <https://www.jianshu.com/p/393f5e51716e>`_
   - `Android 玩家不可错过的神器：Magisk Manager <https://zhuanlan.zhihu.com/p/61302392>`_

   因为原文写得非常明晰，推荐阅读。

Android作为开源系统，基于Linux的内核以及开源软件，形成了远比iPhone iOS开放的手机生态系统。Andorid虽然不鼓励普通用户root系统，但是对于geeker和haker还是提供了及其强大的 ``root`` 功能，你可以完全掌控Android。

不过，从Android 6.0(棉花糖)开始，Google阻断了之前流行的root方法，即直接将su守护程序放置到 ``/system`` 分区，并在启动时取得所需权限。也就是现代的Android系统已经不允许任何方式修改 ``/system`` 分区。

什么是 Magisk
===============

出于增加安全性的考虑，Google 推出了 SafetyNet 这样的检测，以确保 Android Pay 等一些 App 的安全运行。

Magisk 是出自一位台湾学生 @topjohnwu 开发的 Android 框架，是一个通用的第三方 systemless 接口，通过这样的方式实现一些较强大的功能。

Magisk通过启动时在 ``boot`` 中创建钩子，把 ``/data/magisk.img`` 挂载到 ``/magisk`` ，构建出一个在 ``system`` 基础上能够自定义替换，增加以及删除的文件系统，所有操作都在启动的时候完成，实际上并没有对 ``/system`` 分区进行修改（即 ``systemless`` 接口，以不触动 ``/system`` 的方式修改 ``/system`` ）。这样就实现了绕过SafetyNet使用root的方法。

.. note::

   看到这里，你是不是觉得这种方式很熟悉，非常类似 :ref:`docker` 中镜像和文件层的概念？

Magisk可以实现的功能包括:

- 集成root (MagiskSU)
- root和Magisk的日志功能
- Magisk Hide（隐藏 Magisk 的 root 权限，针对 Snapchat、Android Pay、PokémonGo、Netflix 等）

.. note::

   这个Magisk Hide功能可能比较有用，在使用StarBucks、银行软件，如果Android系统被root过，StarBucks应用软件会拒绝启动，通过这个方法可以避免问题。

- 为广告屏蔽应用提供 systemless hosts 支持
- 通过 SafetyNet 检查
- Magisk 功能模块

安装Magisk
=============

在 :ref:`root_pixel` 中介绍了如何安装Magisk

安装 Magisk 需要解锁 Bootloader 并刷入第三方 Recovery。

* 从 `Magisk GitHub release <https://github.com/topjohnwu/Magisk/releases/>`_ 下载 Magisk-v20.3.zip 和 MagiskManager-v7.5.1.apk

* 首先安装 TWRP - 见 :ref:`root_pixel` 或者 :ref:`twrp`

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

Magisk使用
===================

隐藏root
----------

由于Google服务等很多Android上应用、游戏和服务都十分重视保护自己的版权信息，所以这些软件检测到手机遭到root就会拒绝认证设备。

Magisk Hide可以绕过这些检测。

- 首先进入 Magisk Manager 检测是否通过了谷歌服务中的 SafetyNet 安全性测试。

想要通过 SafetyNet 测试，最好使用原厂系统，或者是值得信赖的第三方 ROM 正式版（也就是 Official Builds），以减少不必要的麻烦。

如果是 ``basic integrity`` 这一项没有通过认证，那说明你遇到了大麻烦：试着开启「Magisk 核心功能模式」或者卸载所有模块，如果还是没有通过，那么你可能需要换一个系统或者第三方 ROM 了。

如果是 ``ctsProfile`` 这一项没有通过，那说明你的 ROM 没有通过其兼容性测试，一些 beta 版本或者国内厂商的 ROM 可能出现这种问题。这时我们下载使用 `MagiskHide Props Config <https://forum.xda-developers.com/apps/magisk/module-magiskhide-props-config-t3789228>`_ 模块往往能够解决问题。

- 在 Magisk Manager 的侧边菜单中找到 Magisk Hide 项，选中我们想要隐藏的目标 App 即可。最近更新的 Magisk 19.0 版本还加入了「应用组件」层面进行 Magisk Hide 的功能。

至于对哪些应用进行 Magisk Hide，这个就要看每个读者的具体需要了。一般来说，Google Play 服务和商店是必须的，但也请注意这条来自开发者的注意事项：如无必要，不要随意在 Magisk Hide 列表添加 App 而造成滥用（Do not abuse MagiskHide!）。

如果你还不放心，还可以去 Magisk Manager 的设置中打开「隐藏 Magisk Manager」。此时 Magisk Manager 将会进行一次重新安装，以便打乱软件包名来躲过对 Magisk Manager 的检测。

替代 SuperSU 进行 root 权限管理
---------------------------------

身兼 root 工具的 Magisk，直接使用 Magisk Manager 中的默认设置就能用得舒心。App 向你提请超级用户权限的时候，用户可以选择永久同意、一定时间内同意或者是拒绝，超时之后没有进行选择，那么便会选择拒绝。

获取、管理 Magisk 模块
------------------------

模块的本质，是将原本需要玩家繁复操作的玩机过程与 Magisk「不改动系统」（Systemless-ly） 的特性结合在一起，并进行打包和分发。模块极大地简易了玩机操作，一个小小的 .zip
包文件可能包含了另一套全字重字体，可能囊括了一整套内核参数调教方案，可能附加了一些额外的小功能或是界面美化……模块只是简易了玩机操作的实践，但并没有将它无害化，该翻车的操作还是会翻车，这个时候模块的管理就变得尤其重要。

任何有能力制作模块的开发者都能分发自己制作的模块，也可以选择是否提交到官方的模块仓库。

在模块仓库中点击下载，便会自动开始下载、刷入的步骤，刷入完成后你可以选择关闭或者是直接重启生效。模块更新也是一样的步骤。但如果你是手动下载的模块 .zip 包，一切都需要手动。进入模块菜单项，点击下方的加号图标进入文件目录选取目标模块 .zip 包，即可开始模块的刷入或是更新。

如果「翻车」进不了系统:

无论是提前安装好，还是翻车后进入 TWRP 安装，你都需要用到 Magisk Manager for Recovery Mode 模块（仓库中搜索 mm 即可）。翻车后进入 TWRP 中的终端输入使用指令即可开始管理模块，详见该模块的使用说明。


参考
=======

- `神奇的 Magisk <https://www.jianshu.com/p/393f5e51716e>`_
- `Android 玩家不可错过的神器：Magisk Manager <https://zhuanlan.zhihu.com/p/61302392>`_
- `What is Magisk? <https://www.xda-developers.com/what-is-magisk/>`_ 官方介绍
- `How to install Magisk <https://www.xda-developers.com/how-to-install-magisk/>`_ 官方安装指南
- `Magisk - The Magic Mask for Android <https://forum.xda-developers.com/apps/magisk/official-magisk-v7-universal-systemless-t3473445>`_
- `Magisk - Installation and troubleshooting <https://www.didgeridoohan.com/magisk/Magisk>`_ - 这是非常详细的排查手册，如果你遇到Magisk安装使用问题，请参考该文档
