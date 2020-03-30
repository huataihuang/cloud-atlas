.. _sdcard_speed_class:

=============
SD卡速度等级
=============

在ARM设备中，通常会使用SD卡或者TF卡存储操作系统或者数据，这就涉及到如何选择SD卡/TF卡以便能够更好配合设备使用。

SD存储卡品牌和制造商非常繁多，选择时让人难以确定哪个卡更适合使用，特别是高速写入数据的情况。所以我在这里摘录一些SD标准信息，方便今后选购SD存储卡。

有三中表示最低写入速度的标准：Speed Class、UHS Speed Class和Video Speed Class中的数字符号表示最低写入速度。

.. figure:: ../_static/arm/card-host-marks.jpg
   :scale: 75

Video Speed Class定义了录制高解析度和高画质(4K/8K)视频的需求，同时也具备支持下一代闪存（如3D NAND）的重要功能。此外，Video Speed Class也把录制HD (2K)的视频速度整合在其中。

以下图例很好地展示了不同速度级别SD卡的标志和适合的使用场景

- SD卡速度分类：

.. figure:: ../_static/arm/video_speed_class_01.jpg
   :scale: 75

- 视频格式：

.. figure:: ../_static/arm/video_speed_class_02.jpg
   :scale: 75

.. note::

   由于存储卡中的档案数据不断的被写入或删除，导致卡中的数据会逐渐被碎片化从而影响写入速度。通常来说，因为闪存的特性，在碎片化空间内的写入速度会比连续性的写入速度慢。

参考
======

- `SD速度等级 <https://www.sdcard.org/chs/developers/overview/speed_class/>`_
