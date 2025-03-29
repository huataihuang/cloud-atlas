.. _nginx_reverse_proxy:

======================
Nginx反向代理
======================

反向代理的优点
=================

Nginx反向代理将客户端清酒转发给一个或多个服务器，然后将后端服务器响应返还给客户端。这样大多数常规应用都运行在各自的web服务器上，而Nginx WEB服务器梓提供诸如负载均衡、TLS/SSL 以及特定应用程序所缺乏的加速功能:

- 负载均衡: 确保后端某个服务器宕机不影响
- 增加安全: 保护后端服务器不对外暴露
- 更好的性能: Nginx可以实现更好的静态内容以及URLs分析
- 简便的日志和审计: 由于集中在Nginx反向代理服务器入口，可以方便实现日志和审计
- 加密连接:  :ref:`nginx_reverse_proxy_https` 可以在客户端和Nginx反向代理服务器之间加密通讯，保护数据安全

说明
======

我在 :ref:`nginx_reverse_proxy_nodejs` 简单实现了NGINX反向代理。实际上，在很多时候NGINX的反向代理配置非常实用，例如:

- :ref:`grafana_behind_reverse_proxy` 为 :ref:`helm3_prometheus_grafana` 通过 ``NodePort`` 快速输出
- 为 :ref:`metallb_with_istio` 构建一个反向代理，使得public网络接口能够将流量转发给内网 :ref:`kubernetes` 集群上透过 :ref:`metallb` 输出的服务 **本文**

简单的反向代理
====================

- 在 ``/etc/nginx/sites-available/`` 目录下 配置一个基于域名的 ``vhost`` 配置 ``book-info`` :

.. literalinclude:: nginx_reverse_proxy/book-info
   :caption: 设置基于域名 ``vhost`` 反向代理到后端 :ref:`metallb_with_istio` 输出的WEB服务

- 在 ``/etc/nginx/sites-enabled/`` 为其建立软连接以激活配置:

.. literalinclude:: nginx_reverse_proxy/sites-enabled
   :language: bash
   :caption: 在 ``/etc/nginx/sites-enabled/`` 为其建立软连接以激活配置

参考
======

- `How to setup an Nginx reverse proxy server example <https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/How-to-setup-Nginx-reverse-proxy-servers-by-example>`_
- `Configuring an Nginx HTTPS Reverse Proxy on Ubuntu Bionic <https://www.scaleway.com/en/docs/tutorials/nginx-reverse-proxy/>`_
