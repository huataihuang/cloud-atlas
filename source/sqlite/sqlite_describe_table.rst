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

案例以 :ref:`rails_quickstart` 中表 ``tweets`` 为例，输出信息如下:

.. literalinclude:: sqlite_describe_table/schema_output
   :caption: 通过 ``.schema`` 命令获取表格 ``tweets`` 可以看到该表创建命令


参考
======

- `SQLITE TUTORIAL: SQLite Describe Table <https://www.sqlitetutorial.net/sqlite-describe-table/>`_
