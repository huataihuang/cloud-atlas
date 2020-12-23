.. _jetson_soft_ap:

=====================
Jetson Nano无线AP
=====================

Jetson Nano安装了外接的Intel无线模块以后，非常类似一个无线路由器，所以我考虑利用这个现有硬件结合 :ref:`soft_ap` 实现一个个人使用的无线路由器，方便我测试基于 :ref:`raspberry_pi` 的 :ref:`kubernetes_arm` 。

由于这是在ARM架构上实现无线AP，所以可以作为通用的低功耗路由器的实践基础，为后续实现无线路由交换设备做一个参考。

硬件准备
===========

- 无线网卡必须是 ``nl80211`` 兼容无线设备，以便支持 AP operating mode。执行 ``iw list`` 命令 ``interface modes`` 列表中包含 ``AP`` 支持::

   Supported interface modes:
            * IBSS
		    * managed
		    * AP
		    * AP/VLAN
		    * monitor
		    * P2P-client
		    * P2P-GO
		    * P2P-device

- 我的Jetson Nano已经连接了局域网的无线AP，我的目标是构建同时作为无线 ``客户端`` (连接现有无线局域网AP) 和无线 ``AP`` 的混合设备角色。这种模式是将软件AP作为无线中继器( ``wireless repeater`` )，就只需要一个无线设备。这个能力通过 ``iw list`` 可以检查::

   valid interface combinations:
            * #{ managed } <= 1, #{ AP, P2P-client, P2P-GO } <= 1, #{ P2P-device } <= 1,
              total <= 3, #channels <= 2

软件准备
=========

.. note::

   Oblique开发了 `Oblique – GitHub <https://github.com/oblique/create_ap>`_ ，是一个配置WiFi AP的脚本，不过现在已经不再维护。这个create_ap的优点是简洁，仅需要bash和相关基础工具支持。

   可以采用 lakinduakash 继续维护开发的 `linux-wifi-hotspot <https://github.com/lakinduakash/linux-wifi-hotspot>`_ ，提供了终端和图形界面，并且支持hostspot服务运行。这个新版的linux-wifi-hotspot集成了oblique的create_ap工具逻辑，并提供了gtk图形界面配置工具。

   我在 :ref:`soft_ap` 中已经使用过 ``create_ap`` 来创建WiFi AP，这里改为采用 ``linux-wifi-hotspot`` 来实现。

- 在Ubuntu/Debian系统中安装以下编译安装依赖::

   sudo apt install -y libgtk-3-dev build-essential gcc g++ pkg-config make hostapd

- 安装软件::

   git clone https://github.com/lakinduakash/linux-wifi-hotspot
   cd linux-wifi-hotspot

   make
   sudo make install

配置AP
=======

依然可以使用 ``create_ap`` 工具快速完成快速完成无线AP配置，并且支持bridge和NAT模式，能够自动结合 hostapd, dnsmasq 和 iptables 完成AP设置。最简单的命令如下::

   create_ap wlp3s0 enp0s25 MyAccessPoint MyPassPhrase

不过，这次我们的案例要复杂一些，我们配置一个使用单一无线网卡接口实现同时连接局域网无线AP同时自己作为一个无线AP的模式。这种没有有线网络仅使用无线网卡的模式，需要先创建2个分离的虚拟接口，即这2个虚拟机接口是物理设备 ``wlan0`` 的子接口，并且具有独立的MAC地址::

   iw dev wlan0 interface add wlan0_sta  type managed addr 02:68:b3:29:da:99
   iw dev wlan0 interface add wlan0_ap  type managed addr 02:68:b3:29:da:98

.. note::

   要随机生成一个MAC地址可以参考 `how to generate a random MAC address from the Linux command line <https://serverfault.com/questions/299556/how-to-generate-a-random-mac-address-from-the-linux-command-line>`_ 基于主机名FQDN来生成MAC地址。或者使用 `macchanger <https://wiki.archlinux.org/index.php/MAC_address_spoofing#Method_2:_macchanger>`_ 来随机修改主机接口MAC地址。


- 配置一个NAT模式的隐藏SSID::

   create_ap --hidden wlan0_ap wlan0_sta MyAccessPoint MyPassPhrase

此时终端会提示::

   Config dir: /tmp/create_ap.wlan0_ap.conf.SUJxqY8y
   PID: 10699
   Network Manager found, set ap0 as unmanaged device... DONE
   Creating a virtual WiFi interface... ap0 created.
   Access Point's SSID is hidden!
   Sharing Internet using method: nat
   hostapd command-line interface: hostapd_cli -p /tmp/create_ap.wlan0_ap.conf.SUJxqY8y/hostapd_ctrl
   Configuration file: /tmp/create_ap.wlan0_ap.conf.SUJxqY8y/hostapd.conf
   Using interface ap0 with hwaddr 68:ec:c5:62:3f:6d and ssid "MyAccessPoint"
   ap0: interface state UNINITIALIZED->ENABLED
   ap0: AP-ENABLED

现在你拿出手机，就可以通过添加AP来连接到无线AP上。

