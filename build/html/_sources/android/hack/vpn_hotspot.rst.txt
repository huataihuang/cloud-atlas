.. _vpn_hotspot:

=============
VPN Hotspot
=============

.. note::

   Linux平台VPN连接是可以通过NAT方式共享给局域网其他主机的，例如你可以使用 :ref:`openconnect_vpn` 翻墙，然后局域网其他主机默认路由指向这台主机，只要在这个主机上启用NAT，则其他主机也能够流畅访问网络。

   由于iOS安全限制，即使手机通过蜂窝网络创建了VPN连接，但是手机的热点共享无法提供其他设备共享VPN上网。解决的方法目前还是通过Jailbreak越狱以后才能够实现。

   Android设备安全限制相对灵活，只要Android手机Root过了，就可以通过VPNHotspot应用共享VPN上网。本文就是在Pixel手机上实践共享VPN的记录。

原理
=======



参考
=====

- `How to Share Your VPN Connection? – Step-By-Step Guide Covering Windows, MacOS, Android & iOS! <https://www.technadu.com/share-vpn-connection/38816/>`_
