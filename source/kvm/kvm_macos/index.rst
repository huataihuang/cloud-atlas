.. _kvm_macos:

=================================
KVM虚拟化运行macOS
=================================

KVM提供了不需要修改Guest操作系统的虚拟化运行，也支持将macOS作为Guest运行。网上有不少通过KVM运行macOS的教程，并且 `foxlet/macOS-Simple-KVM <https://github.com/foxlet/macOS-Simple-KVM>`_ 提供了一个快速设置macOS VM的工具方便我们实现。

目前已经有不少云计算厂商提供了虚拟化运行macOS的产品，如AWS，Azure等，甚至有提供纯macOS托管和虚拟化的 `MacStadium <https://www.macstadium.com>`_ , `MacinCloud <https://www.macincloud.com>`_ 和 `Fkiw <https://flow.swiss>`_ 。从开发移动应用需要大量的测试环境来说，macOS的虚拟化云计算有技术和市场价值，值得探索研究。

.. note::

   我希望采用开源虚拟化实现macOS运行，构建持续集成的移动开发环境。

.. toctree::
   :maxdepth: 1

   osx_kvm.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
