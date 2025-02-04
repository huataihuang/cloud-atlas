.. _blfs_networking_libraries:

===================================
BLFS Networking Libraries
===================================

libunistring
=================

.. literalinclude:: blfs_networking_libraries/libunistring
   :caption: 安装 libunistring

libidn2
=============

.. literalinclude:: blfs_networking_libraries/libidn2
   :caption: 安装 libidn2

libpsl
==========

.. note::

   cURL 强烈建议安装libpsl 以实现安全

libpsl包提供了访问和解析Public Suffix List(PSL)的库，这个PSL是标准后缀(例如.com)以外的一组域名。 :ref:`curl` 安装强烈建议安装libpsl

.. literalinclude:: blfs_networking_libraries/libpsl
   :caption: 安装 libpsl

libslirp
============

.. note::

   qemu 建议依赖 libslirp

libslirp 是用户模式网络库，用于虚拟机，容器和不同工具

.. literalinclude:: blfs_networking_libraries/libslirp
   :caption: 安装 libslirp


curl
=========

.. literalinclude:: blfs_networking_libraries/curl
   :caption: 安装 curl

wget
==========

.. literalinclude:: blfs_networking_libraries/wget
   :caption: 安装 wget



