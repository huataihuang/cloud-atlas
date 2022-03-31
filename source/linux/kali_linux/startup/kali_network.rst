.. _kali_network:

===================
Kali Linux网络配置
===================

现在主流Linux发行版通常在服务器版本上(字符界面)采用 :ref:`netplan` 配置网络，而在桌面版本上采用 :ref:`networkmanager` 配置网络。在Kali Linux(图形桌面)中默认使用了 :ref:`networkmanager` 管理网络，所以我也采用NetworkManager完成网络配置。

有线网络静态IP
================

比较简单的配置静态网络方法在 :ref:`kali_static_ip` 已经介绍，这里我重新采用NetworkManager配置静态IP地址

- 检查连接::

   nmcli

显示输出::

   wlan0: disconnected
        "Broadcom BCM43438 combo and Bluetooth Low Energy"
        wifi (brcmfmac), DC:A6:32:FC:9E:27, hw, mtu 1500

   eth0: unmanaged
        "eth0"
        ethernet (bcmgenet), DC:A6:32:FC:9E:26, hw, mtu 1500

- 配置静态IP地址::

   nmcli con add con-name "static-eth0" ifname eth0 type ethernet ip4 192.168.6.7/24 gw4 192.168.6.200
   nmcli con mod "static-eth0" ipv4.dns "xxx.xxx.120.1,8.8.8.8"
   nmcli con up id "static-eth0"

- 重启系统后就可以看到::

   ip addr

显示输出::

   ...
   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
       link/ether dc:a6:32:fc:9e:26 brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.7/24 brd 192.168.6.255 scope global noprefixroute eth0
          valid_lft forever preferred_lft forever
       inet6 fe80::22d4:6938:ecc6:76af/64 scope link noprefixroute
          valid_lft forever preferred_lft forever   
 
无线网络配置
==============

- 配置 ``/etc/default/crda`` 设置5GHz无线网络必须指定的国家编码(也可以在 ``wpa_supplicant.conf`` 配置中指定 ``country=CN`` ) ( :ref:`_wifi_5ghz_country_code` )::

   REGDOMAIN=CN

使用 :ref:`networkmanager` :ref:`nmcli_wifi`

- 检查无线网络AP::

   sudo nmcli device wifi list

- 增加连接到 ``home`` 热点的网络连接:

.. literalinclude:: ../../../linux/ubuntu_linux/network/networkmanager/nmcli_wifi_wpa-psk
   :language: bash
   :caption: nmcli添加wpa-psk认证wifi

- 连接 ``home`` 热点::

   nmcli con up home

- 增加连接到 ``office`` 热点的网络连接:

.. literalinclude:: ../../../linux/ubuntu_linux/network/networkmanager/nmcli_wifi_wpa-eap
   :language: bash
   :caption: nmcli添加wpa-eap认证(802.1x)wifi

- 连接 ``office`` 热点::

   nmcli con up office

.. note::

   详细配置参考 :ref:`networkmanager` 和 :ref:`ubuntu_on_mbp`
   
参考
=====

- `How to stop MAC address from changing after disconnecting? <https://unix.stackexchange.com/questions/395059/how-to-stop-mac-address-from-changing-after-disconnecting>`_
- `Assigning static IP address using nmcli <https://unix.stackexchange.com/questions/290938/assigning-static-ip-address-using-nmcli>`_
