.. _odps_sql_json:

======================
ODPS SQL处理JSON数据
======================

.. literalinclude:: odps_sql_json/select_json
   :caption: odps sql查询语句提取JSON数据

这里遇到一个类型错误，原表字段是 ``string`` ，但是要使用 ``JSON_EXTRACT`` 函数需要输入的字段是 ``json`` **对象** (可能类似 :ref:`mysql` 在odps中， :ref:`json` 也是作为对象)，需要做一次转换。也就是说，即使存储在 ``string`` 类型的字段里是一个正确的JSON数据，也必须先转换成JSON对象才能够使用 ``JSON_EXTRACT`` 函数来处理。否则就会出现以下错误:

.. literalinclude:: odps_sql_json/select_json_err
   :caption: odps sql查询语句执行 ``JSON_EXTRACT`` 函数因为字段类型错误而报错

字符串转JSON
===============

ODPS SQL提供了和 :ref:`mysql` 一样的 ``JSON_PARS`` 函数，可以直接将字符串转换成(视为)JSON对象，这样就能够提供给 ``JSON_EXTRACT`` 函数处理，所以上述SQL修订为

.. literalinclude:: odps_sql_json/select_json_parse
   :caption: odps sql查询语句提取JSON数据，使用 ``JSON_PARSE`` 将字符串转换为JSON

JSON类型转换成字符串
=======================

在完成了JSON处理后，如果还需要将数据插入到字符串字段中，此时又会需要一次JSON转换到字符串的函数操作，可以使用 ``CAST`` 函数: ``CAST(alert_json AS STRING)``

.. note::

   MySQL提供了一个 ``JSON_UNQUOTE()`` 可以将JSON转换成STRING，不过这个函数在ODPS SQL没有提供

参考
=========

- ODPS(Maxcompute) SQL引擎: 内建函数 >> 复杂类型函数
- `how to convert mysql json_object to string? <https://stackoverflow.com/questions/75647604/how-to-convert-mysql-json-object-to-string>`_ 这是json对象转换成字符串的案例
- `Convert String to JSON in MySQL <https://www.techieclues.com/blogs/convert-string-to-json-in-mysql>`_
