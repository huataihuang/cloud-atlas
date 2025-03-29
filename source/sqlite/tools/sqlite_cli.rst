.. _sqlite_cli:

==================
SQLite命令行交互
==================

SQLite主要是通过API接口提供不同语言的开发使用，例如 :ref:`rails` 默认内置SQLite作为无需配置的数据库进行开发，在 :ref:`rails_quickstart` 中，通过非常简单的module就可以对数据库进行增删改查操作。

为了能够配合开发过程的数据检查，虽然我们可以通过API开发简单的查询和简单，但是命令行方式交互，也不失为运维验证的手段。所以，SQLite也提供了常规的命令行交互，方便完成基本运维。

sqlite3
===========

``sqlite3`` 是访问和处理SQLite 数据库文件的简单命令行工具。

- ``sqlite3 数据库名`` 可以打开指定文件名的数据库，如果这个数据库文件不存在，则会自动创建这个新数据库文件

.. note::

   以下实践以 :ref:`rails_quickstart` 案例中已经生成的数据库文件 ``storage/development.sqlite3`` 为例

   这里假设已经按照 :ref:`rails_quickstart` 完成了第一条记录插入(通过Rails的console交互对象，向 ``tweet`` 对象，也就是数据库表 ``tweets`` 插入了数据)

- 打开数据库 ``sqlite3 storage/development.sqlite3`` :

.. literalinclude:: sqlite_cli/open_db
   :caption: sqlite3打开数据库

此时提示信息有一个help提示，表示输入 ``.help`` 能够看到帮助

.. literalinclude:: sqlite_cli/open_db_output
   :caption: sqlite3打开数据库时提示
   :emphasize-lines: 2

.. note::

   ``sqlite3`` 使用 ``.`` 开头表示交互命令，所有命令可以先通过 ``.help`` 查看命令列表，再一点点查看具体帮助

插入数据
===========

在 :ref:`rails_quickstart` 中，使用Rails的models对象创建的 ``tweets`` 默认就添加了 ``created_at`` 和 ``updated_at`` 字段，而且当使用Rails的model对象操作时，无需手工指定时间戳就能够自动添加当前时间。

但是，需要注意到，如果同样使用 ``sqlite3`` 交互命令插入数据库记录，则 ``created_at`` 和 ``updated_at`` 是需要人为提供时间戳的，否则会提示错误


参考
======

- `Command Line Shell For SQLite <https://www.sqlite.org/cli.html>`_
