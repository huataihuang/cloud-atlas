.. _squid_transparent_proxy:

==========================
Squid透明代理
==========================

我在 :ref:`priv_cloud_infra` 中使用 :ref:`apple_airport` 结合 :ref:`priv_dnsmasq_ics` 实现了局域网内部无线客户端能够共享上网。同时，为了解决带宽资源，同时方便内部服务器快速安装和更新软件，在 ``zcloud`` 主机上部署了 :ref:`squid` 作为代理。进一步，通过 :ref:`apt_proxy_arch` 解决了访问Google等 :ref:`kubernetes` 软件仓库更新软件问题。

不过，对于普通用户而言，例如手机客户端，连接到WiFi上，虽然通过 :ref:`iptables_ics` 确实能够上网。但是，受阻于GFW，无法自由访问信息。配置手机客户端的代理也非常麻烦，切换网络还要切换代理。所以，更好的解决方法是使用 ``透明代理`` ，也就是让所有客户端外出访问能够自动经过代理服务器，这样只需要在代理服务器上实现 ``翻墙`` 就能够解决用户的 ``痛点`` 。

透明代理需要代理服务器实现 ``中间人`` HTTPS代理，但是这种透明代理模式需要用代理服务器的SSL/TLS证书代替客户端想要访问的网站SSL/TLS证书。这种模式对于客户端是不能容忍的安全隐患，虽然可以通过导入代理服务器的自签名证书来绕过这个验证问题，但是对于客户端部署有要求，所以实际使用效果并不是完全透明，依然需要配置客户端。

实践发现另一个问题是 :ref:`squid_socks_peer` 失效，虽然我最终实现了透明代理，但是无法使用之前配置的 :ref:`squid_socks_peer` 翻墙，所以感觉非常沮丧。有可能有其他方法可以克服这个问题，但是暂时没有精力来继续折腾了。

在 ``squid透明代理`` 探索过程中，发现通过 :ref:`dnsmasq_dhcp_pac` 实现动态配置客户端代理，可以更为方便实现局域网 ``透明`` 翻墙访问。

http透明代理
===============

http透明代理的原理其实非常简单，就是在网关的内网接口上启用 ``iptables`` 的转发，将访问WEB端口重定向到 ``squid`` 的代理端口上；此时还需要激活 ``squid`` 的 ``intercept`` (拦截) 功能，这样就能实现对客户端无感的透明代理。

- 修订 ``/etc/squid/squid.conf`` 配置，添加一个 ``intercept`` 配置行，注意，需要有两个代理端口，一个是传统的 ``forward proxy`` 一个是 ``intercept`` ::

   http_port 8080
   http_port 3128 intercep

- 修订 :ref:`priv_dnsmasq_ics` 中的 ``ics.sh`` (配置MASQUERADE)脚本，添加::

   # squid transparent proxy
   sudo iptables -t nat -A PREROUTING -i br0 -p tcp --dport 80 -j DNAT --to 192.168.6.200:3128
   sudo iptables -t nat -A PREROUTING -i br0:1 -p tcp --dport 80 -j DNAT --to 192.168.6.200:3128
   sudo iptables -t nat -A PREROUTING -i eno4 -p tcp --dport 80 -j REDIRECT --to-port 3128

完整脚本参考 :ref:`priv_dnsmasq_ics` 中的 ``ics.sh``

https透明代理
=================

https代理实现则比较复杂，早期的squid并没有提供透明拦截SSL连接(transparently intercept SSL connections)。不过，从2011 年开始，squid开始支持作为SSL中间人代理(act as a man in the middle)。这个设置背后的原理就是解密HTTPS连接然后进行内容过滤。

不过，需要担心的是透明代理打断了HTTPS流量，也就导致了可能存在到的和法律问题。不过，对于个人使用或者能够控制安全性的环境，可以采用这种模式。

.. warning::

   透明代理HTTPS相当于代理服务器是中间人，需要绝对保障代理服务器安全，否则会导致安全泄密。

技术上，在编译 ``squid`` 源代码时候，需要激活 ``--enable-ssl`` 选项以支持 ``SslBump`` ，也就是squid透明连接SSL流量的技术要求。

