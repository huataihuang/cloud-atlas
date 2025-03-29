.. _switch_wifi_connect:

========================
切换WIFI连接
========================

如果有多个无线AP，有时候需要切换连接到不同AP上进行工作(例如临时切换到手机共享的热点上)。假设我们已经在 ``/etc/wpa_supplicant/wpa_supplicant.conf`` 中配置好了不同AP的连接配置(账号密码)，那么怎么按需切换到不同WIFI连接呢？

- 首先 :ref:`wpa_supplicant` ，确保 ``/etc/wpa_supplicant/wpa_supplicant.conf`` 包含了需要连接的不同WIFI的配置(密码)

- ``wpa_cli`` 提供了切换网络的功能::

   wpa_cli -i wlan0 list_networks

显示::

   network id / ssid / bssid / flags
   0       alibaba-inc     any
   1       Air     any     [DISABLED]
   2       CMCC-Xidu-5G    any     [CURRENT]
   3       pixel_1598      any     [DISABLED]

使用AP对应的数字来进行切换(第一列)，例如要切换到 ``pixel_1598`` 则执行::

   wpa_cli -i wlan0 select_network 3

.. note::

   切换到 ``pixel_1598`` ，但是反过来切换到 ``CMCC-Xidu-5G`` (5G WIFI)存在问题，未解决(虽然 ``wpa_supplicant.conf`` 已经配置了 ``country=CN`` )

- 此外 ``wpa_cli`` 提供了交互方式切换网络，通过调整不同wifi连接的优先级 ``priority`` 来交互切换，举例如下:

.. literalinclude:: switch_wifi_connect/wpa_cli_switch_wif
   :language: bash
   :caption: 通过调整wifi连接的优先级切换网络
   :emphasize-lines: 13,19,21,23,25,36

参考
=======

- `Switching to a different wireless network when it is available <https://raspberrypi.stackexchange.com/questions/81941/switching-to-a-different-wireless-network-when-it-is-available>`_
