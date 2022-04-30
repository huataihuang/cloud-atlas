.. _pi_400_4k_display:

=========================
Raspberry Pi 400的4K显示
=========================

.. warning::

   经过实践，我发现 :ref:`pi_400` 确实能够支持两台 ``4K`` 显示器，但是都只能工作在 ``30Hz`` 刷新率。并且，和 :ref:`pi_4` 不同， :ref:`pi_400` 即使只使用1台连接在 ``HDMI0`` 上的显示器，也不能达到 ``60Hz`` 刷新率。详情情参考 :ref:`pi_400_display_config` 。

从 :ref:`pi_4` 的技术规格可以看到支持双路4K显示，这对于软件开发者来说是非常完美的，因为我们阅读代码需要有非常大显示器以及高分辨率来提高效率。

从 :ref:`pi_400` 的 `Raspberry Pi 400 Tech Specs <https://www.raspberrypi.org/products/raspberry-pi-400/specifications/>`_ 可以看到： ``2 × micro HDMI ports (supports up to 4Kp60)`` 和 :ref:`pi_4` 完全一致。由于Raspberry Pi 400支持4k显示输出，并且有完整的外壳和键盘，作为轻量级开发桌面非常适合Linux爱好者。

树莓派4B和400差异
==================

当我在YouTube上看到能够 :ref:`fydeos_pi` ，让我非常心动：仅仅500RMB就能够实现Linux融合Android应用，能够用Android应用软件来补充Linux桌面应用，应该是非常适合工作环境。 

我购买了4K显示器和 :ref:`pi_400` ，想要实现一个轻量级的Linux开发环境(大量的计算和部署实践在我的 :ref:`pi_cluster` 通过 :ref:`kubernetes_arm` 实现)。不过，当我使用中发现:

- 在Raspberry Pi 400上如果配置了 ``hdmi_enable_4kp60=1`` ，则重启系统后，4K显示器在 :ref:`xfce` 的Display配置中，虽然刷新率确实是 ``60Hz`` ，但是分辨率最高只有 ``1920x1080`` ，无法设置更高的分辨率。
- 如果去掉 ``hdmi_enable_4kp60=1`` ，则Raspberry Pi 400能够自动检测到4K显示器并且设置最高分辨率 ``3840*2160`` ，但是很不幸，刷新率只有 ``30Hz``

仔细阅读 `Video options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/video.md>`_ ，并参考 `How to enable 4K output on Raspberry Pi 400? <https://forum.endeavouros.com/t/how-to-enable-4k-output-on-raspberry-pi-400/9632/12>`_ 关于 :ref:`pi_4` 和 :ref:`pi_400` 芯片型号对比， 树莓派400和树莓派4B有细微差异：

.. figure:: ../../../_static/arm/raspberry_pi/startup/pi_chip.jpg
   :scale: 50

请注意，在 `维基百科VideoCore文档 <https://en.wikipedia.org/wiki/VideoCore>`_ 列出Dual 4K仅列出Raspberry Pi 4B ，主频是 1.5GHz。

.. figure:: ../../../_static/arm/raspberry_pi/startup/pi_chip_spec.png
   :scale: 70

而Raspberry Pi 400提高了处理器主频到 1.8GHz - ``Broadcom BCM2711 quad-core Cortex-A72(ARM v8) 64-bit SoC @ 1.8GHz`` ，但是在官方 `Video options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/video.md>`_ 配置激活 ``4k@60Hz`` 的参数 ``hdmi_enable_4kp60`` 有一个括号注明 ``Pi 4B only`` 。

不过，在 `Raspberry Pi 400 Tech Specs <https://www.raspberrypi.org/products/raspberry-pi-400/specifications/>`_ 可以看到明确的 ``4Kp60`` 支持，如果没有文档错误的话，说明 :ref:`pi_400` 也是可以实现 60Hz刷新率下 4K 显示分辨率。

那么， :ref:`pi_400` 究竟能否实现  60Hz 刷新率下4K分辨率显示呢？

HDMI线缆
==========

原来要实现4K视频显示，不仅需要主机显示芯片支持，显示器支持，信号传输线缆也必须支持:

- HDMI 1.4: 传输速率10Gbps， 支持分辨率 =< 4K ，但是画面刷新率只能达到 40Hz， 只支持 8bit 色深
- HDMI 2.0: 输输速率18Gbps， 支持分辨率 =< 4K ，画面刷新率提高到 50/60Hz， 支持10bit 色深

详细请参考 `1.4版HDMI线和2.0版HDMI线有什么区别？ <https://www.zhihu.com/question/291749246>`_

之前我的测试始终不能实现 4K@60Hz ，原因就是使用了普通的 HDMI 1.4 线缆。

