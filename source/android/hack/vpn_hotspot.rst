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

VPN Hotspot程序默认设置是一种通用型并且最大兼容的设置，但是这个设置可能并没有为电池寿命做优化。

.. note::

   共享热点也称为 ``Tethering`` 技术，特别是通过USB共享Internet连接，称为 ``USB Tethering`` 。不过，macOS默认没有包含Android USB Tethering驱动，所以在Android手机上激活USB Tethering后，通过USB连接到Mac电脑上是没有任何响应的，需要安装和设置 :ref:`android_usb_tethering` 驱动。

Upstream
-----------

* Upstream network interface: 在VPN Hotspot中主要的upstream是用于重路由数据流量的。如果保持空白则表示自动检测系统VPN(允许/在使用VPN时不允许绕过本程序)。如果设置为 ``none`` 就阻止绑定VPN
* Fallback upstream: Fallack upstream是用于某些VPN将一些失效路由返到默认网卡。如果该设置空白就表示自动检测。如果设置 ``none`` 就禁止 fallback。你可以设置一个接口
* IP Masquerade Mode: 
  * ``None`` : 从downstream来的数据不做任何地址/端口重映射。这个选贤更可能在一些dummy VPN，如ad-blocker或者socksifiers(Shadowsocks)有用。但是如果你使用真正的VPN，如OpenVPN就不要使用这个选项。
  * ``Simple`` : 从downstream来的数据包的源地址和源端口被重映射
  * ``Android Netd Service`` (从Android 9开始提供) : 允许你的系统来处理masquerade。Android系统将做一些额外的事情，如FTP以及绑定流量计数器。在移动运营商网络上隐藏你的绑定操作就可能不会使用这个选项。

Downstream
--------------

* Disable IPv6 tethering: 启用这个选项禁止系统绑定IPv6。这可以阻止IPv6泄漏，因为当前程序不能处理IPv6 VPN 绑定
* (从Android 8.1开始)Tethering hardware acceleration: 这个功能是系统开发者模式的相同设置的快捷方式。为了让VPN绑在系统绑定上工作可能必须关闭这个选项，但是当绑定激活时候可能降低电池寿命
* Enable DHCP workaround: 只在VPN开启时设备无法获得客户端IP地址时使用。这是一个全局设置，也就是只能全局使用一次。

Misc
--------

* Keep Wi-Fi alive: 当开启repeater, temporary hotspot 或 system VPN hotspot时，锁定Wi-Fi

  * 选择 ``System default`` (从Android 10开始的默认设置)可以保护电池寿命
  * 选择 ``On`` (针对Android 10)(默认)主要是在repeater/hotspot仅用了一会儿就自动关闭或停止工作时用来解决这个问题。
  * 选择 ``Disable power save`` 是为了降低数据包延迟，例如在语音连接可能需要，或许可以提高通话质量。这个设置需要硬件支持，
  * 选择 ``Low latency mode`` 是降低数据包延迟(从Android 10提供)，但是可能会导致以下问题:

    * 降低电池寿命
    * 降低带宽
    * 降低Wi-Fi扫描频率 - 这可能导致设备移动或AP间切换的信号质量

* Start repeater on boot
* Network status monitor mode

使用VPN HotSpot
=========================

.. note::

   如果是使用移动数据网络建立的VPN连接，则可以使用 ``Wi-Fi Hotspot`` 。但是，如果是已经在Wi-Fi网络上启用了VPN，就不可以使用 ``Wi-Fi Hotspot`` ，否则会导致VPN断开(因为无线网卡被改为AP热点导致直联的WLAN断开)

通常有3步操作：

* 启动VPN - 可以使用Cisco AnyConnect连接VPN，连接完成后，切换到VPN Hot Spot程序

* 启用 ``Wi-Fi Hotspot`` 或 ``USB Tethering`` 或 ``Bluetooth Tething`` ，也可以组合这几种Tethering设置。这是调用Android系统内建的Tethering设置。

.. figure:: ../../_static/android/hack/vpn_hotspot_1.png
   :scale: 75

这里点击 ``USB tethering`` 将转跳到系统设置 ``Hotspot & tethering`` 启动 :ref:`android_usb_tethering` :

.. figure:: ../../_static/android/hack/vpn_hotspot_2.png
   :scale: 75

* 然后返回 VPN Hotspot 程序，可以看到此时不仅显示 ``USB tethering`` 已经激活，而且多出了一个 ``mdis0`` 设置(这个设置就是共享USB上网的upstream)，请激活 ``mdis0`` 接口:

.. figure:: ../../_static/android/hack/vpn_hotspot_3.png
   :scale: 75

此时你就会发现你的电脑也能够和已经连接VPN的手机一样访问公司内网或者翻墙了。

.. note::

   Andorid系统默认不能连接隐藏的网络，需要在设置添加无线SSID时候选择 ``Advanced options >> Hidden network >> Yes`` 才能连接到Hidden(stealth) WiFi network。否则会始终提示WiFi status是 ``out of range`` (参考 `Android 10: Connect To A Hidden Network <https://supportcommunity.zebra.com/s/article/000020035?language=en_US>`_ )

参考
=====

- `How to Share Your VPN Connection? – Step-By-Step Guide Covering Windows, MacOS, Android & iOS! <https://www.technadu.com/share-vpn-connection/38816/>`_
- `VPN Hotspot <https://github.com/Mygod/VPNHotspot>`_
