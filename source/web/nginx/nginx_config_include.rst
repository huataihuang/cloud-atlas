.. _nginx_config_include:

=========================
Nginx配置文件的include
=========================

在配置 :ref:`nginx_reverse_proxy_https` 时发现，其实很多段落的配置文件时重复的片段，特别是结合 :ref:`nginx_virtual_host` 时，不少配置项其实时不同片段的组合。这就类似于 :ref:`shell` 编程中的 ``source`` 指令，可以将共同的代码片段包含进来。

我拆解修订了 :ref:`nginx_reverse_proxy_https` 配置，来构建:

- 将所有共同的配置部分拆解成片段，按照目录树的方式分别存放到 ``/etc/nginx/includes`` 目录下
- 按照功能分子目录，例如 ``ssl`` 子目录存放TLS/SSL相关配置片段； ``proxy`` 子目录存放 :ref:`nginx_reverse_proxy`

实践案例
=========

:ref:`nginx_reverse_proxy_https` 配置

公网对外Nginx反向代理服务器
-----------------------------

- ``tree`` 输出配置文件列表:

.. literalinclude:: nginx_config_include/config_files
   :caption: ``tree`` 输出配置文件列表

- ``/etc/nginx/conf.d/cloud-atlas.dev.conf`` :

.. literalinclude:: nginx_config_include/cloud-atlas.dev.conf
   :caption: ``/etc/nginx/conf.d/cloud-atlas.dev.conf``

- ``/etc/nginx/includes/server_name.conf`` :

.. literalinclude:: nginx_config_include/server_name.conf
   :caption: ``/etc/nginx/include/server_name.conf``

- ``/etc/nginx/includes/proxy/proxy_set.conf`` :

.. literalinclude:: nginx_config_include/proxy_set.conf
   :caption: ``/etc/nginx/include/proxy/proxy_set.conf``

- ``/etc/nginx/includes/ssl/ssl_set.conf`` :

.. literalinclude:: nginx_config_include/ssl_set.conf
   :caption: ``/etc/nginx/include/ssl/ssl_set.conf``

.. note::

   将上述配置从 ``cloud-atlas.dev.conf`` 作为起点(类似于程序的 ``main()`` )，将不同的配置片段 ``include`` 进来，就可以看出整个配置的原貌。

后端Nginx配置
---------------

- ``tree`` 输出配置文件列表:

.. literalinclude:: nginx_config_include/config_files_backend
   :caption: ``tree`` 输出后端Nginx配置文件列表

- 后端Nginx配置 ``/etc/nginx/conf.d/cloud-atlas.dev.conf`` :

.. literalinclude:: nginx_config_include/cloud-atlas.dev.conf_backend
   :caption: 后端Nginx配置 ``/etc/nginx/conf.d/cloud-atlas.dev.conf``

- 后端Nginx配置 ``/etc/nginx/includes/server.conf`` :

.. literalinclude:: nginx_config_include/server.conf_backend
   :caption: 后端Nginx配置 ``/etc/nginx/includes/server.conf``

参考
======

- `How to Include Nginx Configuration Files and Where to Put Them <https://www.baeldung.com/linux/nginx-configuration-include-directive>`_
