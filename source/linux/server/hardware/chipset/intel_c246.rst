.. _intel_c246:

======================
Intel C246主板芯片组
======================

:ref:`xeon_e` (Coffee Lake-E 处理器)需要C242或C246主板芯片支持。

我在为 :ref:`pi_cluster` 选购ITX机箱时，为了不浪费昂贵的PC金牌电源，选购了一款 :ref:`nasse_c246` :

- 支持 ECC 校验内存(因为是针对 :ref:`xeon_e` 的入门级服务器主板)，这样可以充分利旧我在 :ref:`hpe_dl360_gen9` 替换下的ECC DDR-4内存(可以节约大约500元RMB)
- 支持第八代和第九代Intel Core处理器以及 :ref:`xeon_e` 系列处理器(Coffee Lake)

C246芯片组是2018年Q3推出的入门级服务器主板芯片:

- TDP功耗: 6W
- 每个通道支持DIMM数量: 2
- 支持ECC内存
- 不支持内存超频
- 支持3个显示器
- PCIe 3.0
- 最大支持PCIe Lanes: 24
- 最大支持10个USB 3.1接口

  - 最多6个是USB3.1 Gen2 (10Gb/s)
  - 最多10个USB3.1 Gen1 (5Gb/s)

- 最多8个 SATA 6.0 Gb/s 接口
- 集成有线和无线网络
- 支持PCIe端口配置( :ref:`pcie_bifurcation` ): 1x16 or 2x8 or 1x8+2x4
- 支持 :ref:`intel_rst`

参考
======

- `Intel® C246 Chipset <https://www.intel.com/content/www/us/en/products/sku/147326/intel-c246-chipset/specifications.html>`_
