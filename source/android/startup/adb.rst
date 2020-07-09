.. _adb:

===========================
Android Debug Bridge (adb)
===========================

Android Debug Bridge (adb) 是一个多用途命令行工具，用于和设备通讯。adb命令方便了一系列设备操作，例如安装和调试应用，并且提供了一个Unix shell可以在设备上运行一系列命令。adb是一个客户-服务器程序，包含3个组件:

* 客户端：发送指令。这个客户端程序运行在开发主机上，你可以从命令行终端发起

.. note::

   Android Studio安装Android SDK以后，adb位于 ``sdk/platform-tools`` 目录:

   * Windows平台安装目录： ``%USERPROFILE%\AppData\Local\Android\sdk\platform-tools\``
   * Mac平台安装目录： ``~/Library/Android/sdk/platform-tools``

激活设备adb debugging
=======================

要通过USB连接设备使用adb，需要在设备的系统设置中激活 ``USB debugging`` ，这个激活位于 ``Developer options`` 。

对于Android 4.2或更高版本，这个 Developer options 默认是关闭的，要看到这个选项，选择菜单 ``Settings > About phone`` ，然后在 ``Build number`` 菜单上 ``连续点击7次`` 。

此时将设备通过USB连接电脑，执行命令::

   adb devices

就会看到设备::

   * daemon not running; starting now at tcp:5037
   * daemon started successfully
   List of devices attached
   04a827c034408cdc      unauthorized

注意，此时设备还没有授权给主机，需要在设备上点击确认信任该电脑，确认以后再次执行 ``adb devices`` 就能够看到::

   List of devices attached
   04a827c034408cdc      device

现在就可以使用adb对设备进行操作了。

安装软件包
============

如果你的电脑上连接了多个Android设备，则需要指定设备进行操作，请使用参数 ``-s <DEVICE ID>`` 。可以使用 ``adb`` 安装软件包::

   adb -s <DEVICE ID> install <PATH TO APK>

复制文件
==========

使用 ``pull`` 和 ``push`` 命令可以从设备或到设备复制文件，命令类似 ``git`` ，这个命令可以寄昂文件复制到设备到任何位置。而 ``install`` 命令仅能复制APK文件到特定位置。

- 从设备中复制文件::

   adb pull remote local

- 向设备中复制文件::

   adb push local remote

停止adb服务器
===============

有时候需要终止adb server进程然后重新启动它以解决一些问题，例如不相应命令::

   adb kill-server

shell命令
===========

使用 ``adb shell`` 可以启动交互shell::

   adb [-d |-e | -s serial_number] shell shell_command

adb提供了很多有用的Unix命令航工具，例如要查看可用的工具::

   adb shell ls /system/bin

调用活动管理器(activity manager, am)
--------------------------------------

adb的shell可以使用activity manager工具来执行系统活动，例如启动一个动作，强制停止进程，广播intent，修改设备屏幕属性等::

   am command

例如可以通过adb使用动作管理器命令::

   adb shell am start -a android.intent.action.VIEW

调用软件包管理器(package manager, pm)
--------------------------------------

在adb的shell中，可以使用包管理器执行安装，查询软件包等操作::

   pm command

例如卸载软件包::

   adb shell pm uninstall com.example.MyApp

调用设备策略管理器(policy manager, dpm)
------------------------------------------

::

   dpm command

屏幕截图
----------

使用 ``screencap`` 命令可以截屏::

   screencap filename

举例::

   adb shell screencap /sdcard/screen.png

记录视频
----------

``screenrecord`` 命令可以记录屏幕::

   screenrecord [options] filename

例如::

   adb shell screenrecord /sdcard/demo.mp4

按下 ``Ctrl+C`` (在Mac上是 ``Command+C`` )就可以停止记录。默认自动停止记录是3分钟，或者启动时设置 ``--time-limit`` 。

参考
======

- `Android Stuido文档 - Android Debug Bridge (adb) <https://developer.android.com/studio/command-line/adb>`_
