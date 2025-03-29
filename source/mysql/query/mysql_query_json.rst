.. _mysql_query_json:

=======================
MySQL查询JSON
=======================

.. note::

   本文是一个实践案例，更为详细的MySQL JSON数据处理，请参考 :ref:`using_json_in_mariadb`

JSON数据
===========

在生产环境中，应用数据交换往往会采用 :ref:`json` 进行。这些交换数据可能会存放在数据库中，形成一条JSON(字段)记录，例如:

.. literalinclude:: mysql_query_json/alert.json
   :language: json
   :caption: MySQL记录中的JSON数据记录举例

这里有一个问题，我们的告警记录会合并多条相同告警到一个JSON记录中，对于后期统计报表(从mysql查询)，我们实际上只关注这个JSON数组中第一个值(后面都是重复的)

.. note::

   如果使用阿里云的 :ref:`maxcompute` ODPS SQL 支持 :ref:`odps_sql_json` ，也有类似函数 ``json_extract``

测试数据
==========

我采用 `How to Query JSON column in MySQL <https://ubiq.co/database-blog/how-to-query-json-column-in-mysql/>`_ 案例来学习实践:

- 先快速 :ref:`install_mariadb` ，初始化一个简单的测试数据库

- 创建一个 ``json`` 字段的:

.. literalinclude:: mysql_query_json/create_json_table
   :language: sql
   :caption: 创建包含 ``json`` 数据的简单表

- 插入数据库测试数据:

.. literalinclude:: mysql_query_json/insert_json_table
   :language: sql
   :caption: 插入测试数据

.. note::

   这里我遇到一个 :ref:`using_json_in_mariadb` 相关的报错 :ref:`mariadb_error_4025_constraint_fail` ，原因是 `How to Query JSON column in MySQL <https://ubiq.co/database-blog/how-to-query-json-column-in-mysql/>`_ 提供的SQL源代码有一些格式错误( :ref:`json` 的object形式需要通过 ``,`` 分隔每个键值 )，我通过 :ref:`jq` 工具检查和校对(上文代码已经修正)

- 查询插入的json数据:

.. literalinclude:: mysql_query_json/select_json_table
   :language: sql
   :caption: 查询json测试数据

输出如下:

.. literalinclude:: mysql_query_json/select_json_table_output
   :caption: 查询json测试数据输出结果

一切就绪，我们开始尝试检索(retrieve) JSON字段数据

``JSON_EXTRACT`` 函数
=========================

从MySQL version >= 5.7 开始，提供了 ``JSON_EXTRACT`` 函数可以用来检索JSON数据:

.. literalinclude:: mysql_query_json/json_extract
   :language: sql
   :caption: 使用 ``JSON_EXTRACT`` 函数检索JSON

此时就会看到提取出对应 ``key`` 的 ``value`` :

.. literalinclude:: mysql_query_json/json_extract_output
   :caption: 使用 ``JSON_EXTRACT`` 函数检索JSON输出案例

处理array
------------

回到本文开头提到的告警数据，是一个 :ref:`json` 的array结构:

.. literalinclude:: mysql_query_json/alert.json
   :language: json
   :caption: MySQL记录中的JSON数据记录举例

对于这个案例，我需要提取出 array[0] 中的object的键值，则在 ``JSON_EXTRACT`` 函数中使用 ``$[index].key`` 方式，也就是先指定数组下标(array index)，然后再取出key对应的value。这样语句就是:

.. literalinclude:: mysql_query_json/json_extract_array
   :language: sql
   :caption: 使用 ``JSON_EXTRACT`` 函数检索JSON的array

参考
======

- `How to search JSON data in MySQL? <https://stackoverflow.com/questions/30411210/how-to-search-json-data-in-mysql>`_
- `How To Work with JSON in MySQL <https://www.digitalocean.com/community/tutorials/working-with-json-in-mysql>`_
- `How to Query JSON column in MySQL <https://ubiq.co/database-blog/how-to-query-json-column-in-mysql/>`_
- `MySQL 8.0 Reference Manual >> Functions That Search JSON Values <https://dev.mysql.com/doc/refman/8.0/en/json-search-functions.html>`_
