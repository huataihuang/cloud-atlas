.. _nginx_wpad:

==================
Nginx部署WPAD服务
==================

通过 :ref:`wpad_protocol` 可以为组织内部客户端自动配置代理服务，例如实现 :ref:`squid_socks_peer` 。在 :ref:`priv_cloud_infra` 部署了 :ref:`priv_dnsmasq_ics` 同时也部署了 :ref:`squid_socks_peer` 来提供翻墙。

对于局域网内部客户端，部署 :ref:`airport_express_with_dnsmasq_ics` ，并部署 :ref:`dnsmasq_dns_wpad` 和/或  :ref:`dnsmasq_dhcp_wpad` 实现自动配置移动客户端来使用代理服务器。

上述构建WPAD都需要有一个WEB服务器提供 WPAD/PAC 配置文件瞎子啊，本文提供实践记录 Nginx 部署 WPAD/PAC 下载服务。

安装配置Nginx
================

- :ref:`ubuntu_install_nginx`

- :ref:`nginx_virtual_host` 配置好 ``wpad.staging.huatai.me`` 这个虚拟主机 - :ref:`wpad_protocol` 要求针对域名提供的主机名必须是 ``wpad.<domain>`` - ``/etc/nginx/sites-available/wpad`` 内容如下

.. literalinclude:: nginx_virtual_host/wpad
   :language: html
   :caption: Nginx虚拟主机wpad的配置 /etc/nginx/sites-available/wpad

- 修订 ``/etc/nginx/mime.types`` 添加一段::

   application/x-ns-proxy-autoconfig     pac;
   application/x-ns-proxy-autoconfig     dat;
   application/x-ns-proxy-autoconfig     da;

这样nginx下载 ``.pac`` 以及 ``.dat`` 文件会添加这个header头部

- 配置 ``wpad.dat`` 内容如下:

.. warning::

   这个 ``wpad.dat`` 存在错误，并没有如我预期那样匹配需要翻墙的域名如 ``facebook.com`` 通过代理访问，所以这里我只是记录待后续有时间再修正。读者如果有兴趣验证并解决，请通过 issue 告知我订正方法，多谢。

.. literalinclude:: ../proxy/pac/liberty.pac
   :language: html
   :caption: /var/www/wpad/html/wpad.dat

.. note::

   我实际采用下文简化版 ``wpad.dat`` ，将所有流量都通过 :ref:`squid` 代理。不过，因为我部署了 :ref:`squid_socks_peer` ，将墙内和墙外的 ``squid`` 代理服务器连接，只有需要翻墙的流量才会经过外网代理。所以总体上不影响我的使用。 ``PAC`` 配置改进待后续有时间再进行。

- 验证nginx配置::

   sudo nginx -t

- 重启nginx生效::

   sudo systemctl restart nginx

配置客户端

异常排查
===========

未从virtual host下载wpda.dat
-------------------------------

- 客户端 似乎不能成功下载，nginx日志如下::

   ==> access.log <==
   192.168.6.22 - - [02/Mar/2022:17:52:12 +0800] "GET /wpad.dat HTTP/1.1" 200 809 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15"
   192.168.6.40 - - [02/Mar/2022:17:53:01 +0800] "GET /wpad.dat HTTP/1.1" 404 134 "-" "CFNetworkAgent (unknown version) CFNetwork/1329 Darwin/21.3.0"
   192.168.6.22 - - [02/Mar/2022:17:53:09 +0800] "GET /wpad.dat HTTP/1.1" 404 197 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_16_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36 DingTalk(6.3.25-macOS-15385707) nw Channel/201200"
   192.168.6.22 - - [02/Mar/2022:17:53:09 +0800] "GET /wpad.dat HTTP/1.1" 404 197 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_16_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36 DingTalk(6.3.25-macOS-15385707) nw Channel/201200"
   192.168.6.22 - - [02/Mar/2022:17:55:40 +0800] "GET /wpad.dat HTTP/1.1" 404 134 "-" "CFNetworkAgent (unknown version) CFNetwork/1329 Darwin/21.3.0"
   192.168.6.40 - - [02/Mar/2022:17:55:50 +0800] "GET /wpad.dat HTTP/1.1" 404 134 "-" "CFNetworkAgent (unknown version) CFNetwork/1329 Darwin/21.3.0"

显示文件不存在，但是用浏览器访问 http://wpad.staging.huatai.me/wpad.dat 是可以下载的

- 我尝试做了一个软连接，将默认目录下也软连接一个 ``wpad.dat`` ::

   cd /var/www/html
   ln -s ../wpad/html/wpad.dat ./

然后客户端就能正常下载 ``wpad.dat`` ，似乎是解析了域名 ``wpad.staging.huatai.me`` 得到IP地址之后，客户端是通过IP地址来下载文件的。(待排查)

无法正确解析 ``wpad.dat`` 
----------------------------

时间有限，我还没有排查出为何前述的 ``wpad.dat`` 文件被客户端下载之后，并没有匹配上域名 ``facebook.com`` 来访问代理服务器。

我做了一个简化，将 ``wpad.dat`` 文件修改成只返回代理服务器::

   function FindProxyForURL(url, host) {
       return "PROXY proxy.staging.huatai.me:3128";
   }

则验证完全正常，也就是客户端能够正确获得代理服务器配置，并始终通过 :ref:`squid` 代理访问internet，解决了翻墙。

.. note::

   后续再排查 ``wpad.dat`` 问题，目前初步验证整个 ``nginx + wpad + dnsmasq`` 能够走通整个代理服务器自动配置流程，初步达成目标。

存在问题
==========

- (待排查)iphone客户端似乎不断下载 ``wpad.dat`` 从 nginx 的 access.log 日志看访问非常频繁，并且是每个浏览器或者客户端都会下载
   
参考
======

- `pfSense WPAD/PAC proxy configuration guide <https://nguvu.org/pfsense/pfSense-WPAD-PAC-proxy-configuration/>`_
- `gentoo linux wiki: ProxyautoConfig <https://wiki.gentoo.org/wiki/ProxyAutoConfig>`_
