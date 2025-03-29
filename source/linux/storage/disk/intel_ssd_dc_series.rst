.. _intel_ssd_dc_series:

========================
Intel企业级固态硬盘
========================

.. note::

   本文综合了一些网络资料以便理解Intel企业级SSD的技术以及优缺点，不过，目前我对此了解不多，不能保证准确性。有待后续学习和修订，请谨慎参考

我的思考
===========

Intel 3710 二手SSD可能是具备较好性价比的磁盘(如果健康度95%左右，非翻新)，如果售价在400元以内

概述总结
============

- Intel S3700 和 S3710 是企业级数据中心专用MLC ，采用了 Intel HET 高耐久性技术(High Endurance Technology) 技术:

  - HTE技术在采用20nm工艺的MLC闪存PE次数达到1万次，远超普通MLC的3千次
  - HTE采用了较低的写入电压技术: 

    - MLC需要充更高的电压来表示4种电压(00/01/10/11)，导致绝缘层损耗较大(绝缘层消耗殆尽后闪存会失效)，所以MLC的使用寿命不如SLC (SLC仅需要较低电压表示二进制0与1)
    - HTE技术降低了MLC充电电压，以获得更低的绝缘层损耗

  - HTE技术缺点:

    - 充电更少的HET MLC比普通写入条件下的MLC在断电后更容易丢数据
    - 通常企业级服务器都是24小时通电，所以断电后数据丢失问题较轻

- Intel S3700 (25nm闪存) S3710 (20nm闪存) 

- 所谓 "清零盘" 是指清除了 S.M.A.R.T 中的 E2, E3, E4 属性:

  - ``E2`` 周期内负载介质磨损
  - ``E3`` 周期内负载主机读/写比率
  - ``E4`` 周期内负载计数器，单位分钟，这个值除以60就是多少小时(通电)

- 市场上几乎不可能存在0通电二手企业级SSD:

  - Intel S3710清零后会恒定显示 ``0xFFFF`` (65535): 正常的全新盘刚通电时也是 ``0xFFFF`` 但是0~60分钟以后就会正常计数，清零盘是不会计数的
  - 淘宝上有很多Intel S3710售卖，但是都是号称 "工包全新" 的清零盘，无法确定实际使用寿命: 这一点不如 :ref:`sandisk_cloudspeed_eco_gen_ii_sata_ssd` ，Sandisk SSD大多数没有做清零(还算明码标价)`

- S3710 似乎有写入放大的固件Bug(不确定)

- S3710 **功率极高** : 1.2T版本 读取功率5w，写入功率12w ，所以无法在笔记本电脑SATA上使用，也很难用于USB硬盘盒(没有外接电源肯定写坏) 总之 **只适合服务器使用**

.. csv-table:: Intel SSD DC S3700 400G, S3710 400G, S3520 480G 对比
   :file: intel_ssd_dc_series/intel_ssd_dc_s3700_s3710_s3520.csv
   :widths: 25,25,25,25
   :header-rows: 1

Intel SSD DC S3520 480GB
==========================

.. csv-table:: Intel SSD DC S3520 / 480GB,MLC
   :file: intel_ssd_dc_series/intel_ssd_dc_s3520_480g.csv
   :widths: 60, 40
   :header-rows: 0

Intel SSD DC S3710 400GB
==========================

.. csv-table:: Intel SSD DC S3710 / 400GB,MLC
   :file: intel_ssd_dc_series/intel_ssd_dc_s3710_400g.csv
   :widths: 60, 40
   :header-rows: 0

Intel SSD DC S3700 400GB
==========================

.. csv-table:: Intel SSD DC S3700 / 400GB,MLC
   :file: intel_ssd_dc_series/intel_ssd_dc_s3700_400g.csv
   :widths: 60, 40
   :header-rows: 0

.. note::

   intel 早期2款MLC的企业级SATA SSD:

   - S3700系列: Q4'12 发布，25nm工艺，Endurance Rating (Lifetime Writes) 10 drive writes per day for 5 years = 7.3PB

     - 400GB: 465元

   - S3710系列: Q1'15 发布, 20nm工艺, Endurance Rating (Lifetime Writes) = 8.3PB 

     - 400GB: 595元

   早期的MLC真是非常夸张的耐用寿命!

   - S3520系列: 03'16 发布, 16nm 3D NAND工艺，Endurance Rating (Lifetime Writes) = 945TBW

     - 480GB: 480元
     - 800GB: 787元

   可以看到S3520系列，后期改进工艺但是使用寿命和读写速度大为降低，性价比反而不如 S3710 系列

   - S3610系列: Q1'15 发布，20nm工艺, 官方没有提供耐久度 Endurance Rating 数据

参考
========

- `Intel SSD DC S3520 Series <https://ark.intel.com/content/www/us/en/ark/products/93026/intel-ssd-dc-s3520-series-480gb-2-5in-sata-6gbs-3d1-mlc.html>`_
- `Intel固态硬盘总结 <https://www.cnblogs.com/hongdada/p/17321748.html>`_
- `超耐久（cao）MLC！英特尔HET闪存技术是什么原理？ <https://www.bilibili.com/read/cv1125639?from=articleDetail>`_
