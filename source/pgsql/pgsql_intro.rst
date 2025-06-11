.. _pgsql_intro:

=====================
PostgreSQL简介
=====================

RDB(relational database)
===========================

关系数据库(relation database, RDB)是建立在关系模型基础伤的数据库，借助于集合袋鼠等数学概念和方法来处理数据库中大数据。关系模型是IBM公司的E. F. Codd于1970年在「A Relational Model of Data for Large Shared Data Banks」论文中提出，奠定了现代数据库的基础。

结构化查询语言(Structured Query Language, :ref:`sql` )是大多数RDBMS提供的查询和更新数据库的语言。

RDB是数据存储和检索的基石，虽然不断有各种 :ref:`nosql` (在特定应用场景)尝试替代RDB，但是RDBMS也不断吸收新的技术自我迭代发展，例如PostgreSQL，成为更为全面和强大的数据管理系统。

.. note::

   油管博主"原子能": `为什么关系数据库的挑战者都没有好下场【让编程再次伟大#25】 <https://www.youtube.com/watch?v=IUUpxfa1SSw>`_


PostgreSQL历史渊源
=====================

PostgreSQL最早由加州伯克利计算机系开发的 ``POSTGRES v4.2`` (POSTGRES项目最早于1986年实现，于1993年终止4.2版本)为基础的对象关系型数据库管理系统(ORDBMS)继承而来，最初以 ``Postgres95`` 发布源代码。第一次正式发布 ``PostgreSQL`` 是上世纪1996年，版本以 ``6.0`` 开始。

PostgreSQL支持大部份SQL标准并提供了很多现代特性，并且提供了多种方法扩展。PostgreSQL使用了较为宽松的许可证，任何人都可以以任何目的免费使用、修改和分发PostgreSQL。

当前(2024年12月)，PostgreSQL已经发展到 v17.2 ，是最先进的开源数据库。

.. note::

   PostgreSQL的缩写是 ``pgsql`` (我最初想要找到一个类似 :ref:`mysql` 一样简短的缩写来减少自己的输入):

   - `PostgreSQL手册 附录 L. 首字母缩写词 <http://www.postgres.cn/docs/current/acronyms.html>`_ 权威列出了PostgreSQL文档中常用的缩略词列表，其中 ``PGSQL`` 代表的 ``PostgreSQL``
   - 很多PostgreSQL的内置函数使用了 ``pg_XXXX`` ，所以 ``pg`` 可以看作是 ``Postgres`` 的缩写，而 ``POSTGRES`` 是 PostgreSQL 的前身和继承
   - 虽然 ``psql`` 是 PostgreSQL 的客户端名字，但是单字母 ``p`` 用作函数缩写部分不容易区分

PostgreSQL vs. MySQL
=======================

.. note::

   PostgreSQL和MySQL对比，可以参考知乎问答 `PostgreSQL 与 MySQL 相比，优势何在？ <https://www.zhihu.com/question/20010554>`_

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
- `PostgreSQL官方手册中文版 <http://www.postgres.cn/docs/current/index.html>`_ 版本略微落后，但是非常方便快速阅读
- `Planet PostgreSQL <https://planet.postgresql.org>`_ 
- `PostgreSQL Wiki <https://wiki.postgresql.org/wiki/Main_Page>`_

学习资料:

- `《PostgreSQL 内参：深入解析运行原理》 <https://postgres-internals.cn/>`_ `xiongcccc <https://github.com/xiongcccc>`_ 翻译自 Egor Rogov 所著的 `《PostgreSQL 14 Internals》 <https://postgrespro.com/community/books/internals>`_  ，是深入学习PostgreSQL原理(也是数据库原理)的电子书。不过，这本书不是入门书，需要有基本的PostgreSQL使用和管理基础，但非常推荐。
- `PostgreSQL官方网站电子书(索引) <https://www.postgresql.org/docs/books/>`_ 提供了PostgreSQL相关电子书列表，可以选择学习

参考
=======

- 「PostgreSQL即学即用」
