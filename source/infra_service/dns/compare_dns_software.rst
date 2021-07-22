.. _compare_dns_software:

==================
DNS软件比较
==================

在 `Wikipedia - Comparison of DNS server software <https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software>`_ 中列举了常见的DNF软件，其中有应用最广泛堪称互联网基石的 Bind，也有虚拟化环境紧密结合使用的 dnsmasq 。本文尝试综合对比一些常见的DNS服务器，以便后续在架构上部署DNS基础服务。

.. figure:: ../../_static/infra_service/dns/dns-lookup.png
   :scale: 40

BIND
========

BIND是Berkely Internet Name Domain，是自由开源软件，广泛应用在Linux服务器上提供域名和IP解析，提供了认证名字服务器用于特定域名，也提供递归DNS系统解析。

BIND提供的关键功能:

- 多视图(Multiple Views): 基于客户端的网络请求，Bind可以提供不同的信息。举例，可以对非本地局域网的客户端拒绝提供敏感的DNS解析，而对局域网内部客户端提供完整查询服务。
- 交易签名(Transaction SIGnatures, TSIG): 在主DNS服务器和备DNS服务器传输前首先使用共享的加密密钥进行加密。这个功能加强了原先仅仅依赖IP地址的安全措施。
- DNS安全扩展(DNS Security Extensions, DNSSEC): DNSSEC主要提供了DNS数据的认证和授权以及数据一致性。
- 支持IPv6
- 响应速率限制(Response Rate Limiting, RRL): 这个功能防范了DNS分布式拒绝服务攻击(DNS Distributed Denial of Service, DDoS)
- BIND可以作为权威名字服务器和递归名字服务器，支持NDS通知，也就是主DNS服务器可以通知从NDS有zone数据修改，触发同步

Dnsmasq
==========

Dnsmasq是一个轻量级DNS, TFTP, PXE 以及路由器公告和DHCP服务器。

参考
======

- `Wikipedia - Comparison of DNS server software <https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software>`_
- `Bind vs dnsmasq vs PowerDNS vs Unbound <https://computingforgeeks.com/bind-vs-dnsmasq-vs-powerdns-vs-unbound/>`_
