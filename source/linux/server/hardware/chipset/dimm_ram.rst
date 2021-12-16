.. _dimm_ram:

=======================================
Dual In-Line Memory Module (DIMM) 内存
=======================================


Dual In-Line Memory Module (DIMM) 双列直插式内存模块

.. _lrdimm_ram:

LRDIMM 内存
=================

.. _rdimm_ram:

RDIMM 内存
===============

.. _nvdimm_ram:

NVDIMM 内存
================

有3中 JEDEC 标准组织发布的NVDIMM实现:

- NVDIMM-F: 配有flash存储的DIMM，系统用户必须配对安装存储DIMM和传统的DRAM DIMM。虽然没有官方标准，NVDIMM-F类型模块从2014年开始发布
- NVDIMM-N: 在同一个模块中装配了flash存储和传统的DRAM。在系统运行时，计算机是直接访问DRAM的，如果发生断电，模块会把易失的传统DRAM数据复制到持久化flash内存中，并持续保存知道电力恢复。这种模块需要使用一个小型的后备电池，以便模块能够把数据从DRAM复制到flash存储
- NVDIMM-P: 2021年4月由JEDEC完整发布标准，使用 :ref:`linux_pmem` 技术确保计算机主内存持久化，并且可以在DRAM DIMM插槽混合使用DDR4或DDR5内存

.. note::

   我感觉 NVDIMM 技术非常鸡肋，虽然号称和DRAM相同速度，其实只是具备后备电池的flash存储+DRAM，技术上没有突破。

   和 Intel 的 Optane 采用的 3D X-Point 技术相比较，使用范围非常狭窄，成本极高。

NVDIMM RAM主要使用场景:

- 存储: 用于写入加速和commit日志
- 数据恢复: 当服务器hang住时候，能够通过NVDIMM内存恢复系统crash的状态
- GPU服务器: 配合GPU卡和组件，加速机器学习应用速度

NVDIMM RAM本质上还是使用DRAM，所以内存容量极小，并且由于配套flash和后备电池，以及断电时能够回写的控制电路，所以售价极高，对于普通用户来说性价比很低。

参考
======

- `Persistent Memory NVDIMM-N and Optane DC DIMM <https://www.smartm.com/api/download/fetch/61#:~:text=The%20NVDIMM%20has%2010x%20lower,DRAM%20memory%20module%2Dsized%20capacity.>`_
- `Wikipedia NVDIMM <https://en.wikipedia.org/wiki/NVDIMM>`_
- `Dual In-Line Memory Module (DIMM): RDIMMs versus LRDIMMs, which is better? <https://www.dasher.com/server-memory-rdimm-vs-lrdimm-and-when-to-use-them/>`_
- `DDR4 RDIMM and LRDIMM Performance Comparison <https://www.microway.com/hpc-tech-tips/ddr4-rdimm-lrdimm-performance-comparison/>`_
- `Is RDIMM or LRDIMM Right for Your Design? <https://www.eeweb.com/is-rdimm-or-lrdimm-right-for-your-design/>`_
