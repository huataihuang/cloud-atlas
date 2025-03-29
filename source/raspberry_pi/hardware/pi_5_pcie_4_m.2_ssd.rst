.. _pi_5_pcie_4_m.2_ssd:

=======================================================
树莓派5 PCIe转M.2 NVMe "PCIe gen4" SSD存储报错记录
=======================================================

我原本计划 :ref:`pi_5_pcie_m.2_ssd` 采用 :ref:`kioxia_exceria_g2` ，但是淘宝商家发错成 ``kioxia EXCERIA Plus`` 版本，也就是 ``PCIe gen4`` 规格的NVMe。从官方文档来看，树莓派似乎只能工作于PCIe gen2 和 gen3，其中gen 3模式需要特定激活。

和商家协商后准备寄还错发的 `kioxia EXCERIA Plus`` **PCIe gen4** ，换成正确的 :ref:`kioxia_exceria_g2` 。不过，此时我已经拿到 ``微雪电子 树莓派5 PCIe转M.2转接板 D型`` ，就在想是否可以用我曾经购买过 ``PCIe gen 4`` 的 :ref:`samsung_pm9a1` 试试。毕竟 ``PCIe gen 4`` 号称是兼容 ``PCIe gen 3`` ，如果测试成功，也可以避免重复投资购买 :ref:`nvme` 存储。

.. warning::

   现在回看当时尝试其实存在没有注意到的疏忽，所以我在 :ref:`update_samsung_pm9a1_firmware` 实践中修复了使用 :ref:`samsung_pm9a1` ，本文仅记录当时的尝试。

   实际上，2021年购买的 :ref:`samsung_pm9a1` 的firmware存在缺陷，无法用于USB移动硬盘，也无法用于 :ref:`pi_5` 的PCIe转接 M.2 NVMe。通过升级到新版本firmware可以解决本文遇到的识别问题。

默认 ``pcie 2`` 模式
=======================

默认没有激活 ``pcie 3`` ，所以 :ref:`pi_5` 启动的是 ``pcie 2`` 模式。我通过 :ref:`pi_5_uart` 观察看到如下日志，显示 NVMe 存储识别，但是无法工作:

.. literalinclude:: pi_5_pcie_4_m.2_ssd/pcie_2_err
   :caption: 默认 ``pcie 2`` 模式下，识别到 ``gen 4`` 的NVMe设备但无法工作
   :emphasize-lines: 31-33

激活 ``pcie 3`` 模式
=======================

- 修改 ``/boot/firmware/config.txt`` 设置:

.. literalinclude:: pi_5_pcie_3_m.2_ssd/pcie_3_config.txt
   :caption: 配置激活 ``PCIe gen 3``

可以看到确实激活了 ``pcie 3`` 模式，但是很不幸，无法正常使用 ``PCIe gen 4`` 的 :ref:`samsung_pm9a1`

.. literalinclude:: pi_5_pcie_4_m.2_ssd/pcie_3_err
   :caption: 强制激活 ``pcie 3`` 模式下，但是依然无法使用 ``gen 4`` 的NVMe设备 :ref:`samsung_pm9a1`
   :emphasize-lines: 6,17,30-32

实验失败，准备继续等待换回 :ref:`kioxia_exceria_g2` ( ``PCIe gen 3`` SSD存储)再测试
