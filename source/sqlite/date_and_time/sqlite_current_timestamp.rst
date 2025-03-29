.. _sqlite_current_timestamp:

===================================
SQLite ``current_timestamp`` 函数
===================================

SQLite ``current_timestamp`` 函数可以返回格式为 ``YYYY-MM-DD HH:MM:SS`` 的 UTC 当前日期和时间

默认时间戳
===========

在 :ref:`rails_quickstart` 中，使用Rails的models对象创建的 ``tweets`` 默认就添加了 ``created_at`` 和 ``updated_at`` 字段，而且当使用Rails的model对象操作时，无需手工指定时间戳就能够自动添加当前时间。

但是，需要注意到，如果同样使用 ``sqlite3`` 交互命令插入数据库记录，则 ``created_at`` 和 ``updated_at`` 是需要人为提供时间戳的，否则会提示错误:

.. literalinclude:: sqlite_current_timestamp/insert
   :caption: 在数据库表插入数据时没有提供 ``created_at`` 和 ``updated_at``

此时报错:

.. literalinclude:: sqlite_current_timestamp/insert_error
   :caption: 在数据库表插入数据时没有提供 ``created_at`` 和 ``updated_at`` 报错信息

此时解决方法是使用 ``CURRENT_TIMESTAMP`` :

.. literalinclude:: sqlite_current_timestamp/insert_current_timestamp
   :caption: 插入时提供当前时间戳
   :language: sql

数据库表默认时间戳
===================

要避免手工插入 ``CURRENT_TIMESTAMP`` ，可以修订数据库表，增加默认时间戳为 ``CURRENT_TIMESTAMP``

.. note::

   怎么修订列添加默认值？等我再学习一下 :ref:`sql`

一个案例:

.. literalinclude:: sqlite_current_timestamp/default_current_timestamp
   :caption: 创建表的时间字段可以添加默认current_timestamp
   :language: sql

参考
=========

- `SQLITE TUTORIAL: SQLite current_timestamp Function <https://www.sqlitetutorial.net/sqlite-date-functions/sqlite-current_timestamp/>`_
