.. _mbp15_late_2013:

============================
MacBook Pro 15" Late 2013
============================

我的虚拟化测试实践主要在我很久以前购买的的MacBook Pro 15" Late 2013上完成的，这台笔记本陪伴了我7、8年，经历过各种macOS和Linux版本的折腾。

大约使用5年多时候，笔记本电池鼓包，在Apple Store更换了电池组件(这款笔记本电池和键盘、触摸板是一体的，整体替换花费1500元)。

规格
======

- Apple型号: A1398 (Model ID: MacBookPro11,3)

- 预装操作系统: MacOS X 10.9 ，目前支持最新操作系统版本(2021年为 macOS Big Sur 11.2.3)

- 整机重量: 2.02 kg

- 处理器

  - 22nm Haswell/Crystalwell 2.3GHz :ref:`intel_core_i7_4850hq`
  - 4个处理器核心支持超线程(Hyper Threading)，相当于8个虚拟核心
  - 每个处理器核心有一个独立32k L1缓存(32k x4)
  - 每个处理器核心有一个独立的256k L2缓存(256k x4)
  - 6MB共享L3缓存
  - 支持Turbo Boost 2.0(最高3.5GHz)

- 内存

  - 16GB 1600MHz DDR3L SDRAM

- 存储

  - 存储接口: PCIe 2.0x2
  - 512GB PCIe SSD

.. note::

   PCIe 2.0接口单通道500MB/s，所以对于PCIe 2.0x2可以达到 1GB/s 传输速率。理论上16-lane PCIe接口(x16)可以合并传输最高8GB/s。

   由于MacBook Pro 15" late 2013的存储接口最大传输速率1GB/s，所以在选购存储设备时可以按接口规格挑选，没有必要使用最高速NVMe，以免浪费性能(资金)

- 显卡

  - 独立显卡: NVIDIA GeForce GT 750M, 2GB显存(GDDR5)
  - 集成显卡: Intel Iris 5200 Pro, 128MB Crystalwell

- 屏幕

  - 2880x1800(220 ppi) Retina显示屏(LED背光)

- 接口

  - 802.11ac Wi-Fi
  - Bluetouch 4.0
  - 2个USB 3.0接口
  - 2个雷电2接口
  - 1个HDMI接口
  - 一个3.5耳机接口
  - 一个SDXC读卡接口

参考
======

- `Apple MacBook Pro 15-Inch "Core i7" 2.3 Late 2013 (DG) Specs <https://everymac.com/systems/apple/macbook_pro/specs/macbook-pro-core-i7-2.3-15-dual-graphics-late-2013-retina-display-specs.html>`_
