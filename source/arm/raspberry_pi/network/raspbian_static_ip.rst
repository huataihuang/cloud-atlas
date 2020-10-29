.. _raspbian_static_ip:

===================
Raspbian配置静态IP
===================

.. note::

   Raspberry Pi官方提供的Raspbian系统是基于Debian的定制系统，在配置网络上和常用的Ubuntu有一些差异，使用了dhcpcd服务来管理网络。

Raspberry Pi使用 ``dhcpcd`` 配置所有网络接口的TCP/IP。这个 dhcpcd服务是倾向于配置all-in-one ZeroConf客户端，功能包括设置每个接口的IP地址，设置网络掩码，配置基于Name Service Switch(NSS)机制的DNS解析。

默认情况下，Raspberry Pi OS尝试通过DHCP配置所有的网络接口，当DHCP失败时则回退到自动分配 169.254.0.0/16 的私有地址。这个特性和其他Linux发行版及Windows类似。

静态IP地址
==========

如果需要禁用接口自动配置采用静态IP，则配置 ``/etc/dhcpcd.conf`` ::

   interface eth0
   static ip_address=192.168.6.110/24
   static routers=192.168.6.9
   static domain_name_servers=202.96.209.133 202.96.209.5

.. note::

   这里采用的DNS服务器是上海电信DNS解析服务器，如果你在墙外没有阻碍的话，建议使用Google提供的DNS服务器 ``8.8.8.8``

早期的Raspberry Pi系统使用 ``/etc/network/interfaces`` 来配置网络接口：如果在该配置文件中存在一个接口，就会覆盖 ``/etc/dhcpcd.conf`` 的配置。

如果在Raspberry Pi系统中使用图形桌面，则有一个 ``lxplug-network`` 提供修改 ``dhcpcd`` 的功能，也包括设置静态IP地址。这个 ``lxplug-network`` 工具基于 ``dhcpcd-ui`` 。

参考
=========

- `Raspberry TCP/IP networking <https://www.raspberrypi.org/documentation/configuration/tcpip/>`_
- `How to set a Raspberry Pi with a static ip address? <https://www.ionos.com/digitalguide/server/configuration/provide-raspberry-pi-with-a-static-ip-address/>`_
