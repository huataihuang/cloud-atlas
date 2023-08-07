.. _install_mariadb:

=============
安装MariaDB
=============

MariaDB是开源关系型数据库，和MySQL兼容并且用于替代MySQL。这是因为Oracle收购了SUN公司之后拥有了MySQL，潜在影响了MySQL开源。所以MySQL社区基于原先MySQL fork出了新的开源项目MariaDB，并得到了众多Linux发行版支持。从CentOS 7开始，MiriaDB已经取代了MySQL作为默认数据库系统。

快速起步
==========

实际上在CentOS上安装部署并启动MariaDB只有3条命令，所以可以快速完成:

.. literalinclude:: install_mariadb/mariadb_startup
   :caption: 快速安装、启动和初始化MariaDB

安装
=========

- 执行以下命令安装:

.. literalinclude:: install_mariadb/yum_install_mariadb
   :caption: 在CentOS上安装 MariaDB

建议同时安装 ``mariadb`` 和 ``mariadb-devel`` 软件包，方便后续开发

.. note::

   CentOS 7操作系统通过EPEL安装mariadb，需要注意EPEL提供的mariadb的版本很低，和最新的版本不兼容，带来很多开发移植上的不变。所以，我建议不要使用EPEL提供的版本，而是采用 `MariaDB官方软件仓库 <https://mariadb.org/download/#mariadb-repositories>`_ 安装。即将网站提供的 ``MariaDB.repo`` 存放到 ``/etc/yum.repos.d`` 目录下，然后执行安装::

      sudo yum install MariaDB-server MariaDB-client

- 启动数据库:

.. literalinclude:: install_mariadb/start_mariadb
   :caption: 启动MariaDB

手工启动数据库
-----------------

.. note::

   如果直接使用上文操作系统发行版安装MariaDB数据库，则已经自动初始化数据库了。无需本段手工初始化和手工启动，本段落只适用于需要重建数据库的情况。

- 首先初始化系统数据库目录和系统表::

   sudo -u mysql mysql_install_db

默认数据库位于 ``/var/lib/mysql``

- 启动数据库::

   /usr/bin/mysqld_safe 

- 通过 ``mysqld_safe`` 启动启动的数据库可以通过 ``mysqladmin`` 关闭::

   mysqladmin shutdown

启动数据库报错排查
~~~~~~~~~~~~~~~~~~~

我遇到一个问题，发现数据库启动失败， ``/var/log/mariadb/mariadb.log`` 记录::

   210207 14:16:06 [ERROR] mysqld: Can't find file: './mysql/plugin.frm' (errno: 13)
   210207 14:16:06 [ERROR] Can't open the mysql.plugin table. Please run mysql_upgrade to create it.
   210207 14:16:06 [Note] Server socket created on IP: '0.0.0.0'.
   210207 14:16:06 [ERROR] mysqld: Can't find file: './mysql/host.frm' (errno: 13)
   210207 14:16:06 [ERROR] Fatal error: Can't open and lock privilege tables: Can't find file: './mysql/host.frm' (errno: 13)
   210207 14:16:06 mysqld_safe mysqld from pid file /var/run/mariadb/mariadb.pid ended

但是，前面执行 ``mysql_install_db`` 实际上已经创建了 ``/var/lib/mysql/`` 目录并存储了数据库文件在 ``/var/lib/mysql/mysql/host.frm`` 。

实际上仔细查看了文件权限发现，原来 ``mysql_install_db`` 命令必须使用 ``mysql`` 用户来执行，否则创建的 ``/var/lib/mysql/mysql`` 目录以及该目录下文件都是属于root用户的。不过，mysql用户账号默认是 ``nologin`` ，所以需要使用 ``sudo -u mysql`` 方式来运行。

数据库安全加固
====================

- 使用 ``root`` 用户身份登陆系统，执行以下数据库默认安全加固脚本:

.. literalinclude:: install_mariadb/mysql_secure_installation
   :caption: 执行初始化安全加固( **重要操作** )

上述脚本命令也可以直接手工执行::

   '/usr/bin/mysqladmin' -u root password 'new-password'
   '/usr/bin/mysqladmin' -u root -h `hostname` password 'new-password'

.. note::

   在MariaDB的高版本中默认安全策略只允许操作系统的 ``root`` 用户执行上述 ``mysql_secure_installation`` 安全加固脚本，以便首次以无密码方式登陆mysql的root账号。

创建数据库及授权
=====================

- 快速创建一个数据库并创建访问账号及授权:

.. literalinclude:: install_mariadb/create_db_user
   :caption: 创建一个数据库并创建访问账号及授权

从MySQL 8.0开始，默认字符集是 ``utf8mb4_0900_ai_ci``

参考
======

- `Install MariaDB on CentOS 7 <https://linuxize.com/post/install-mariadb-on-centos-7/>`_
- `Starting and Stopping MariaDB <https://mariadb.com/kb/en/starting-and-stopping-mariadb-automatically/>`_
