.. _web:

=================================
Web Atlas
=================================

Web是Internet最主要的服务，也是汇集主要云计算技术的应用服务。我主要想探索的技术有：

* Web服务器：Nginx / Apache
* Web应用防火墙(WAF): ModSecurity / lua-resty-waf / NAXSI 
* 代理服务器
  * 正向代理： Squid
  * 反向代理： Varnish / Nginx
* 缓存系统： Memcached
* 负载均衡：
  * LVS
  * Nginx
* 数据库
  * MySQL集群

.. toctree::
   :maxdepth: 1

   nginx/index
   cache/index
   proxy/index
   load_balancer/index
   waf/index
   webdav/index
   websocket/index
   firefox/index

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
