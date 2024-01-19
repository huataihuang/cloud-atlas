.. _gentoo_virtualization:

=============================
Gentoo 虚拟化
=============================

硬件
======

大多数现代计算机架构都包括对硬件级别虚拟化的支持:

- AMD 的 AMD-V (svm): ``grep --color -E "svm" /proc/cpuinfo``
- Intel 的 Vt-x (vmx): ``grep --color -E "vmx" /proc/cpuinfo``

虚拟化扩展必须受处理器支持并在系统固件（通常是主板的固件菜单）中启用，以便可由 Guest 操作系统访问

软件
=====

- Hypervisors: :ref:`qemu`
- 虚拟化管理工具包: :ref:`libvirt`
- GUI: ``virt-manager``

Kernel
========

to be continue...

USE flags
================

:ref:`qemu`
-------------

:ref:`libvirt`
----------------

``virt-manager``
------------------

.. literalinclude:: gentoo_virtualization/virtual.use
   :caption: ``/etc/portage/package.use/virtual``

安装
======

.. literalinclude:: gentoo_virtualization/install_virt
   :caption: 安装

安装了netcat 出现 virt-manager 但由于包被阻止而失败:

.. literalinclude:: gentoo_virtualization/emerge_virt-manager_block_package
   :caption: virt-manager 但由于包被阻止而失败

`emerge virt-manager failed with block package (Solved) <https://forums.gentoo.org/viewtopic-t-1107184-start-0.html>`_ : 删除 netcat

.. literalinclude:: gentoo_virtualization/emerge_uninstall_netcat
   :caption: 删除 netcat

Refer
===============

- `gentoo linux wiki: Virtualization <https://wiki.gentoo.org/wiki/Virtualization>`_
- `gentoo linux wiki: QEMU <https://wiki.gentoo.org/wiki/QEMU>`_
- `gentoo linux wiki: virt-manager <https://wiki.gentoo.org/wiki/Virt-manager>`_
- `gentoo linux wiki: libvirt <https://wiki.gentoo.org/wiki/Libvirt>`_
