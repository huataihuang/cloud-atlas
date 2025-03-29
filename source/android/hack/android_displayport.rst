.. _android_displayport:

==========================================
Android(Pixel 3)直连外接显示器(扩展屏幕)
==========================================

之前我尝试过:

- :ref:`android_monitor` : 将Android手机作为视频输入(视频捕捉)，接收其他电脑设备( :ref:`raspberry_pi` )视频输入
- :ref:`androidscreencast` : 将Android屏幕通过 :ref:`adb` 捕捉通过PC主机上的程序播放，这种模式需要有一台电脑主机
- :ref:`scrcpy` : 最强最方便的在电脑上投影Android手机屏幕，并且支持鼠标键盘交互的应用，几乎可以将Andoroid手机无缝结合到电脑操作系统中

上述视频输入和输出虽然能够实现功能，但是都比较笨拙，因为都需要外部配备一台电脑才能完成。

USB-C视频输出
=====================

如果你使用现代的 MacBook ，你会看到MacBook都已经使用了USB-C接口输出视频(兼电源输入)。实际上，现代电脑设备都已经开始广泛使用USB type-c接口作为视频输出，取代了之前广泛使用都HDMI接口。

但是，不是所有USB-C端口都支持视频输出，设备必须特别提供支持 ``USB-C Alternate Mode`` (交替模式)，这种模式和USB-C 3.1线缆的直接 ``device-to-host`` (设备到主机)传输数据协议有所不同。

``Thunderbolt 3(雷电3) Alternate Mode`` 视频流DisplayPort 1.2 或 DisplayPort 1.4视频，所有Thunderbolt 3控制器都支持 ``DisplayPort Alternate Mode`` ，也支持 ``DisplayPort Alternate Mode over USB-C`` 。

DisplayPort Alternate Mode over USB-C
----------------------------------------

- Chrome OS设备都是用USB Type-C输出视频，包括Google Chromebook Pixel(2015)
- MacBook从2015年开始都使用USB Type-C输出视频
- 联想ThinkPad (Windows 10)和小米Mi NoteBook系列也使用USB Type-C输出视频
- 二合一(笔记本/平板)设备，不论是Chrome OS或Windows 10系统，都采用USB Type-C输出视频
- 三星Galaxy Tab平板设备(Android)从2018年开始采用USB Type-C输出视频
- 苹果iPad Pro三代(2018年) / iPad Air四代(2020年) / iPad mini六代(2021年) 开始使用USB Type-C接口，也支持视频输出

智能手机的USB-C视频输出
-------------------------

实际上所有iOS设备(iPhone 4 and later, iPod touch 4th gen and later, iPad 1st gen and later)都支持线缆视频输出。传统上，即使没有使用Micro USB或USB-C，iOS设备都是支持线缆视频输出的，例如早期的30帧 dock连接或Lightning连接，都可以输出视频。

对于Android系统，则不同厂商采用了不同的策略，有可能部分产品线支持USB-C视频输出:

- HTC，三星，华为在大多数旗舰产品线支持DisplayPort:

  - HTC U系列
  - Samsung Galaxy S系列/Note系列
  - 华为 Mate系列/P系列

- LG在G系列和V系列上支持DisplayPort，但是2018年前的部分手机需要通过软件升级开启该功能

- 三星的 DeX 模式， 华为的 Easy投影 和 微软的 Continuum (连续体) 都可以提供类似PC的体验: 不仅能够使用屏幕镜像，而且还能够像电脑连接外部显示器和鼠标键盘一样让应用使用多个窗口

- 很多面向游戏的智能手机，例如ROG和Razer手机，都支持DisplayPort

Android系统的原生桌面模式
---------------------------

Android 10的2019年3月13日首个beta版本，引入了一个原生桌面模式。但是在最终发布版本，却隐藏了这个桌面功能。LG公司修改并增强了这个桌面模式，在自家的LG V50 ThinQ 和 LG G8 ThinQ 推出。

