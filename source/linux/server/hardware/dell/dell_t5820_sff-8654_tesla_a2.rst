.. _dell_t5820_sff-8654_tesla_a2:

=====================================
Dell T5820板载SFF-8654连接Tesla A2
=====================================

Dell T5820提供了一种U.2接口支持的硬盘背板方式，将FlexBay 1的2个硬盘位置转成U.2接口，而这个U.2硬盘的数据连线是直接插在主板CPU旁边的2个 ``SFF-8654`` 接口上:

.. figure:: ../../../../_static/linux/server/hardware/dell/sff-8654.jpg

   Dell T5820主板SFF-8654接口，提供了PCIe信号

由于我想尽可能支持更多GPU设备，所以我准备将这两个 ``SFF-8654`` 接口连接PCIe插槽来提供 :ref:`tesla_a2` 连接。而主板的PCIe 3.0X16准备通过 :ref:`pcie_bifurcation` 转换成 ``x4x4x4x4`` 来同时安装4块NVMe设备。这样以获得更多的SSD存储以及能够同时支持更多GPU设备。
