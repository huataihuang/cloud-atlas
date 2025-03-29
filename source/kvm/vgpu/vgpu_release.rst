.. _vgpu_release:

===================
vGPU软件包版本
===================

`NVIDIA Virtual GPU (vGPU) Software Documentation <https://docs.nvidia.com/grid/>`_ 首页提供了NVIDIA发布的release系列说明:

Linux vGPU Manager需要针对Linux的hypervisor，支持hypervisor有:

- Citrix Hypervisor
- Linux with KVM
- Red Hat Enterprise Linux with KVM
- Ubuntu
- VMware vSphere

当前(2023年6月)已经发布的版本系列有:

- `NVIDIA vGPU Software 15 (doc) <https://docs.nvidia.com/grid/15.0/index.html>`_ (EOL 2023年12月): Linux vGPU Manager / Driver 版本 525 , Windows vGPU Manager / Driver 527-528
- `NVIDIA vGPU Software 14 (doc) <https://docs.nvidia.com/grid/14.0/index.html>`_ (EOL 2023年2月): Linux vGPU Manager / Driver 版本 510 , Windows vGPU Manager / Driver 511-514
- `NVIDIA vGPU Software 13 (doc) <https://docs.nvidia.com/grid/13.0/index.html>`_ （Release 13是LTS长期支持版，生命周期到2024年8月，目前是企业最常用版本）: Linux vGPU Manager / Driver 版本 470 , Windows vGPU Manager / Driver 471-474
- 其他旧版本已经EOL(这里不再列举)

支持设备及Hypervisor
=======================

.. note::

   以官方文档为准，我仅摘录一些和我所使用设备相关信息

- ``NVIDIA vGPU Software 15`` : 官方在 `vGPU Release 15 support matrix <https://docs.nvidia.com/grid/15.0/product-support-matrix/index.html>`_ 提供了详细的软硬件支持列表，非常详尽清晰

  - 针对 ``Linux with KVM Support`` 有不同Linux发行版Hypervisor的支持清单，官方列出了 Red Hat OpenStack Platform 和 SUSE Linux Enterprise Server，不过根据 ``vGPU Release 14`` 资料，Ubuntu应该也是支持的

- ``NVIDIA vGPU Software 14`` :

  - 支持RHEL 9和8系列KVM hypervisor
  - 支持Ubuntu 22.04 LTS hypervisor
  - 支持Ctrix Virtual Apps and Desktops version 7 2203
  - 支持VMware Horizon 2203 (8.5)/2206 (8.6)
  - **不再支持** Windows Server 2016 作为Guest(建议不再使用)

参考
======

- `NVIDIA Virtual GPU (vGPU) Software Documentation <https://docs.nvidia.com/grid/>`_
