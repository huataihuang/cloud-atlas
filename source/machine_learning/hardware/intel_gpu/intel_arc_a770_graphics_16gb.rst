.. _intel_arc_a770_graphics_16gb:

============================
Intel Arc A770 16GB显卡
============================

A770采用 ``Alchemist`` 架构(第一代Xe):

.. csv-table:: A770 16GB 技术参数
   :file: intel_arc_a770_graphics_16gb/spec.csv
   :widths: 20,10,10,20,20,10,10
   :header-rows: 1

这里可以关注到几个有意思的参数:

- A770的Xe核心和光追核心是32个，下一代B580的Xe核心和光追核心是24个: 

  - 新一代(Xe2 Battlemage)核心处理逻辑在执行AI常用的FP16/BF16 指令时，单个核心的实际产出（IPC）显著高于上一代
  - B580的第二代XMX引擎针对大模型推理中的低精度运算（INT8/INT4/FP16）进行了吞吐优化: 即便核心数少了 30%，但由于每个 XMX 单元每时钟周期的矩阵运算吞吐量大幅提升，B580 的理论 AI 峰值算力（TFLOPS/TOPS）通常能与 A770 持平甚至反超
  - B580 大幅加大了 L2 缓存: 在推理模型时，更多的权重数据和中间张量可以保留在缓存中，减少了去显存里“翻找”的次数。这对于提升 Token 生成速度（Tokens per Second） 的意义，远比增加核心数大得多。

- A770的16GB规格内存带宽是 ``560 GB/s`` 比8GB规格的内存带宽 ``512GB/s`` 要高(有什么验证的方法吗?)

.. note::

   虽然第二代B580显著提升了推理速度，但是由于最高12GB显存比上一代A770少了4GB，所以适应的模型会比较受限，所以作为个人实验环境，我依然选择上一代 A770:

   - 14B 模型在 INT4 量化下，权重占用约为 9.5 GB, ``A770`` 的剩余6.5GB显存能支持高达 3.2 w token(远超B580可能只支持4k~8k token)




参考
=====

- `Intel® Arc™ A770 Graphics 16GB Specifications <https://www.intel.com/content/www/us/en/products/sku/229151/intel-arc-a770-graphics-16gb/specifications.html>`_

