.. _apache_reverse_proxy:

=======================
Apache反向代理
=======================

现代WEB服务器通常都具备反向代理功能( ``reverse proxy servver`` )，也称为网关( ``gateway`` )服务器。

当 ``httpd`` 收到客户单请求，会将请求代理到后端服务器，由后端服务器处理请求并生成内容。后端服务器将内容发送给 ``httpd`` 服务，再由 ``httpd`` 服务生成实际的HTTP响应返回给客户端。

采用反向代理的主要原因是:

- 安全
- 高可用性
- 负载均衡
- 集中式身份认证和授权
- 为后端应用服务器提供功能补充: 缓存、压缩或SSL加密

采用反向代理架构，为后端服务器提供了隔离保护；而对于客户端，反向代理服务器是所有内容的唯一来源。

.. note::

   :ref:`nginx_reverse_proxy` 也是非常常用的部署模式

Apache反向代理模块
=====================

Apache提供了功能丰富的模块，例如 :ref:`apache_webdav` 。对于反向代理，主要使用以下模块:

- ``mod_proxy`` : 用于重定向连接的主要代理模块，允许Apache作为底层应用服务器的网关
- ``mod_proxy_http`` : 添加对代理HTTP连接的支持
- ``mod_proxy_balancer`` 和 ``mod_lbmethod_byrequests`` : 为多个后端服务器增加负载均衡功能

- 执行以下命令激活反向代理功能(包括重启服务):

.. literalinclude:: apache_reverse_proxy/apache_enable_reverse_proxy_modules
   :language: bash
   :caption: 激活Apache 2的反向代理模块

待续...

参考
=======

- `Apache > HTTP Server > Documentation > Version 2.4 > How-To/Tutorials: Reverse Proxy Guide <https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html>`_
- `How to Set Up a Reverse Proxy With Apache <https://www.howtogeek.com/devops/how-to-set-up-a-reverse-proxy-with-apache/>`_
- `How To Use Apache as a Reverse-Proxy with mod_proxy on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-use-apache-http-server-as-reverse-proxy-using-mod_proxy-extension-ubuntu-20-04>`_
