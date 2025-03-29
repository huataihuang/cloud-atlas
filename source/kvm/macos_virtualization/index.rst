.. _macos_virtualization:

=================================
macOS Virtualization
=================================

.. note::

   苹果公司虽然没有主推服务器，但是实际上在 :ref:`macos` 中内置了原生的 :ref:`apple_virtualization` 框架，提供了极佳的虚拟化性能。虽然不是开源技术，但是通过定制开发，能够在macOS上原生运行macOS和 :ref`linux` ，例如开源的 :ref:`tart` 虚拟化toolset就可以方便地在Apple Silicon上构建运行和管理macOS/Linux虚拟机。

.. toctree::
   :maxdepth: 1

   ../../apple/virtualization/index
   lima/index
   osx_kvm.rst
   darwinkvm.rst
   xhyve.rst


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
