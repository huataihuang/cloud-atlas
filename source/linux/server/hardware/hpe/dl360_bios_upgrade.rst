.. _dl360_bios_upgrade:

=====================
HPE DL360 BIOS升级
=====================

HP服务器的驱动升级以及各种软件包下载都需要购买HPE服务，这对个人购买的二手服务器显然不合适。

.. note::

   在eBay上有 ``HPE Service Pack ProLiant SPP HP Latest G7 G8 G9 G10 Servers - Direct Download`` 销售，SSP包括了HPE不同型号服务器的升级包，售价约50美金。

我购买的二手 :ref:`hpe_dl360_gen9` 服务器是 2015年8月8日 的BIOS版本，所以我想能够升级到最新的BIOS以便增加稳定性和性能。

Reddit的帖子 `HPE DL380 Gen 9 Firmware/Bios update <https://www.reddit.com/r/homelab/comments/k037h2/hpe_dl380_gen_9_firmwarebios_update/>`_ 提供了线索: 根据 ``SPP for G9 and G10`` 关键字在Google搜索，果然可以找到下载资源::

   Gen9/Gen10 Production SPP:
   Link: P35938_001_spp-2021.05.0-SPP2021050.2021_0504.129.iso
   Size: 9.99 GB
   MD5: 2a869e4138e2ac0e1cd09cd73c8faf70
   SHA1: 73fbd4f4c97c4928944cd9330132764a09d49de2
   SHA256: b98c578bf96e4ebed8645236a70d5df4d104d37238e5d17d59387888db5ae106

.. note::

   下载建议使用 :ref:`axel` 加速

参考
=======

- `HPE DL380 Gen 9 Firmware/Bios update <https://www.reddit.com/r/homelab/comments/k037h2/hpe_dl380_gen_9_firmwarebios_update/>`_
