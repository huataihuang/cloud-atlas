.. _intro_freeebsd_virtualization:

======================
FreeBSD虚拟化技术概览
======================

虚拟化软件可以在一台主机上同时运行不同操作系统。和Linux平台的 :ref:`kvm` 类似，FreeBSD也有自己的虚拟化技术 :ref:`bhyve` ，也移植了Linux平台的 :ref:`qemu` 。

.. note::

   我关注的是FreeBSD服务器技术，所以主要实践 :ref:`bhyve` 将FreeBSD作为Host主机提供虚拟化运行环境。少量实践是在VMware Fusion或者QEMU中运行FreeBSD guest。

参考
=======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
