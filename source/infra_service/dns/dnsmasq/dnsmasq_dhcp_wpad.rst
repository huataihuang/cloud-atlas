.. _dnsmasq_dhcp_wpad:

======================================
DNSmasq部署DHCP WPAD(WEB代理自动发现)
======================================

.. note::

   目前通用的 :ref:`wpad_protocol` 部署方式是采用DNS方式，该方式得到所有主流浏览器的支持。不过，也可以使用传统的 DHCP option 方式提供 ``WPAD`` 配置，指定客户端下载对应的 ``wpad`` 配置文件( ``PAC`` 文件 )


:ref:`wpad_protocol` 实现中，DHCP配置优先级高于DNS，所以配置了本文支持 ``WPAD`` 的DNSmasq之后，可以不用 :ref:`dnsmasq_dns_wpad` 。

DNSmasq配置DHCP
=================

- 配置 ``/etc/dnsmasq.d/dhcp.conf`` 如下::

   dhcp-option=252,http://wpad.staging.huatai.me/wpad.dat 

- 重启dnsmasq::

   sudo systemctl restart dnsmasq

配置nginx
=============

- :ref:`nginx_wpad` 提供 ``WPAD`` 配置文件下载

参考
=======

- `Web Proxy Auto-detection Configuration <https://documentation.clearos.com/content:en_us:kb_o_web_proxy_auto-detection_configuration>`_
