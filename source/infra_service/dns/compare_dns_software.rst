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



参考
======

- `Wikipedia - Comparison of DNS server software <https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software>`_
- `Bind vs dnsmasq vs PowerDNS vs Unbound <https://computingforgeeks.com/bind-vs-dnsmasq-vs-powerdns-vs-unbound/>`_
