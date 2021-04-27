.. _setup_hostapd_failed:

==================================
配置hostapd实现无线热点(失败记录)
==================================

在 :ref:`pi_400` 上运行 :ref:`kali_linux` 时，我尝试 :ref:`linux_wifi_hotspot` ，但是会遇到由于树莓派采用的brmfmac驱动(broadcom芯片)可能会触发内核crash，所以 :ref:`create_ap` 禁止使用虚拟机接口来实现同一个无线网卡同时作为internet接口和共享AP接口。

由于 :ref:`create_ap` 实际是 ``hostapd`` 的包装脚本，所以还是可以全程手工配置 ``hostapd`` 来实现一个单一无线接口实现Internet共享的无线AP配置。

.. warning::

   我的在树莓派上实践尚未成功!

准备
======

- 安装必要软件::

   sudo apt install hostapd dnsmasq

配置
=====

- 检查接口::

   iw list

可以看到::

   ...
   valid interface combinations:
         * #{ managed } <= 1, #{ monitor } <= 1, #{ P2P-device } <= 1, #{ P2P-client, P2P-GO } <= 1,
           total <= 4, #channels <= 2
         * #{ managed } <= 1, #{ AP } <= 1, #{ monitor } <= 1, #{ P2P-client } <= 1, #{ P2P-device } <= 1,
           total <= 5, #channels <= 1

- 配置 ``/etc/dnsmasq.conf`` 内容::

   interface=lo,uap0
   no-dhcp-interface=lo,wlan0
   dhcp-range=192.168.2.100,192.168.2.200,12h

这里关闭了 ``wlan0`` 接口上的dhcp很重要，避免和无线网络上的DHCP服务冲突，启用了虚拟接口 ``uap0`` 上的DNS解析。

- 编辑 ``/etc/hostapd/hostapd.conf`` ::

   interface=uap0
   ssid=pipi
   hw_mode=g
   channel=6
   macaddr_acl=0
   auth_algs=1
   ignore_broadcast_ssid=0
   wpa=2
   wpa_passphrase=0123456789
   wpa_key_mgmt=WPA-PSK
   wpa_pairwise=TKIP
   rsn_pairwise=CCMP

注意，请修改配置中的 ``ssid`` 和 ``wpa_passphrase`` 内容以符合实际要求

- 编辑 ``/etc/network/interfaces`` ::

   auto uap0
   iface uap0 inet static
   address 192.168.2.1
   netmask 255.255.255.0

- 增加一个文件 ``/usr/local/bin/hostapdstart`` ::

   iw dev wlan0 interface add uap0 type __ap
   service dnsmasq restart
   sysctl net.ipv4.ip_forward=1
   iptables -t nat -A POSTROUTING -s 192.168.2.0/24 ! -d 192.168.2.0/24 -j MASQUERADE
   ifup uap0
   hostapd /etc/hostapd/hostapd.conf

- 并设置上述脚本可执行::

   chmod 667 /usr/local/bin/hostapdstart

- 启动::

   hostapdstart

如果正常，也可以::

   hostapdstart >1&

