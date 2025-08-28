.. _sni_esni_ech:

==========================================
SNI, ESNI 和 ECH (Encrypted Client Hello)
==========================================

阿里云的自建网站异常
=======================

我在阿里云上租用额一个99元一年的小规格虚拟机，用于部署 :ref:`nginx_reverse_proxy_https` 来实现homelab的外部输出。然而，我发现奇怪的问题，在 macOS 上使用 Safari 访问域名 `docs.cloud-atlas.dev <https://docs.cloud-atlas.dev>`_ ，有一定几率无法打开页面:

.. literalinclude:: nginx_reverse_proxy_https/safari_error
   :caption: Safari访问网站随机断开连接

然而，服务器是非常空闲的。有时候刷新safari浏览器又能够看到页面...

这个问题困扰我很久，最初我以为是阿里云外网访问的随机问题(但我觉得阿里云这样的头部云厂商不太可能存在这样的bug)，所以我尝试更换操作系统(Linux更换到FreeBSD)，问题依旧。

今天我更新了Sequioa 15.3版本macOS之后，我突然发现现在safari完全不能打开我的网站 https://docs.cloud-atlas.io/discovery/ ，晕倒...

**但是，chrome浏览器访问是正常的** 另外，验证了 Firefox 也可以正常访问网站。奇怪的是Safari不行... iOS设备无法访问我的网站，毕竟这是非常主要的手机客户端

我注意到Safari浏览器访问网站时候，Nginxi日志 ``error.log`` 显示:

.. literalinclude:: nginx_reverse_proxy_https/nginx_error.log
   :caption: safari浏览器访问时nginx错误日志

参考 `nginx faq: What does the following error mean in the log file: “accept() failed (53: Software caused connection abort) while accepting new connection on 0.0.0.0:80”? <https://nginx.org/en/docs/faq/accept_failed.html>`_ 说明:

这类错误是因为客户端在nginx能够处理之前关闭的连接。例如，当用户没有等待一个包含大量图像的页面完全加载，而是点击了另一个链接是，就会发生这种情况。在这种情况下，用户浏览器将关闭所有不需要的先前连接。 **这是一个非关键错误**

但是，为何safari客户端会快速关闭页面访问连接，而chrome却能够正常浏览？

.. warning::

   2025年8月，我再次尝试在阿里云虚拟机上部署 :ref:`nginx_reverse_proxy_https` ，发现问题更为严重，NGINX服务器没有任何日志输出，而Safari客户端每次访问连接都断开。排查发现是阿里云前面的防火墙直接reset了TCP连接，而且显然阿里云做了升级，现在已经不是随机异常，而是每次Safari访问都是失败的...

排查
----------

2025年8月的 :ref:`nginx_reverse_proxy_https` 实践方式是在 :ref:`lets_encrypt_wildcard_certificates` 采用 :ref:`nginx_in_jail` ，再次遇到这个问题迫使我思考如何解决而不是放弃。

我逐渐感觉可能是阿里云对于没有备案的网站采用了某种方式来阻塞443端口，影响了sarfri的访问，但是对于chrome和firefox影响没有影响。所以我想找出这个差异在哪里，原因为何，以及如何解决

- 我采用了 :ref:`ssh_tunneling` 将服务器的 ``127.0.0.1:443`` 映射到本地macOS的 ``127.0.0.1:443``
- 然后采用safari直接访问 https://127.0.0.1 或者 https://docs.cloud-atlas.dev (已经配置hosts指向127.0.0.1)，发现safari完全能够正常访问网站

这证明我的NGINX服务器配置完全没有问题，关键问题在于阿里云在443端口做了手脚。考虑到阿里云是国内最大的云厂商，这个问题很可能是为了防范没有备案的网站直接对外提供服务做的手脚。

- 使用 :ref:`curl` 测试:

.. literalinclude:: nginx_reverse_proxy_https/curl_test
   :caption: curl 测试下载index.html

输出结果显示确实是服务器端(实际上是阿里云防火墙reset):

.. literalinclude:: nginx_reverse_proxy_https/curl_test_output
   :caption: curl 测试下载index.html 显示服务器端reset了连接
   :emphasize-lines: 7

就是不知道为何 :strike:`firefox 和 chrome 能够忽略这个reset` ? 答案是 ``Encrypted Client Hello (ECH)``

.. note::

   ``Connection reset by peer`` 是TCP/IP网络层事件，所以浏览器是无法忽略这个连接重置的。之所以chrome和firefox能够访问阿里云没有备案的HTTPS网站，在于目前最新版本的chrome和firefox都强制启用了 :ref:`ech` 支持，也就是加密了TLS握手的客户端发起请求SNI。这种情况下，阿里云无法检测出你访问的域名，也就不会发出TCP reset。

.. note::

   `阿里云是用什么技术拦截未备案的域名的？ <https://www.zhihu.com/question/31752003>`_ 有人提供了有用的线索:

   - HTTP：明文解析识别域名
   - HTTPS：通过 ``SNI`` 识别域名
   - `什么是 SNI？TLS 服务器名称指示如何工作 <https://www.cloudflare.com/zh-cn/learning/ssl/what-is-sni/>`_

.. _sni:

SNI(Server Name Indication)
=============================

对于多个网站托管在同一个服务器并共享一个IP地址，并且每个网站都有自己的SSL证书。此时客户端尝试连接到其中一个网站时，服务器可能不知道显示哪个SSL证书。因为SSL/TLS握手发生在客户端真正连接某个网站之前。

