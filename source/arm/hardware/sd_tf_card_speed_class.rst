.. _sd_tf_card_speed_class:

=================
SD/TF卡速度等级
=================

.. note::

   在使用 :ref:`jetson` 设备时需要使用TF卡来作为存储，我最初随手拿了很久以前购买的手机TF卡安装系统。但是，在使用过程中发现系统卡顿非常验证，特别在启动应用程序缓慢得让人抓狂。

   很明显， ``top`` 显示iowait非常严重，这显示TF卡性能严重制约了ARM设备的运行。所以我在购买 :ref:`pi_4` 特别注意选择合适的TF卡，避免存储瓶颈。

在ARM设备中，通常会使用SD卡或者TF卡存储操作系统或者数据，这就涉及到如何选择SD卡/TF卡以便能够更好配合设备使用。

SD/TF存储卡品牌和制造商非常繁多，选择时让人难以确定哪个卡更适合使用，特别是高速写入数据的情况。而且厂商为了营销，采用了眼花缭乱的等级介绍，很少会提供实际的性能测试报告，导致选择非常困难。所以，为了能够辨别"真伪"，需要首先了解这个行业的标准，通过标准分类来初步确定目标，再寻找网友的不同测试报告综合进行选择。

如果你在淘宝上搜索TF卡，你会看到厂商的宣传资料中有如下标记:

.. figure:: ../../_static/arm/tf_card.png
   :scale: 50

.. note::

   我为 :ref:`pi_4` 选择的就是上述SanDisk Extreme 128GB TF卡:

   - 读取速度160MB/s，写入速度90MB/s（理论值，实际待测试）
   - 达到了A2标准，意味着对随机读写对IOPS有一定保证，我觉得应该能够改善之前在 :ref:`jetson` 上慢速TF卡导致应用卡顿的问题

有三种表示最低写入速度的标准：Speed Class、UHS Speed Class和Video Speed Class中的数字符号表示最低写入速度。

.. figure:: ../../_static/arm/card-host-marks.jpg
   :scale: 75

.. note::

   正如硬盘 `SATA3.0接口 <https://baike.baidu.com/item/SATA3.0%E6%8E%A5%E5%8F%A3>`_ 接口速率达到600MB/s(理论值SATA接口速率是6Gb/s=768MB/s实际产品大约600MB/s)，但实际上机械硬盘内部传输速率远达不到接口速率(5400转笔记本硬盘约为 50-90MB/s，7200转台式机硬盘越90-190MB/s)。

Class 10
============

- Class 0: 包括低于Class 2和未标注Speed Class的情况
- Class 2: 能满足观看普通MPEG4 MPEG2的电影、SDTV、数码摄像机拍摄
- Class 4: 可以流畅播放高清电视(HDTV)，数码相机连拍等需求
- Class 6: 满足单反相机连拍和专业设备的使用要求
- Class 10: 满足更高速率要求的存储需求

Class等级是按照8KB/s换算的，Class 4最低写入为 4MB/s ，Class 10表示最低写入为10MB/s。

UHS-X
=========

UHS-1 表示支持 UHS (Ultra High Speed, 超高速)接口，其带宽达到 104MB/s。但是这个速度只代表总线规格，并不代表闪存内部速率。

V30
========

Video Speed Class定义了录制高解析度和高画质(4K/8K)视频的需求，同时也具备支持下一代闪存（如3D NAND）的重要功能。此外，Video Speed Class也把录制HD (2K)的视频速度整合在其中。

以下图例很好地展示了不同速度级别SD卡的标志和适合的使用场景

- SD卡速度分类：

.. figure:: ../../_static/arm/video_speed_class_01.jpg
   :scale: 75

- 视频格式：

.. figure:: ../../_static/arm/video_speed_class_02.jpg
   :scale: 75

.. note::

   由于存储卡中的档案数据不断的被写入或删除，导致卡中的数据会逐渐被碎片化从而影响写入速度。通常来说，因为闪存的特性，在碎片化空间内的写入速度会比连续性的写入速度慢。



参考
======

- `SD速度等级 <https://www.sdcard.org/chs/developers/overview/speed_class/>`_
- `tf卡读写速度等级排序 <https://www.php.cn/faq/440958.html>`_
