.. _introduce_squid:

===========
Squid简介
===========

Squid是一个用于Web的缓存代理服务器，支持HTTP, HTTPS, FTP等协议。通过使用缓存代理缓存和重用经常访问的web页面，可以节约带宽和提高服务响应。Squid具有极强的访问控制以及网络加速能力。Squid提供了多种操作系统版本，并使用GPL协议发布。

.. note::

   使用Squid的著名用户可能是Wiki百科，从 :ref:`wikipedia_early_infra` 可以了解到Wikimedia采用了大量的Squid服务器结合memcached和LVS来构建支持全球最大网站。

.. figure:: ../../../_static/web/proxy/squid/squid_log.jpg
   :scale: 75

Squid完全支持HTTP/1.0 proxy并且几乎完全支持HTTP/1.1 proxy。提供了多功能的访问控制，认证和日志功能，实现了web代理和内容服务应用。Squid提供了丰富的流量优化选项，并且大多数选项默认激活以便安装和提供高性能。

Squid历史
==========

Squid基于1990年代开发的Harvest Cache Daemon，是从当时的Harvest项目的两个分支之一(另一个分支是Netapp公司的Netcache)。Squid是有NSF捐赠资助的项目，该项目涉及缓存技术研究。

Squid项目由NSF捐赠(NCR-9796082)涉及缓存技术研究。 `ircache <http://www.ircache.net/>`_ 基金运行了一些年，之后Squid项目持续志愿投入并有少量商业投入。

Squid当前由一些独立开发者投入并且构建当前及下一代内容缓存和分发技术。不断有公司使用Squid来节约网络访问流量并提高性能，以及更快分发他们的客户端程序以及提供稳定、动态和流媒体内容给因特网。很多用户把Squid结合到家用和办公室使用的防火墙设备，以及大型web代理服务加速带宽。

参考
=======

- `Squid: Optimising Web Delivery <http://www.squid-cache.org/>`_
