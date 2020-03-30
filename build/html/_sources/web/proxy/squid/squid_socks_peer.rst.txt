.. _squid_socks_peer:

===================
Squid父级socks代理
===================

在局域网部署的Squid代理服务器，在没有配置上一级转发代理之前，其实和局域网中其他电脑能够访问的网站是完全一样的。需要给Squid服务器配置一个父级代理，父级代理是能够翻墙的代理服务器，这样局域网部署的Squid就具备了翻墙的功能。

.. note::

   之所以没有直接把Squid代理服务器配置成直接能够访问外网的服务器原因主要有2个：

   * 在Squid服务器上直接使用 :ref:`openconnect_vpn` 会导致该服务器网络断开，目前我还没有找到解决的方法。
   * 我希望在Squid上实现 :ref:`pac` 以便仅仅做部分被墙掉的网站流量走加密代理
     * 公司内部有专线提供了部分被墙网站的访问，但是有些必要网站依然需要梯子

Squid提供了 ``cache_peer`` 配置parent proxies来请求内容，并且可以控制哪些内容可以直接获取或者间接使用 ``always_direct`` 或 ``never_direct`` 。

举例::

   cache_peer proxy.some-isp.com parent 8080 0 no-query no-digest
   never_direct allow all

上述配置中设置 squid 使用父级proxy ``proxy.some-isp.com:8080``

Squid也支持 ``round-robin`` 方式访问多个parent proxy::

   cache_peer proxy.isp1.com parent 8080 round-robin no-query
   cache_peer proxy.isp2.com parent 8080 round-robin no-query
   cache_peer proxy.isp3.com parent 8080 round-robin no-query



参考
=======

- `Using a parent proxy with Squid <https://www.christianschenk.org/blog/using-a-parent-proxy-with-squid/>`_
- `squid-cache wiki - Feature: Linking Squid into a Cache Hierarchy <https://wiki.squid-cache.org/Features/CacheHierarchy>`_
- `Squid configuration directive cache_peer <http://www.squid-cache.org/Doc/config/cache_peer/>`_`
