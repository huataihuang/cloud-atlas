.. _twrp:

====================
TWRP Recovery管理器
====================

.. note::

   在使用了最新的Android 10系统的Pixel 3设备，已经不在支持传统的recovery方式，也就是本文TWRP Recovery无法工作，我们需要改为 :ref:`magisk_root_ota`

   本文作为Android 9系列操作系统的TWRP Recovery管理器实践记录。

- 检查连接设备::

   adb devices

显示::

   List of devices attached
   912X1U972       device  

如果设备状态是 ``unauthorized`` ，则需要在手机端确认信任PC端才能正常连接

安装TWRP
==========

安装TWRP需要根据自己手机型号来选择下载文件，以及参考文档。例如我现在 :ref:`pixel_3` ，则参考 `TWRP for Google Pixel 3 <https://twrp.me/google/googlepixel3.html>`_

提供了2个下载文件:

- twrp-pixel3-installer-blueline-3.3.0-0.zip
- twrp-3.3.0-0-blueline.img

如果已经安装过TWRP，则只需要下载 ``zip`` 文件，如果是首次安装，则需要使用 ``img`` 文件(用来启动TWRP操作系统通过旁路刷入zip文件)

- 重启手机进入 bootloader::

   adb reboot bootloader

- 执行 ``fastboot boot`` 命令加载TWRP镜像作为操作系统::

   fastboot boot twrp-3.3.0-0-blueline.img

在Android 11(Android 10也如此)上实行上述启动命令会出现报错::

   Sending 'boot.img' (65536 KB)                      OKAY [  0.290s ]
   Booting                                            FAILED (remote: 'Error verifying the received boot.img: Invalid Parameter')
   fastboot: error: Command failed

Pixel系列手机自2016年开始发布，提供了很多安全改进，这也带来了手机root更为困难的挑战。例如Pixel具备A/B分区系统以及内核的安全功能，都使得获取root访问更为困难。特别是2018年Google旗舰手机提供了内核的一些修改阻止了用户root Pixel手机。这个安全修改是Google Pixel的新的Boot Image Header版本v1，所有使用Android 9 Pie的智能手机都是用了这个Boot Image Header v1。

Pixel 3和4在最新的Android 10中采用了和以前Android版本不同的AOSP recovery，也就是使用动态库ramdisk，而TWRP在Pixel 3/4上提供的是静态库ramdisk(针对Pixel3的版本自2018年之后没有更新过)，所以导致无法挂在 ``/system`` 目录。而且Android 10引入了新的动态分区系统，并不是以前的独立system分区和独立的vendor分区，即Andorid 10使用了一个super分区。这些问题在TWRP上都没有解决，所以至今尚未能够在Pixel 3上Andorid 10上实现TWRP。( `Pixel 3 boot failing on Android 11 #109
<https://github.com/TeamWin/twrpme/issues/109>`_ )

- 此时我们可以看到手机进入了TWRP系统，这样我们就能把TWRP的zip刷入到Pixel设备的两个启动slot中::

   adb push twrp-pixel3-installer-blueline-3.3.0-0.zip /

.. note::

   这里假设 ``twrp-3.3.0-0-blueline.img`` 和 ``twrp-pixel3-installer-blueline-3.3.0-0.zip`` 都存放在当前目录下

完成了TWRP安装之后，我们就可以使用TWRP来安装 :ref:`magisk` ，以便修订Android系统。

参考
========

- `How a Custom Recovery With TWRP Works On Android <https://www.online-tech-tips.com/smartphones/how-a-custom-recovery-with-twrp-works-on-android/>`_
- `手机刷TWRP Recovery <https://www.jianshu.com/p/d53cc06df76a>`_
- `Android Root 教程 <https://www.jianshu.com/p/c33b909db895>`_
- `How to Install TWRP Recovery and Root Google Pixel 3 (XL) <https://www.thecustomdroid.com/root-google-pixel-3-xl-guide/>`_
- `TWRP and Android 10 <https://twrp.me/site/update/2019/10/23/twrp-and-android-10.html>`_
