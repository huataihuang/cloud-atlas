.. _squid_ssl_bumping:

=====================
Squid SSL拦截
=====================

企业级应用
===========

著名的安全公司 `卡巴斯基 <https://www.kaspersky.com>`_ 有一款集成了 :ref:`haproxy` (七层负载均衡) 和 :ref:`squid` (正向代理)的WEB流量安全产品，实现企业级的安全:

- Kaspersky Web Traffic Security 会扫描通过代理服务器的用户 HTTP、 HTTPS 和 FTP 流量
- :ref:`haproxy` 实现复杂的内网向外流量分发负载均衡到 :ref:`squid` ，由 ``Squid`` 实现集成企业认证、杀毒、跟踪分析、缓存等代理服务，实现公司级WEB/邮件等安全控制

  - 由于企业会在公司设备上安装企业证书，所以 :ref:`squid_ssl_bumping` 可以实现HTTPS明文过滤

- `Kaspersky Web Traffic Security帮助: 在 Squid 服务中配置 SSL Bumping <https://support.kaspersky.com/KWTS/6.1/zh-Hans/166244.htm>`_ 可以了解 :ref:`squid_ssl_bumping` 为企业内部控制用户上网行为提供了技术基础

参考
=======

- `Intercept HTTPS CONNECT messages with SSL-Bump <https://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpExplicit>`_ Squid官方文档，非常详尽的配置
- `Squid使用SSLBump正向代理 <https://www.jianshu.com/p/71c43aa7438f>`_ 提供了一个解决访问https网站证书修正的思路，原文参考了 `Squid (v3.5+) proxy with SSL Bump <https://www.smoothnet.org/squid-v3-5-proxy-with-ssl-bump/>`_ 提供了不少借鉴思路
- `Kaspersky Web Traffic Security帮助: 在 Squid 服务中配置 SSL Bumping <https://support.kaspersky.com/KWTS/6.1/zh-Hans/166244.htm>`_
