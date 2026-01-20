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

- 最简单的PF规则 ``/etc/pf.conf``

.. literalinclude:: freebsd_nat/pf.conf
   :caption: 设置NAT的 **最简单** ``/etc/pf.conf``

或者更为复杂一些，效果相同

.. literalinclude:: freebsd_nat/pf_sample.conf
   :caption: 设置NAT的 ``/etc/pf.conf``

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