SSL key
~~~~~~~

一个非常重要的步骤是为终端用户创建squid使用的证书，在测试环境，可以采用自签名证书。生产环境，则使用 ``let's encryption`` 提供的证书。

- 生成SSL key::

   mkdir -p /etc/squid/certs/
   cd /etc/squid/certs/
   # This puts the private key and the self-signed certificate in the same file
   openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 -keyout myCA.pem -out myCA.pem
   # This can be added to browsers
   openssl x509 -in myCA.pem -outform DER -out myCA.der

初始化SSL数据库
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 初始化SSL数据库: Squid需要生成一个新的 ``fake`` (伪造) 自签名证书用来 ``bump`` (碰撞) SSL连接，这些都会保存在一个目录中:

以下是Ubuntu 20中执行命令(用户名是 ``proxy`` )::

   sudo /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
   sudo chown proxy:proxy -R /var/lib/ssl_db

以下是 Fedora系统执行命令(用户名是 ``squid`` )::

   sudo /usr/lib64/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
   sudo chown squid:squid -R /var/lib/ssl_db

修正客户端证书
~~~~~~~~~~~~~~~

客户端默认不使用自签名证书，所以需要做以下修复:

- 浏览器: 使用 ``myCA.der`` 来导入证书
- Linux: 复制cert文件到 ``/etc/pki/ca-trust/source/anchors`` 目录下然后运行 ``update-ca-trust``
- Node.js: 待验证
- Headless Chrome (Puppeteer): 待验证

配置iptables
~~~~~~~~~~~~~~

- 使用 ``PREROUTING`` ::

   sudo iptables -t nat -A PREROUTING -i br0 -p tcp --dport 443 -j DNAT --to 192.168.6.200:3128
   sudo iptables -t nat -A PREROUTING -i br0:1 -p tcp --dport 443 -j DNAT --to 192.168.6.200:3128
   sudo iptables -t nat -A PREROUTING -i eno4 -p tcp --dport 443 -j REDIRECT --to-port 3128

配置
~~~~~~

- 在 ``/etc/squid/squid.conf`` 中配置::

   http_port 8080
   http_port 3128 intercept
   http_port 3129 intercept ssl-bump cert=/etc/squid/cert/myCA.pem \
     generate-host-certificates=on dynamic_cert_mem_cache_size=4MB

   # For squid 3.5.x
   # sslcrtd_program /usr/local/squid/libexec/ssl_crtd -s /var/lib/ssl_db -M 4MB

   # For squid 4.x
   # sslcrtd_program /usr/local/squid/libexec/security_file_certgen -s /var/lib/ssl_db -M 4MB

   sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/ssl_db -M 4MB

   acl step1 at_step SslBump1

   ssl_bump peek step1
   ssl_bump bump all

- 启动::

   sudo systemctl start squid

