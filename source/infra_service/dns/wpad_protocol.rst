.. _wpad_protocol:

============================================================
Web代理自动发现(Web Proxy Auto-Discovery,WPAD)协议
============================================================

为了能够在 :ref:`priv_cloud_infra` 更方便使用 :ref:`priv_dnsmasq_ics` ，我尝试实现 :ref:`squid_transparent_proxy` 以方便接入无线局域网的客户端能够自由访问因特网。

不过，实践发现 :ref:`squid_transparent_proxy` 需要实现复杂的 SslBump ，看似透明无需客户端配置网络代理，但是为了解决HTTPS自签名证书，需要将自签名证书导入客户端。所以，我反过来寻求能够通过DHCP/DNS( :ref:`dnsmasq` )自动分发代理配置给客户端。

Web Proxy Auto-Discovery (WPAD) 协议
=======================================

Web代理自动发现(Web Proxy Auto-Discovery, WPAD)协议是一种客户端段通过DHCP或DNS发现定位配置文件的URL的方式。一旦检测并下载好配置文件，客户端就能够通过一个特定URL执行检查代理。

WPAD协议是一个发现定位文件机制的大纲，但是最常用的部署配置文件格式是 ``proxy auto-config`` 格式，也就是最早在Netscape Navigator 2.0(远古时期浏览器，Firefox的前身)设计的 ``PAC`` 文件。虽然WPAD是一个已经在1999年12月过期的internet草案，但是依然被所有主要浏览器支持。

WPAD标准定义了两种可以让系统管理员推送proxy配置文件的定位方法，也就是使用DHCP或者DNS:

- 在获取首个页面之前，浏览器首先发送一个 ``DHCPINFORM`` 查询给DHCP服务器，并使用服务器回应中的 ``WPAD`` 选项中的URL
- 如果DHCO服务器没有提供需要的信息，则使用DNS。举例，如果用户的计算机名字是 ``laptop01.us.division.company.com`` ，则浏览器会尝试使用以下URL来找到为这个客户端提供域名的代理配置:

  - http://wpad.us.division.company.com/wpad.dat
  - http://wpad.division.company.com/wpad.dat
  - http://wpad.company.com/wpad.dat
  - http://wpad.com/wpad.dat (现代DNS查询已经屏蔽过滤掉这个查询，避免有恶意注册 wpad.com 域名)

.. figure:: ../../_static/infra_service/dns/wpaddns_diagram.png
   :scale: 50

另外，对于Windows平台，如果DNS查询不成功，还会使用 Link-Local Multicast Name Resolution (LLMNR) 和/或 NetBIOS 。

注意：

- DHCP优先级高于DNS: 如果DHCP提供了WPAD URL，则不执行DNS查询。但是这仅适用于DHCPv4，因为在DHCPv6中没有定义WPAD选项
- Firefox不支持DHCP只使用DNS，此外对于非Windows平台和ChromeOS平台的Chrome也是这样
- 当构建查询数据包时，DNS查询首先移除自己FQDN域名的第一部分(也就是客户端主机名)，然后替代成 ``wpad`` ，然后依次移除FQDN域名的剩余部分，直到它找到 ``WPAD PAC`` 文件
- 对于DNS查询，配置文件的名字始终是 ``wpad.dat`` ，而对于DHCP协议，则可以使用任何URL。由于历史原因， ``PAC`` 文件通常被命名为 ``proxy.pac``
- 配置文件的 ``MIME类型`` 必须是 ``application/x-ns-proxy-autoconfig``
- 目前只有Internet Explorer 和 ``Konqueror`` (KDE桌面的浏览器) 实现了同时支持DHCP和DNS方式

运行要求
=========

要使得WPAD工作，需要满足以下要求:

- 要使用DHCP，服务器必须配置提供 ``site-local`` 选项 ``252`` ( ``auto-proxy-config`` )配置，例如 ``http://example.com/wpad.dat`` ，这里的 ``example.com`` 是一个WEB服务器地址
- 如果使用DNS作为唯一方式，则这个DNS项必须是命名为 ``WPAD`` 的主机名
- 使用WPAD地址的主机必须提供WEB页面服务
- WEB服务器必须配置能够服务于使用 ``application/x-ns-proxy-autoconfig`` MIME类型的 WPAD 文件
- 如果使用DNS方式，则 ``wpad.dat`` 必须位于 WPAD网站的根目录下
- 如果使用Windows Server 2003或者之后版本的Windows服务器作为DNS服务器，可能需要禁止 ``DNS Server Global Query Block List``

安全性
=======

虽然WPAD协议提供了非常简单的配置浏览器功能，但是需要非常小心使用WPAD，一个简单的错误可能导致攻击隐患:

- 内网的攻击者可以设置DHCP来提供一个伪造的PAC脚本
- 由于WPAD的DNS查询会依次递减域名查询，这就带来，有可能较短域名是公司外部的公开域名: 例如 http://wpad.company.co.uk/wpad.dat 如果没有提供，则会访问 http://wpad.co.uk/wpad.dat ，但是有可能 ``wpad.co.uk`` 实际上是Internet公网上的服务器，而浏览器可能不会检测到已经访问了公司外部地址
- ISP可能会部署 DNS hijacking 来阻断WPAD协议的DNS查询
- WPAD查询泄漏可能导致内部网络命名规则碰撞，黑客可能会注册域名来响应泄漏的WPAD查询并配置一个有效代理，这回导致潜在的中间人攻击

实践
======



参考
=======

- `wikipedia: Web Proxy Auto-Discovery Protocol <https://en.wikipedia.org/wiki/Web_Proxy_Auto-Discovery_Protocol>`_
- `Introduction to WPAD <http://findproxyforurl.com/wpad-introduction/>`_
- `wikipedia: Proxy auto-config <https://en.wikipedia.org/wiki/Proxy_auto-config>`_
- `Web Proxy Auto-detection Configuration <https://documentation.clearos.com/content:en_us:kb_o_web_proxy_auto-detection_configuration>`_
- `OpenWrt: automatic proxy config with dnsmasq <https://forum.archive.openwrt.org/viewtopic.php?id=49005>`_
- `Gentoo wiki: ProxyAutoConfig <https://wiki.gentoo.org/wiki/ProxyAutoConfig>`_
