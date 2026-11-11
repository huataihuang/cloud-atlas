.. _python_string:

==================
Python字符串
==================

f字符串
========

.. literalinclude:: python_string/f_string.py
   :language: python
   :caption: f字符串案例
   :emphasize-lines: 4

f字符串，f是 ``format`` (设置格式)的简写

大写/小写/首字母大写
======================

.. literalinclude:: python_string/f_string_case.py
   :language: python
   :caption: 字符大小写和首字母大写
   :emphasize-lines: 5-7

删除空白
===========

- 字符串左侧删除空白 ``lstrip()``
- 字符串右侧删除空白 ``rstrip()``

删除前缀
=========

- 删除前缀 ``removeprefix()``
- 删除后缀 ``removesuffix()``

.. literalinclude:: python_string/removeprefix.py
   :language: python
   :caption: 删除前缀

参考
======

- 『Python编程从入门到实践』
