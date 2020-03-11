.. _lineageos_16_nexus_5:

====================================================
在Nexus 5(hammerhead)上安装LineageOS 16(Android 9)
====================================================

.. note::

   由于LineageOS目前官方已停止支持Nexus 5，所以安装LineageOS 16(Android 9)从第三方下载：

   - `[ROM][UNOFFICIAL] LineageOS 16.0 for Nexus 5 <https://forum.xda-developers.com/google-nexus-5/orig-development/rom-lineageos-16-0-nexus-5-t3921162>`_
   - `CyanogenMods - Download LineageOS 16 for Nexus 5 <https://www.cyanogenmods.org/forums/topic/download-lineage-os-16-for-nexus-5/>`_

   Nexus 5目前没有LineageOS 17.1的镜像可以下载，能够找到的针对Gphone的 `LineageOS17镜像 <https://www.cyanogenmods.org/download-lineageos-17/>`_ 的最低硬件配置是Nexus 5X

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
   # 当前最新版本为 twrp-3.3.1-0-hammerhead.img
   # 所以执行：
   # fastboot flash recovery twrp-3.3.1-0-hammerhead.img

* 然后验证是否可以进入recovery: 在设备关机状态下，安装 ``音量减小`` 键，然后安装电源键直到设备启动菜单出现，然后通过音量按键上下滚动，并通过 电源键 选择 ``RECOVERY``

此时 TWRP 的管理界面，可以对系统进行各种底层操作。

.. warning::

   我为了干净安装，使用了TWRP的wipe功能，将系统和数据完全擦除，然后通过 ``sideload`` 方式进行OTA安装。这种方式数据是完全丢失的，请不要在有数据需要保留情况下使用这个方法。

- 在设备上TWRP菜单中选择 ``Advanced`` 和 ``ADB Sideload`` ，然后滑动控制条开始进入sideload

- 此时在主机上执行 ``adb devices`` 可以看到设备进入sideload状态::

   List of devices attached
   04a827c034408cdc      sideload 

- 下载LineageOS 16 for Nexus5: `CyanogenMods - Download LineageOS 16 for Nexus 5 <https://www.cyanogenmods.org/forums/topic/download-lineage-os-16-for-nexus-5/>`_ 提供了2个版本， `[ROM][UNOFFICIAL] LineageOS 16.0 for Nexus 5 <https://forum.xda-developers.com/google-nexus-5/orig-development/rom-lineageos-16-0-nexus-5-t3921162>`_ 提供了另一个更新的版本(推荐)：

  - lineage-16.0-20180922-UNOFFICIAL-hammerhead.zip:

  `Nexus 5 LineageOS 16 by Krizthian <https://androidfilehost.com/?w=files&flid=282201&sort_by=date&sort_dir=DESC>`_

  - lineage-16.0-20180907-UNOFFICIAL-hammerhead.zip:

  `Nexus 5 LineageOS 16 by Prashanth <https://androidfilehost.com/?fid=1322778262904002530>`_

  - lineage-16.0-20190926-UNOFFICIAL-hammerhead.zip:

  `Nexus 5 LineageOS 16 by EnesSastim <https://sourceforge.net/projects/nexus5oof/files/LineageOS/>`_

  - 
- 在主机上执行以下命令把镜像压缩包sideload到设备中::

   adb sideload lineage-16.0-20190926-UNOFFICIAL-hammerhead.zip

- `下载 MindTheGapps <http://downloads.codefi.re/jdcteam/javelinanddart/gapps>`_ :

.. note::

   建议在LineageOS 16 Android 9 Pie Rom上使用MindTheGapps，因为它是由LineageOS的核心成员开发的，并且支持LineageOS的A/B分区(主要由Android实现)。注意，这个软件包是区分ARM架构(分为32位和64位)和x86架构的。由于Nexus 5使用的 `Snapdragon 800 <https://www.qualcomm.com/products/snapdragon-processors-800>`_ 是32位架构，所以下载

   `MindTheGapps-9.0.0-arm-20190615_031401.zip
   <http://downloads.codefi.re/jdcteam/javelinanddart/gapps/MindTheGapps-9.0.0-arm-20190615_031401.zip>`_

- 刷入Gapps::

   adb sideload MindTheGapps-9.0.0-arm-20190615_031401.zip

.. note::

   这里我遇到一个问题，16G存储版本的Nexus 5在刷入 MindTheGapps 始终报错::

      Mounting system partition
      /system mounted
      Extracting files
      Low resource device detected, removing large extras
      Not enough space for GApps! Aborting
      Updater process ended with ERROR: 1

   所以，我改为刷入 `GApps for LineageOS 16 <https://www.cyanogenmods.org/forums/topic/google-apps-download-lineage-os-16-gapps-zip-file/>`_ ::

      adb sideload gapps_arm_cancro_9.0_pie.zip

   但是也同样类似报错::

      Insufficient storage space available in System partition. You may want to use a smaller OpenGApps package or consider removing some apps using gapps-config. See:'/sideload/open_gapps_log.txt' for complete details and information.

      - Copying Log to /sideload
      - NO changes wee made to your device

      Installer will now exit...
      Error Code: 70
      - Umounting /persist /system

- Root设备是通过安装 `LineageOS’ AddonSU <https://download.lineageos.org/extras>`_ 或者 Magisk 完成的，注意是安装 ``arm`` 包::

   adb sideload addonsu-14.1-arm-signed.zip

- 完成以上工作后重启手机系统

参考
======

- `Install LineageOS on hammerhead <https://wiki.lineageos.org/devices/hammerhead/install>`_
- `Download LineageOS 16 for Nexus 5 <https://www.cyanogenmods.org/forums/topic/download-lineage-os-16-for-nexus-5/>`_
