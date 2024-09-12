.. _crucial_p3:

==============================
英睿达Crucial P3 NVMe SSD存储
==============================

.. note::

   英睿达 ``P3`` (PCIe 3.0) 和 ``P3 plus`` (PCIe 4.0) 系列都是无缓存QLC存储颗粒

优点:

- 最高4TB规格(价格差不多是2TB规格翻倍)
- 顺序读(3500 MB/s)写(3000 MB/s)，比 :ref:`kioxia_exceria_g2` 性能好很多(顺序读 2100 MB/s, 顺序写 1700 MB/s)

缺点:

- 英睿达 ``P3`` (PCIe 3.0) 和 ``P3 plus`` (PCIe 4.0) 系列都是无缓存QLC存储颗粒

  - 直接使用主机内存缓存(Host-Memory-Buffer,HMB) 64MB

- 耐用度比 :ref:`kioxia_exceria_g2` 差，2T规格 440TB TBW ( :ref:`kioxia_exceria_g2` 2T规格 800TBW，其实铠侠的 TBW 比 :ref:`samsung_pm9a1` 低很多，但是却比英睿达好很多)
- 主控芯片 Phison PS5021-E21T ，架构是 ARM 32-bit Cortex-R5 ，3核处理器1GHz : 对比 :ref:`kioxia_exceria_g2` Phison PS5012-E12S-32 ，架构也是 ARM 32-bit Cortex-R5， 4核处理器667 MHz，实际上两者差别不大，但考虑到铠侠的核心频率低，可能热量更少一些

参考
=======

- `NVME硬盘有缓存好还是无缓存好？ <https://www.zhihu.com/question/502746914>`_
