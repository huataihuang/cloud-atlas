.. _hpe_dl160_gen9:

================================
HPE ProLiant DL160 Gen9服务器
================================

HPE ProLiant DL160 Gen9 服务器类似 :ref:`hpe_dl360_gen9` 的简化版本:

- 主板芯片和 :ref:`hpe_dl360_gen9` 相同，也是 :ref:`intel_c610` 系列，所以基本规格非常相似
- CPU支持和 :ref:`hpe_dl360_gen9` 相同，支持 :ref:`xeon_e5-2600_v3` 和 :ref:`xeon_e5-2600_v4` ，但是根据官方文档，支持的CPU型号要少一些:

.. csv-table:: HPE ProLiant DL160 Gen9 支持E5-2600 v3/v4处理器
   :file: hpe_dl160_gen9/hpe_dl160_gen9_cpu.csv
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
