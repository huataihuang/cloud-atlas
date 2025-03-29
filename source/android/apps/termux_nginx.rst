.. _termux_nginx:

==========================
Termux环境安装配置Nginx
==========================

我在Termux中安装 :ref:`sphinx_doc` 以及 ``mkdocs`` 来撰写文档。由于都是最终转换成html文档进行阅读，所以需要有一个简单的 :ref:`nginx` 服务来提供build之后的html文档浏览。

- 安装nginx::

   apt install nginx

按照Termux的安装目录，nginx配置文件位于 ``/data/data/com.termux/files/usr/etc/nginx`` 目录::

   fastcgi.conf  fastcgi_params  koi-utf  koi-win  mime.types  nginx.conf  scgi_params  uwsgi_params  win-utf

配置
=========

- 简单浏览一下 ``nginx.conf`` 就可以看到默认配置 ``8080`` 端口:

.. literalinclude:: termux_nginx/nginx.conf_origin
   :language: bash
   :caption: nginx默认配置

由于 :ref:`sphinx_doc` 以及 ``mkdocs`` 分别将build的html目录存储在不同位置，需要配置 :ref:`nginx_root_alias` 来实现:

  - 访问 ``cloud-atlas/`` 目录则访问 ``/data/data/com.termux/files/home/docs/github.com/cloud-atlas/build/html`` 目录
  - 访问 ``works/`` 目录则访问 ``/data/data/com.termux/files/home/docs/works/site`` 目录

- 添加以下段落增加 ``alias`` 配置

.. literalinclude:: termux_nginx/nginx.conf_alias
   :language: bash
   :caption: nginx增加alias工作目录

参考
=======

- `NginX : alias and location <https://stackoverflow.com/questions/31599884/nginx-alias-and-location>`_ 
