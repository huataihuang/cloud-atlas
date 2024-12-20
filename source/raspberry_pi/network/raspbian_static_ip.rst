.. _raspbian_static_ip:

===================
Raspbian配置静态IP
===================

.. warning::

   ``raspi-config`` 只提供了无线配置，没有提供有线网络配置。有线网络配置可以通过 ``nmtui`` 交互工具来完成配置。

   2024年10月我的实践发现默认系统没有使用 ``dhcpcd`` ，也就导致本文经验无法使用。不过，使用 ``nmtui`` 交互可以非常容易配置。待我后续再仔细研究一下底层实现原理。

   但是， :ref:`archlinux_wpa_supplicant` 是采用 ``dhcpcd`` 分配IP地址的，所以可以使用本文方法为 :ref:`arch_linux` 的无线网络分配静态地址

.. _dhcpcd_static_ip:

dhcpcd分配静态IP
===================

.. note::

   Raspberry Pi官方提供的Raspbian系统是基于Debian的定制系统，在配置网络上和常用的Ubuntu有一些差异，使用了dhcpcd服务来管理网络。

Raspberry Pi使用 :ref:`dhcpcd` 配置所有网络接口的TCP/IP。这个 dhcpcd服务是倾向于配置all-in-one ZeroConf客户端，功能包括设置每个接口的IP地址，设置网络掩码，配置基于Name Service Switch(NSS)机制的DNS解析。

默认情况下，Raspberry Pi OS尝试通过DHCP配置所有的网络接口，当DHCP失败时则回退到自动分配 169.254.0.0/16 的私有地址。这个特性和其他Linux发行版及Windows类似。

.. note::

   实际上，很多发行版都使用 :ref:`dhcpcd` 来为网络接口动态分配IP，特別是无线网络 :ref:`wpa_supplicant` 认证完成后，就会通过 :ref:`dhcpcd` 来完成IP地址分配。如果你需要静态分配IP地址(例如本文)，或者部分设置为静态配置(例如 :ref:`dhcpcd_set_static_dns` )

.. _dhcpcd_lan_static_ip:

dhcpcd有线网络静态IP地址
--------------------------

如果需要禁用接口自动配置采用静态IP，则配置 ``/etc/dhcpcd.conf`` :

.. literalinclude:: raspbian_static_ip/lan_dhcpcd.conf
   :caption: 有线网络使用dhcpcd分配静态IP地址

.. note::

   这里采用的DNS服务器是上海电信DNS解析服务器，如果你在墙外没有阻碍的话，建议使用Google提供的DNS服务器 ``8.8.8.8``

早期的Raspberry Pi系统使用 ``/etc/network/interfaces`` 来配置网络接口：如果在该配置文件中存在一个接口，就会覆盖 ``/etc/dhcpcd.conf`` 的配置。

如果在Raspberry Pi系统中使用图形桌面，则有一个 ``lxplug-network`` 提供修改 ``dhcpcd`` 的功能，也包括设置静态IP地址。这个 ``lxplug-network`` 工具基于 ``dhcpcd-ui`` 。

.. _dhcpcd_wlan_static_ip:

dhcpcd无线网络静态IP地址
---------------------------

在 :ref:`archlinux_wpa_supplicant` 配置中，修改 ``/etc/dhcpcd.conf`` 配置文件添加如下内容可以为无线网络分配静态IP地址:

.. literalinclude:: raspbian_static_ip/wlan_dhcpcd.conf
   :caption: 无线网络使用dhcpcd分配静态IP地址


参考
=========

- `Raspberry TCP/IP networking <https://www.raspberrypi.org/documentation/configuration/tcpip/>`_
- `How to set a Raspberry Pi with a static ip address? <https://www.ionos.com/digitalguide/server/configuration/provide-raspberry-pi-with-a-static-ip-address/>`_
