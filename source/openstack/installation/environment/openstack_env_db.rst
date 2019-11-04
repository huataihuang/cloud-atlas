.. _openstack_env_db:

============================
OpenStack环境数据库
============================

OpenStack使用SQL数据库存储大多数信息，数据库可以安装在管控服务器上，也可以独立部署（适合更大规模集群）。常用数据库可以采用 MariaDB或MySQL数据库，此外OpenStack也支持PostgreSQL数据库。

.. note::

   初次安装部署可以采用简化安装MySQL系统，后续升级成采用 :ref:`run_vitess_locally` 集成高可用MySQL集群。
