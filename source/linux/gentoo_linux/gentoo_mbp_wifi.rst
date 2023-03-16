.. _gentoo_mbp_wifi:

===================================
Gentoo Linux在MacBook Pro配置Wifi
===================================

Broadcom WiFi
===============

早期MacBook Air 11" 2011版
----------------------------

我曾经使用过MacBook Air 11" 2011版，这款笔记本使用的是Broadcom B43xx系列，是可以使用 ``b43-firmware`` 驱动的，装 ``b43`` 驱动即可:

.. literalinclude:: gentoo_mbp_wifi/macbook_air11_2011_b43
   :language: bash
   :caption: MacBook Air 11" 2011版可以使用 ``b43`` 驱动

Broadcom BCM4360
-------------------

到 :ref:`mbp15_late_2013` 以及我另外一台 MacBook Air 13" ，采用是 Broadcom BCM4360 。这款无线芯片对开源支持不佳，参考 `Linux wireless b43文档 <https://wireless.wiki.kernel.org/en/users/drivers/b43>`_ 可以看到 ``b43`` 驱动不支持BCM4360，建议使用 ``wl`` 驱动。

也就是需要使用闭源的Broadcom驱动( `Apple Macbook Pro Retina - Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina#Closed_source_Broadcom_driver>`_ )

.. literalinclude:: gentoo_mbp_wifi/lspci_k
   :caption: lspci -k 输出硬件信息

内核
========

IEEE 802.11
-------------

至少需要激活 ``cfg80211`` (CONFIG_CFG80211) 和 ``mac80211`` (CONFIG_MAC80211)

.. literalinclude:: gentoo_mbp_wifi/kernel_80211
   :caption: 内核激活 ``cfg80211`` (CONFIG_CFG80211) 和 ``mac80211`` (CONFIG_MAC80211)

.. note::

   由于需要加载firmware，所以 wireless configuration API (CONFIG_CFG80211) 需要配置成模块方式而不是直接buildin

WEXT
-------

``cfg80211 wireless extensions compatibility`` 选项( ``WEXT`` )可以支持传统的 ``wireless-tools`` 和 ``iwconfig`` :

.. literalinclude:: gentoo_mbp_wifi/kernel_wext
   :caption: 内核激活  ``cfg80211 wireless extensions compatibility`` 选项( ``WEXT``  )

.. note::

   我在 Kernel 6.1.12 未找到这个配置项

设备驱动
-----------

注意，建议将驱动编译为内核模块，因为WiFi驱动通常需要firmware，只有作为模块加载时才能使用firmware:

.. literalinclude:: gentoo_mbp_wifi/kernel_wifi_drivers
   :caption: 内核激活相应的驱动内核模块

.. note::

   ``b43`` 可以在内核源码中激活模块方式编译，但是Broadcom4360需要私有驱动 `net-wireless/broadcom-sta <https://packages.gentoo.org/packages/net-wireless/broadcom-sta>`_ 没有编译选项

LED支持
---------

笔记本内置WiFi没有LED，可忽略

.. literalinclude:: gentoo_mbp_wifi/kernel_wifi_led
   :caption: 内核WiFi的LED支持(数据包收发LED triggers)

Firmware
==========

根据 `gentoo linux wiki: WiFi <https://wiki.gentoo.org/wiki/Wifi>`_ 文档，除了内核模块编译支持之外，WiFi芯片还需要对应firmware:

.. csv-table:: Broadcom无线网卡驱动及firmware
   :file: gentoo_mbp_wifi/broadcom_wifi_driver_firmware.csv
   :widths: 30,20,20,30
   :header-rows: 1

Broadcom BCM4360驱动和Firmware
================================

综上所述，对于 Broadcom BCM4360 实际上就只有安装私有驱动和firmware了，几乎连内核驱动模块都省了:

- 安装 ``wl`` 驱动和firmware:

.. literalinclude:: gentoo_mbp_wifi/broadcom_bcm4360_driver_firmware
   :caption: 安装Broadcom BCM4360的私有驱动和firmware

.. note::

   ``net-wireless/broadcom-sta`` 同时包含了驱动和firmware


参考
=====

- `Apple Macbook Pro Retina - Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina#Closed_source_Broadcom_driver>`_
- `gentoo linux wiki: WiFi <https://wiki.gentoo.org/wiki/Wifi>`_
