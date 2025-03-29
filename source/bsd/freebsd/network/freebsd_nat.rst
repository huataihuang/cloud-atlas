.. _freebsd_nat:

================
FreeBSD NAT
================

.. note::

   这里是一个简单的NAT共享网络上网配置，有待进一步完善。

说明:

- ``wifibox0`` 是外网接口，见 :ref:`freebsd_wifi_bcm43602`
- ``ue0`` 是内网接口，连接内部局域网
- 目标是将 ``ue0`` 连接的内部网络通过NAT连接访问外网

设置pf防火墙规则
=================

- ``/etc/pf.conf``

.. literalinclude:: freebsd_nat/pf.conf
   :caption: 设置NAT的 ``/etc/pf.conf``
   :emphasize-lines: 10

- 激活IP转发:

.. literalinclude:: freebsd_nat/ip_forwarding
   :caption: 激活IP forwarding



参考
======

- `Basic NAT config with FreeBSD <https://github.com/network-computer/NAT>`_
