.. _intro_huge_memory_pages:

==================================
内存大页(huge memory pages)简介
==================================

在 :ref:`kvm` 虚拟化技术中，提高虚拟机性能的有效手段之一就是采用内存大页，但是这项技术的使用有很多特定适用场景，使用不当可能产生 ``负优化`` ，所以需要仔细研究规划并实践验证。

透明大页(transparent huge pages)
=====================================

静态大页(static huge pages)
=============================

动态大页(dynamic huge pages)
==============================

参考
========

- `PCI passthrough via OVMF: Huge memory pages <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages>`_
