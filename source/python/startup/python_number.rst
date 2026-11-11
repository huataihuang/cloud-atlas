.. _python_number:

===================
Python 数(number)
===================

变量
======

- 将任意两个数相除，结果总是浮点数，即便这两个数都是整数且能整除
- 在书写很大的数时，可使用下划线将其中的位分组，使其更清晰易读

.. literalinclude:: python_number/large_number.py
   :language: python
   :caption: 大数用下划线分组

- 多个数字同时赋值:

.. literalinclude:: python_number/multi_number.py
   :language: python
   :caption: 多个数赋值

常量
========

Python没有内置的常量类型，但是Python程序员会使用全大写字幕来指出应将某个变量视为常量，其值应始终不变:

.. literalinclude:: python_number/const_number.py
   :caption: 全大写的变量视为常量

参考
======

- 『Python编程从入门到实践』
