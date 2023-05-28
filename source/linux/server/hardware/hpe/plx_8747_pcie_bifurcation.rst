.. _plx_8747_pcie_bifurcation:

==============================
PLX 8747硬件PCIe bifurcation
==============================

在 :ref:`pcie_bifurcation` 探索时，我曾经想采用硬件来实现PCIe bifucation，市场上主流的硬件PCIe bifurcation是PLX公司芯片，例如 ``PEX 8747``

检查验证
=============

- 先安装一个NVMe存储，启动服务器

- 启动服务器后，检查设备识别，使用 ``lspci`` 命令:

.. literalinclude:: plx_8747_pcie_bifurcation/lspci
   :language: bash
   :caption: 使用 ``lspci`` 检查输出

输出显示:

.. literalinclude:: plx_8747_pcie_bifurcation/lspci_output
   :language: bash
   :caption: 使用 ``lspci`` 检查输出

既然没有识别正常，那么我们再安装一块nvme看看 ``PCIe bifurcation`` 效果

- 再次重启服务器，使用相同的 ``lspci`` 命令检查，可以看到输出识别出了2个nvme设备:

.. literalinclude:: plx_8747_pcie_bifurcation/lspci_output_2
   :language: bash
   :caption: 使用 ``lspci`` 检查输出
   :emphasize-lines: 6,7

- 检查 ``fdisk -l`` 磁盘输出:

.. literalinclude:: plx_8747_pcie_bifurcation/fdisk_output
   :language: bash
   :caption: 使用 ``fdisk -l`` 检查输出
   :emphasize-lines: 1,2,14,15

验证成功，能够正确识别多NVMe设备

读写验证
===========

.. note::

   由于我的NVMe磁盘已经输出给 :ref:`ceph` 虚拟机，难以直接测试读写，暂时忽略
