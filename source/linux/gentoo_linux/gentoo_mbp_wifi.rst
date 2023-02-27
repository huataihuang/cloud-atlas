.. _gentoo_mbp_wifi:

===================================
Gentoo Linux在MacBook Pro配置Wifi
===================================

早期MacBook Air 11" 2011版
===========================

我曾经使用过MacBook Air 11" 2011版，这款笔记本使用的是Broadcom B43xx系列，是可以使用 ``b43-firmware`` 驱动的，装 ``b43`` 驱动即可:

.. literalinclude:: gentoo_mbp_wifi/macbook_air11_2011_b43
   :language: bash
   :caption: MacBook Air 11" 2011版可以使用 ``b43`` 驱动

Broadcom BCM4360
=================

到MacBook Pro 2013 以及我另外一台 MacBook Air 13" ，采用是 Broadcom BCM4360 。这款无线芯片对开源支持不佳，参考 `Linux wireless b43文档 <https://wireless.wiki.kernel.org/en/users/drivers/b43>`_ 可以看到 ``b43`` 驱动不支持BCM4360，建议使用 ``wl`` 驱动。

也就是需要使用闭源的Broadcom驱动( `Apple Macbook Pro Retina - Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina#Closed_source_Broadcom_driver>`_ )

参考
=====

- `Apple Macbook Pro Retina - Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina#Closed_source_Broadcom_driver>`_
