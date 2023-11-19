.. _android_13_pixel_4:

=======================
在Pixel 4上刷Android 13
=======================

在 :ref:`build_lineageos_20_pixel_4` 系统中，使用 :ref:`cn_samsung_galaxy_watch_4_wich_android` 遇到连接配对时 ``Samsung wareable`` 程序总是在最后同步阶段推出，所以想尽量减少触发问题的变量，所以尝试先将手机系统刷回标准的Android系统，避免自定义编译系统存在不兼容问题。

注意，我是从LineageOS回退到官方Android 13系统

准备工作
==========

- 首先在主机上安装 :ref:`adb` ，并且激活设备的开发模式和 ``adb debugging`` ，确保::

   adb devices

可以看到设备::

   List of devices attached
   9B1AFS000009SCdevice 

备份和复制文件
==============

- 使用 `adb` 命令下载或者上传文件(之前在Download中下载的文件都是后续安装时需要的程序)::

   adb pull /sdcard/Download/myapp.apk myapp.apk

解锁
============

- 重启进入bootloader状态::

   adb reboot bootloader

解锁步骤对于玩机非常关键，我们需要通过解锁来实现root手机，以便能够定制操作系统，或者刷入自己制作的镜像或者恢复出厂镜像::

   fastboot oem unlock

.. note::

   我是通过刷入 `Nexus和Pixel设备的出厂镜像 <https://developers.google.com/android/images>`_ 来完成第一次设备初始化，目的是得到一个干净的系统，所以这里需要首先 unlock bootloader .

Root Pixel 4(可选)
===================

Root Pixel之后，可以安装 :ref:`magisk` 实现操作系统定制，特别是我们需要激活 voLTE。

下载工厂镜像
=============

从Google开发网站下载针对 `Nexus和Pixel设备的出厂镜像 <https://developers.google.com/android/images>`_

- 解压缩::

   unzip flame-tp1a.221005.002.b2-factory-38e4f49a.zip

- 手机重启进入 ``fastboot`` 模式: 注意，可以通过 :ref:`android_recovery_mode` 找到进入 ``fastboot`` 的菜单入口(一定要采用 ``fastboot`` 模式，否则刷机可能失败)

   adb reboot bootloader

- 进入镜像目录::

   cd flame-tp1a.221005.002.b2/
   ./flash-all.sh

Recovery
============

我这里遇到一个问题，是一个乌龙，我忘记之前的操作步骤，直接在Recovery模式下，采用 ``Apply update from ADB`` 菜单进行恢复，见下文 ``修复错误``

先进入 :ref:`android_recovery_mode`

- 按住 ``电源+音量向下`` 进入Recovery模式，此时进入Recovery模式，再按一下电源键，会看到 ``No command`` 
- 按下并保持主电源键，然后按一下 ``音量向上`` 键；再放开电源键，就会看到手机进入了 Recovery 模式

修复错误
============

- 在 Recovery 模式下，可以选择 ``Apply update from ADB`` 菜单，此时可以采用侧载(sideload)方式刷入官方镜像

.. literalinclude:: android_13_pixel_4/sideload_androd_zip
   :caption: 在 ``recovery`` 模式下，通过 ``sideload`` 方式刷入官方镜像

- 但是，由于手机安装过 LineageOS，分区和签名已经不同，会导致无法重新刷入Google官方Android镜像，此时在手机端会看到证书错误:

.. literalinclude:: android_13_pixel_4/sideload_androd_zip_err
   :caption: 通过 ``sideload`` 方式刷入官方镜像显示证书错误

.. note::

   Google提供了一个在线网站，可以用来修复Pixel手机: `Google Pixel - Update and Software Repair <https://pixelrepair.withgoogle.com/>`_ 

参考 `Is there a way to "undo" Lineage and restore my phone to its original state? <https://www.reddit.com/r/LineageOS/comments/w7ikaq/is_there_a_way_to_undo_lineage_and_restore_my/>`_ ，原来当系统完全异常(无法恢复)，Google提供了一种称为 ``Stock Firmware`` 来完全覆盖恢复的方法。这个操作必须是在 ``fastboot`` 模式下进行，而不是 ``Apply update from ADB`` (sideload)

刷机完成
===========

- 刷机完成后重启手机，注意首次初始化选择离线初始化，这样可以在完成简单初始化之后安装翻墙软件连接google服务进行进一步设置

- 对于原生Android系统，非常关键的操作就是连接Google账号进行认证和同步，并登录Google Play更新和安装系统软件。当我们首次初始化Pixel手机时候，系统还没有安装和设置任何VPN，所以我们需要借用其他系统共享的完整Internet访问，我采用 :ref:`vpn_hotspot` 方法，借用另一台可以翻墙的Android手机完成初始化设置，并从Google Play上安装Cisco Anyconnect。

- 之后这台Pixel手机就是完全自由的手机了

.. note::

   绝不要安装Google Play之外的Android应用，并且尽可能杜绝使用国产软件。因为国产软件在墙内不能使用Google推送服务Firebase 云消息传递（Firebase Cloud Messaging，即 FCM），导致每个应用各自实现了不断唤醒自己的强制推送，也是导致国产软件耗能大响应缓慢的原因。原本不弱于iPhone的Pixel旗舰，硬生生拖成了二三流手机。

参考
======

- `How to Go Back to Stock Android From a Custom ROM: 3 Ways <https://www.makeuseof.com/tag/rooted-android-back-stock/>`_
- `Is there a way to "undo" Lineage and restore my phone to its original state? <https://www.reddit.com/r/LineageOS/comments/w7ikaq/is_there_a_way_to_undo_lineage_and_restore_my/>`_
