.. _archlinux_kernel:

==============================
Arch Linux 内核
==============================

:ref:`archlinux_zfs-dkms_x86` 需要特定内核支持ZFS :ref:`dkms` 内核模块，所以本文整理 Arch Linux 的内核异同，以及安装指定 Linux 6.1 内核

Arch Linux官方支持内核分类
=============================

简单来说，arch linux的官方内核分为以下5类(图示中显示类没有包含实时内核):

.. figure:: ../../_static/linux/arch_linux/arch-linux-kernels.png
   
   Arch Linux 官方支持内核分类

.. csv-table:: Arch Linux官方支持内核分类
   :file: archlinux_kernel/kernel.csv
   :widths: 20,50,30
   :header-rows: 1

自编译内核
=================

kernel.org内核
--------------------

从kernel.org获取内核，arch linux 通过 :ref:`archlinux_aur` 方式可以安装特定版本呢内核(例如指定 ``6.1`` 内核以满足 :ref:`archlinux_zfs-dkms_x86` 运行)，请参考 `archlinux wiki: Kernel <https://wiki.archlinux.org/title/Kernel>`_ 获取完整列表。

注意， :ref:`archlinux_aur` 需要使用类似 ``yay`` 这样的第三方工具进行安装，在完成 ``yay`` 编译安装之后，执行以下命令可以安装指定内核 ``6.1`` LTS:

.. literalinclude:: archlinux_kernel/yay_linux6.1
   :caption: 通过 :ref:`archlinux_aur` 安装指定的 Kernel 6.1

参考
======

- `Different Types of Kernel for Arch Linux and How to Use Them <https://itsfoss.com/switch-kernels-arch-linux/>`_
- `archlinux wiki: Kernel <https://wiki.archlinux.org/title/Kernel>`_
