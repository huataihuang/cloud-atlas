.. _freebsd_static_ip:

==================
FreeBSD静态IP设置
==================

.. note::

   也可以参考 :ref:`freebsd_static_ip_startup`

:ref:`freebsd_on_intel_mac` ，由于初始FreeBSD无法识别无线网卡，所以采用 :ref:`iptables_masquerade` 结合本文静态IP配置，先让FreeBSD能够连接Internet进行更新，并进一步配置 :ref:`freebsd_wifi` 。

- 检查主机网络::

   ifconfig -a

此时只能看到回环地址::

   lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
   	options=680003<RXCSUM,TXCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
   	inet6 ::1 prefixlen 128
   	inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1
   	inet 127.0.0.1 netmask 0xff000000
   	groups: lo
   	nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>

- 插入 Belkin 以太网卡，非常好直接识别::

   ugen0.3: <Belkin Belkin USB-C LAN> at usbus0
   ure0 on uhub0
   ure0: <Belkin Belkin USB-C LAN, class 0/0, rev 3.00/30.00, addr 7> on usbus0
   miibus0: <MII bus> on ure0
   rgephy0: <RTL8251/8153 1000BASE-T media interface> PHY 0 on miibus0
   rgephy0:  none, 10baseT, 10baseT-FDX, 100baseTX, 100baseTX-FDX, 1000baseT-FDX, 1000baseT-FDX-master, auto
   ue0: <USB Ethernet> on ure0
   ue0: Ethernet address: 58:ef:68:e2:90:8f

此时检查 ``ifconfig -a`` 可以看到 ``ue0`` 

- FreeBSD将主机名和静态IP地址配置存放在 ``/etc/rc.conf`` 中，以下是配置实例:

.. literalinclude:: freebsd_static_ip/rc.conf
   :language: bash
   :caption: /etc/rc.conf 配置了FreeBSD启动服务以及静态IP
   :emphasize-lines: 14-16

.. note::

   根据识别的网卡名 ``ue0`` 配置 ``/etc/rc.conf``

- 重启服务:

.. literalinclude:: freebsd_static_ip/service_netif_routing_restart
   :language: bash
   :caption: 重启 netif 和 routing 服务以使 /etc/rc.conf 中静态IP和路由生效

- 然后验证IP地址，以及使用 :ref:`iptables_masquerade` 环境是否能够访问internet

- 再配置 ``/etc/resolv.conf`` DNS(这里设置为局域网的DNS):

.. literalinclude:: freebsd_static_ip/resolv.conf
   :language: bash
   :caption: /etc/resolv.conf配置DNS

参考
======

- `How to configure static IP Address on FreeBSD <https://www.cyberciti.biz/faq/how-to-configure-static-ip-address-on-freebsd/>`_
- `Set hostname & Static IP address on FreeBSD 12/13 <https://computingforgeeks.com/how-to-set-hostname-static-ip-address-on-freebsd/>`_
