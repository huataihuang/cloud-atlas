.. _dell_t5820:

=============================
Dell Precision T5820 工作站
=============================

2026年3月底剁手了二手的 Dell Precision T5820工作站，950W电源的准系统(有2个U.2位的背板)只需要1100元，是目前感觉能够承担的较为经济实惠的主机:

- 静音台式工作站，应该能够解决我使用机架式 :ref:`hpe_dl380_gen9` 烦人的噪音困扰
- 能够充分利旧我之前在 :ref:`hpe_dl380_gen9` 投资的大量ECC DDR4内存(这是最主要原因，2026年内存价格暴涨到原先的3-5倍)

  - 提供了 **8根** DIMM内存槽，这是我横向对比了同价位主机的选择，再低端的HP Z440,同级别的Z640(单路)都只有4个DIMM
  - 再高端的DELL T7820/T7920 或者 :ref:`hp_z8_g4` 虽然内存扩展更好(24根)但是准系统价格需要乘以3-4倍，性价比不如T5820

- 提供了5根PCIe插槽，虽然对于我同时安装 2个 :ref:`amd_mi50` 和 2个 :ref:`tesla_a2` 依然非常拥挤(甚至难以布局)，但是还是算这个价位单处理器工作站中比较好的PCIe扩展性

技术规格
==========

- 支持 至强 W-21xx 和 W-22xx 处理器

  - 提供了 :ref:`vnni` 指令集(AVX512升级)，为使用 :ref:`openvino` 部署CPU推理加速提供了硬件支持

U.2背板和NVMe
===============

Dell T5820前面板有4个硬盘槽位，分为2个版本:

- 全SATA版本: 4个槽位可以安装4个 3.5寸SATA 硬盘(通过转接支架也可以安装2.5寸SATA硬盘)
- 2个U.2+2个SATA: 升级版本，其中2个槽位的背板换成了U.2接口。这个版本的U.2接口不仅能够安装企业级U.2接口SSD硬盘，而且通过专用的 ``NVMe Flexbay`` 能够转接NVMe SSD，这样就能够充分利旧家用型NVMe设备，如 :ref:`kioxia_exceria_g2`

.. figure:: ../../../../_static/linux/server/hardware/dell/m2_u2_box.avif

   通过NVMe Flexbay可以将U.2转接NVMe SSD设备

.. note::

   如果要使用企业级的U.2 SSD硬盘，建议购买 ``2个U.2+2个SATA`` 版本T5820，实际上是通过更换 FlexBay 1 的背板，来直接支持在主机前面方便更换 :ref:`nvme` 

   `升级 Dell Precision 5820、7820 和 7920 塔式工作站中的存储 <https://www.dell.com/support/kbdoc/zh-cn/000146243/%E5%8D%87%E7%BA%A7-dell-precision-5820-7820-%E5%92%8C-7920-%E5%A1%94%E5%BC%8F%E5%B7%A5%E4%BD%9C%E7%AB%99%E4%B8%AD%E7%9A%84%E5%AD%98%E5%82%A8>`_ 视频介绍了如何安装NVMe设备，前提条件是选购 **U.2** 背板的T5820

   不过，实际上U.2或NVMe的支持是通过主板集成的 PCIe0 和 PCIe1 端口提供连接，该接口也可以直接用于连接GPU设备，这样实际上可以多安装2块 :ref:`tesla_a2` : :ref:`dell_t5820_ssf-8654_tesla_a2`


参考
======

- `戴尔 Precision 5820 Tower 用户手册 <https://dl.dell.com/content/manual34500682-%E6%88%B4%E5%B0%94-precision-5820-tower-%E7%94%A8%E6%88%B7%E6%89%8B%E5%86%8C.pdf?language=zh-cn>`_
- `升级 Dell Precision 5820、7820 和 7920 塔式工作站中的存储 <https://www.dell.com/support/kbdoc/zh-cn/000146243/%E5%8D%87%E7%BA%A7-dell-precision-5820-7820-%E5%92%8C-7920-%E5%A1%94%E5%BC%8F%E5%B7%A5%E4%BD%9C%E7%AB%99%E4%B8%AD%E7%9A%84%E5%AD%98%E5%82%A8>`_
