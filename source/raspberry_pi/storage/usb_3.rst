.. _usb_3:

===============
USB标准3.x
===============

在 :ref:`choice_pi_storage` 时，我对比了淘宝上不同固态存储的性能和售价，选择最适合 :ref:`raspberry_pi` 和 :ref:`jetson` 的USB外界存储设备。不过，在选择USB移动固态硬盘中，对接口选择最初让我很疑惑，因为现在市场上能够提供的NVMe移动硬盘，性能大约是传统的SSD固态硬盘的2倍，但是我的树莓派设备能达到使用这种高性能外接存储的级别么？

USB标准和USB 3.x
===================

最初我们接触到USB设备很少关心它的性能，毕竟早期主要是U盘，性能和方便程度比软盘和光盘已经大大提高。但是随着数据爆炸发展，传输的数据量越来越多，USB接口速度就成了制约的瓶颈。

- USB 2.0标准发布于2000年，传输速度 480Mbit/s
- USB 3.0标准发布于2008年，传输速度提升到 5Gbit/s
- USB 3.1标准将传输速度翻倍，提升到 10Gbis/s

简单来说USB 3.0速度是USB 2.0的10倍，而USB 3.1 则是 3.0的2倍。

不过，出于市场宣传需求，USB-IF组织，将 USB 3.0 改名为 USB3.1 Gen 1，而 USB 3.1 改名为 USB 3.1 Gen 2 。这对早期接触USB的人来说，听到自己熟悉的名字更改，还是有点不太适应。不过，还好，记住USB 3.1有一代和二代的区别，性能差一倍。

此外，USB 3.1 Gen 2通常的接口形式是Type-C，也就是Android手机和现在笔记本电脑上常用的USB小接口。而早期的USB 3.1 Gen 1，则就是Type A大接口。为了区分相似的都使用Type-A接口的USB 3.1 Gen1和USB 2.0，主要区别是接口塑料片的颜色：USB 3.1 Gen 1是蓝色，而古老的USB 2.0则是黑色或白色。

USB 3.2
-----------

2017年发布了USB 3.2，不过有带来混乱是：之前的USB 3.1 Gen 1 （也就是 USB 3.0） 又被改名为 USB 3.2 Gen 1x1，记住，速率是 5Gbps。

而USB 3.1 Gen 2则改名为 USB 3.2 Gen 1x2，速率是 10Gbps。

再之后是 USB 3.2 Gen 2x1，速率还是 10Gbps

最后是 USB 3.2 Gen 2x2，速率是 20Gbps

.. note::

   USB-IF组织实际上是把 5Gbps 作为基数，然后按照这个基数来翻倍作为断代区别，也就是 1x1, 1x2, 2x1, 2x2

   其中 Gen 1x2 和 Gen 2x2 只有 USB Type-C 接口。

由于Type-C接口可以正反方向插入，并且接口小巧，已经成为主流的USB接口。而苹果从Thunderbolt（雷霆) 3开始，接口也改为采用USB-C接口。

USB4
=========

USB 4再次把USB 3.2 Gen 2x2速率翻倍，达到了 40Gbps，兼容雷霆3，仅采用USB-C接口。

树莓派存储选择
===============

树莓派仅提供2个USB 3.0 (USB 3.1 Gen1)接口，也就是最高速率只有5Gbps，折算成字节，则只有大约 625MB/s。所以对于这个接口速率的限制，选择NVMe存储设备是不合适的(NVMe读取速率约2~3.5GB/s，写入速率约2~3GB/s，远超过USB 3.0接口)。

NVMe
-------

Non-Volatile Memory Express (NVMe) 是专为固态存储器设计的新型传输协议。SATA (Serial Advanced Technology Attachment) 仍是行业存储协议标准，但它并非专为固态硬盘等闪存存储器设计，无法提供 NVMe 所具有的优势。采用 NVMe 的固态硬盘最终将取代 SATA 固态硬盘，成为新行业标准。

要使用NVMe固态硬盘，计算机上需要具有M.2插槽，并且主板支持NVMe(也称为PCIe模式)。

.. note::

   NVM Express (NVMe) 或Non-Volatile Memory Host Controller Interface Specification (NVMHCIS) 是开放的逻辑设备接口，通过PCIe总线通讯。

参考
=====

- `USB 3.1 Gen 1/Gen 2/USB 3.2 之间有什么区别 <https://www.kingston.com/cn/usb-flash-drives/usb-30>`_
