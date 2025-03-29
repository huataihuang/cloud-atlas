.. _squid_ssl_bumping:

=====================
Squid SSL拦截
=====================

.. warning::

   HTTPS拦截需要注意道德和法律问题!!!

   在 `Intercept HTTPS CONNECT messages with SSL-Bump <https://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpExplicit>`_ Squid官方文档开头提供了警告和建议... 对于一些国家

HTTPS拦截是Squid-3.5开始提供的功能，需要注意 TLS 是一种安全协议，明确旨在是安全通讯成为可能，并且防止未经监测点第三方(例如 squid)拦截流量， 

**如果正确使用，TLS不能被拦截** ( ``when used properly TLS cannot be “bumped”.`` )

即使是错误使用TLS通常也会使得通行通道的至少一端检测到代理的存在。 ``Squid SSL-Bump`` 是有意以允许在不破坏TLS的的情况下进行检测的方式实现的。此时客户端是能够识别代理存在，所以如果寻求一种完全保密的方法，不应该使用squid。

使用原理
==========

在家庭和公司环境，客户端设备可以配置使用代理或者HTTPS消息使用 ``CONNECT`` 消息通过代理发送。要拦截这种 HTTPS 流量，需要向 Squid 提供 **自签名CA证书的公钥和私钥** ，而Squid则使用自签名CA证书的公钥和私钥为HTTPS域客户端访问生成服务器证书。此时，客户端设备需要配置为在验证Squid生成的证书时信任CA证书。

.. note::

   在 :ref:`squid_transparent_proxy` 也是使用了本文 ``Squid SSL拦截`` 配置，只不过进一步结合了iptables做端口转发，以便减少客户端配置

创建自签名Root CA证书
======================

Squid使用自签名Root CA证书为被代理的网站生成动态证书。这个自签名根证书是一个Root Certificate，而你自己就是根CA(机构)。

.. warning::

   如果这个自签名根证书被泄漏，则任何信任(有意或无意)你的根证书的用户将无法检测到由其他人策划的中间人攻击!!!

- 创建存储证书目录:

.. literalinclude:: squid_ssl_bumping/mkdir_ssl_cert
   :language: bash
   :caption: 创建CA证书存储目录(位置不重要)

- 使用OpenSSL创建证书:

.. literalinclude:: squid_ssl_bumping/openssl_create_ca
   :language: bash
   :caption: 使用openssl创建CA证书

如果使用GnuTLS来完成，也可以使用如下命令:

.. literalinclude:: squid_ssl_bumping/gnutls_create_ca
   :language: bash
   :caption: 使用GnuTLS的certtool创建CA证书

创建DER-encoded证书以便导入到客户端浏览器
============================================

- 执行以下命令构建提供给客户端的证书:

.. literalinclude:: squid_ssl_bumping/openssl_der-encoded_certificate
   :language: bash
   :caption: 构建浏览器客户端使用的 DER-encoded certificate

生成的 ``myCA.der`` 提供给客户端浏览器导入

.. note::

   由于我改为 HTTP 方式实现 :ref:`docker_proxy` 服务端代理，所以暂时没有做进一步实践。原文还有不少技术细节和解决方案，待以后有机会再学习实践。

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
- `SSL-Bump using an intermediate CA <https://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpWithIntermediateCA>`_ Squid官方wiki，精简说明
- `Using Squid to Proxy SSL Sites <https://elatov.github.io/2019/01/using-squid-to-proxy-ssl-sites/>`_
- `Squid使用SSLBump正向代理 <https://www.jianshu.com/p/71c43aa7438f>`_ 提供了一个解决访问https网站证书修正的思路，原文参考了 `Squid (v3.5+) proxy with SSL Bump <https://www.smoothnet.org/squid-v3-5-proxy-with-ssl-bump/>`_ 提供了不少借鉴思路
- `Kaspersky Web Traffic Security帮助: 在 Squid 服务中配置 SSL Bumping <https://support.kaspersky.com/KWTS/6.1/zh-Hans/166244.htm>`_
