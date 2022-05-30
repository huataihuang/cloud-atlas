.. _kexec:

================
kexec
================

kexec是一个系统调用，能够从当前运行的内核直接加载和启动另一个内核。这种方式在内核开发或者生产环境需要快速重启(无需等待BIOS启动漫长过程)。需要注意，kexec可能对于设备必须完全重初始化才能工作的情况不适用，虽然这种情况较为少见。

安装
========

- 软件包 ``kexec-tools`` ::

   sudo dnf install kexec-tools

使用kexec
==============

虽然通常我们不需要执行 ``kexec`` ，一般都是系统crash时候，通过 :ref:`kdump` 服务自动调用 ``kexec`` 来保存内核转储。不过，我们可以通过 ``kexec`` 来快速切换内核

- 例如，当前在 :ref:`fedora` ，内核版本::

   uname -r

显示::

   5.15.6-200.fc35.x86_64

使用 ``sudo dnf update`` 更新整个系统后，最新安装的内核位于 ``/boot`` 目录下::

   vmlinuz-5.17.8-200.fc35.x86_64
   initramfs-5.17.8-200.fc35.x86_64.img

对于物理服务器，重启需要进行硬件初始化，特别是对于大内存服务器以及大量磁盘设备的存储服务器，初始化时间非常漫长，而且重复启动容易引发硬件异常。所以，我们可以通过 ``kexec`` 来跳过硬件初始化，直接加速启动

- 指定内核 ``kexec`` :

.. literalinclude:: kexec/kexec_special_kernel
   :caption: 指定内核kexec快速启动

.. warning::

   使用 ``kexec -e`` 直接启动内核，不会将挂载的目录 ``umount`` ，也不会非常优雅地停止任何运行服务，所以，还是推荐下文使用 :ref:`systemd` 来处理 ``kexec``

- 建议采用 :ref:`systemd` 来里

.. literalinclude:: kexec/systemd_kexec_special_kernel
   :caption: 指定内核通过systemd运行kexec快速启动

参考
=====

- `arch linxu kexec <https://wiki.archlinux.org/title/Kexec>`_
