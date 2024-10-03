.. _pi_5_pcie_3_m.2_ssd:

===============================================
树莓派5 PCIe转M.2 NVMe PCIe gen ``3`` SSD存储
===============================================

.. warning::

   经过 :ref:`pi_5_pcie_4_m.2_ssd` 验证，证明 :ref:`pi_5` 只能使用 ``PCIe gen 3`` SSD存储，无法驱动 **gen4** SSD存储


实践采用的硬件是 :ref:`kioxia_exceria_g2` 配合 :ref:`pi_5_pcie_m.2_ssd` 转接卡

激活 ``pcie 3`` 模式
=======================

:ref:`pi_5` 默认没有激活 ``pcie 3`` ，对于 ``PCIe gen 3`` :ref:`kioxia_exceria_g2` ，虽然 :ref:`pi_5` 不能达到标准的 ``PCIe gen 3`` 速率，但是激活 ``PCIe gen 3`` 还是能够大大提高接口性能:

- 修改 ``/boot/firmware/config.txt`` 设置:

.. literalinclude:: pi_5_pcie_3_m.2_ssd/pcie_3_config.txt
   :caption: 配置激活 ``PCIe gen 3``

- 重启系统，通过 ``dmesg -T`` 检查系统启动信息如下:

.. literalinclude:: pi_5_pcie_4_m.2_ssd/dmesg
   :caption: 配置激活 ``PCIe gen 3`` 后重启检查 ``dmesg -T`` 输出

- 检查pci设备 ``lspci`` :

.. literalinclude:: pi_5_pcie_4_m.2_ssd/lspci
   :caption: 检查PCI设备

输出信息显示已经识别了 :ref:`kioxia_exceria_g2` :

.. literalinclude:: pi_5_pcie_4_m.2_ssd/lspci_output
   :caption: 检查PCI设备可以看到识别了 :ref:`kioxia_exceria_g2`
   :emphasize-lines: 2

- 检查块设备:

.. literalinclude:: pi_5_pcie_4_m.2_ssd/lsblk
   :caption: 检查块设备设备

可以看到识别了 ``nvme``

.. literalinclude:: pi_5_pcie_4_m.2_ssd/lsblk_output
   :caption: 检查块设备设备
   :emphasize-lines: 5

使用存储
===========

接下来是软件配置如何使用这个存储发挥其性能:

- :ref:`pi_5_nvme_boot`
- :ref:`boot_on_zfs_for_raspberry_pi`

参考
=======

- `How to boot Raspberry Pi 5 from NVMe M.2 SSD <https://notenoughtech.com/raspberry-pi/boot-raspberry-pi-5-from-nvme/>`_
- `NVMe SSD boot with the Raspberry Pi 5 <https://www.jeffgeerling.com/blog/2023/nvme-ssd-boot-raspberry-pi-5>`_
