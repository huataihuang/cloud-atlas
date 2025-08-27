.. _lets_encrypt_challenge:

================================
Let's Encrypt 验证(challenge)
================================

当需要从Let's Encrypt获取证书，Let's Encrypt的服务器会检查你是否使用 **ACME标准定义的验证方式** ``证明你对证书中的域名控制权`` 。虽然这个验证是由ACME客户端自动完成(例如 ``certbot`` )，但是由于网络环境的限制，实际上需要做一些复杂的配置决策，也就是需要了解本文所整理的 Let's Encrypt 验证(challenge) 不同方案的原理和差异。

.. note::

   由于大陆对80端口有"备案"要求，所以阿里云默认会重定向80端口到一个要求备案到页面。这会导致默认的 Let's Encrypt ``certbot`` **HTTP-01 challenge** 无法完成。

   根据 `certbot FAQ: Can I issue a certificate if my webserver doesn't listen on port 80? <https://certbot.eff.org/faq#can-i-issue-certificate-if-my-webserver-doesn-t-listen-on-port-80>`_ 可以使用 ``DNS-01`` 或 ``TLS-ALPN-01`` challenge来避免使用被防火墙阻塞到80端口。不过， ``certbot`` 不支持 TLS-ALPN-01 challenge，所以如果继续使用 ``certbot`` ，则需使用 **DNS-01 challenge**

.. warning::

   实践中我发现阿里云的"要求备案"页面劫持慢于WEB服务器的重定向: 也就是说，实际上可以配置强制转跳HTTPS，此时阿里云不会阻断HTTPS访问。只需要第一次使用 :ref:`self_signed_ssl_nginx` 能够加密https访问，Let's Encrypt **HTTP-01 验证** 是允许重定向到HTTPS 443端口来验证Token的，也就避开了"备案"这个奇葩的要求。

   不过，我希望配置 :ref:`lets_encrypt_wildcard_certificates` ，该方案不能使用 HTTP-01 验证 。这个思路仅供参考!

.. _http-01_challenge:

HTTP-01 验证
===============

``HTTP-01 验证`` 是最常见的验证方式: Let's Encrypt向ACME客户端提供一个令牌，而ACME客户端会在Web服务器的 ``http://<你的域名>/.well-known/acme-challenge/<TOKEN>`` （用提供的令牌替换 <TOKEN>）路径上放置指定文件。

该文件包含令牌以及帐户密钥的指纹。 一旦 ACME 客户端告诉 Let’s Encrypt 文件已准备就绪，Let’s Encrypt 会尝试获取它。

只有Let's Encrypt验证机制在你的Web服务器正确位置获得了正确文件，才能通过验证并继续申请颁发证书。

**HTTP-01 验证** 要点:

- Let's Encrypt HTTP-01 验证最多接收10次重定向(前面说过了要解决 大陆对80端口有"备案"要求)，并且只接受目标为 ``http:`` 或 ``https:`` 且端口为 ``80`` 或 ``443`` 的重定向，但不支持目标为IP地址的重定向。
- 当重定向到HTTPS链接时，Let's Encrypt不会验证证书是否有效(因为验证的目的是申请有效证书，所以它可能会遇到自签名或过期的证书)
- HTTP-01 验证只能使用 80 端口(这对于大陆"未备案"网站或者住宅ISP可能无法完成): 因为允许客户端指定任意端口会降低安全性，所以 ACME 标准已禁止此行为。
- **Let's Encrypt HTTP-01 验证方式不支持颁发通配符证书**
- 如果在负载均衡后面部署多个Web服务器，必须确保该token文件在所有服务器上都可用(也许需要使用 :ref:`nfs` 来存储共享文件)

.. _dns-01_challenge:

DNS-01 验证
===============

``DNS-01 验证`` 是通过在域名的TXT记录中放置特定值来证明用户控制域名的DNS系统:

- 配置比 HTTP-01 验证 困难些，但是可以在某些 HTTP-01 不可用的情况下工作
- **允许您颁发通配符证书** （ :ref:`lets_encrypt_wildcard_certificates` )
- 当在负载均衡后面部署多个web服务器时可以正常工作(无需在web服务器上同步分发文件)
- 即使是内部WEB服务器(没有公网连接)也可以通过DNS-01 验证其域名

注意风险和缺点:

- 由于需要使用DNS操作当API凭据，所以一定要确保DNS API凭据安全，绝对不能泄露
- 有可能DNS服务商无法提供API或DNS API无法提供有关更新时间的信息

**为降低风险，建议在独立的服务器上执行DNS验证，然后自动将证书复制到Web服务器上**

Let's Encrypt在查找用于DNS-01验证的TXT记录时遵循DNS标准，所以可以使用CNAME记录或NS记录将验证工作委派给其他DNS区域

需要注意大多数DNS服务商有一个"propagation time"(更新时间)，表示更新DNS记录到所有服务器上都可用所需的时间。这个时间很难测量，因为供应商通常使用"anycast"(任播)，也就是多个服务器使用相同的IP地址，并且根据位置，你所使用的ACME客户端和Let's Encrypt可能会与不同的服务器通信(并获得不同的应答)。所以最好DNS API提供了自动检查DNS更新是否完成的方法，如果DNS供应商没有提供这个方法，则需要将ACME客户端配置为等待足够长时间(通常多达一个小时)以确保在触发验证前更新已经完成。

TLS-ALPN-01验证
==================

``TLS-ALPN-01验证`` 通过443 端口上的 TLS 执行，使用自定义的 ALPN 协议来确保只有知道此验证类型的服务器才会响应验证请求。 这还允许对此质询类型的验证请求使用与要验证的域名匹配的SNI字段，从而使其更安全。

``TLS-ALPN-01验证`` 验证类型并不适合大多数人，最适合那些想要执行类似于 HTTP-01 的基于主机的验证，但希望它完全在 TLS 层进行以分离关注点的 TLS 反向代理的场景。目前这一群体主要是大型的网站托管服务商。

TLS-SNI-01验证
================

这种方式不够安全，因此已于 2019 年 3 月被废除。

.. note::

   请参考 `Let's encrypt社区提供的DNS供应商列表 <https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438>`_ 了解DNS服务商是否支持API操作

参考
======

- `Challenge Types <https://letsencrypt.org/docs/challenge-types/>`_ 中文文档 `验证方式 <https://letsencrypt.org/zh-cn/docs/challenge-types/>`_
