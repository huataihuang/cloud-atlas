.. _intro_tart:

=================================
Tart Virtualization Toolset简介
=================================

.. note::

   `OrbStack <https://orbstack.dev/>`_ 是类似的商业化Apple Virtualization桌面应用。个人使用免费，商业使用订阅费每月8美金。不过，我觉得参考Tart开源软件进行学习实践更有价值，并且有 :ref:`orchard` 可以规模化部署Apple Silicon虚拟化集群。

对Intel架构Host的支持?
========================

虽然macOS目前依然支持在Intel架构的硬件上运行，例如我现在使用的 ``Sequoia 15.2`` ，但是底层的 ``Virtualization.Framework`` 从上一代 macOS Ventura已经不怎么更新了，预计将来将完全去除Intel支持。

参考
=======

- `Hacker News >> Tart: VMs on macOS using Apple's native Virtualization.Framework <https://news.ycombinator.com/item?id=39059100>`_
- `Apple macOS Intel host -> macOS Intel guest VM support / repo naming #140 <https://github.com/cirruslabs/tart/issues/140>`_
