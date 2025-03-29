.. _upgrade_mariadb:

=======================
升级MariaDB
=======================

为了完成在古老的CentOS7(aliOS 7.2)上部署 :ref:`django_mysql` ，遇到了非常折磨的问题，无法完成 ``mysqlclient`` Python模块编译安装。这个问题我最初想通过 :ref:`centos7_install_mysql` 来绕过，但是发现MySQL官方提供的 ``mysql-server`` 实际上已经无法在CentOS早期版本上运行(crash)。所以还是回到MariaDB安装，想通过社区提供的高版本MariaDB 10.11 来解决这个编译兼容问题。

由于已经安装过MariaDB 5.5，所以启动 MaraiDB 10.11 时候观察 ``systemctl status mariadb`` 可以看到提示需要升级系统表:

.. literalinclude:: upgrade_mariadb/status_mariadb
   :caption: ``systemctl status mariadb`` 提示需要升级系统表
   :emphasize-lines: 17-19

升级步骤似乎非常简单，主要就是使用 ``/bin/mysql_upgrade`` :

.. literalinclude:: upgrade_mariadb/mysql_upgrade
   :caption: 升级 mysql 数据库

输出显示:

.. literalinclude:: upgrade_mariadb/mysql_upgrade_output
   :caption: ``mysql_upgrade`` 升级 mysql 数据库输出信息显示正常

再次重启 MariaDB 观察状态，就可以看到所有输出信息正常:

.. literalinclude:: upgrade_mariadb/status_mariadb_after_upgrade
   :caption: 完成 ``mysql_upgrade`` 之后再次检查 ``mariadb`` 状态


参考
======

- `Upgrading MariaDB <https://mariadb.com/kb/en/upgrading/>`_ : `Upgrading from MariaDB 5.5 to MariaDB 10.0 <https://mariadb.com/kb/en/upgrading-from-mariadb-55-to-mariadb-100/>`_