2019年11月，根据Android源代码发现，Google已经明确屏蔽了Pixel 4的DisplayPort功能。

.. note::

   Displayport alt mode over usb-c 功能是在内核中支持的(根据XDA论坛)，Google官方镜像内核应该已经关闭这个功能以便强推 ``chromecast`` 。第三方镜像，如LineageOS默认应该是打开该选项(待验证)。

对于没有原生DisplayPort支持的设备，需要使用 ``DisplayLink`` 投影软件，这个功能是使用DisplayLink芯片的连接器或者docking设备，提供的有限的屏幕镜像功能。不过，作为第三方解决方案，使用HDCP加密视频内容的播放可能会被禁止。

2020年5月，视频电子标准协会(Video Electronics Standards Association, VESA)发布了DisplayPort Alternate Mode(Alt Mode)版本2.0，可以支持在USB 4 Type-C接口输出16K视频。

.. note::

   在智能手机市场上，支持线缆视频输出的厂家最好的如下:

   - 苹果: 全系列
   - HTC: 2016年之后U系列，特别是旗舰系列
   - LG: 2016年以后G系列，V系列
   - 华为: 2017年以后Mate系列，P系列
   - 三星: 2017年以后Galaxy S系列，Note系列
   - Asus: 2018年以后ROG系列
   - Sony: 2019年以后Xperia 1系列，5系列，10系列和Pro系列

   Google比较迷，Pixel4的硬件可能是支持DisplayPort的，但是发布的软件禁用了这个功能

VirtualLink Alternate Mode over USB-C
----------------------------------------

Nvidia的Geforce RTX 20系列显卡支持USB-C输出视频

Pixel屏幕投影
================

根据Google的Pixel手机帮助支持文档 `Project your Pixel phone's screen <https://support.google.com/pixelphone/answer/2865484?hl=en>`_ 可以看到:

无线镜像投屏
-------------

- Google的产品策略是使用 ``Chromecast`` 设备来实现Pixel手机屏幕镜像

  - Google真是店大欺客，非要走一个自己独有的技术路线而不采用标准方案
  - Google的 ``野望`` 是创造一个类似 Apple TV ，实现一个万亿规模的市场

在淘宝上搜索 ``chromecast`` 可以看到支持 ``chromecast`` 的Google TV售价500元左右(疫情的5月底，售价降低到420元左右)

.. note::

   经过反复比较和折腾，我感觉还是购买官方 :ref:`chromecast` 最为一劳永逸的方式，连接显示器或电视机，直接手机无线输出图像同时也支持流媒体播放。除了翻墙是比较麻烦的操作其他功能完全匹敌Apple TV。

有线镜像投屏
--------------

Google的官方帮助提供的有线镜像投屏居然也不是标准的 DisplayPort over USB-C ，而是推荐使用第三方 ``DisplayLink`` Presenter app来实现。看来Google是铁了心阉割掉USB-C的视频输出功能，来强制消费者使用Google TV。

Hack解决方案构想
==================

我觉得从硬件上Pixel系列是支持DisplayPort over USB-C的，只是Google的官方Android代码阉割了这个功能。

考虑以下几个方案:

- 安装第三方镜像(LineageOS)
- 自己编译LineageOS，开启内核支持
- 在淘宝上购买同时支持 ``chromecast`` 和 ``airplay`` 的无线连接器(国内第三方产支持)

我准备尝试使用 :ref:`pixel_3` 实现移动开发工作站...

参考
=====

- `Is there a way to connect a Google pixel to a monitor via a USB-C to HDMI cable? <https://www.reddit.com/r/GooglePixel/comments/n36yyq/is_there_a_way_to_connect_a_google_pixel_to_a/>`_
- `Project your Pixel phone's screen <https://support.google.com/pixelphone/answer/2865484?hl=en>`_
- `List of devices with video output over USB-C <https://en.everybodywiki.com/List_of_devices_with_video_output_over_USB-C#Smartphones>`_
