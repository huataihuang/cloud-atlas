.. _grafana_mysql_data_source:

========================
Grafana使用MySQL数据源
========================

Grafana内置提供了MySQL数据源插件，也就是可以直接查询和可视化MySQL兼容的数据库数据。

这在日常运维工作中非常有用，因为大多数后端开发和运维工程师都不擅长前端开发，自己使用框架开发图表虽然也可行，但是毕竟效率较低，且很难达到Grafana这样专业的水准。虽然各大互联网公司都有自己的大数据平台和可视化报表系统，但是专有闭源平台往往非常沉重使用不变。对于个人和中小型公司，实际上使用 Grafana 结合数据库就能构建非常好的BI系统。

准备工作
==========

- 首先完成 :ref:`install_mariadb` ，获得可运行和访问的MySQL数据库:

.. literalinclude:: ../../../mysql/installation/install_mariadb/mariadb_startup
   :caption: 快速安装、启动和初始化MariaDB

.. literalinclude:: ../../../mysql/installation/install_mariadb/create_db_user
   :caption: 创建一个数据库并创建访问账号及授权

- 比较简单的方式是通过程序脚本、日志系统，向MySQL数据库加载数据

参考
=======

- `Grafana documentation > Data sources > MySQL <https://grafana.com/docs/grafana/latest/datasources/mysql/>`_
