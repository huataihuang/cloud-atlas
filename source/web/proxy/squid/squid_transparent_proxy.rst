.. _squid_transparent_proxy:

==========================
Squid透明代理
==========================

我在 :ref:`priv_cloud_infra` 中使用 :ref:`apple_airport` 结合 :ref:`priv_dnsmasq_ics` 实现了局域网内部无线客户端能够共享上网。同时，为了解决带宽资源，同时方便内部服务器快速安装和更新软件，在 ``zcloud`` 主机上部署了 :ref:`squid` 作为代理。进一步，通过 :ref:`apt_proxy_arch` 解决了访问Google等 :ref:`kubernetes` 软件仓库更新软件问题。

不过，对于普通用户而言，例如手机客户端，连接到WiFi上，虽然通过 :ref:`iptables_ics` 确实能够上网。但是，受阻于GFW，无法自由访问信息。配置手机客户端的代理也非常麻烦，切换网络还要切换代理。所以，更好的解决方法是使用 ``透明代理`` ，也就是让所有客户端外出访问能够自动经过代理服务器，这样只需要在代理服务器上实现 ``翻墙`` 就能够解决用户的 ``痛点`` 。

透明代理的原理其实非常简单，就是在网关的内网接口上启用 ``iptables`` 的转发，将访问WEB端口重定向到 ``squid`` 的代理端口上；此时还需要激活 ``squid`` 的 ``intercept`` (拦截) 功能，这样就能实现对客户端无感的透明代理。

透明代理配置
===============

- 修订 ``/etc/squid/squid.conf`` 配置，添加一个 ``intercept`` 配置行，注意，需要有两个代理端口，一个是传统的 ``forward proxy`` 一个是 ``intercept`` ::

   http_port 8080
   http_port 3128 intercep

- 修订 :ref:`priv_dnsmasq_ics` 中的 ``ics.sh`` (配置MASQUERADE)脚本，添加::

   # squid transparent proxy
   sudo iptables -t nat -A PREROUTING -i br0 -p tcp --dport 80 -j DNAT --to 192.168.6.200:3128
   sudo iptables -t nat -A PREROUTING -i br0:1 -p tcp --dport 80 -j DNAT --to 192.168.6.200:3128
   sudo iptables -t nat -A PREROUTING -i eno4 -p tcp --dport 80 -j REDIRECT --to-port 3128

完整脚本参考 :ref:`priv_dnsmasq_ics` 中的 ``ics.sh``

No forward-proxy ports
==========================

注意，在 ``squid.conf`` 配置中如果只配置一行::

   http_port 3128 intercept

来代替原先默认的::

   http_port 3128

就会出现 ``squid`` 无法启动问题。此时检查 ``systemctl status squid`` 会看到如下报错::

   ...
   ERROR: No forward-proxy ports configured.

这个报错原因实际上是因为 ``squid`` 在配置 ``intercept`` 模式端口同时还需要保留一个 ``forward proxy`` 端口，也就是不惜类似如下配置::

   http_port 8080
   http_port 3128 intercept

即使实际上不使用 ``forward proxy`` 也需要配置一行 ``http_port 8080`` (其他端口也可以)

参考
======

- `Squid Transparent proxy server : How to configure <https://linuxtechlab.com/squid-transparent-proxy-server-complete-configuration/>`_
- `squid-cache wiki: No forward-proxy ports <https://wiki.squid-cache.org/KnowledgeBase/NoForwardProxyPorts>`_
