.. _dnsmasq_dhcp_pac:

============================================================
DNSmasq DHCP配置提供PAC(auto-proxy-config)下载
============================================================

为了能够在 :ref:`priv_cloud_infra` 更方便使用 :ref:`priv_dnsmasq_ics` ，我尝试实现 :ref:`squid_transparent_proxy` 以方便接入无线局域网的客户端能够自由访问因特网。

不过，实践发现 :ref:`squid_transparent_proxy` 需要实现复杂的 SslBump ，看似透明无需客户端配置网络代理，但是为了解决HTTPS自签名证书，需要将自签名证书导入客户端。所以，我反过来寻求能够通过DHCP自动分发代理配置给客户端。

Web Proxy Auto-Discovery (WPAD) 协议
=======================================



参考
=======

- `wikipedia: Web Proxy Auto-Discovery Protocol <https://en.wikipedia.org/wiki/Web_Proxy_Auto-Discovery_Protocol>`_
- `wikipedia: Proxy auto-config <https://en.wikipedia.org/wiki/Proxy_auto-config>`_
- `OpenWrt: automatic proxy config with dnsmasq <https://forum.archive.openwrt.org/viewtopic.php?id=49005>`_
- `Gentoo wiki: ProxyAutoConfig <https://wiki.gentoo.org/wiki/ProxyAutoConfig>`_
