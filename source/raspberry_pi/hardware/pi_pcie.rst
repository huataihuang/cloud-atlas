.. _pi_pcie:

==================
树莓派PCIe设备
==================

:ref:`pi_4` **计算模块** 主板集成PCIe
=======================================

Raspberry Pi Compute Module 4 IO 主板提供了一个 :ref:`pcie` 1x ，可以用于 存储 / 网络 / GPU 等设备。(虽然性能有限，但聊胜于无)

`YouTube播客Jeff Geerling <https://www.youtube.com/channel/UCR-DXc1voovS8nhAvccRZhg>`_ 专注于 :ref:`ansible` 自动化和 :ref:`raspberry_pi` 硬件设备评测，他建立了一个网站测试和整理了适用于树莓派的 `Raspberry Pi PCIe Devices <https://pipci.jeffgeerling.com>`_ 。

.. _pi_5_pcie:

:ref:`pi_5` 集成PCIe 2.0 x1接口
================================

:ref:`pi_5` 则进一步在标准版本上集成了一个 :ref:`pcie` 2.0 x1 连接器，终于第一次为高速存储提供了接口(但是仍有不小限制):

- 单通道 PCIe 2.0 接口（500 MB/s 峰值传输速率）

  - 默认 PCIe 2.0 支持 :ref:`nvme` Gen2 模式，接口理论传输速度 ``5Gbps`` (读写速度大约500MB/s)
  - :ref:`pi_5` 也可以启用 PCIe Gen 3速度，但是 :ref:`pi_5` **没有通过 Gen 3.0 速度(10Gbps)认证** ，激活PCIe Gen 3之后，只能达到 ``8Gbps`` 传输速率(读写速度大约800MB/s)

.. figure:: ../../_static/raspberry_pi/hardware/m2-hat-plus-installation-07.png

   树莓派5官方M.2 HAT+(NVMe接口板)

我的实践是采用了国产的 ``微雪电子 树莓派5 PCIe转M.2转接板 D型`` ，具体实践记录见 :ref:`pi_5_pcie_m.2_ssd`

参考
=========

- `Raspberry Pi PCIe Devices <https://pipci.jeffgeerling.com>`_
- `Raspberry Pi Connector for PCIe: A 16-way PCIe FFC Connector Specification <https://datasheets.raspberrypi.com/pcie/pcie-connector-standard.pdf?_gl=1*1dvyrki*_ga*MTc0NDU4OTUxNC4xNzI2MDU0MjI5*_ga_22FD70LWDS*MTcyNjEwNTEwMi4xLjEuMTcyNjEwNTIwOC4wLjAuMA..>`_
- `M.2 HAT+(NVMe接口板 / 新品) <https://pidoc.cn/docs/accessories/m2-hat-plus>`_
