.. _intro_mxgpu:

==========================
AMD MxGPU技术简介
==========================

虚拟化隔离PCIe资源规范 SR-IOV(Single-root input/output virtualization, 单根输入/输出虚拟化)是一种个允许在不同用户之间隔离PCIe资源的规范:

- SR-IOV 是用于共享网络资源(NIC)和安全网络流量的标准
- SR-IOV 也是GPU共享技术的业界标准

.. note::

   `AMD unveils hardware-virtualised GPU product line <https://develop3d.com/develop3d-blog/amd-hardware-virtualized-gpu-firepro-s7150-cad-creo-solidworks-mxgpu-vdi-nx/>`_ 2016年2月5日，在发布了 :ref:`amd_firepro_s7150x2` 之后，AMD宣布 AMD FirePro S7150 和 :ref:`amd_firepro_s7150x2` 成为业界首个实现基于 :ref:`sr-iov` GPU共享技术的产品。

根据AMD官方发布，选择SR-IOV作为MxGPU技术基础(MxGPU实际上就是AMD的SR-IOV的商业宣传名称)原因如下:

- SR-IOV 是虚拟化 PCIe 设备的长期行业标准，标准受到公开的安全性审查
- VF 提供的隔离有助于确保每个 VM 与其他 VM 隔离，例如内存是安全的，而不是共享的
- SR-IOV 是一项基础技术: 实现可扩展性和更高的用户密度，最大限度地减少上下文切换开销
- SR-IOV 可以提供VM资源隔离，提高稳定性和可靠性

AMD MxGPU( :ref:`sr-iov` )支持多种操作系统以及虚拟化技术:

- Xen

  - `The Xen Project(YouTube): Implementing AMD MxGPU <https://www.youtube.com/watch?v=4xp_nMc7EOc>`_ 在2019年的一个视频分享，介绍了如何部署实践，可参考

- VMware ESXi
- :ref:`kvm`

想法
======

- 通过 MxGPU 来分配 :ref:`amd_firepro_s7150x2` 的一个GPU作为2个VF(vGPU)分别提供给2个虚拟机(我期望一个是 :ref:`macos` 一个是 :ref:`windows` ) ，另一个GPU则用于推理(不过性能可能很差)

  - 虚拟化运行 :ref:`macos`
  - 虚拟化运行 :ref:`windows` 玩 :ref:`flight_simulator` (思路整理在 :ref:`intro_flight_simulator` )

参考
========

- `AMD官方博客: What is SR-IOV? Why it’s the gold-standard for GPU sharing. <https://community.amd.com/t5/visual-cloud/what-is-sr-iov-why-it-s-the-gold-standard-for-gpu-sharing/ba-p/418727>`_
