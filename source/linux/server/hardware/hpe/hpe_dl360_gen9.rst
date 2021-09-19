.. _hpe_dl360_gen9:

================================
HPE ProLiant DL360 Gen9服务器
================================

HPE ProLiant DL360 Gen9 服务器综合配置介于 :ref:`dell_r630` 和 :ref:`dell_r640` 之间:

- 主板芯片和 :ref:`dell_r630` 相同，采用 :ref:`intel_c610` 系列
- CPU支持和 :ref:`dell_r630` 相同，支持 :ref:`xeon_e5-2600_v3` 和 :ref:`xeon_e5-2600_v4` ，这款服务器支持的CPU型号较多(比DL160):

.. csv-table:: HPE ProLiant DL360 Gen9 支持E5-2600 v3/v4处理器
   :file: hpe_dl360_gen9/hpe_dl360_gen9_cpu.csv
   :widths: 25, 15, 10, 10, 10, 15, 15
   :header-rows: 1

- 内存支持和 :ref:`dell_r640` 类似，同时支持不同类型(超越了Dell R630)

  - :ref:`lrdimm_ram` 3TB (24 x 128GB LRDIMM @ 2400 MHz)
  - :ref:`rdimm_ram` 768GB (24 x 32GB RDIMM @ 2133 MHz)
  - :ref:`nvdimm_ram` 128GB (16 x 8GB NVDIMM)
  
.. note::

   不过从淘宝可以看到 LRDIMM 内存目前非常昂贵，不如 RDIMM内存 性价比高。不过，技术发展迅速，或许未来也可能进入二手市场的高性价比范围。

存储
========

DL360服务器内置驱动器分为8盘位和10盘位两种，有以下集中配置规格:

存储控制器
-------------

主板内置存储控制芯片: HPE Dynamic Smart Array B140i控制器 (对于E5-2600v3 CPU处理器，主板集成的B140i只能工作在UEFI模式)。默认B140i设置为AHCI模式，如果要使用SATA only模式则需要配置激活。

支持2种阵列卡：

- H240ar 阵列卡，适合少量硬盘，只支持RAID 0和1模式，硬盘也可以设置为无阵列模式
- H440ar 阵列卡，配置2G缓存和电池，支持多硬盘RAID 5,6,10,50,60等模式，硬盘也可以设置为无阵列模式

HP官方支持网站提供了部件安装视频指南，例如 `HP Smpart Array Controller <https://support.hpe.com/hpesc/public/docDisplay?docId=psg000107aen_us&page=GUID-F16DC03B-D44C-4C4C-B314-BD207D305DF1.html>`_ 介绍了如何替换阵列卡。其他组件的安装替换也有相应指导，非常方便

内置硬盘配置组合:

电源支持
=========

- 500W标配
- 800W
- 1400W
- 750W +

参考
=======

- `HPE ProLiant DL360 Gen9 Server <https://support.hpe.com/connect/s/product?language=en_US&ismnp=0&l5oid=7252836&kmpmoid=7252838&cep=on#t=All>`_
- `HPE ProLiant DL360 Gen9 Server QuickSpecs <https://support.hpe.com/hpesc/public/docDisplay?docLocale=en_US&docId=c04346229>`_
