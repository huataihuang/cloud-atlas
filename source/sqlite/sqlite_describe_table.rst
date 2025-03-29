.. _sqlite_describe_table:

=====================
SQLite描述表格
=====================

在使用 :ref:`mysql` 这样的常规SQL数据库时，我们通常会使用 ``describe <table_name>`` 来检查一个表的结构，那么在SQLite中有没有相同或类似的命令呢？

``.schema``
===============

SQLite提供了一个 ``.schema`` 命令来获取表格创建的命令，这样就能对应知道表的结构信息:

.. literalinclude:: sqlite_describe_table/schema
   :caption: 通过 ``.schema`` 命令获取表格信息

.. note::

   这里执行 ``.schema <table_name>`` 时不要在命令结尾添加 ``;`` ，否则会导致没有输出信息

案例以 :ref:`rails_quickstart` 中表 ``tweets`` 为例，输出信息如下:

.. literalinclude:: sqlite_describe_table/schema_output
   :caption: 通过 ``.schema`` 命令获取表格 ``tweets`` 可以看到该表创建命令

通过 ``.schema`` 输出的创建表命令，实际上和我们常见的 ``describe <tables_name>`` 有些不同，那么怎么更为直观简单地显示表结构呢？

SQLite还提供了一个 ``pragma`` 命令来显示表结构

``pragma``
================

通过以下命令使用 ``pragma`` 命令可以显示 ``tweets`` 表结构:

.. literalinclude:: sqlite_describe_table/pragma
   :caption: 通过 ``pragma`` 命令展示表结构

查询 ``sqlite_schema``
=========================

.. note::

   注意， ``sqlite_schema`` 表是 SQLite 3.33.0 引入的，在这个版本之前不存在。旧版本的表名是 ``sqlite_master`` !!!

   也就是说，如果你使用的SQLite版本早于 3.33.0 ，则查询 ``sqlite_master`` 表。我的实践在 SQLite 3.32.3 上完成(因为我的macOS是古早的11.7.10 Big Sur，所以通过 :ref:`homebrew` 安装只有 SQLite 3.32.3)，此时就必须查询 ``sqlite_master`` ，否则会报错::

      Error: no such table: sqlite_schema

和上述 ``.schema`` 方法类似，可以直接查询 ``sqlite_schema`` 表来获得指定表名的创建SQL命令:

.. literalinclude:: sqlite_describe_table/sqlite_schema
   :caption: 通过查询 ``sqlite_schema`` 可以获得指定表名的创建命令

输出表的创建SQL:

.. literalinclude:: sqlite_describe_table/sqlite_schema_output
   :caption: 通过查询 ``sqlite_schema`` 获得指定表名的创建命令输出举例

参考
======

- `SQLITE TUTORIAL: SQLite Describe Table <https://www.sqlitetutorial.net/sqlite-describe-table/>`_
- `SQLite ForumDocumentation issue (wrong table name) in FAQ, point 7 <https://sqlite.org/forum/forumpost/d90adfbb0a>`_

