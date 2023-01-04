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

更新: 对于任何内核版本高于 5.10 都需要使用补丁。但是需要注意内核5.13不能工作，建议不要使用5.13。对于内核版本较高的系统，可以自己使用 `DualCoder/vgpu_unlock <https://github.com/DualCoder/vgpu_unlock>`_ 提供的 ``Kernel module hooks: vgpu_unlock_hooks.c`` 做补丁，这样就能够解锁。(应该不需要降级内核版本，我准备尝试一下，毕竟降低内核版本实际上是非常大的损失)

`Rust-based vgpu_unlock <https://github.com/mbilker/vgpu_unlock-rs>`_ 提供了一个 :ref:`rust` 开发的 vgpu_unlock ，可以和使用 python 开发的解锁互相参看(都是user space工具，核心没有区别)

- Guest虚拟机:

  - Enterprise Linux distributions (RHEL, CentOS, Fedora)
  - Debian/Ubuntu (20.04 LTS)
  - Windows 10, 8.1, Server 2019 and 2016

.. note::

   不建议在不受支持/未经认证的硬件上使用 vGPU，但是 ``vgpu_unlock`` 脚本依然可能会让某些N卡能够运行 ``vGPU`` 技术，不过采用开源技术需要自担风险。该 ``vgpu_unlock`` 项目是MIT授权，不提供任何保证。

.. note::

   总之，尽可能使用NVIDIA官方提供的最新版本 vGPU 驱动，实在不行再使用 `Virtual Machine with vGPU Unlock for single GPU desktop <https://github.com/tuh8888/libvirt_win10_vm>`_ 提供的2021年4月版本驱动 ( :ref:`vgpu_startup` )

安装
========

- NVIDIA GRID vGPU驱动需要以 :ref:`dkms` 模块方式安装::

   ./nvidia-installer --dkms

参考
======

- `DualCoder/vgpu_unlock <https://github.com/DualCoder/vgpu_unlock>`_ 
- `vGPU_Unlock Wiki <https://docs.google.com/document/d/1pzrWJ9h-zANCtyqRgS7Vzla0Y8Ea2-5z2HEi4X75d2Q>`_ 详细的 ``vgpu_unlock`` 使用文档
