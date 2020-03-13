.. _vpn_hotspot:

=============
VPN Hotspot
=============

.. note::

   Linux平台VPN连接是可以通过NAT方式共享给局域网其他主机的，例如你可以使用 :ref:`openconnect_vpn` 翻墙，然后局域网其他主机默认路由指向这台主机，只要在这个主机上启用NAT，则其他主机也能够流畅访问网络。

   MacOS设置共享VPN给热点非常方便，请参考 `How to share a VPN connection from your Mac OS <https://torguard.net/article/217/vpn-sharing-on-mac.html>`_ ：只需要把 VPN PPTP/L2TP 连接通过 ``Internet Sharing`` 功能共享给 ``Wi-Fi`` 设备，就能够创建一个AP热点：

   .. figure:: ../../_static/android/hack/share_vpn_hotspot.png
      :scale: 75

   由于iOS安全限制，即使手机通过蜂窝网络创建了VPN连接，但是手机的热点共享无法提供其他设备共享VPN上网。解决的方法目前还是通过Jailbreak越狱以后才能够实现。

   Android设备安全限制相对灵活，只要Android手机Root过了，就可以通过VPNHotspot应用共享VPN上网。本文就是在Pixel手机上实践共享VPN的记录。

原理
=======

`VPN Hotspot <https://github.com/Mygod/VPNHotspot>`_ 是一个开源共享VPN连接给hotspot或repeater的Android程序，不过运行需要root过的Android环境。可以从 `XDA labs的vpnhotspot <https://labs.xda-developers.com/store/app/be.mygod.vpnhotspot>`_ 下载，也可以直接从Goolge Play安装。



参考
=====

- `How to Share Your VPN Connection? – Step-By-Step Guide Covering Windows, MacOS, Android & iOS! <https://www.technadu.com/share-vpn-connection/38816/>`_
- 