.. warning::

   虽然理论上(根据树莓派官方网站pi 400 spec)树莓派400是支持 ``4Kp60`` ，但是我购买了 HDMI 2.1 数据线(理论支持8K)，但是在树莓派400上依然没有实现60Hz刷新率下的4K显示输出。

   这让我很困惑，暂时没有找到解决方法...

   不过，我有3台树莓派4B设备，其中2G版本的Raspberry Pi 4B作为 :ref:`arm_k8s` 的管控主机 ``pi-master1`` 。既然Raspberry Pi 4B是明确支持 ``4Kp60`` ，那么我要充分发挥硬件性能，就用 2G版本的Raspberry Pi 4B 连接新购买的4K显示器，验证我的假设。

   新的实践记录在 :ref:`pi_4b_4k_display` ，已经验证 Raspberry Pi 4B可以实现 ``4K@60Hz`` ，可以较为完美使用4K显示器。 

4k显示器
=========

.. note::

   所谓4k显示器通常指 3840*2160像素的分辨率

在选购4k显示器的时候主要考虑因素:

- 显示尺寸

3840*2160像素的分辨率，对于28英寸4k像素密度为157ppi，在30厘米左右的观赏距离下是非常适合的一个标准。相对来说，32英寸4K会将像素密度降低至140ppi左右，清晰度降低。

可以参考一下 27英寸5K屏幕的苹果iMac视网膜版，像素密度为220ppi。既然苹果选择推出27英寸的5K显示器，可以推测在28英寸规格下，4K分辨率应该是比较合适的。

- 刷新率

理论上刷新率越高对于动态显示图形越流畅，不过对于编程没有太大要求，常规的60Hz应该能够满足。高刷新率对于显卡要求极高，树莓派虽然是支持4K输出，但是规格参考 `树莓派HDMI配置 <https://www.lxx1.com/pi/basis/HDMI_config.html>`_ :

  - Raspberry Pi 4可以驱动最多两个显示器
  - 4K分辨率下，如果连接两个显示器，则刷新率将限制为30Hz
  - 以60Hz的刷新率以4K驱动单个显示器要求:

    - 显示器连接到与UCB-C电源输入（标记为HDMI0）相邻的HDMI端口
    - config.txt中设置标志来启用4Kp60输出: ``hdmi_enable_4kp60=1``

.. note::

   我的实践遇到一个奇怪的问题，默认配置下，Raspberry Pi 400是能够检测出 ``AOC International 28''`` 显示器，并且能够以 ``3840x2160 30.0Hz`` 输出显示。但是，当我配置了 ``hdmi_enable_4kp60=1`` 之后，重启虽然显示刷新率是60Hz，但是屏幕分辨率最高只能 ``1920x1080`` 。我尝试了替换电源，hdmi接口以及配置 ``hdmi_mode=97`` (模式列表中只有 ``4096x2160`` 的对应值 102)都没有实现60Hz下高分辨率。目前仅能退而求其次，采用 ``3840x2160 30.0Hz`` 。

我的选择 - AOC U28P2U/BS 28英寸4K

AOC U28P2U/BS 28英寸4K显示器
-----------------------------

选择的原因:

- AOC市场占有率较高，品控有一定保障
- AOC U28P2U/BS 119%sRGB色域，10bit色彩，色彩准确度DeltaE<2，据说显示效果较好，有些设计师反馈较好，也就是说基本色彩准确，应该能够满足我这样的码农
- AOC U28P2U/BS 不是高刷显示器，也就意味着它侧重点不是游戏(恰好我完全不玩游戏)
- DC不闪背光技术，通过TUV低蓝光认证(据说对眼睛比较好，既然广告主推，多少有些加分)
- 4ms响应时间(够用？)
- 没有自带音箱(说实在显示器带音箱效果很差白白浪费资金)，不过提供了一个音频输出插孔，可以连接耳机 - 恰好配我平时最常用的SONY MDR-7506耳机，而且我想通过 :ref:`pi_400` 的HDMI输出音频

  - 已测试，通过 Raspberry Pi 400的HDMI接口输出，可以直接从显示器的音频输出插孔输出声音，当卡朋特的 ``yesterday once more`` 从SONY MDR-7506传出，真是让人心情舒适

- 提供一个快充USB接口(我想用来连接我的 :ref:`homepod_mini` 这样可以节约出一个快充充电器)，以及2个USB3.2接口(这个我还不理解如何使用，难道是提供了USB HUB功能？)，目前我考虑通过USB接口来给 :ref:`pi_400` 提供电源
- 支持同时接入两路信号共用屏幕 - 可以在屏幕上通过并排方式显示两台电脑的显示输出，这样就不用购买显示分屏器了：我恰好有一台笔记本显示屏损坏，偶尔需要外接显示器使用，这样可以和 :ref:`pi_400` 分享使用显示器
- 划重点：花呗24期免手续费分期 - 穷困如我

