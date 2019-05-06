.. _mysql:

=================================
MySQL Atlas
=================================

MySQL是使用最广泛的开源数据库，很多开源项目都会在后端使用MySQL数据库。在 :ref:`studio` 规划中，云计算集群OpenStack使用了MySQL的开源社区分支 `MariaDB <https://mariadb.org>`_ ，所以，我后续的实践将在此基础上实现：

- 扩展高可用MySQL数据库集群
- 实现数据库性能监控和调优
- 数据库备份和恢复
- 构建MySQL的DAAS

.. toctree::
   :maxdepth: 1

   install_mysql.rst
   vitess.rst
   deploy_vitess.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
