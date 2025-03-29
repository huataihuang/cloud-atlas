.. _openstack_env_db:

============================
OpenStack环境数据库
============================

OpenStack使用SQL数据库存储大多数信息，数据库可以安装在管控服务器上，也可以独立部署（适合更大规模集群）。常用数据库可以采用 MariaDB或MySQL数据库，此外OpenStack也支持PostgreSQL数据库。

.. note::

   初次安装部署可以采用简化安装MySQL系统，后续升级成采用 :ref:`run_vitess_locally` 集成高可用MySQL集群。

   案例首次安装在 ``worker1`` 服务器上安装单机版 mariadb。

安装和配置数据库
==================

- 安装数据库软件包::

   yum install mariadb mariadb-server python2-PyMySQL

- 创建 ``/etc/my.cnf.d/openstack.cnf`` 配置文件::

   [mysqld]
   bind-address = 192.168.1.1

   default-storage-engine = innodb
   innodb_file_per_table = on
   max_connections = 4096
   collation-server = utf8_general_ci
   character-set-server = utf8

.. note::

   这里 ``bind-address`` 是物理主机 ``worker1`` 的网卡地址，OpenStack将使用这个绑定地址来访问数据库。

- 启动数据库服务::

   systemctl enable mariadb.service
   systemctl start mariadb.service

- 执行 ``mysql_secure_installation`` 脚本设置数据库安全::

   mysql_secure_installation