hdmi0
========

我在使用 :ref:`pi_400` 来尝试 :ref:`fydeos_pi` ，遇到的第一个问题就是启动后只看到树莓派的著名的彩虹方块，然后显示器就黑屏指示没有输入信号。这个问题和HDMI的配置相关，促使我学习树莓派的启动配置 ``config.txt`` 有关HDMI输出设置。

树莓派有2个HDMI接口，其中标记为 ``hdmi0`` 的接口是主显示接口，这个接口靠近 ``USB-C`` 电源接口。如果你只有一个显示器，请连接到 ``hdmi0`` 接口。

树莓派使用的显示核心是 `VideoCore <https://en.wikipedia.org/wiki/VideoCore>`_ ，这是一个低能耗的移动设备多媒体处理器。VideoCore的二维DSP架构使它能够有效完成解码多种多媒体编码而保持较低能耗。VideoCore的智能核心(SIP core)在Broadcom单片SoC上集成，例如在树莓派上使用的 Broadcom BCM2711B0 ，就通过ARM Cortex-A72 集成了VideoCore，提供了 ``双4K`` 显示输出支持。

树莓派4的HDMI pipeline(管道)
=============================

hdmi_safe
==============

设置 ``hdmi_safe`` 参数 ``1`` 可以以最大的HDMI兼容模式启动，相当于同时设置如下配置::

   hdmi_force_hotplug=1
   hdmi_ignore_edid=0xa5000080
   config_hdmi_boost=4
   hdmi_group=2
   hdmi_mode=4
   disable_overscan=0
   overscan_left=24
   overscan_right=24
   overscan_top=24
   overscan_bottom=24

应用程序在高分辨率调整
=======================

高分辨率下应用程序字体较小导致不够清晰，请参考 :ref:`xfce` 中 ``高分辨率调优``

屏幕黑边
=============

有可能图形桌面不能全屏(在桌面周围有一圈黑边)，我在AOC 28“显示器就遇到这个问题。这是因为错误设置了 ``Underscan/overscan`` 导致的，可以通过 ``raspi-config`` 工具修改::

   sudo raspi-config

选择::

   Display Options => Underscan

然后选择不激活 compensation for dispalys with overscan

详细参考 `Install the XFCE desktop on your Raspberry PI <https://www.pragmaticlinux.com/2020/11/install-the-xfce-desktop-on-your-raspberry-pi/>`_

Raspberry Pi 400 4K@60Hz (失败)
=================================

我反复测试了 Raspberry Pi 400 的4K设置，发现只能达到 30Hz显示刷新率。配置模仿 :ref:`pi_4b_4k_display` 并且参考::

   [all]

   #dtoverlay=vc4-fkms-v3d 
   dtoverlay=vc4-kms-v3d 
   max_framebuffers=2 
   gpu_mem=128 
   #hdmi_group=1
   #hdmi_mode=97
   hdmi_enable_4kp60=1

激活 ``hdmi_enable_4kp60=1`` 就能够显示 4K 但是只有最高刷新率 30Hz。然后我尝试使用 ``dtoverlay=vc4-fkms-v3d`` 则不能显示最高分辨率，同时设置了 ``hdmi_group=1`` 和 ``hdmi_mode=97`` (指定分辨率3840x2160)也不行。尝试了修改成闭源的 ``dtoverlay=vc4-kms-v3d`` 则又能够显示最高分辨率4K，但是同时刷新率落回了 30Hz。

参考
======

- `数显之家快讯：4K超清分辨率显示器尺寸多少合适？ <https://zhuanlan.zhihu.com/p/320555314>`_
- `Raspberry Pi 4 HDMI pipeline <https://www.raspberrypi.org/documentation/configuration/config-txt/pi4-hdmi.md>`_
- `No HDMI output on my Raspberry Pi 4 <https://support.thepihut.com/hc/en-us/articles/360008687257-No-HDMI-output-on-my-Raspberry-Pi-4>`_
- `Raspberry Pi HDMI not working? Follow these simple solutions <https://windowsreport.com/raspberry-pi-hdmi-not-working/>`_
- `How to enable 4K output on Raspberry Pi 400? <https://forum.endeavouros.com/t/how-to-enable-4k-output-on-raspberry-pi-400/9632/12>`_
- `Video options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/video.md>`_
- `HDMI monitors says NO SIGNAL (solved) <https://www.raspberrypi.org/forums/viewtopic.php?t=34061>`_
- `RPI4 & Ubuntu MATE - How to enable video acceleration <https://www.dedoimedo.com/computers/rpi4-ubuntu-mate-hw-video-acceleration.html>`_
