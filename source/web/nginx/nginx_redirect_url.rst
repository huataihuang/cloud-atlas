.. _nginx_redirect_url:

=====================
NGINX重定向URL
=====================

URL重定向是常用的WEB服务器功能:

- 避免用户无法访问旧文档，将旧文档URL重定向到新文档URL
- 将用户访问的不安全的HTTP(端口80)的URL更改为加密的HTTPS(端口443) 
- 将用户通过IP访问的请求更改为DNS方式域名访问

重定向URL
==============

我在服务器上部署了 :ref:`nginx_reverse_proxy_nodejs` ，其中使用了一个 ``/arm`` 目录作为 :ref:`patternfly` 的compent目录，所以之前访问 ``/arm`` 目录下的文件需要改到其他目录下避免冲突( ``/download`` 目录 )

- ``/etc/nginx/conf.d/onesre.conf`` 配置重定向，将原先 ``/arm`` 目录下文件URL重定向到 ``/download`` 目录下:

.. literalinclude:: nginx_redirect_url/onesre.conf
   :language: bash
   :caption: 重定向URL
   :emphasize-lines: 6,17-19

参考
==========

- `How to Redirect URL in NGINX <https://ubiq.co/tech-blog/redirect-url-nginx/>`_
- `Redirect URLs in NGINX <https://linuxhint.com/redirect_urls_nginx/>`_