- 然后观察 ``/var/log/squid/*.log``

HTTP透明代理错误:No forward-proxy ports
========================================

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

HTTPS透明代理:error:invalid-request
=====================================

启动了https透明代理，我发现日志中出现大量::

   1646123605.853      0 192.168.6.22 NONE_NONE/400 3685 - error:invalid-request - HIER_NONE/- text/html
   1646123606.086      0 192.168.6.22 NONE_NONE/000 0 - error:transaction-end-before-headers - HIER_NONE/- -
   1646123606.094      0 192.168.6.22 NONE_NONE/400 3685 - error:invalid-request - HIER_NONE/- text/html

这个报错似乎是因为配置了::

   http_port 3129 intercept ssl-bump cert=/etc/squid/cert/myCA.pem \
     generate-host-certificates=on dynamic_cert_mem_cache_size=4MB

修改成 ``https_port`` ::

   https_port 3129 intercept ssl-bump cert=/etc/squid/cert/myCA.pem \
     generate-host-certificates=on dynamic_cert_mem_cache_size=4MB

此时日志报错显示::

   ==> access.log <==
   1646124814.877    164 192.168.6.22 NONE_NONE/000 0 CONNECT 203.119.129.34:443 - ORIGINAL_DST/203.119.129.34 -
   1646124815.121     80 192.168.6.22 NONE_NONE/000 0 CONNECT 59.82.15.79:443 - ORIGINAL_DST/59.82.15.79 -
   
   ==> cache.log <==
   2022/03/01 16:53:36 kid1| ERROR: failure while accepting a TLS connection on conn239 local=117.18.232.200:443 remote=192.168.6.22:53993 FD 28 flags=33: 0x5561efffa6a0*1
       current master transaction: master55 

这个报错其实已经说明建立了HTTPS代理了，仔细观察 ``/var/lib/ssl_db/certs`` 可以看到缓存了大量的远端服务器证书 

``failure while accepting a TLS`` 表示当尝试TLS连接失败。参考 `Intercept HTTPS CONNECT messages with SSL-Bump <https://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpExplicit>`_ 提到 ``Modern DH/EDH ciphers usage`` :

现代化 DH/EDH exchanges/ciphers 选项 ``tls-dh=`` 所以我尝试 (这个方法估计可行，类似tls配置)::

   https_port 3129 intercept ssl-bump cert=/etc/squid/certs/myCA.pem \
     generate-host-certificates=on dynamic_cert_mem_cache_size=4MB \
     tls-dh=/etc/squid/certs/dhparam.pem

但是此时报错变成监测到不正确端口::

   ==> cache.log <==
   2022/03/01 20:47:48 kid1| SECURITY ALERT: Host header forgery detected on conn27 local=192.168.6.200:3128 remote=192.168.6.253:56774 FD 16 flags=33 (intercepted port does not match 443)
       current master transaction: master57
   2022/03/01 20:47:48 kid1| SECURITY ALERT: By user agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0
       current master transaction: master57
   2022/03/01 20:47:48 kid1| SECURITY ALERT: on URL: www.google.com:443
       current master transaction: master57
   2022/03/01 20:47:48 kid1| kick abandoning conn27 local=192.168.6.200:3128 remote=192.168.6.253:56774 FD 16 flags=33
       connection: conn27 local=192.168.6.200:3128 remote=192.168.6.253:56774 FD 16 flags=33
   
   ==> access.log <==
   1646138868.558      0 192.168.6.253 NONE_NONE/409 4212 CONNECT www.google.com:443 - HIER_NONE/- text/html

此外，根据该文档提示 ``TLS`` ，有一个 squid 外连网站的设置::

   sslproxy_cipher EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:HIGH:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

或者使用::

   sslproxy_cipher HIGH:MEDIUM:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

或者使用::

   tls_outgoing_options cipher=HIGH:MEDIUM:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

我尝试了一下 ``sslproxy_cipher HIGH:MEDIUM:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS`` ，结果，访问 google 也同样出现::

   2022/03/01 20:59:41 kid1| SECURITY ALERT: Host header forgery detected on conn29 local=192.168.6.200:3128 remote=192.168.6.253:56782 FD 18 flags=33 (intercepted port does not match 443)
    current master transaction: master61

我注意到一个奇怪的问题，我的配置中设置了::

   http_port 8080
   http_port 3128 intercept
   https_port 3129 intercept ssl-bump cert=/etc/squid/certs/myCA.pem \
     generate-host-certificates=on dynamic_cert_mem_cache_size=4MB

https端口明明是 3129 为何日志中显示是 3128?

汗，我发现我忘记修改浏览器的网络设置，原来浏览器的网络设置了 通过 ``192.168.6.200:8123`` 代理，这样浏览器是明确设置了代理，而现在squid是配置了透明代理(443)，这就导致了两者冲突。

同样，在Linux终端中设置环境变量 ``http_proxy=http://192.168.6.200:3128/`` 也会导致直接访问 ``3128`` 端口也会有同样的日志报错。原理相同

类似 `Re: "intercepted port does not match 443" <https://www.spinics.net/lists/squid/msg92601.html>`_ 一定要确保透明代理时客户端不能配置代理设置，否则冲突

另一种证书配置
==================

解决参考: `Using Squid to Proxy SSL Sites <https://elatov.github.io/2019/01/using-squid-to-proxy-ssl-sites/>`_

重新生成证书(需要合并CA证书)::

   openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 -extensions v3_ca -keyout squid-ca-key.pem -out squid-ca-cert.pem

   # 结合文件
   cat squid-ca-cert.pem squid-ca-key.pem >> squid-ca-cert-key.pem

- 移动到证书目录::

   sudo mkdir /etc/squid/certs
   sudo mv squid-ca-cert-key.pem /etc/squid/certs/
   sudo chown proxy:proxy -R /etc/squid/certs

- 配置 ``/etc/squid/squid.conf`` ::

   http_port 3128 intercept
   https_port 3129 intercept ssl-bump cert=/etc/squid/certs/squid-ca-cert-key.pem \
     generate-host-certificates=on dynamic_cert_mem_cache_size=16MBB

   sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/ssl_db -M 16MB

   acl step1 at_step SslBump1
   ssl_bump peek step1
   ssl_bump bump all
   ssl_bump splice all

此时启动报错::

   Mar 01 17:11:55 zcloud squid[499390]: FATAL: mimeLoadIcon: cannot parse internal URL: http://zcloud:0/squid-internal-static/icons/silk/image.png

这个报错是因为使用了 ``transparent`` 模式之后，无法处理下载文件，所以还要在添加一行不带 ``interrupt`` 的配置::

   http_port 8080

但是即使能够运行squid，还是会出现日志中有::

   2022/03/01 17:43:00 kid1| ERROR: failure while accepting a TLS connection on conn1486 local=203.119.129.34:443 remote=192.168.6.22:63105 FD 24 flags=33: 0x563fb47ef180*1
    current master transaction: master57

这说明证书方法配置可以，但是还是需要解决 squid 向远端发送请求问题

完整参考配置
=================

以下是我经过实践和不断摸索，初步形成的能够工作的 ``squid 透明代理`` 配置:

.. literalinclude:: squid_transparent_proxy/squid.conf
   :language: bash
   :caption: squid透明代理 squid.conf

客户端配置
==============

实际上客户端此时如果没有导入服务器证书，浏览器或者下载工具都会拒绝 https 连接，因为都发现了中间人攻击。

此时可以在浏览器中点击 ``Advanced`` ，然后接受安全风险并继续访问

* 当使用firefox访问 https://baidu.com ，则只要接受 ``squid`` 自签名证书就可以继续访问，只是浏览器上会多一个感叹号
* 但是访问 https://www.google.com 则不行，因为google的安全策略(HSTS)不允许证书例外::

   www.google.com has a security policy called HTTP Strict Transport Security (HSTS), which means that Firefox can only connect to it securely. You can’t add an exception to visit this site.

要彻底解决这个问题，还是需要将前面生成的服务器证书 ``/etc/squid/certs/myCA.der`` 导入到浏览器中，之后访问所有的https网站都能正常工作了

.. note::

   也是就是说，虽然透明代理可以减少客户端的代理配置，但是实际上并不是很容易使用，必须在浏览器和操作系统中导入这个中间人(代理服务器)证书才能正常工作。这种情况，也就只有技术人员自己使用，或者企业对证书有完全控制，能够在企业电脑或移动设备中安装企业证书才能解决。

   这个实践我虽然完成，但是并没有达到预期的简便易用目标。这也是现代HTTPS加密安全性带来的限制，要想绕开安全加密，实际上并不是非常容易(安全性有保障)。



参考
======

- `Intercept HTTPS CONNECT messages with SSL-Bump <https://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpExplicit>`_ 官方文档，是标准
- `Using Squid to Proxy SSL Sites <https://elatov.github.io/2019/01/using-squid-to-proxy-ssl-sites/>`_
- `A short guide on Squid transparent proxy & SSL bumping <https://dev.to/suntong/a-short-guide-on-squid-transparent-proxy-ssl-bumping-k5c>`_ 这个文档系列有点混乱
- `Squid Transparent proxy server : How to configure <https://linuxtechlab.com/squid-transparent-proxy-server-complete-configuration/>`_
- `squid-cache wiki: No forward-proxy ports <https://wiki.squid-cache.org/KnowledgeBase/NoForwardProxyPorts>`_
- `Transparent Squid Proxy for HTTPS <https://bbs.archlinux.org/viewtopic.php?id=256961>`_
