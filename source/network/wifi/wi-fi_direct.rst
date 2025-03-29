.. _wi-fi_direct:

======================
Wi-Fi Direct无线直连
======================

Wi-Fi Direct 是允许两个设备直接建立Wi-Fi连接而无需中间无线AP(wireless access point)，路由器或Internet连接的无线直连标准。Wi-Fi Direct(无线直连)是一个单跳(single-hop)通讯，和常见的多跳(multi-hop)通讯如无线ad hoc网络(wireless ad hoc networks)不同。该Wi-Fi Direct标准是2009年制定的。

Wi-Fi Direct无线直连通常用于文件传输，Miracast，无线打印以及在典型Wi-Fi速度下同时进行多设备通讯(无需热点)。这个技术类似于蓝牙技术，但是可以提供更远的通讯距离。只需要一个Wi-Fi设备申明Wi-Fi Direct就可以建立起P2P连接。

.. note::

   `Miracast <https://en.wikipedia.org/wiki/Miracast>`_

   无线联盟制定的从设备，如笔记本电脑、手机，向显示接收器，如电视、显示器或投影仪，直接传输视频和音频的无线协议。Miracast协议使用了Wi-Fi Direct来创建一个ad hoc加密无线连接，并且使用一种称为 `HDMI over Wi-Fi <https://en.wikipedia.org/wiki/Wireless_HDMI>`_ 的技术来代替连接电缆。

`GitHub: Ircama/hostp2pd <https://github.com/Ircama/hostp2pd>`_ 项目使用了 `wpa_supplicant Wi-Fi P2P <https://jw1.fi/cgit/hostap/plain/wpa_supplicant/README-P2P>`_ 来实现host AP服务，这个实现和常见的 :ref:`hostapd` 有所不同，以后可以研究实践一下。

.. note::

   看起来 :ref:`wpa_supplicant` 在 ``P2P GO`` 网络上有独立实现，后续可以参考 `wpa_supplicant.conf 配置样例 <https://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf>`_ 研究

目标规划
===========

- :ref:`pi_wi-fi_direct`

参考
=======

- `Wikipedia: Wi-Fi Direct <https://en.wikipedia.org/wiki/Wi-Fi_Direct>`_
