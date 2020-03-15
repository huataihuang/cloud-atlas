.. _chromium_os:

======================================
Chromium OS
======================================

Chromium OS基于 :ref:`gentoo_linux` 开发，结合了开源的Chromium浏览器，实现了轻量级面向云应用的Linux。

不过Chromium OS/Chrome OS完全基于因特网运行的轻量级客户端，在网络受限的墙内使用非常痛苦。不过，Chormium OS通过crostini这样的容器技术，可以在PixelBook/ChromeBook上运行Linux应用程序，为本地应用打开了一扇门。

我个人更看好基于Android的系统来融合移动设备操作系统，毕竟Android市场海量的应用目前还是WEB无法超越的。何况，在国内的生态环境，很多工作应用如果不能使用Android，则即使引入Linux容器也无法满足需求。目前我的想法是采用 :ref:`bliss` 来使用轻量级应用，同时采用 :ref:`linux_on_android` 来完成工作。

.. note::

   基于Chromium OS开发定制的Linux操作系统有 `Flint OS <https://flintos.io/>`_ ，以及在国内再定制的 `FydeOS <https://fydeos.com/>`_ (FydeOS提供针对FydeOS定制的硬件，可以视为ChromeBook在国内的翻版)。

.. toctree::
   :maxdepth: 1

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
