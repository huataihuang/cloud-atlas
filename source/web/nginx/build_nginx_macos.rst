.. _build_nginx_macos:

============================
macOS环境编译NGINX
============================

为了 :ref:`nginx_webdav` 能够实现完整的

编译采用独立的安装目录，并且对于NGINX的依赖软件包进行源代码编译，这样可以不依赖 :ref:`homebrew` 实现完整的软件堆栈:

- 安装 ``--prefix`` 目录选择 ``/opt/nginx``


编译
====================

- (预先)配置编译环境 :ref:`cppflags_ldflags` :

.. literalinclude:: build_nginx_macos/build_env
   :language: bash
   :caption: 编译环境参数

.. note::

   这里我偷懒了，一次性设置好多个依赖软件包的头文件和库文件环境变量。实际最好是每个依赖软件编译安装完成后再设置对应的环境变量。不过，这里没有什么影响

- PCRE2 - 支持常用表达式，对于NGINX Core 和 Rewrite 模块都需要

.. literalinclude:: build_nginx_macos/build_pcre2
   :language: bash
   :caption: 编译 PCRE2

- zlib - 支持HTTP 头压缩，对于NGINX Gzip 模块需要

.. literalinclude:: build_nginx_macos/build_zlib
   :language: bash
   :caption: 编译 zlib

- OpenSSL - 支持HTTPS协议，对于NGINX SSL模块等需要

.. literalinclude:: build_nginx_macos/build_openssl
   :language: bash
   :caption: 编译 OpenSSL

- 为 :ref:`nginx_webdav` 准备第三方NGINX模块 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ :

.. literalinclude:: build_nginx_macos/nginx-dav-ext-module
   :language: bash
   :caption: 准备第三方 nginx-dav-ext-module 源代码目录

- NGINX - 启用 :ref:`webdav` (使用第三方模块)

.. literalinclude:: build_nginx_macos/build_nginx
   :language: bash
   :caption: 下载NGIX最新源代码 v1.23.3

以上编译安装NGNIX支持 :ref:`nginx_webdav` ，就可以进一步完成配置实现 :ref:`joplin_sync_webdav`
 
参考
======

- `Building nginx from Sources <http://nginx.org/en/docs/configure.html>`_
- `NGINX: Installation and Compile-Time Options <https://www.nginx.com/resources/wiki/start/topics/tutorials/installoptions/>`_
- `NGINX Admin Guide: Compiling and Installing from Source <https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#compiling-and-installing-from-source>`_
- `Compiling Modules <https://www.nginx.com/resources/wiki/extending/compiling/>`_
- `How to Build NGINX from Source on Ubuntu 20.04 LTS <https://www.alibabacloud.com/blog/how-to-build-nginx-from-source-on-ubuntu-20-04-lts_597793>`_
- `Compiling and Installing NGINX from Source <https://medium.com/t%C3%BCrk-telekom-bulut-teknolojileri/nginx-is-an-open-source-web-server-software-designed-to-use-as-a-web-server-reverse-proxy-http-7e0cd0bab12>`_
