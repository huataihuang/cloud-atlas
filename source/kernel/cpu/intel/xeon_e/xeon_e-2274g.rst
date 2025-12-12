.. _xeon_e-2274g:

===================
Intel Xeon E-2274G
===================

Intel Xeon E-2274G是我在淘宝上找到的最便宜的内置GPU的 :ref:`xeon_e` 二代(我不知道为何只有这款特别便宜):

- 2019年Q2发布
- Cofee Lake 微处理器架构(Intel第八代微处理器架构)
- ``14nm`` 光刻工艺
- 4核心8线程(至强处理器相当于同时代的i7)
- 基本频率 4.00 GHz / 最大睿频 4.90 GHz
- 8 MB缓存
- 8 GT/s 总线速度
- TDP功耗 ``83W``
- 最高支持128G内存(但是需要BIOS更新，不是所有主板都支持)
- 内存最高支持 DDR4-2666 (不过我原先购买的 :ref:`hpe_dl360_gen9` 配套的是 DDR4-2400)
- 内置GPU: :ref:`intel_uhd_graphics_630`

  - 显卡基本频率 350 MHz
  - 显卡最大动态频率 1.20 GHz
  - 显卡最大显存 128GB (和CPU共享内存)
  - 支持 4k@60Hz (DP输出口) / 4k@24Hz (HDMI输出口)

- PCIe 3.0

  - 1x16, 2x8, 1x8+2x4

- 处理器插槽 ``FCLGA1151``
- 虚拟化支持:

  - :ref:`intel_vt`
  - :ref:`intel_ept` 可支持大内存虚拟化加速

参考
=======

- `英特尔® 至强® E-2274G 处理器 <https://www.intel.cn/content/www/cn/zh/products/sku/191042/intel-xeon-e2274g-processor-8m-cache-4-00-ghz/specifications.html>`_
