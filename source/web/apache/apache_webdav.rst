.. _apache_webdav:

====================
Apache WebDAV服务器
====================

正如 :ref:`apache_vs_nginx` 所述，NGINX核心模块功能有限，对于 :ref:`webdav` 的完整功能支持需要依赖第三方模块，部署和配置复杂。而Apache httpd服务，则在核心模块提供了丰富的功能，可以方便配置部署WebDAV服务。

.. note::

   后续我准备将 :ref:`joplin_sync_webdav` 从 :ref:`nginx_webdav` 改为Apache WebDAV，主要考虑方便配置，同时学习Apache的配置管理。

   待续

参考
=====

- `Enabling WebDAV in Apache httpd <https://access.redhat.com/articles/10636>`_
- `How To Configure WebDAV Access with Apache on Ubuntu 18.04 <https://www.digitalocean.com/community/tutorials/how-to-configure-webdav-access-with-apache-on-ubuntu-18-04>`_
- `Apache Module mod_dav <https://httpd.apache.org/docs/2.4/mod/mod_dav.html>`_
- `How to create a webdav server with Apache <https://www.filestash.app/2022/03/04/apache-webdav/>`_
