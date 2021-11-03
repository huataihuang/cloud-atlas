.. _tesla_p10:

===============================
Nvidia Tesla P10 GPU运算卡
===============================

疯狂的 ``挖矿`` 和 ``芯片荒`` 使得显卡已经成为技术工作者 `生命无法承受之重 <https://book.douban.com/subject/1017143/>`_ ，原本消费级别的 ``经济型`` GTX 显卡，已经到了二手现价远超5年前发售上市价格。

我脑海中出现的就是 **未来废土世界** - `疯狂的麦克斯4：狂暴之路 Mad Max: Fury Road (2015) <https://movie.douban.com/subject/3592854/>`_ 

.. figure:: ../../_static/machine_learning/hardware/mad_max.jpg
   :scale: 50

NVIDIA Tesla P10
====================

Telsa P10是NVIDIA于2016年9月13日发布的专业图形卡，采用16 nm技术，基于 GP102 图形处理器。

GP102图形处理器是die面积高达471 mm²，包含了11,800 million (1亿1千8百万) 晶体管。

功能:

- 3840个 着色单元
- 240个 纹理映射单元
- 96个 ROP

硬件配置:

- 24 GB GDDR5X 内存 (384-bit内存接口，运行在1808 MHz，有效带宽 14.5 Gbps)
- GPU主频 1025 MHz，boost频率达到 1493 MHz

Tesla P10是一个单插槽运算卡，长度 267 mm / 宽度 97 mm，使用 PCIe 3.0 x16 接口，这恰好是我购买的二手 :ref:`hpe_dl360_gen9` 能够安装的规格(1U服务器)，这也是我能够找到经济上可以承受同时能够安装到1U服务器的GPU卡。

.. figure:: ../../_static/machine_learning/hardware/tesla_p10.jpg
   :scale: 50

.. figure:: ../../_static/machine_learning/hardware/tesla_p10_back.jpg
   :scale: 50

神奇之P10
----------

Tesla P10是一块 ``隐形运算卡`` ，你在网上几乎找不到资料，虽然同属 NVIDIA Tesla 系列，但是我们常见的有 ``Tesla P40 24GB`` 和 ``Tesla P199 12GB`` ，同属Pascal 微架构

技术规格
------------

.. csv-table:: Tesla P10 vs. GeForce GTX 1080 Ti
   :file: tesla_p10/tesla_spec.csv
   :widths: 33, 33, 33
   :header-rows: 1

Tesla P10 和 GeForce GTX 1080 Ti 采用了相同的GPU核心 GP102 ，也就是 Pascal 架构，工艺和技术参数几乎相同，主要差异:

- P10 GPU主频降到 1025 MHz (Boost 1493 MHz)，比侧重游戏和图形应用的 1080 Ti 低了 30% ，虽然在渲染、游戏上会差很多，但是也带来了极佳的低温散热，所以 P10 的优势是 ``刀卡`` (只需要1个插槽) 而且是被动散热
- P10 通过提高内存主频(带宽)以及加大内存大小来提升性能，内存带宽比 1080 Ti 高了 32% ，同时 P10 增加了 7~9% 的(着色、纹理映射、ROP)处理单元，这使得两者的性能评分非常接近

.. figure:: ../../_static/machine_learning/hardware/p10_1080_ti.png
   :scale: 80

- 其他差异是 P10 没有显示输出，是纯粹的数据中心运算卡，无法用于3D游戏加速，也不能用于挖矿(算力是个位数)，所以这也是同样性能的 Tesla P10 在当前 ``疯狂时期`` 二手售价仅为 GeForce GTX 1080 Ti 的 1/5 的原因之一(GTX 1080 Ti二手价格被炒高了)

.. note::

   我使用的二手 :ref:`hpe_dl360_gen9` 是1U服务器，内部空间狭窄，无法安装双槽GPU卡，所以Tesla P10是少数能够安装且价格较为低廉的运算卡。

   我准备采用这块GPU运算卡实现 :ref:`sr-iov` 虚拟化运行，具体实践后续补充

安装
=======

我在购买Tesla P10之前，一直担心在 :ref:`hpe_dl360_gen9` 上安装空间不足。根据淘宝买家介绍的显卡安装案例 ``Quadro K4200 4GB 图形显卡`` 广告中声明 ``支持显卡的最大尺寸：长*宽*高 25*2*11 cm（由于机器是1U尺寸机箱 所以只能插刀卡）`` 。不过，按照 `techpowerup GPU Database - NVIDIA Tesla P10 <https://www.techpowerup.com/gpu-specs/tesla-p10.c3750>`_ 资料， 长宽是 ``267 mm x 97 mm`` 。

按照查询资料，似乎测量板卡尺寸各有不同，有些测量没有包括板卡的固定板，有的则包含，所以尺寸测量实际上是一个迷。我查询了很多Nvidia的GPU卡，发现大量的GPU卡公开资料都显示长度是 ``267 mm`` ，也就是说，这个长度尺寸是标准尺寸。服务器和PC都是标准化设备，有可能还是可以安装(即使看上去只差一点点)。

电源线
--------

Tesla P10买家是通过顺丰空运，第二天晚上就拿到了，安装到 DL360 Gen9的狭窄1U机箱，果然如我所推测，尺寸正好。

不过，遇到一个问题，Nvidia的GPU卡需要外接电源，而DL 360内部没有这个电源线。问了卖家，这个电源线就是PC机的标准8-pin电源线。在HP DL360 gen9的 ``Primary PCIe 3.0 riser for PCIe slot 1 & 2`` (对应CPU 1) 的电路板背面(靠近 slot2)有一个象牙色的电源出输出(8-pin)，可以输出电流给显卡使用。下图是PCIe Slot 1 & 2板上电源接口(部件翻转过来看):

.. figure:: ../../_static/machine_learning/hardware/dl360_gen9_pcie1.png
   :scale: 70

不过，万能淘宝上能够找到 ``DELL R720 双8针 独立显卡 供电线 8针供电 8P 6+2`` ，虽然卖家反复强调这根电源线只能用于Dell服务器，但是苦于无法找到HP服务器的显卡供电线，我仔细对比观察了 ``Dell R720 双2针`` 的接口，看起来是标准电源线接口，和我的HPE DL360 Gen9的 ``Primary PCIe 3.0 riser for PCIe slot 1 & 2`` 电源输出接口完全匹配。

考虑到PC服务器大多是标准通用部件，所以我推测Dell的电源线也可以用于HP服务器。价格不贵，10元，但是我也非常担心加电以后错误输电导致显卡或主板烧毁。毕竟，现在显卡实在太昂贵了...

收到显卡电源线之后，仔细检查了 ``PCIe 3.0 riser`` 的电源输出和 Tesla P10 电源输入，确认接口完全一致。连接以后，确实完全匹配。一咬牙，加电启动...还好，没有出现短路或者烧焦的现象出现。

经过一番折腾，通过 :ref:`enable_gpu_iommu` 就能够正常使用Tesla P10

参考
======

- `techpowerup GPU Database - NVIDIA Tesla P10 <https://www.techpowerup.com/gpu-specs/tesla-p10.c3750>`_
