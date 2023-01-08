.. _intro_intel_gvt:

=====================
Intel GVT技术简介
=====================

Intel图形虚拟化技术分为:

- Intel VGT-d : 直接GPU 1:1 访问 (类似 :ref:`iommu` )
- Intel VGT-s : 用于API级别 1:多 共享
- Intel VGT-g : 共享虚拟GPU技术 (类似 :ref:`vgpu` )

Intel GVT-g
=============

Intel GVT-g技术是在Intel GPU (Broadwell以及更新)上提供的 ``mediated device passthrough`` 技术，也就是将GPU虚拟化切分提供给多个虚拟机使用，可以高效地以接近原生图形性能来使用GPU。这项技术在Windows虚拟机中可以加速图形显示而不需要使用完全的设备passthrough。类似的技术在NVIDIA :ref:`vgpu` 和AMD的 MxGPU 都有对应，不过这些GPU专业厂商限制只能在高端专业GPU系列上才允许使用GPU虚拟化。对于Intel这样的GPU后来者，产品性能不足所以只能在技术上另辟蹊径，提供更为丰富的功能来弥补短板，故而在虚拟化技术多样性上，Intel采用了更为先进和开放的技术标准。

.. note::

   我的 :ref:`hpe_dl360_gen9` 没有集成Intel GPU，所以无法实践这项技术。不过，我有 ``MacBook Pro 2013 later`` 笔记本集成了Intel显卡，后续我会尝试这项虚拟化技术。

参考
=====

- `arch linux: Intel GVT-g <https://wiki.archlinux.org/title/Intel_GVT-g>`_
- `INTEL® GRAPHICS VIRTUALIZATION UPDATE <https://01.org/blogs/2014/intel%C2%AE-graphics-virtualization-update>`_
