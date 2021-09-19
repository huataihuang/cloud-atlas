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

参考
=======

- `HPE ProLiant DL360 Gen9 Server - Overview <https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-c04442953>`_
