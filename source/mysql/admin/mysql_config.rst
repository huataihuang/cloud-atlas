.. _mysql_config:

==========================
MySQL配置文件 ``my.cnf``
==========================

全局配置 ``my.cnf``
=====================

MariaDB将原先传统的 ``/etc/my.cnf`` 拆分到 ``/etc/my.cnf.d`` 目录下的多个配置文件::

   auth_gssapi.cnf
   client.cnf
   cracklib_password_check.cnf
   enable_encryption.preset
   mariadb-server.cnf
   mysql-clients.cnf
   spider.cnf

并通过原先的 ``/etc/my.cnf`` 进行包含:

.. literalinclude:: mysql_config/my.cnf
   :caption: MariaDB的全局配置文件 ``/etc/my.cnf``
   :emphasize-lines: 10

.. note::

   实际上 ``my.cnf`` 可以决定MySQL运行的很多特性，贸然调整可能会引发问题，所以建议先从系统默认配置开始，参考手册，逐步调整优化。例如，修订客户端连接数量

个人MySQL配置 ``.my.cnf``
===========================

用户可以在自己的个人目录下配置一个 ``~/.my.cnf`` 来设置自己个人的mysql配置选项，通常可以配置mysql的客户端用户名和账号，例如:

.. literalinclude:: mysql_config/home_my.cnf
   :caption: 用户个人目录下 ``~/.my.cnf`` 配置访问账号

这样就能够非常方便地访问 :ref:`install_mariadb` 最后快速创建的数据库(只需要执行 ``mysql`` 就能访问默认需要访问的开发数据库)

.. note::

   为了能够保障自己的 ``~/.my.cnf`` 不被其他人访问，可以修改文件权限::

      chmod 700 ~/.my.cnf

参考
=======

- `MySQL 8.0 Reference Manual >> Using Option Files <https://dev.mysql.com/doc/refman/8.0/en/option-files.html>`_
- `MySQL configuration file example <https://www.ibm.com/docs/en/ztpf/2022?topic=performance-mysql-configuration-file-example>`_
- `oinume/my.cnf <https://gist.github.com/oinume/fc9b72bd8b14ab07e94c>`_
- `MySQL 8 sample config (my.cnf example) and tuning. <https://linuxblog.io/mysql-8-sample-config-tuning/>`_
- `Configuring MySQL with .my.cnf file <https://tomlankhorst.nl/mysql-my-cnf-options-file/>`_
