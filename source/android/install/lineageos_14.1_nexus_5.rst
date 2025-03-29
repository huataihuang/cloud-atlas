.. _lineageos_14.1_nexus_5:

============================================
在Nexus 5(hammerhead)上安装LineageOS 14.1
============================================

.. note::

   由于LineageOS目前官方已停止支持Nexus 5，所以需要从 xda-developers 网站获取安装信息：

   - `[ROM][OFFICIAL] LineageOS 14.1 for Nexus 5 (hammerhead) <https://forum.xda-developers.com/google-nexus-5/orig-development/rom-cm14-1-nexus-5-hammerhead-t3510548>`_
   - `[ROM][UNOFFICIAL] LineageOS 16.0 for Nexus 5 <https://forum.xda-developers.com/google-nexus-5/orig-development/rom-lineageos-16-0-nexus-5-t3921162>`_`

前提要求
===========

- 确保主机已经安装了 :ref:`adb` 和 ``fastboot`` - 通过安装Android Studio可以获得工具，也可以单独下载安装
- 手机设备已经启用USB debugging

解锁bootloader
=================

.. note::

   解锁 ``unlock bootloader`` 只需要执行一次就可以，需要注意，解锁会抹除设备上所有数据，所以解锁前务必备份数据。

* 将设备通过USB连接到主机
* 在主机命令行执行以下命令::

   adb reboot bootloader

也可以通过组合键进入 ``fastboot`` 模式: 先关手机，然后安装同时按住 ``电源键`` 和 ``音量减小键`` 则设备启动就会进入 ``fastboot`` 模式。

* 在命令行执行::

   fastboot oem unlock

* 同时按下 ``音量增加键`` 和 ``电源键`` 来确认bootloader unlock
* 在主机上执行命令重启手机::

   fastboot reboot

使用fastboot安装recovery工具
==============================

* 需要下载 `TWRP <https://dl.twrp.me/hammerhead>`_ ，下载后命名类似 ``twrp-x.x.x-x-hammerhead.img``
* 连接USB
* 执行以下命令进入 bootloader::

   adb reboot bootloader

* 验证是否进入fastboot模式::

   fastboot devices

* 刷入recovery::

   fastboot flash recovery <recovery_filename>.img

* 然后验证是否可以进入recovery: 在设备关机状态下，安装 ``音量减小`` 键，然后安装电源键直到设备启动菜单出现，然后通过音量按键上下滚动，并通过 电源键 选择 ``RECOVERY``

此时 TWRP 的管理界面，可以对系统进行各种底层操作。

.. warning::

   我为了干净安装，使用了TWRP的wipe功能，将系统和数据完全擦除，然后通过 ``sideload`` 方式进行OTA安装。这种方式数据是完全丢失的，请不要在有数据需要保留情况下使用这个方法。

- 在设备上TWRP菜单中选择 ``Advanced`` 和 ``ADB Sideload`` ，然后滑动控制条开始进入sideload

- 此时在主机上执行 ``adb devices`` 可以看到设备进入sideload状态::

   List of devices attached
   04a827c034408cdc      sideload 

- 在主机上执行以下命令把镜像压缩包sideload到设备中::

   adb sideload lineage-14.1-20191226-UNOFFICIAL-hammerhead.zip

- 对于还需要安装的软件包，也请一并sieload进去::

   adb sideload open_gapps-arm-7.1-nano-20200205.zip

- Root设备是通过安装 `LineageOS’ AddonSU <https://download.lineageos.org/extras>`_ 完成的，注意是安装 ``arm`` 包::

   adb sideload addonsu-14.1-arm-signed.zip

- 完成以上工作后重启手机系统

参考
======

- `Install LineageOS on hammerhead <https://wiki.lineageos.org/devices/hammerhead/install>`_
