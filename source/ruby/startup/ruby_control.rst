.. _ruby_control:

=================
Ruby控制语句
=================

控制语句分类
================

- 顺序控制: 按照程序编写的顺序，从头到尾执行
- 条件控制: 如果某条件成立，则执行A，否则执行B
- 循环控制: 在某条件成立之前，反复执行A
- 异常控制: 发生某种异常时，执行A

.. note::

   ruby的控制语句其实和 :ref:`shell` 差不多，但是做了一些更接近英语自然语言的精简，所以使用起来更自然一些。

   你把它想象成用英语对话就行了

条件控制
=========

在 Ruby 中 ``=`` 已经被用作赋值运算，所以判断是否相等的运算符使用两个=，也就是 ``==``

``if`` 判断案例:

.. literalinclude:: ruby_control/if_then_else.rb
   :language: ruby
   :caption: if then else 条件判断控制案例

.. note::

   :ref:`shell` 中使用 ``fi`` 来结尾条件控制，有点尬。ruby直接说 ``end``

while循环
============

.. literalinclude:: ruby_control/while.rb
   :language: ruby
   :caption: while 循环案例

times固定循环次数
======================

``ruby`` 为固定循环次数的循环提供了 ``times`` 方法(语法糖):

.. literalinclude:: ruby_control/times.rb
   :language: ruby
   :caption: times 固定次数循环案例

在 ``ruby`` 中 ``times`` 方法被称为迭代器( ``iterator`` )。

此外， ``ruby`` 还提供了很多有特色的迭代器，例如 ``each`` 方法

迭代器( ``iterator`` )标识的是循环( ``iterate`` )的容器( ``-or`` )；类似的，运算符( ``operator`` )也是运算( ``operate`` )的容器( ``-or`` )。总之，迭代器就是指用于执行循环处理的方法。

参考
========

- 「Ruby基础教程」
