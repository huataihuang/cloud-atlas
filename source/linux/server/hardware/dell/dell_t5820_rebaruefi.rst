.. _dell_t5820_rebaruefi:

=======================================
Dell T5820通过ReBarUEFI工具强制修改BAR
=======================================

Dell T5820这款早期工作站的主板有一个巨大缺陷是不支持 :ref:`tesla_a2` 和 :ref:`amd_mi50` 这样的服务器GPU计算卡的大规格BAR，导致无法启动主机。我在反复折腾 :ref:`amd_mi50_change_vbios_bar_size` 失败之后，gemini终于推荐了使用开源工具 `xCuri0/ReBarUEFI <https://github.com/xCuri0/ReBarUEFI>`_ 来为主板BIOS注入一个 UEFI 驱动（DXE Driver），这样可以将显卡的 BAR 强制限制在 256MB、512MB 或 1GB，即使显卡固件请求32GB，主板也只会给他分配一个小窗口，从而允许顺利开机。

.. note::

   和AI对话就像即时战略游戏中的无尽地图，通过不断的排列组合试探，才能在某一个瞬间触发发现新大陆!!!

.. warning::

   由于 :ref:`dell_t5820` 对BIOS写入有签名保护，所以自制的BIOS是无法直接刷入主机BIOS的，需要采用 :ref:`external_eeprom_flasher` 绕过主板上的PRR(写保护寄存器)

分析
=======

为何我的 :ref:`amd_mi50` 一直无法在 :ref:`dell_t5820` 上启用，我经过各种尝试后推测如下:

`evilJazz/MI50_32GB_VBIOS.md <https://gist.github.com/evilJazz/14a4c82a67f2c52a6bb5f9cea02f5e13>`_ 列出了 :ref:`amd_mi50` 原生的VBIOS ``113-D1631711-100`` 是一个Legacy only VBIOS(不支持UEFI)，同时不支持ReBAR。既然GPU不支持ReBAR，那么 :ref:`dell_t5820` 不支持ReBAR也没关系。但是这里有一个关键点就是这款MI50数据中心计算卡，由于不支持ReBAR，就会强制要求主机提供一个32GB的大型BAR。

这种大型BAR的要求，对于 :ref:`hpe_dl380_gen9` 这样的标准数据中心服务器是能够满足的，但是对于 :ref:`dell_t5820` 则无法做到。虽然T5820也支持工作站系列的NVIDIA RTX，并且支持高达48GB的显存，但是工作站显卡显然不会采用数据中心这种申请整块巨大BAR的方式，而是采用传统的Small BAR，所以在T5820上大规格显存的工作站显卡可以使用。

我后来刷新了 :ref:`amd_mi50` 的VBIOS，采用了V420的VBIOS，此时由于V420的VBIOS是UEFI格式，并且支持ReBAR协商，理论上应该更好地适应工作站主板或者兼容台式机(在2017年以后的台式机主板普遍支持ReBAR)。此时就凸显出了T5820的短板: 不支持ReBAR协商，这导致它无法和MI50握手协商一个双方都能够支持的BAR Size。

目前最佳的用于工作站的 :ref:`amd_mi50` VBIOS是用于V420的VBIOS，兼顾了UEFI和ReBAR，这意味着能够用于无法直接支持32GB大BAR的普通工作站。现在需要解决的就是如何让 :ref:`dell_t5820` 也支持ReBAR协商，以便能够和 :ref:`amd_mi50` 握手确定一个最佳BAR。

.. _rebaruefi:

ReBarUEFI
============

`xCuri0/ReBarUEFI <https://github.com/xCuri0/ReBarUEFI>`_ 提供了 ``ReBarUEFI`` 为官方不支持Resiable BAR的系统提供了一个UEFI DXE驱动，来实现ReBAR支持。这样就为陈旧的老主机带来了支持最新ReBAR协议的能力，可以安装类似 :ref:`intel_gpu` Arc 系列这样必须使用ReBAR的显卡。

准备
------

- (可选)激活 ``4G Decoding`` : 在BIOS中激活 :ref:`above_4g_decoding` ，没有激活这个选项那么就会被限制在 ``1GB BAR`` 甚至 ``512MB BAR`` ，这种情况下最多可以设置为 ``2GB BAR``
- (可选)BIOS 支持Large BARs : **ReBarUEFI** 能够修复和这个相关的大多数问题

添加FFS模块
-------------



参考
======

- `xCuri0/ReBarUEFI <https://github.com/xCuri0/ReBarUEFI>`_
- `Resizable BAR (ReBar) on LGA 2011-3 X99 – how to enable and get extra performance <https://www.youtube.com/watch?v=vcJDWMpxpjE>`_