检查生成的 ``/tmp/create_ap.wlan0_ap.conf.SUJxqY8y/hostapd.conf`` 配置文件类似如下::

   beacon_int=100
   ssid=MyAccessPoint
   interface=ap0
   driver=nl80211
   channel=1
   ctrl_interface=/tmp/create_ap.wlan0_ap.conf.xY8Tn75d/hostapd_ctrl
   ctrl_interface_group=0
   ignore_broadcast_ssid=1
   ap_isolate=0
   hw_mode=g
   wpa=3
   wpa_passphrase=MyPassPhrase
   wpa_key_mgmt=WPA-PSK
   wpa_pairwise=TKIP CCMP
   rsn_pairwise=CCMP

尝试使用wlan0接口
------------------

不过，我发现，实际上 ``create_ap`` 会自动创建虚拟接口 ``ap0`` ，看上去实际上没有使用 ``wlan0_ap`` 和 ``wlan_sta`` 接口(这两个接口还是DOWN状态)，但是如果删除了这2个虚拟接口( ``iw dev wlan0_sta del; iw dev wlan0_ap del`` ) 再使用类似命令 ``create_ap --hidden wlan0 wlan0 MyAccessPoint MyPassPhrase`` 会出现报错::

   Config dir: /tmp/create_ap.wlan0.conf.9DjnL09H
   PID: 22113
   Network Manager found, set ap0 as unmanaged device... DONE
   wlan0 is already associated with channel 44 (5220 MHz)
   multiple channels supported
   Creating a virtual WiFi interface... ap0 created.
   ERROR: Your adapter can not transmit to channel 1, frequency band 5GHz.
   Doing cleanup.. done

原因是对于5GHz无线，需要指定country code，并且由于 wlan0 已经绑定了channel 44，之前在 ``iw list`` 输出信息中显示 ``#channels <= 2`` 表明software AP必须和WiFi client连接使用相同通道，所以修改成::

   create_ap --hidden --country CN -c 44 wlan0 wlan0 MyAccessPoint MyPassPhrase

可惜依然报错::

   Channel number is greater than 14, assuming 5GHz frequency band
   Config dir: /tmp/create_ap.wlan0.conf.qgNWN8UH
   PID: 11886
   Network Manager found, set ap0 as unmanaged device... DONE
   wlan0 is already associated with channel 56 (5280 MHz)
   multiple channels supported
   Creating a virtual WiFi interface... ap0 created.
   ERROR: Your adapter can not transmit to channel 44, frequency band 5GHz.
   Doing cleanup.. done

脚本
======

为了简化方法，我目前还是没有使用daemon方式，并不是十分优雅。采用了一个手工启动脚本 ``hotspot``

.. literalinclude:: hotspot
   :language: bash
   :linenos:

Thinkpad x86环境create_ap
===========================

在zcloud主机(Thinkpad X220笔记本运行Arch Linux)上执行遇到问题::

   sudo iw dev wlp3s0 interface add wlp3s0_sta  type managed addr 02:68:b3:29:da:99
   sudo iw dev wlp3s0 interface add wlp3s0_ap  type managed addr 02:68:b3:29:da:98
   sudo create_ap --daemon --hidden wlp3s0_ap wlp3s0_sta MyAccessPoint MyPassPhrase

报错::

   ...
   WARN: Low entropy detected. We recommend you to install `haveged'`
   Failed to set beacon parameters
   Interface initialization failed
   ...

检查网卡接口::

   iw list

可以看到这块无线网卡的参数::

    valid interface combinations:
             * #{ managed  } <= 1, #{ AP  } <= 1,
               total <= 2, #channels <= 1, STA/AP BI must match
             * #{ managed  } <= 2,
               total <= 2, #channels <= 1

其中 ``#channels <= 1, STA/AP BI must match`` 参考 `hostapd not working anymore <https://serverfault.com/questions/966352/hostapd-not-working-anymore>`_ 可知，要求sta网卡和ap网卡使用相同的channel。

所以需要先检查当前使用的通道::

   iw wlp3s0 info

可以看到输出信息::

   Interface wlp3s0
           ...
           channel 44 (5220 MHz), width: 20 MHz, center1: 5220 MHz
           ...

所以尝试添加 ``-c 44`` 参数::

   sudo create_ap -c 44 --daemon --hidden wlp3s0_ap wlp3s0_sta MyAccessPoint MyPassPhrase

但是报错::

   ERROR: Your adapter can not transmit to channel 44, frequency band 5GHz.

这个问题可能可以参考 `oblique/create_ap Error while trying to establish a connection #75 <https://github.com/oblique/create_ap/issues/75>`_ 

.. note::

   `Turn any computer into a wireless access point with Hostapd <https://linuxnatives.net/2014/create-wireless-access-point-hostapd>`_ 介绍了更为详细的手工配置方法，可以作为参考

参考
======

- `Creating Wifi On Ubuntu <https://theubuntuguide.wordpress.com/2016/08/03/creating-wifi-on-ubuntu/>`_
- `linux-wifi-hotspot <https://github.com/lakinduakash/linux-wifi-hotspot>`_
