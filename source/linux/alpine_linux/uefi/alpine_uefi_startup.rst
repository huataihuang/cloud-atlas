.. _alpine_uefi_startup:

=========================
Alpine Linux UEFI起步
=========================

UEFI和BIOS
===========

我在探索 :ref:`pi_uefi` 发现，对于现代服务器体系，使用UEFI+ACPI是非常基础的规范要求，甚至可以说是实现标准服务器不可或缺。我在树莓派上最初构建 :ref:`pi_stack` 集群，部署 :ref:`edge_cloud` 是基于Alpine Linux实现，也遇到如何将树莓派转换成使用UEFI+ACPI的挑战。

.. note::

   以往遇到UEFI系统，例如我在安装 :ref:`hpe_dl360_gen9` 上 :ref:`ubuntu_linux` ，就遇到过为了实现 :ref:`iommu` :ref:`ovmf` ，将物理服务器从BIOS模式转换成UEFI模式。这个过程对于操作系统来说是一个不同的磁盘分区和启动模式，我当时被迫做了操作系统重装。

   实际上，对于现有操作系统重装和恢复已有部署是非常耗费精力的，更为理想的方法是进行转换，这也是我下一步要完成的技术挑战，以加深对UEFI技术的掌握



参考
======

- `alpine linux wiki: Alpine and UEFI <https://wiki.alpinelinux.org/wiki/Alpine_and_UEFI>`_
