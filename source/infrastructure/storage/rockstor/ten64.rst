.. _ten64:

================================
Ten64 网络+存储+网管 边缘云设备
================================

Ten64是一款非常全面的边缘云设备:

- 高速网络支持(8个千兆以太网口+2个万兆SFP+光口)
- Eight-Core ARM Cortex-A53@1.6GHz
- 最高32G DDR4 SODIMM 内存(支持 ECC) 
- 支持5G PCIe 3.0 蜂窝网络Modem
- 支持双SIM卡LTE/5G卡
- 支持双频WiFi 5和6

价格虽然昂贵(参考 `CROW Supply Traverse Ten64 <https://www.crowdsupply.com/traverse-technologies/ten64>`_ 整体组合售价可能在1k美金)，但是设计架构值得借鉴。

`Traverse Ten64 Platform Documentation <https://ten64doc.traverse.com.au/>`_ 对硬件和软件堆栈的详细说明，可以看到操作系统基于 :ref:`openwrt` ，并且运行 :ref:`muvirt` 系统来实现一个微型虚拟化。很赞的设计架构，值得学习借鉴。

参考
=====

- `Hardware: Ten64 <https://traverse.com.au/products/ten64-networking-platform/>`_
