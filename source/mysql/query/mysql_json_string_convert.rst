.. _mysql_json_string_convert:

============================
MySQL中JSON和STRING互相转换
============================

在 :ref:`mysql_query_json` 中，对于MySQL而言，字段类型JSON和STRING是不同类型，例如不能直接将 JSON 数据插入STRING字段，也不能直接用处理JSON的 ``JSON_EXTRACT()`` 函数来直接处理STRING字符串。此时我们需要使用转换函数进行类型转换 

字符串转JSON对象
====================

MySQL提供了 ``JSON_PARSE()`` 函数将字符串转换成JSON对象:

.. literalinclude:: mysql_json_string_convert/json_parse
   :language: sql
   :caption: 使用 ``JSON_PARSE()`` 函数将字符串转换成JSON对象例子

JSON对象转字符串
===================

``JSON_UNQUOTE()`` 函数可以将JSON转换字符串

.. literalinclude:: mysql_json_string_convert/json_unquote
   :language: sql
   :caption: 使用 ``JSON_UNQUOTE()`` 函数将JSON对象转为字符串

参考
=======

- `how to convert mysql json_object to string? <https://stackoverflow.com/questions/75647604/how-to-convert-mysql-json-object-to-string>`_
- `Convert String to JSON in MySQL <https://www.techieclues.com/blogs/convert-string-to-json-in-mysql>`_
