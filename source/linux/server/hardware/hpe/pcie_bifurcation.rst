.. _pcie_bifurcation:

=========================
PCIe bifurcation选项
=========================

:ref:`hpe_dl360_gen9` 支持PCIe直接使用NVMe存储，这样可以在服务器上实现高性能存储集群。(原厂的 U.2 接口NVMe SSD存储升级套件实在成本太高)

在淘宝上可以购买到 PCIe X16 四盘NVMe扩展卡:

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_nvme_extendcard.png

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_nvme_extendcard-1.png
   :scale: 60

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_nvme_extendcard-2.png
   :scale: 50

PCIe bifurcation
====================

需要注意，扩展卡是 PCIe x16 规格的，为了能够支持4个NVMe m.2 存储，需要将这个 X16 分成4个 X4 才能支持4个NVMe盘。需要主板支持一种称为 ``PCIe bifurcation`` 技术，这样在主板BIOS中可以将 PCIe X16 改成 ``x4x4x4x4`` 

.. figure:: ../../../../_static/linux/server/hardware/hpe/pcie_bifurcation-1.png
   :scale: 50

参考HP官方文档，DL360 gen10 是支持 PCIe Bifurcation 的:

``System Configuration > BIOS/Platform Configuration (RBSU) > PCIe Device Configuration > PCIe Bifurcation Options``

对于 :ref:`hpe_dl360_gen9` 我尝试完成 :ref:`dl360_bios_upgrade` 再做BIOS配置验证

.. note::

   目前尚未实践，等完成 :ref:`dl360_bios_upgrade` 之后看能否实现分成4个X4，如果只支持对半分，则购买2块双盘NVMe扩展卡，安装到 PCIe 3.0 Slot 1 和 Slot 2上，也能实现相同效果 - 因为HP DL360的Slot 1和Slot 2都连接在CPU 1上，和在一个Slot 1上切分4个X4一样。
