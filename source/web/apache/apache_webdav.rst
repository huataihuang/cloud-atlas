.. _apache_webdav:

====================
Apache WebDAV服务器
====================

正如 :ref:`apache_vs_nginx` 所述，NGINX核心模块功能有限，对于 :ref:`webdav` 的完整功能支持需要依赖第三方模块，部署和配置复杂。而Apache httpd服务，则在核心模块提供了丰富的功能，可以方便配置部署WebDAV服务。

.. note::

   后续我准备将 :ref:`joplin_sync_webdav` 从 :ref:`nginx_webdav` 改为Apache WebDAV，主要考虑方便配置，同时学习Apache的配置管理。

激活 :ref:`webdav` Apache模块
=================================

- Apache web服务器提供了很多模块，通过 ``a2enmod`` 工具可以激活或关闭，使用以下命令激活:

.. literalinclude:: apache_webdav/apache_enable_webdav
   :caption: Apache web server激活 :ref:`webdav` 模块

- 重启apache:

.. literalinclude:: apache_webdav/apache_restart
   :caption: 重启Apache web server

配置 :ref:`webdav`
===================

- 创建 :ref:`joplin` 存储目录::

   mkdir /home/huatai/docs/joplin

- :ref:`webdav` 需要存储一个数据库文件来管理 :ref:`webdav` 用户存取文件的所，这个锁文件必须被Apache能够读写，但是不能被web网站访问到以免泄露安全信息。创建目录::

   mkdir /home/huatai/docs/var

上述目录在Apache配置中存放 ``DavLock`` 锁文件

采用 :ref:`apache_basic_auth` 方法，结合 :ref:`webdav` :

.. literalinclude:: apache_webdav/000-default.conf
   :caption: webdav结合 :ref:`apache_basic_auth`
   :emphasize-lines: 1,16-18,20-24

.. note::

   你会注意到，我在 ``/`` 和 ``/joplin`` 两次配置了 :ref:`apache_basic_auth` ::

      AuthType Basic
      AuthName "Restricted Content"
      AuthUserFile /etc/apache2/.htpasswd
      Require valid-user

   我最初以为 ``/joplin`` 会集成上一级的目录配置，但是实际上并不是，需要为每个目录配置认证，否则会类似 :ref:`apache_simple_config` 那样由于默认安全限制无法访问 ``/joplin`` 

参考
=====

- `Enabling WebDAV in Apache httpd <https://access.redhat.com/articles/10636>`_
- `How To Configure WebDAV Access with Apache on Ubuntu 18.04 <https://www.digitalocean.com/community/tutorials/how-to-configure-webdav-access-with-apache-on-ubuntu-18-04>`_
- `Apache Module mod_dav <https://httpd.apache.org/docs/2.4/mod/mod_dav.html>`_
- `How to create a webdav server with Apache <https://www.filestash.app/2022/03/04/apache-webdav/>`_
