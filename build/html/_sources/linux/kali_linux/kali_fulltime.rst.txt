.. _kail_fulltime:

==================================
Kali Linux作为日常Linux工作平台
==================================

虽然Kali Linux是作为安全渗透而闻名的Linux发行版，但是实际上Kali是基于Debian/Ubuntu开发的Linux，继承了APT仓库的大量应用程序，也可以作为日常开发和工作平台。要作为日常Linux工作平台，就涉及到一些日常工作软件和环境的设置。我现在就是使用 :ref:`pi_400` 运行ARM版本Kali Linux，作为一个轻量级桌面来远程工作于服务器集群，主要的密集运算和持久化数据都在 :ref:`real` 云上，仅在ARM设备上实现移动办公。所以，我会在本文实践一些桌面日常工作平台设置。

Offiec
==========

实际上我日常对Office的需求很少:

- 由于在互联网公司工作，大量的工作都是基于WEB完成的，无论是文档还是流程，都是通过浏览器操作。这里带来一个问题，就是现在WEB开发越来越依赖Google的Chrome，很多页面排版和特效都只有chrome/chromium才能正常工作，这也限制了浏览器市场的健康竞争。我通常会使用chromium作为工作浏览器，firefox作为个人学习文档阅读浏览器。
- 最主要的Office操作是使用sheet类应用，在Linux平台没有Excel，替代产品很多，虽然达不到Excel这样丰富的功能和兼容性，但是也已经足够。我选择Gnumeric作为日常表格应用，主要考虑安装的依赖较少，轻量级
- 其他偶尔的需求是PPT，不过现在主要使用MarkDown格式的WEB文档来交流，抛却动态效果，也已经足够表达。

在Linux平台上最推荐的Office软件是 LibreOffice ，开发历史悠久，和微软Office兼容性较好::

   sudo apt install libreoffice

另外一个全能型Office软件是基于QT(也就是KDE底层)开发的Calligra Office，最有特色的是提供了类似MS Visio的绘图软件，如果需要绘制流程图并且习惯visio的用户可以使用。

我仅仅安装Gnumeric来完成日常数据整理(只需要80+MB空间)::

   sudo apt install gnumeric

在Linux上运行MS Office
--------------------------

.. note::

   我曾经折腾过很多在Linux上运行原生MS Office的尝试，通过wine构建Windows程序运行环境，可以实现比较古老的MS Office程序运行。不过，对于中文输入非常不友好，且容易崩溃。时间有限，现在我已经不再折腾，必要时还是通过 :ref:`kvm` 虚拟机来运行完整Windows操作系统，实现MS Office运行。所以，这段内容仅做记录参考。

``PlayOnLinux`` 是一个基于wine开发的Windows运行环境，最初只是为了运行Windows平台的游戏，不过逐渐成为运行MS Office的有效手段。

- 安装 ``winbind`` ，这个工具可以让PlayOnLinux正确链接Windows登录::

   sudo apt install winbind

- 安装PlayOnLinux::

   sudo apt install playonlinux

在Linux平台，目前能够运行最完善的是MS Office 2016(32位版本)，你需要下载Microsoft Office 2016 ISO进行安装，安装必须是完整安装。

如果要安装最新版本的MS Office，则可以考虑收费的 ``CrossOver`` 软件，提供了增强版本的wine，可以比较好运行现代版本的MS Office。

.. note::

   对于ARM平台运行Kali Linux，运行Office的方式还可以采用Android应用方式。

视频应用
===========

- 推荐VLC media player::

   sudo apt install vlc

蓝牙
=======

我需要蓝牙连接鼠标键盘，所以安装适合桌面运行的蓝牙组件::

   sudo apt install bluetooth bluez bluez-tools rfkill

上述命令会在Kali Linux中安装好需要组件，然后使用以下命令激活::

   sudo systemctl enable bluetooth
   sudo systemctl start bluetooth

此时会在桌面托盘上看到蓝牙图标，就可以开始使用了蓝牙设备进行配对使用。我在 :ref:`pi_400` 上运行Kali Linux，采用 Logitech的M337蓝牙鼠标，通过这种方式可以顺列通过蓝牙图形管理工具来配对和使用。

ARM运行环境应用软件
=======================

我是在 :ref:`pi_400` 这样的ARM平台运行Kali Linux： ARM 环境可以原生运行Android应用程序，所以我采用 :ref:`anbox` 来安装Android应用。各种商用软件在Android都提供了应用程序，可以满足日常工作需求。




参考
========

- `Kali Linux as Full Time OS in our Daily Life -- Installing Office, Media and other <https://www.kalilinux.in/2020/02/kali-in-our-daily-life.html>`_
- `How to Install Microsoft Office on Linux <https://www.makeuseof.com/tag/install-use-microsoft-office-linux/>`_
