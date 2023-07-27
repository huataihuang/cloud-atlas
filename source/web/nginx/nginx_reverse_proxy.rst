.. _nginx_reverse_proxy:

======================
Nginx反向代理
======================

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
