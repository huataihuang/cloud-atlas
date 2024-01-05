.. _intro_pgsql:

=====================
PostgreSQL简介
=====================

.. note::

   PostgreSQL和MySQL对比，可以参考知乎问答 `PostgreSQL 与 MySQL 相比，优势何在？ <https://www.zhihu.com/question/20010554>`_

PostgreSQL vs. MySQL
=======================

作为开源领域最著名的两大RDBMS，PostgreSQL和MySQL各有千秋：

- PostgreSQL对SQL标准支持以及内建功能和可扩展性超越MySQL，特别适合构建大型的功能复杂的数据库系统

  - 对于地理系统(GIS)，PostgreSQL内建了支持，这是MySQL所缺乏的功能

- PostgreSQL稳定性超过MySQL，但在较为简单的应用场景中MySQL占优

  - 大多数应用都没有使用到复杂的SQL功能，即使是互联网巨头的应用系统，其实也只是追求性能以及将RDBMS作为简单的数据记录和快速查询，依靠的是自定义开发软件系统来实现复杂的商业逻辑，对RDBMS功能要求其实不高。所以大多数互联网公司都会选择MySQL作为数据库系统，以便自己定制和开发商业软件。互联网公司的数据库选择并不能为上述两个数据库系统对比做背书，实际上仅仅是一个特殊应用场景。


.. note::

   所有对比都具有先决条件，所谓稳定性和性能对比，实际上都需要在特定运行和维护条件下对比，没有绝对的优劣。一切以自己的实际使用为准。我这里仅做引述，后续逐步补充自己的实践。

PostgreSQL特点
================

- PostgreSQL支持多种编程语言编写的存储过程和函数，除了PostgreSQL系统自带的编程语言，还通过插件支持不同语言( PL/Perl , PL/Python , PL/V8 即 PL/JavaScript , PL/R )。这种多语言支持特性对于解决特定领域问题非常有价值，开发人员可以根据需求来选择最合适的语言。
- PostgreSQL支持调用C语言编写的函数，可以在一个SQL语句中调用不同语言编写的多个函数，甚至仅使用SQL语言(无过程话能力的纯sQL)来创建用户自定义聚合函数。PostgreSQL可以不用编译任何代码就创建非常复杂的函数。
- PostgreSQL支持用户自定义数据类型，使用简便并且性能卓越: 用户可以在PostgreSQL中定义新的数据类型，然后就可以用这个自定义用户类型来作为表列类型。此外hi可以为新增数据类型定义运算符、函数和索引绑定来协同工作。很多第三方PostgreSQL扩展包就是利用自定义数据类型能力来优化性能，或者添加支持某个领域专用的特殊SQL语法来让业务代码更整洁和易于维护，或实现特殊功能。

PostgreSQL的对安全要求较高，带来了复杂的安全管理和一些性能消耗，所以对于简单的单用户场景并不适合。并且PostgreSQL功能及其强大，正如其Logo的大象一样即强大又智慧，所以驾驭这样一个大型数据库系统，需要使用者投入很多时间和精力进行学习、调试、开发。

在线文档
==========

PostgreSQL有非常丰富的在线文档:

- `PostgreSQL官方手册 <https://www.postgresql.org/docs/>`_
- `Planet PostgreSQL <https://planet.postgresql.org>`_ 
- `PostgreSQL Wiki <https://wiki.postgresql.org/wiki/Main_Page>`_

参考
=======

- 「PostgreSQL即学即用」
