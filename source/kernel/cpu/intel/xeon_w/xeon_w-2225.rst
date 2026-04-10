.. _xeon_w-2225:
 
===================
Intel Xeon W-2225
===================

我购买的 :ref:`dell_t5820` 按照Dell官方手册是支持 :ref:`xeon_w-2235` ，价格低廉性能强劲。然而， :ref:`dell_t5820_crash_debug` 定位到主板 **电感不足** 导致无法支持高启动电流的处理器。

所以最终我更换为Intel Xeon W-2225，价格实际上和 :ref:`xeon_w-2235` 一致，但是核心数量少了2个，TDP功耗则从130W降低到105W

- 基准主频 4.10 GHz，最高Turbo主频 4.60 GHz(基准频率比W-2235上升了300MHz)
- 支持 内存类型 DDR4 2933，最大1TB容量，最大内存带宽 93.85 GB/s (这对于使用CPU进行推理的性能至关重要)，性能参数和W-2235一致，所以实际用于 :ref:`machine_learning` GPU推理调度基本无影响
- 支持 Intel® Deep Learning Boost (Intel® DL Boost) on CPU 技术，也就是提供了 Intel AVX-512 指令支持 :ref:`vnni` 能够比上一代大幅加速INT8量化大模型的推理速度(3-4倍)

.. csv-table:: Xeon W-2225和W-2235对比
   :file: xeon_w-2225/compare.csv
   :widths: 20,20,30,30
   :header-rows: 1

参考
======

- ` Intel® Xeon® W-2225 Processor 8.25M Cache, 4.10 GHz <https://www.intel.com/content/www/us/en/products/sku/198610/intel-xeon-w2225-processor-8-25m-cache-4-10-ghz/specifications.html>`_
