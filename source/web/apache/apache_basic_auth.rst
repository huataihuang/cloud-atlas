.. _apache_basic_auth:

======================
Apache基本认证配置
======================

和 :ref:`nginx_basic_auth` 类似，可以配置简单的密码文件认证(其实这个方法就是 Apache 内置方法， :ref:`nginx` 也是借用Apache的工具实现)

- 安装Apache工具包:

.. literalinclude:: apache_basic_auth/install_apache2-utils
   :caption: 安装Apache工具

- 创建密码文件，这里创建了一个用户 ``huatai`` :

.. literalinclude:: apache_basic_auth/create_htpasswd
   :caption: 创建密码文件

如果要添加新用户，则去掉 ``-c``  参数(创建文件)就可以

- 配置访问控制，以 :ref:`apache_simple_config` 为基础进行配置:

.. literalinclude:: apache_basic_auth/000-default.conf
   :caption: 为 :ref:`apache_simple_config` 加上基本认证
   :emphasize-lines: 13-16

.. note::

   和 :ref:`apache_simple_config` 不同，必须去除原先取消安全限制的配置部分，即::

      <Directory "/home/huatai/docs/github.com/huataihuang/cloud-atlas/build/html">
          ...
          #AllowOverride All
          #Order allow,deny
          #Allow from all
          #Require all granted
          ...
      </Directory>

   否则认证会被覆盖掉(即不生效)

参考
========

- `How To Set Up Password Authentication with Apache on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-password-authentication-with-apache-on-ubuntu-20-04>`_
