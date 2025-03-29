.. _apache_simple_config:

====================
Apache 简单配置
====================

.. note::

   好久好久没有使用 Apache 了，突然发现简单的配置也可能并不简单

配置Apache
=============

- 从 ``/etc/apache2/apache2.conf`` 可以看到完整的配置说明，以及指定环境变量 ``/etc/apache2/envvars`` ：需要修改 ``/etc/apache2/envvars`` 配置运行进程的 ``uid/gid`` 以便能够访问我自己的个人目录::

   export APACHE_RUN_USER=huatai
   export APACHE_RUN_GROUP=staff

- 默认配置 ``/etc/apache2/sites-enabled/000-default.conf`` ::

   #DocumentRoot /var/www/html
   DocumentRoot /home/huatai/docs/github.com/huataihuang/cloud-atlas/build/html

- 重启::

   systemctl restart apache2.service

排查 ``Forbidden``
======================

这里有一个问题，浏览器访问时提示错误::

   Forbidden

   You don't have permission to access this resource.

从 ``/var/log/apache2/error.log`` 可以看到::

   [Wed Mar 22 20:26:03.790868 2023] [authz_core:error] [pid 56382:tid 140055863621184] [client 192.168.6.36:56366] AH01630: client denied by server configuration: /home/huatai/docs/github.com/huataihuang/cloud-atlas/build/html/

可以看到这里导致错误的模块是 ``authz_core`` ( **[authz_core:error]** )，也就是认证错误，所以要找认证相关的配置问题。

考虑到上文我修改了默认的 ``DocumentRoot`` 目录，会不会是这个原因呢?

恢复默认配置::

   DocumentRoot /var/www/html
   #DocumentRoot /home/huatai/docs/github.com/huataihuang/cloud-atlas/build/html

果然，重启apache2服务之后，就可以访问WEB页面了

接下来的问题就是，修改 ``DocumentRoot`` 为何会导致无法访问?

修订过 ``DocumentRoot`` 之后，在Apache2中，需要为目录配置允许覆盖默认目录配置拒绝(改为允许)，所以需要改为:

.. literalinclude:: apache_simple_config/000-default.conf
   :caption: 简单的启用目录访问WEB /etc/apache2/sites-enabled/000-default.conf
   :emphasize-lines: 4-11

参考
=====

- `Apache giving 403 forbidden errors <https://stackoverflow.com/questions/18447454/apache-giving-403-forbidden-errors>`_
