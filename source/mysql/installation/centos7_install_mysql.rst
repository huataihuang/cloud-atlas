.. _centos7_install_mysql:

==========================
CentOS 7 安MySQL
==========================

我在部署 :ref:`django_env_linux` 遇到一个困境，现在安装 :ref:`django_mysql` 环境的 ``mysqlclient`` 始终编译报错。参考MariaDB官方文档 `How to connect Python programs to MariaDB <https://mariadb.com/resources/blog/how-to-connect-python-programs-to-mariadb/>`_ 看来官方已经改为 ``mariadb`` 作为Python的连接器。但是我现在不想改代码，所以我考虑重新安装原生的MySQL服务器来完成这个工作。

- 从MySQL官网获得Repo仓库包(根据不同操作系统): `MySQL Community Downloads: MySQL Yum Repository <https://dev.mysql.com/downloads/repo/yum/>`_ 安装::

   sudo rpm -ivh mysql80-community-release-el7-10.noarch.rpm

- 安装::

   sudo yum update
   sudo yum install mysql-server

- 对于 :ref:`django_mysql` 还需要安装 ``mysql-devel`` ::

   sudo yum install mysql-devel

- 启动::

   sudo systemctl start mysqld

启动错误排查
===============

我这里遇到一个启动失败的问题:

.. literalinclude:: centos7_install_mysql/status_mysqld_start_fail
   :caption: 启动 ``mysqld`` 失败，执行 ``systemctl status mysqld``
   :emphasize-lines: 8,9

.. literalinclude:: centos7_install_mysql/mysqld.log
   :caption: 检查 ``/var/log/mysqld.log`` 可以看到由于 ``/var/lib/mysql`` 目录非空导致初始化失败
   :emphasize-lines: 2-4,7

我检查了一下目录，发现下面是一些证书:

.. literalinclude:: centos7_install_mysql/mysql_data_directory_has_files
   :caption: 在 ``/var/lib/mysql`` 目录下有一些证书文件导致 ``mysqld`` 初始化无法完成

我之前安装过 MariaDB ，我尝试将 ``/var/lib/mysql`` 目录移除(会自动重建)，但是依然是同样的报错

我仔细看了 ``/var/log/mysqld.log`` 日志，发现 ``mysqld got signal 11`` 

搜索这个信号 ``11`` 表示: 遇到了一个bug。使用的mysql二进制文件或者它所使用的链接库之一已经损坏、构建不当或配置错误。这个错误也可能硬件故障引起，需要尝试手机一些错误诊断信息。由于这是一次崩溃并且肯定有问题，所以信息搜集过程也可能失败。

考虑到我使用的服务器是古老的CentOS 7.2(魔改aliOS)，所以我推测是操作系统不兼容导致的问题。具体如何排查，在官方bug中提供了建议: 激活Audit日志来找出哪些查询触发了bug(不过我这里是启动问题，和官方文档中所说的运行时sql查询触发的bug不同)

.. note::

   没有时间再折腾了，我最终决定还是将数据库切换到 MariaDB (Django也支持MariaDB 10.4以及更高版本)


参考
======

- `How To Install MySQL on CentOS 7 <https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7>`_
- `Bug #96113mysqld got signal 11 <https://bugs.mysql.com/bug.php?id=96113>`_
