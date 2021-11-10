.. _vgpu_unlock:

==================
vgpu_unlock
==================

NVIDIA不允许在消费级GPU上使用vGPU功能，但是实际上硬件是完全支持的。所以开源软件 `DualCoder/vgpu_unlock <https://github.com/DualCoder/vgpu_unlock>`_ 通过软件方式解锁了消费级NVidia vGPU功能。

vgpu_unlock支持的硬件和软件
============================

支持类型
--------------------

.. csv-table:: vgpu_unlock支持类型
   :file: vgpu_unlock/vgpu_unlock_types.csv
   :widths: 15, 15, 20, 10, 20, 20
   :header-rows: 1

支持硬件
------------

- CPU和主板:

运行 vGPU/vgpu_unlock 需要硬件支持虚拟化扩展。也就是Intel平台的VT-X或者AMD平台的AMD-V。这样才能获得较好的VM性能。请注意需要在主机BIOS激活虚拟化支持。

在一些系统上要使用vGPU需要激活 :ref:`iommu` ，例如 Ampere GPU。

- 图形卡:

.. csv-table:: vgpu_unlock支持图形卡
   :file: vgpu_unlock/vgpu_unlock_graphics_cards.csv
   :widths: 30, 30, 40
   :header-rows: 1

我在 :ref:`hpe_dl360_gen9` 上使用 :ref:`tesla_p10` 属于 ``gp102`` 图形芯片，等同于 ``Tesla P40``

支持操作系统
---------------

- 物理主机:

  - Red Hat Enterprise Linux (certified by Nvidia for vGPU, tested kernel 4.18)
  - Proxmox VE (Tested kernel 5.4)
  - There may be more that we don’t explicitly list here.

对于 5.10-5.12 的内核，需要使用 `rupansh/vgpu_unlock_5.12 <https://github.com/rupansh/vgpu_unlock_5.12>`_ 补丁

- Guest虚拟机:

  - Enterprise Linux distributions (RHEL, CentOS, Fedora)
  - Debian/Ubuntu (20.04 LTS)
  - Windows 10, 8.1, Server 2019 and 2016
 

参考
======

- `DualCoder/vgpu_unlock <https://github.com/DualCoder/vgpu_unlock>`_ 
- `vGPU_Unlock Wiki <https://docs.google.com/document/d/1pzrWJ9h-zANCtyqRgS7Vzla0Y8Ea2-5z2HEi4X75d2Q>`_ 详细的 ``vgpu_unlock`` 使用文档
