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

条件控制
=========

在 Ruby 中 ``=`` 已经被用作赋值运算，所以判断是否相等的运算符使用两个=，也就是 ``==``

``if`` 判断案例:

.. literalinclude:: ruby_control/if_then_else.rb
   :language: ruby
   :caption: if then else 条件判断控制案例

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

在 ``ruby`` 中 ``times`` 方法被称为迭代器( ``iterator`` )。此外， ``ruby`` 还提供了很多有特色的迭代器，例如 ``each`` 方法

参考
========

- 「Ruby基础教程」
