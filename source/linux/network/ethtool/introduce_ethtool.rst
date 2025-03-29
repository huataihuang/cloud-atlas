.. _introduce_ethtool:

=========================
ethtool简介
=========================

ethtool是控制网络驱动和硬件，特别是有线以太网设备的标准Linux工具。这个工具在很多网络故障排查、性能调优上有很大作用。

ethtool的主要用途：

- 获取设备的标示和诊断信息
- 获取扩展设备状态
- 控制以太网设备的速度、双工、自动协商和流控
- 控制校验卸载(checksum offload)和其他硬件卸载(hardware offload)功能
- 控制DMA ring( :ref:`ring_buffer_dma_mmio` )规格以及中断

参考
=====

- `kernel.org ethtool <https://mirrors.edge.kernel.org/pub/software/network/ethtool/>`_
