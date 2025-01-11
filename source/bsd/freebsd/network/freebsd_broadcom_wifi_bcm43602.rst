.. _freebsd_broadcom_wifi_bcm43602:

======================================
FreeBSD Broadcom Wi-Fi驱动(BCM43602)
======================================

之前尝试 :ref:`freebsd_wifi` 没有成功 ，我现在review了一下当时的操作，感觉还是在加载内核配置上存在问题。最近看到 `FreeBSD从入门到跑路: 第 14.2 节 WiFi >> 博通（broadcom）网卡驱动 <https://book.bsdcn.org/di-14-zhang-wang-luo-guan-li/di-14.2-jie-wifi#bo-tong-broadcom-wang-ka-qu-dong>`_ 介绍了如何安装驱动方法。我又仔细看了一下 `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_ 最后一段，提到了Retian MacBook Pro 2016，其中使用的 Broadcom FullMAC设备(BCM4350)不能被 ``bwn`` 驱动支持。但是， ``bhnd`` 驱动是从 Broadcom 的 ISC-licensed ``brcmfmac`` Linux驱动移植过来，似乎可能会支持。

.. note::

   主要是license的原因，导致驱动移植无法直接加入FreeBSD内核。这部分我准备再仔细阅读一下原文，有时间再做一次尝试。

   待续...

参考
=========

- `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_
