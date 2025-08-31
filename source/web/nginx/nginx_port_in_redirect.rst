.. _nginx_port_in_redirect:

=================================
Nginx ``port_in_redirect``
=================================

我是在实践 :ref:`cloudflare_tunnel` 注意到一个奇怪的现象:

当我的页面中嵌入的URL没有跟随 ``/`` ，也就是使用了 ``https://docs.cloud-atlas.dev/discovery`` 而不是 ``https://docs.cloud-atlas.dev/discovery/`` 。此时作为 :ref:`cloudflare_tunnel` 后端的NGINX运行在 ``8001`` 端口，浏览器客户端会访问 ``https://docs.cloud-atlas.dev:8001/discovery/`` 。这导致根本打不开页面，因为Cloudfare Tunnel对外输出的HTTPS端口是443，客户端是无法访问内部服务器端口 ``80001`` 的。

为什么会出现这么奇怪的将内部服务器端口暴露到Internet的现象？

NGINX如何处理url最后没有加 ``/``
====================================

简单来说:

- 在URL中，最后的 ``/`` 和我们UNIX文件系统类似，表示的是一个路径(目录)，此时会按照NGINX配置 ``index  index.html index.htm;`` 去自动加载 ``index.html`` 页面
- 如果URL最后没有加上 ``/`` ，那么NGINX/Apache等WEB服务器就会按照如下顺序去判断:

  - 首先假设最后没有 ``/`` 的URL部分是一个文件，例如 ``https://docs.cloud-atlas.dev/discovery`` 就假设在WEB服务器根目录下可能有一个名为 ``discovery`` 的文件，先尝试去访问 ``discovery`` 文件来提供给浏览器客户端
  - 当然这里确实没有这个 ``discovery`` 文件，那么WEB服务器就会默认将该URL理解为对一个目录的请求，也就是 ``discovery/`` 目录的请求
  - **重定向行为** : WEB服务器通常会执行 ``301`` 永久重定向，将请求自动转跳到 ``discovery/`` 。这样，用户访问的就是该目录下的默认文件(通常是 ``index.html`` )

为什么会暴露出 ``8001`` 端口
=================================

这就涉及到NGINX的一个默认配置 ``port_in_redirect`` :

- `Module ngx_http_core_module >> port_in_redirect <http://nginx.org/en/docs/http/ngx_http_core_module.html#port_in_redirect>`_ 默认设置是 ``on`` :

  - 当NGINX重定向一个URL时候，默认会将服务器端口添加到重定向URL中: 对于我的案例就是 ``301`` 永久重定向，自动转跳 ``discovery/`` 时会插入 ``8001`` 端口

为什么以前部署反向代理没有暴露后端服务器端口
===============================================

在没有使用 :ref:`cloudflare_tunnel` 之前，我使用 :ref:`nginx_reverse_proxy_https` 来部署网站，关于反向代理的配置设置，有一段 ``proxy_set_header`` 配置修正了这个问题(这里取 :ref:`nginx_config_include` 配置为例):

.. literalinclude:: nginx_config_include/proxy_set.conf
   :caption: ``/etc/nginx/include/proxy/proxy_set.conf``
   :emphasize-lines: 8

这个 ``proxy_set_header X-Forwarded-Port  $server_port;`` 表示:

  - Nginx反向代理服务器 在端口 443 上接收请求，添加标头 ``X-Forwarded-Port: 443`` ( ``$server_port`` )，并将请求转发到端口 ``8001`` 上的后端
  - 当后端WEB服务器生成重定向时，后端NGINX会使用header(443)，并将客户端正确重定向到 ``https://docs.cloud-atlas.dev/discovery/`` ，而不是画蛇添注增加 ``port_in_redirect`` 的 ``8001`` 端口

结合 :ref:`cloudflare_tunnel` 的修正方法
==========================================

既然已经了解了前因后果，那么修正方法有:

- 方法一: 在后端NGINX服务器配置 ``port_in_redirect off;`` 以杜绝重定向暴露错误的端口号(我采用这个方法):

.. literalinclude:: ../cloudflare/cloudflare_tunnel/docs.cloud-atlas.dev
   :caption: ``/etc/nginx/sites-available/docs.cloud-atlas.dev`` 配置NGINX
   :emphasize-lines: 7

- 方法二: 修订 :ref:`cloudflare_tunnel` 配置，使用 ``httpHostHeader`` 设置来明确发送正确的公开主机名端口

- 方法三: 在 Cloudflare dashboard 的 ``Rules > Redirect Rules`` 设置一个处理 trailing slash 的URL规则: ``Forwarding URL with a 301 (Permanent Redirect)`` 的动作包含 ``trailing slash``

.. warning::

   上述方法二和三我没有实践，仅参考Google搜索AI回答记录参考

``301 (Permanent Redirect)`` 问题
------------------------------------

我发现一个尴尬的问题，就是之前错误的 ``port_in_redirect`` 默认配置对于客户端是有持久影响的，如果客户端不清除缓存，会一直保留着重定向URL中插入 ``8001`` 端口。当然浏览器客户端清理缓存是能够解决问题的，但实际是不可能让用户清理换缓存但。

我理解是需要让nginx发送给客户端页面内容已经更新，强制客户端刷新缓存。不过，目前是实验环境，就我一个人使用，我还没哟研究。

参考
======

- `url后加不加/区别 <https://blog.csdn.net/m0_45000011/article/details/131443958>`_
- `网址最后面不带斜杠与带斜杠有什么区别 <https://blog.csdn.net/wangpaiblog/article/details/117408899>`_
- `What are X-forwarded Headers, and why it is used? <https://requestly.com/blog/what-are-x-forwarded-headers-and-why-it-is-used/>`_
