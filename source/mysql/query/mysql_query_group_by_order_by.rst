.. _mysql_query_group_by_order_by:

==================================
MySQL查询数据GROUP BY和ORDER BY
==================================

MySQL的查询计数非常简单，通过 ``COUNT ... GROUP BY`` 可以对指定字段进行计数，为了方便排序， ``COUNT`` 字段应该有一个 ``alias`` :

.. literalinclude:: mysql_query_group_by_order_by/sql_group_order.sql
   :language: sql
   :caption: 统计字段数量，并且进行排讯

参考
======

- `Ordering by specific field value first <https://stackoverflow.com/questions/14104055/ordering-by-specific-field-value-first>`_
