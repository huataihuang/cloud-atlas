.. _freebsd_nat:

================
FreeBSD NAT
================

.. note::

   我使用 :ref:`thinkpad_x220` 为局域网内主机临时提供NAT网络转换，方便局域网主机联网更新系统

   - ``wlan0`` 是外网接口(无线网络)
   - ``em0`` 是内网接口，连接内部局域网

   本文以快速实践完成为主

内核转发
==========

- 开启内核转发功能，既允许数据包在不同网卡间流动:

.. literalinclude:: freebsd_nat/ip_forwarding
   :caption: 激活IP forwarding

设置pf防火墙规则
=================

针对pf网关直连网卡
---------------------

``pf`` 提供了一个非常简单的方法，能够直接将其连接局域网的网段IP地址NAT出去:

- 最简单的PF规则 ``/etc/pf.conf``

.. literalinclude:: freebsd_nat/pf.conf
   :caption: 设置NAT的 **最简单** ``/etc/pf.conf``

或者更为复杂一些，效果相同

.. literalinclude:: freebsd_nat/pf_sample.conf
   :caption: 设置NAT的 ``/etc/pf.conf``

.. note::

   ``localnet = $int_if:network`` 配置巧妙地将内网接口 ``em0`` 的 ``network`` 定义为本地局域网网段，也就是说，当 ``em0`` 配置了 ``192.168.6.100/24`` ，就会自动获得 ``192.168.6.0/24`` 网段作为 ``network`` 变量。此时上文配置的 ``localnet`` 就是 ``192.168.6.0/24`` 能够被NAT出internet

.. warning::

   上述通过pf主机的内网网卡接口获得的 ``network`` 网段只针对直接连接的局域网网段，如果有更多内网网段(如 ``192.168.7.0/24`` ，则因为不在范围内，NAT规则会直接跳过

扩大局域网网段NAT
--------------------

在企业内部，通常内网有很多网段。例如，我在homelab中，就分配了2个网段 ``192.168.6.0/24`` 和 ``192.168.7.0/24`` ，要通过pf实现NAT，需要使用 ``Table`` 来扩大来源的 ``nat`` 规则:

.. literalinclude:: freebsd_nat/pf.conf_table
   :caption: 使用Table扩大NAT内网网段
   :emphasize-lines: 6,8

此时 ``table <my_internal_nets>`` 能够非常灵活地定义多个内网网段，这样就能够为局域网多个网段提供NAT

启用PF使NAT生效
=====================

- 在 ``/etc/rc.conf`` 中启用PF:

.. literalinclude:: freebsd_nat/rc.conf
   :caption: 设置 ``/etc/rc.conf`` 启用PF

- 启动PF服务

.. literalinclude:: freebsd_nat/pf_start
   :caption: 启动

参考
======

- `OpenBSD PF - Network Address Translation <https://www.openbsd.org/faq/pf/nat.html>`_
- `Basic NAT config with FreeBSD <https://github.com/network-computer/NAT>`_
- Google Gemini
