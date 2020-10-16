.. _networkmanager:

================
NetworkManager
================

MAC Spoofing
===============

NetworkManager的Mac Spoofing是通过 ``ethernet.cloned-mac-address`` 和 ``wifi.cloned-mac-address`` 属性实现的，通过 ``nmcli`` 命令可以设置。

- 查看连接::

   nmcli con show

- 修改连接，添加 ``cloned-mac-address`` 属性::

   nmcli con modify <con_name> wifi.cloned-mac-address XX:XX:XX:XX:XX:XX

- 然后启动连接::

   nmcli con up <con_name>

一旦启动连接，就会看到无线网卡的MAC地址做了spoofing修改。

参考
=======

- `MAC Address Spoofing in NetworkManager 1.4.0 <https://blogs.gnome.org/thaller/2016/08/26/mac-address-spoofing-in-networkmanager-1-4-0/>`_
