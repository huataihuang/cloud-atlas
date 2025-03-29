.. _android_11_pixel_3:

=======================
在Pixel 3上刷Android 11
=======================

2021年中，终于等到Pixel 3二手价格降低到能够承受范围，所以购买了二手Pixel 3来使用最新Android系统。目前稳定版本Android 11，Preview版本是Android 12。我拿到设备的第一时间，首先尝试刷Android 11，并计划在稍后刷新Android 12。

准备工作
==========

- 购买的是可解锁版本Pixel 3，价格比不能解锁版本要高不少，不过为了能够在解锁状态下使用VoLTE，也只能这样了

- 首先在主机上安装 :ref:`adb` ，并且激活设备的开发模式和 ``adb debugging`` ，确保::

   adb devices

可以看到设备::

   List of devices attached
   912X1U972device  

备份和复制文件
==============

- 使用 `adb` 命令下载或者上传文件::

   adb pull /sdcard/Download/myapp.apk myapp.apk

解锁
============

- 重启进入bootloader状态::

   adb reboot bootloader

解锁步骤对于玩机非常关键，我们需要通过解锁来实现root手机，以便能够定制操作系统，或者刷入自己制作的镜像或者恢复出厂镜像::

   fastboot oem unlock

.. note::

   我是通过刷入 `Nexus和Pixel设备的出厂镜像 <https://developers.google.com/android/images>`_ 来完成第一次设备初始化，目的是得到一个干净的系统，所以这里需要首先 unlock bootloader .

Root Pixel 3(可选)
===================

Root Pixel之后，可以安装 :ref:`magisk` 实现操作系统定制，特别是我们需要激活 voLTE。

下载工厂镜像
=============

从Google开发网站下载针对 `Nexus和Pixel设备的出厂镜像 <https://developers.google.com/android/images>`_

- 解压缩::

   unzip blueline-rq3a.210605.005-factory-53820251.zip

- 手机重启进入bootloader状态::

   adb reboot bootloader

- 进入镜像目录::

   cd blueline-rq3a.210605.005/
   ./flash-all.sh

刷机完成
===========

- 刷机完成后重启手机，注意首次初始化选择离线初始化，这样可以在完成简单初始化之后安装翻墙软件连接google服务进行进一步设置

- 对于原生Android系统，非常关键的操作就是连接Google账号进行认证和同步，并登录Google Play更新和安装系统软件。当我们首次初始化Pixel手机时候，系统还没有安装和设置任何VPN，所以我们需要借用其他系统共享的完整Internet访问，我采用 :ref:`vpn_hotspot` 方法，借用另一台可以翻墙的Android手机完成初始化设置，并从Google Play上安装Cisco Anyconnect。

- 之后这台Pixel手机就是完全自由的手机了

.. note::

   绝不要安装Google Play之外的Android应用，并且尽可能杜绝使用国产软件。因为国产软件在墙内不能使用Google推送服务Firebase 云消息传递（Firebase Cloud Messaging，即 FCM），导致每个应用各自实现了不断唤醒自己的强制推送，也是导致国产软件耗能大响应缓慢的原因。原本不弱于iPhone的Pixel旗舰，硬生生拖成了二三流手机。

TWRP
======

Pixel 3默认没有提供国内移动运营商的VoLTE支持，这会导致很多时候无法无法正常通话(中国移动已经关停了很多2g基站，导致只有4g VoLTE才能正常通话)，所以我们需要通过首先安装 `TWRP boot recovery工具 <https://twrp.me/>`_ 获得root权限，然后刷入Magis才能够完成很多特殊操作。

参考
======

- `手机刷TWRP Recovery <https://www.jianshu.com/p/d53cc06df76a>`_
- `Android Root 教程 <https://www.jianshu.com/p/c33b909db895>`_
