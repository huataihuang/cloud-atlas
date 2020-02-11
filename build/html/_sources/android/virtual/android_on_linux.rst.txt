.. _android_on_linux.rst:

=====================
在Linux上运行Android
=====================

虽然Linux能够满足技术工作者90%的需求，并且随着技术发展，WEB逐渐缩小了不同操作系统的差异。但是，总有一些商业软件没有提供Linux发行版，甚至通过WINE这样的兼容方式也无法运行。

好在移动平台的兴起，Andorid占据了极大的市场份额，大多数商业软件都有Android版本。而Android底层就是采用Linux内核和系统，为我们打开了另外一扇运行特定软件的大门。

汇总的在Linux平台上运行Android应用的方案，通过对比，我将选择部分解决方案进行实践。

Android模拟器
===============

Android Emulator(模拟器)是指Android虚拟设备(Android Virtual Devices, AVD)，通常使用模拟器在PC上来测试和运行Android程序。模拟器对于程序就像一个常规的Android智能手机，虽然有可能由于硬件模拟限制，较为消耗计算机资源并且部分程序无法工作。

ARChon(推荐)
-------------

Google开发了一个基于Chrome的runtime来运行Android程序 :ref:`archon` ，通过 Arc Welder 可以在Chrome浏览器中安装应用。

不过，在Arc Welder和Chrome中运行Android apps很困难，需要下载APK。建议从 `apkmirror.com <https://www.apkmirror.com/>`_ 搜索和下载应用。

Shashlik
----------

`Shashlik <http://www.shashlik.io>`_ (shashlik意思是烤肉串) 提供了一个Android模拟层来运行Android Apps:

- Shashlik不需要运行虚拟机，但是集成了Android的核心软件包
- Shashlik包含基于Linux系统的OpenGL
- Shashlik建议在KDE Plasma上运行
- Shashlik的缺点是不能运行需要Google Play服务的应用

`How to Install and Run Android Apps APKs in Ubuntu, Other Version of Linux <https://innov8tiv.com/install-run-android-apps-apks-linux-ubuntu/>`_

不过，从 `Shashlik GitHub项目 <http://github.com/shashlik>`_ 来看，开发工作停留在2016年，所以仅参考，不做尝试。

参考
=====

- `10 Best Android Emulators for Linux 2020 – Run Android Apps on Linux <https://securedyou.com/best-android-emulators-for-linux-run-android-apps/>`_
