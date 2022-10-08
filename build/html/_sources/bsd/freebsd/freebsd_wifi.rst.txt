.. _freebsd_wifi:

====================
FreeBSD无线网络
====================

.. note::

   本文实践在 :ref:`mbp15_late_2013` 完成，使用的无线网卡芯片是 Broadcom

- 加载内核模块::

   sudo kldload if_bwn 
   sudo kldload bwn_v4_ucode 
   sudo kldload bwn_v4_lp_ucode



参考
======

- `FreeBSD Broadcom Wi-Fi Improvements <https://landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_
- `FreeBSD cannot use WiFi with BCM4360 on MacBook Air <https://unix.stackexchange.com/questions/367591/freebsd-cannot-use-wifi-with-bcm4360-on-macbook-air>`_
