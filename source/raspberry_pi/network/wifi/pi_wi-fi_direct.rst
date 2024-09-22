.. _pi_wi-fi_direct:

================================
树莓派Wi-Fi Direct无线直连(p2p)
================================

目标
========

- 实现树莓派和 :ref:`android` (有案例) :ref:`iphone` (有可能不行)手机连接，实现文件传输

.. note::

   `树莓派论坛: We need a WiFi Direct guide <https://forums.raspberrypi.com/viewtopic.php?t=282553>`_ 的讨论提到建议采用 ad hoc 网络 ( `Wikipedia: Wireless ad hoc network <https://en.wikipedia.org/wiki/Wireless_ad_hoc_network>`_ 来取代Wi-Fi Direct

   iOS已经支持 ad-hoc ，而 Android不支持(不知道现在如何?)

参考
======

- `Set up WiFi direct (p2p) between a dedicated pair of Raspberry Pi 3 B+ (one as the Group Owner, the other as the client) <https://raspberrypi.stackexchange.com/questions/114012/set-up-wifi-direct-p2p-between-a-dedicated-pair-of-raspberry-pi-3-b-one-as-t>`_ 其中介绍了 `德州仪器: WiLink8 Linux Advanced Demons <https://www.ti.com/lit/ug/swru576/swru576.pdf?ts=1726911018874#Connect_in_Pin_.28PIN_Number.29_where_EVM_.231_is_defined_as_the_group_owner>`_ 介绍了详细的P2P模式，可以作为技术参考
