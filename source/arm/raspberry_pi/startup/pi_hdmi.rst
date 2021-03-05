.. _pi_hdmi:

=================
树莓派HDMI接口
=================

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

- `Rasp <https://www.raspberrypi.org/documentation/configuration/config-txt/pi4-hdmi.md>`_
- `No HDMI output on my Raspberry Pi 4 <https://support.thepihut.com/hc/en-us/articles/360008687257-No-HDMI-output-on-my-Raspberry-Pi-4>`_
- `Raspberry Pi HDMI not working? Follow these simple solutions <https://windowsreport.com/raspberry-pi-hdmi-not-working/>`_
- `How to enable 4K output on Raspberry Pi 400? <https://forum.endeavouros.com/t/how-to-enable-4k-output-on-raspberry-pi-400/9632/12>`_
- `Video options in config.txt <https://www.raspberrypi.org/documentation/configuration/config-txt/video.md>`_
- `HDMI monitors says NO SIGNAL (solved) <https://www.raspberrypi.org/forums/viewtopic.php?t=34061>`_
