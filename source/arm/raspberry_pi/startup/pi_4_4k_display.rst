.. _pi_4_4k_display:

=======================
Raspberry Pi 4的4K显示
=======================

从 :ref:`pi_4` 的技术规格可以看到支持双路4K显示，这对于软件开发者来说是非常完美的，因为我们阅读代码需要有非常大显示器以及高分辨率来提高效率。 :ref:`pi_400` 虽然价格低廉，但是丝毫没有降低 :ref:`pi_4` 显示配置，同样支持双4K显示，所以我购买了4K显示器来用于树莓派400。

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

我的选择 - AOC U28P2U/BS 28英寸4K

AOC U28P2U/BS 28英寸4K显示器
-----------------------------

选择的原因:

- AOC市场占有率较高，品控有一定保障
- AOC U28P2U/BS 119%sRGB色域，10bit色彩，色彩准确度DeltaE<2，据说显示效果较好，有些设计师反馈较好，也就是说基本色彩准确，应该能够满足我这样的码农
- AOC U28P2U/BS 不是高刷显示器，也就意味着它侧重点不是游戏(恰好我完全不玩游戏)
- DC不闪背光技术，通过TUV低蓝光认证(据说对眼睛比较好，既然广告主推，多少有些加分)
- 4ms响应时间(够用？)
- 没有自带音箱(说实在显示器带音箱效果很差白白浪费资金)，不过提供了一个音频输出插孔，可以连接耳机 - 恰好配我平时最常用的SONY MDR-7506耳机，而且我想通过 :ref:`pi_400` 的HDMI输出音频，应该可以直接使用这个转换方式
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


参考
======

- `数显之家快讯：4K超清分辨率显示器尺寸多少合适？ <https://zhuanlan.zhihu.com/p/320555314>`_
- `Rasp <https://www.raspberrypi.org/documentation/configuration/config-txt/pi4-hdmi.md>`_
- `No HDMI output on my Raspberry Pi 4 <https://support.thepihut.com/hc/en-us/articles/360008687257-No-HDMI-output-on-my-Raspberry-Pi-4>`_
- `Raspberry Pi HDMI not working? Follow these simple solutions <https://windowsreport.com/raspberry-pi-hdmi-not-working/>`_
- `How to enable 4K output on Raspberry Pi 400? <https://forum.endeavouros.com/t/how-to-enable-4k-output-on-raspberry-pi-400/9632/12>`_
- `Video options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/video.md>`_
- `HDMI monitors says NO SIGNAL (solved) <https://www.raspberrypi.org/forums/viewtopic.php?t=34061>`_