服务器名称指示 (SNI) 旨在解决此问题:

- SNI 是 TLS 协议（以前称为 SSL 协议）的扩展，该协议在 HTTPS 中使用
- SNI 包含在 TLS/SSL 握手流程中，以确保客户端设备能够看到他们尝试访问的网站的正确 SSL 证书
- 在 TLS 握手期间指定网站的主机名或域名 ，而不是在握手之后打开 HTTP 连接时指定

但是，这带来一个安全隐患: **SNI是明文，监听TLS握手的第三方会知道用户正在访问哪些网站**

- TLS 握手中的第一条消息称为“客户端问候”。作为此消息的一部分，客户端要求查看 Web 服务器的 TLS 证书。服务器回应时将发送证书。
- SNI 通过标示客户端正在尝试访问哪个网站来解决此问题。矛盾的是，只有在使用 SNI 成功完成 TLS 握手后，才能进行加密。
- 任何监视客户端和服务器之间连接的攻击者都可以读取握手的 SNI 部分，以此确定客户端正在与哪个网站建立连接，即便攻击者无法解密进一步通信。

.. _esni:

ESNI(encrypted SNI)
======================

ESNI 通过加密客户端问候消息的 SNI 部分（仅此部分），来保护 SNI 的私密性。加密仅在通信双方（在此情况下为客户端和服务器）都有用于加密和解密信息的密钥时才起作用。

**ESNI 加密密钥** : 通过在DNS记录中添加域名公钥，客户端能够使用公钥来加密 SNI 记录，以便只有特定的服务器才能解密它(因为只有服务器具备对应私钥)

但是，即使部署了ESNI，由于常规DNS没有加密，导致仍然可以监听用户查询的DNS记录以确定其访问哪些网站，所以还需要进一步的附加协议增强安全:

- 基于 TLS 的 DNS: 使用TLS加密DNS查询
- 基于 HTTPS 的 DNS: 也是使用TLS加密DNS穿，但是在HTTPS网络层加密
- DNSSEC: 确保DNS记录真实并且来自合法的DNS服务器

.. note::

   随着TLS协议发展，现在浏览器(chrome和firefox)已经采用 ``ECH`` 取代了 ``ESNI``

.. _ech:

ECH (Encrypted Client Hello)
==============================

加密客户端问候 (ECH)，这是 TLS 的一项新扩展，对整个握手过程进行加密，以确保这些元数据的机密性。

ECH提供了以下安全加强:

- 保护SNI不泄漏客户端和服务器的协商
- 保护ALPN(TLS连接后决定使用哪个应用层的协议)不泄露客户端和服务器之间的功能以及连接用途

在最新版本 TLS 1.3 之前，TLS 根本没有握手加密。2013 年斯诺登事件爆发后，IETF 社区开始思考如何应对大规模监控对开放互联网构成的威胁。2014 年，TLS 1.3 的标准化进程启动，其设计目标之一就是尽可能多地加密握手过程。遗憾的是，最终标准未能实现完全握手加密，包括 SNI 在内的多个参数仍然以明文形式发送。

**ECH 的前身是加密 SNI (ESNI) 扩展。**

使用 ESNI 扩展的 TLS 1.3 握手。它与 TLS 1.3 握手完全相同，只是 SNI 扩展已被 ESNI 替换。

为了使用 ESNI 连接到网站，客户端需要在其标准 ``A/AAAA`` 查询上搭载一个包含 ESNI 公钥的 TXT 记录请求。例如，要获取 crypto.dance 的密钥，客户端需要请求 ``_esni.crypto.dance`` 的 TXT 记录

但是需要注意，如果DNS查询不加密，则依然会泄漏访问的域名，就会导致ESNI失去意义。所以，需要引入 ``DNS-over-HTTPS`` 来加密传输ESNI公钥。

由于ESNI不够完善(仅保护 SNI)，容易受到一些复杂攻击(协议设计中存在一些理论上的缺陷): 

- 依赖DNS进行密钥分发可能存在泄露
- DNS缓存导致实际运行时客户端会使用过期公钥(虽然Cloudflare的ESNI服务一定程度上容忍这种情况)
- DNS解析可能有多个地址并属于不同CDN运营，则ESNI的DNS记录可能只包含其中一个CDN的公钥，从而导致访问其他CDN时ESNI解密失败

.. note::

   由于ECH协议有点复杂，我还没有完全理解，后续可能需要不断修订完善文档

ECH的设计目标是确保与同一 ECH 服务提供商背后的不同源服务器建立的 TLS 连接彼此之间无法区分: 也就是当你连接Cloudflare背后的源服务器时，你和Cloudflare之间网络上的任何人都不能辨别出你连接到哪个源服务器，也不能辨别你和源服务器之间写上了哪些隐私敏感的握手参数。

也就是说，ECH要能够低于流量分析

待续...

参考
=======

- `什么是 SNI？TLS 服务器名称指示如何工作 <https://www.cloudflare.com/zh-cn/learning/ssl/what-is-sni/>`_
- `什么是加密的 SNI？ | ESNI 如何工作 <https://www.cloudflare.com/zh-cn/learning/ssl/what-is-encrypted-sni/>`_
- `Good-bye ESNI, hello ECH! <https://blog.cloudflare.com/encrypted-client-hello/>`_
