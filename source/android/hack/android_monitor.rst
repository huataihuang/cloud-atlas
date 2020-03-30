.. _android_monitor:

=======================
Android手机作为显示器
=======================

现在手机的屏幕越来越大，主流都能够达到2K的分辨率，实际上已经是一个非常清晰的小型便携显示屏了。

在玩树莓派( :ref:`raspberry_pi` ) 设备时，甚至 :ref:`jeston` 都存在一个显示问题，手边虽然没有显示器，但是我们有 :ref:`pixel` 手机，如果能够直接把显示输出到手机屏幕，再结合蓝牙键盘，或许就能够打造一个随身的Linux服务器系统。

这种设备称为 ``HDMI视频采集卡`` ，在淘宝上能够找到 250~300元 左右 (USB 3.0输出，支持 1920x1080@60fps) 的设备。这样就能够把HDMI输出(例如树莓派)转换成USB的输入，此时再结合一个USB OTG转换器，就可以输入到Android手机。(甚至有更为便宜的早期USB 2.0视频捕捉卡，价格约70+元)。

`Portable HDMI Screen Using Your Smartphone <https://keyboardinterrupt.org/smartphone-hdmi-screen/>`_ 中介绍的 ``USB HDMI grabber`` 在淘宝上有销售，就是USB 2.0视频捕捉卡，价格非常低廉。

在Android手机上，还需要安装一个应用软件来查看视频捕捉卡的输入，可以使用 ``USB Camera`` 这个应用软件来显示

.. note::

   `THIS DEVICE LETS YOU USE YOUR PHONE AS AN EXTERNAL HDMI MONITOR WITH ANY CAMERA <https://www.diyphotography.net/device-lets-use-phone-external-hdmi-monitor-camera/>`_ 介绍了一种名为 `Lukilink <https://www.kickstarter.com/projects/220205692/lukilink/>`_ 设备用于将HDMI输出到手机上。

   `HDMI Input for Android <https://www.instructables.com/id/HDMI-Input-for-Android/>`_ 介绍了通过 ``EasyCap Recorder`` (在Google Play商店可以安装) 结合 EasyCap视频捕捉卡通过USB-OTG转换线来实现视频显示。同一个开发者还提供了 ``USB Camera`` 工具软件，是相同的应用。

参考
=====

- `Portable HDMI Screen Using Your Smartphone <https://keyboardinterrupt.org/smartphone-hdmi-screen/>`_
- `HDMI Input for Android <https://www.instructables.com/id/HDMI-Input-for-Android/>`_ 
