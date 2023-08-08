.. _mysql_query_date_time:

=======================
MySQL查询日期和时间
=======================

查询当前日期和时间:

.. literalinclude:: mysql_query_date_time/current_date_time
   :language: sql
   :caption: 在MySQL中查询当前日期和时间

找出两个时间之间的记录:

.. literalinclude:: mysql_query_date_time/between_two_timestamps
   :language: sql
   :caption: 找出两个时间戳之间记录

统计
=========

- 统计一定时间范围内按照天的告警计数，这里使用 ``date()`` 可以按天合并统计:

.. literalinclude:: mysql_query_date_time/count_rows_per_day
   :caption: 按照每天统计告警数量

输出案例:

.. literalinclude:: mysql_query_date_time/count_rows_per_day_output
   :caption: 按照每天统计告警数量输出案例

- 如果要按照小时进行统计也类似，只不过需要注意小时数据排序时默认是ASCII排序，需要转换成数值排序:

.. literalinclude:: mysql_query_date_time/count_rows_per_hour_order_by_number
   :caption: 按照小时统计排序

输出案例:

.. literalinclude:: mysql_query_date_time/count_rows_per_hour_order_by_number_output
   :caption: 按照小时统计排序输出案例

参考
======

- `How to Query Date and Time in MySQL <https://popsql.com/learn-sql/mysql/how-to-query-date-and-time-in-mysql>`_
- `The Ultimate Guide To MySQL DATE and Date Functions <mysqltutorial.org/mysql-date/>`_
- `MySQL - count rows per day <https://dirask.com/posts/MySQL-count-rows-per-day-D6BLnD>`_
- `SQL order string as number <https://stackoverflow.com/questions/11808573/sql-order-string-as-number>`_ 数据查询按字段排讯默认是ASCII顺序，有时候我们需要按照数字大小排序，这里提供了很好的案例