我这里遇到 ``dmesg -T`` 显示报错::

   [Tue Apr 27 17:36:17 2021] brcmfmac: brcmf_link_down: WLC_DISASSOC failed (-52)
   [Tue Apr 27 17:36:18 2021] brcmfmac: brcmf_sdio_hostmail: mailbox indicates firmware halted
   [Tue Apr 27 17:36:21 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:21 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:23 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:23 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:23 2021] brcmfmac: brcmf_c_set_joinpref_default: Set join_pref error (-110)
   [Tue Apr 27 17:36:26 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:26 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:28 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:28 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:28 2021] brcmfmac: brcmf_cfg80211_connect: BRCMF_C_SET_SSID failed (-110)
   [Tue Apr 27 17:36:31 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:31 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:31 2021] brcmfmac: brcmf_run_escan: error (-110)
   [Tue Apr 27 17:36:31 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)
   [Tue Apr 27 17:36:35 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:35 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:35 2021] brcmfmac: brcmf_run_escan: error (-110)
   [Tue Apr 27 17:36:35 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)
   [Tue Apr 27 17:36:37 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:37 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:37 2021] brcmfmac: brcmf_vif_set_mgmt_ie: vndr ie set error : -110
   [Tue Apr 27 17:36:37 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)
   [Tue Apr 27 17:36:40 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:40 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:40 2021] brcmfmac: brcmf_vif_set_mgmt_ie: vndr ie set error : -110
   [Tue Apr 27 17:36:40 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)
   [Tue Apr 27 17:36:42 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:42 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:42 2021] brcmfmac: brcmf_cfg80211_get_tx_power: error (-110)
   [Tue Apr 27 17:36:42 2021] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
   [Tue Apr 27 17:36:45 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:45 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:45 2021] brcmfmac: _brcmf_set_multicast_list: Setting mcast_list failed, -110
   [Tue Apr 27 17:36:48 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:48 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:48 2021] brcmfmac: _brcmf_set_multicast_list: Setting allmulti failed, -110
   [Tue Apr 27 17:36:50 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:50 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:53 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:53 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:53 2021] brcmfmac: brcmf_cfg80211_get_channel: chanspec failed (-110)
   [Tue Apr 27 17:36:55 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:55 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:55 2021] brcmfmac: brcmf_cfg80211_get_tx_power: error (-110)
   [Tue Apr 27 17:36:58 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:36:58 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:36:58 2021] brcmfmac: _brcmf_set_multicast_list: Setting BRCMF_C_SET_PROMISC failed, -110
   [Tue Apr 27 17:37:00 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:00 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:03 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:03 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:05 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:05 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:08 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:08 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:08 2021] brcmfmac: _brcmf_set_multicast_list: Setting mcast_list failed, -110
   [Tue Apr 27 17:37:11 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:11 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:13 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:13 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:13 2021] brcmfmac: _brcmf_set_multicast_list: Setting allmulti failed, -110
   [Tue Apr 27 17:37:16 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:16 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:16 2021] brcmfmac: _brcmf_set_multicast_list: Setting BRCMF_C_SET_PROMISC failed, -110
   [Tue Apr 27 17:37:18 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:18 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:21 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:21 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:23 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:23 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:26 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:26 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:28 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:28 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:31 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:31 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:31 2021] brcmfmac: _brcmf_set_multicast_list: Setting mcast_list failed, -110
   [Tue Apr 27 17:37:34 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:34 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:34 2021] brcmfmac: _brcmf_set_multicast_list: Setting allmulti failed, -110
   [Tue Apr 27 17:37:36 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:36 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:39 2021] brcmfmac: brcmf_sdio_bus_rxctl: resumed on timeout
   [Tue Apr 27 17:37:39 2021] brcmfmac: brcmf_sdio_checkdied: firmware trap in dongle
   [Tue Apr 27 17:37:39 2021] brcmfmac: _brcmf_set_multicast_list: Setting BRCMF_C_SET_PROMISC failed, -110
   [Tue Apr 27 17:37:44 2021] brcmfmac: brcmf_netdev_set_mac_address: Setting cur_etheraddr failed, -110
   [Tue Apr 27 17:37:49 2021] brcmfmac: brcmf_proto_bcdc_query_dcmd: brcmf_proto_bcdc_msg failed w/status -110
   [Tue Apr 27 17:37:49 2021] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
   [Tue Apr 27 17:37:49 2021] brcmfmac: brcmf_cfg80211_set_power_mgmt: power save disabled
   [Tue Apr 27 17:37:52 2021] brcmfmac: brcmf_cfg80211_set_power_mgmt: error (-110)
   [Tue Apr 27 17:37:57 2021] brcmfmac: _brcmf_set_multicast_list: Setting mcast_list failed, -110
   [Tue Apr 27 17:37:59 2021] brcmfmac: brcmf_vif_set_mgmt_ie: vndr ie set error : -110
   [Tue Apr 27 17:37:59 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)
   [Tue Apr 27 17:38:02 2021] brcmfmac: _brcmf_set_multicast_list: Setting allmulti failed, -110
   [Tue Apr 27 17:38:04 2021] brcmfmac: brcmf_run_escan: error (-110)
   [Tue Apr 27 17:38:04 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)
   [Tue Apr 27 17:38:07 2021] brcmfmac: _brcmf_set_multicast_list: Setting BRCMF_C_SET_PROMISC failed, -110
   [Tue Apr 27 17:38:09 2021] brcmfmac: brcmf_run_escan: error (-110)
   [Tue Apr 27 17:38:09 2021] brcmfmac: brcmf_cfg80211_scan: scan error (-110)

参考
======

- `Pi 3 as wiireless client and wireless AP? <https://www.raspberrypi.org/forums/viewtopic.php?p=938306#p938306>`_ 
- `Raspberry Pi Zero W as Internet connected Access Point *and* Wireless Client <https://gist.github.com/tcg/0c1d32770fcf6a0acf448b7358c5d059>`_ 提供了完整的配置文件可以参考，并且介绍了 `lukicdarkoo/rpi-wifi <https://github.com/lukicdarkoo/rpi-wifi>`_ 设置脚本，以及完整的设置方法参考文档:

  - `Raspberry Pi Zero W Simultaneous AP and Managed Mode Wifi <https://blog.thewalr.us/2017/09/26/raspberry-pi-zero-w-simultaneous-ap-and-managed-mode-wifi/>`_ 这篇文档是最完善的
