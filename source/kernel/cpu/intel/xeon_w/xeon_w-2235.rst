.. _xeon_w-2235:
 
===================
Intel Xeon W-2235
===================

我入手的 :ref:`dell_t5820` 支持 Xeon W-22xx 系列处理器，我选择了当前最经济实惠的 **W-2235** ，只需要460元，就嗯够拥有:

- 基准主频 3.80 GHz，最高Turbo主频 4.60 GHz
- 支持 内存类型 DDR4 2933，最大1TB容量，最大内存带宽 93.85 GB/s (这对于使用CPU进行推理的性能至关重要)
- 支持 Intel® Deep Learning Boost (Intel® DL Boost) on CPU 技术，也就是提供了 Intel AVX-512 指令支持 :ref:`vnni` 能够比上一代大幅加速INT8量化大模型的推理速度(3-4倍)

我之所以为 :ref:`dell_t5820` 选择了 W-2235 ，主要考虑能够实践 :ref:`openvino` 的加速CPU推理，尝试新的 :ref:`machine_learning` 技术线

然而很不幸，我购买的 :ref:`dell_t5820` 遇到了非常诡异的无法启动的问题，排查了一个晚上，最后从卖家那里获知，售卖的T5820最高只支持 : ``W-2225`` 。经过和gemini讨论和排查，基本确定是早期主板 :ref:`dell_t5820_crash_debug` 发现电感不足导致无法支持高电流要求的W-2235

参考
======

- `Intel® Xeon® W-2235 Processor <https://www.intel.com/content/www/us/en/products/sku/198608/intel-xeon-w2235-processor-8-25m-cache-3-80-ghz/specifications.html>`_
