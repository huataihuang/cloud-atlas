.. _chromium_os:

======================================
Chromium OS
======================================

Chromium OS基于 :ref:`gentoo_linux` 开发，结合了开源的Chromium浏览器，实现了轻量级面向云应用的Linux。

Chromium OS/Chrome OS完全基于因特网运行的轻量级客户端，在网络受限的墙内使用非常痛苦。不过，Chormium OS通过crostini这样的容器技术，可以在PixelBook/ChromeBook上运行Linux应用程序，为本地应用打开了一扇门。

我个人更看好基于Android的系统来融合移动设备操作系统，毕竟Android市场海量的应用目前还是WEB无法超越的。何况，在国内的生态环境，很多工作应用如果不能使用Android，则即使引入Linux容器也无法满足需求。

对于技术爱好者，我觉得更好的方式是学习 :ref:`chromium_os_arch` ，通过 :ref:`lfs` 来构建自己的操作系统，构建精简的轻量级操作系统，同时构建AnBox来运行Android应用。

.. note::

   基于Chromium OS开发定制的Linux操作系统有 `Flint OS <https://flintos.io/>`_ ，以及在国内再定制的 `FydeOS <https://fydeos.com/>`_ (FydeOS提供针对FydeOS定制的硬件，可以视为ChromeBook在国内的翻版)。

   `Flint OS于2018年3月被Neverware收购 <https://www.neverware.com/pressrelease-03-06-2018>`_ ，合并到Neverware的CloudReady产品。Neverware在2020年11月又被Google收购，所以目前这个产品应该是融入Chrome OS作为云计算中远程运行的桌面系统产品。

.. toctree::
   :maxdepth: 1

   chromium_os_arch.rst
   fydeos_pi.rst
   chromeos_serial.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
