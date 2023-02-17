.. _apache_vs_nginx:

====================
Apache Vs NGINX
====================

Apache HTTP Server
=====================

`Apache HTTP Server <https://httpd.apache.org/>`_ 是非常稳定发展的HTTP WEB服务器。从1995年作为 ``httpd`` 发布依赖，已经成为最成功的开源项目(Apache软件基金会成为众多重量级开源项目的支持者)。

和 :ref:`nginx` (WEB服务器+反向代理)不同，Apache httpd是纯粹的WEB服务器，在长期的开发过程中，积累了大量的核心模块功能，可以说是功能最全面的WEB服务器

NGINX
=======

取长补短
=========

虽然NGINX在静态内容服务上性能卓越(比Apache快)，但是核心模块功能不及Apache，对于特定的服务需求(例如 :ref:`webdav` )需要使用第三方模块，部署配置复杂且可能无法达到一致的软件质量(第三方模块停止发展)。所以，在动态内容服务上，可以采用Apache来弥补NGINX的不足。

.. figure:: ../../_static/web/apache/nginxwithapache.png
   :scale: 80
   
   NGINX结合Apache: Apache负责动态内容，NGINX负责静态内容

参考
======

- `Apache Vs NGINX – Which Is The Best Web Server for You? <https://serverguy.com/comparison/apache-vs-nginx/>`_ 
