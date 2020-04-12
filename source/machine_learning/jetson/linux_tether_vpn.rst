.. _linux_tether_vpn:

=====================
tethering共享VPN加速
=====================

在 :ref:`jetson_nano_startup` 中，我遇到一个困难：在墙内访问NVIDIA软件仓库几乎是 `Mission: Impossible <https://movie.douban.com/subject/1292484/>`_ 。

技术人不能让尿憋死，你说是不是？

专线+多级代理
==============

为了能够稳定访问NVIDIA的软件仓库，可以使用 :ref:`openconnect_vpn` 来突破墙的干扰。

但是，直接访问海外的VPN服务器，SSL加密通讯阻塞非常严重。所以，通常需要借助 :ref:`squid` 通过墙内和墙外 :ref:`squid_socks_peer` 这样的解决方案：寻找到稳定的专线连接，通过多级代理迂回实现稳定的Internet访问。

Android共享VPN
===============

在访问 :ref:`squid` ，为了安全，需要构建加密通讯。但是，Linux平台可能没有专用的商业VPN客户端，此时我们需要借用Android手机上常用的商业VPN客户端构建加密通道。

:ref:`android_usb_tethering` 同时运行 :ref:`vpn_hotspot` ，可以让 :ref:`jetson` 主机借助Android手机的VPN安全访问 :ref:`squid` ，实现稳定的Internet访问。

Jetson nano的Linux系统默认已经能够识别 :ref:`android_usb_tethering` 设备，当Android端启用USB tethering时，系统自动添加网络设备 ``usb1`` ，此时只需要在该设备上启动 ``dhclient`` 就可以::

   dhclient usb1

获取到USB tethering分配的IP地址之后，只需要简单关闭无线网络默认路由，就可以用共享VPN方式访问Internet。

.. note::

   对于Linux tethering支持，请参考 `arch linux官方文档: Android tethering <https://wiki.archlinux.org/index.php/Android_tethering>`_
