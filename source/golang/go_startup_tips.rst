.. _go_startup_tips:

====================
Go起步Tips
====================

.. note::

   本文面向小白(我)的随手记，比较杂乱

Go是静态类型语言，也就是编译时即确定变量类型，变量类型不可错误使用，否则编译时报错。

变量类型
=============

``reflect`` 包提供了 ``TypeOf`` 函数可以返回参数类型:

.. literalinclude:: go_startup_tips/reflect_typeof.go
   :language: go
   :caption: 使用 reflect.TypeOf 获取类型

``=`` 和 ``:=`` 区别
========================

- ``=`` 表示赋值
- ``:=`` 表示声明变量并赋值，并且系统自动推断类型，不需要var关键字

.. literalinclude:: go_startup_tips/go_variables.go
   :language: go
   :caption: 使用 ``:=`` 声明变量并赋值

``for`` 循环 ``range`` (键值)
===============================

``for ... range`` 是Go语言特有的迭代结构，可以遍历数组、切片、字符串、map以及通道(channel)。非常类似于其他语言的 ``foreache`` 语句::

   for key, val := range coll {
       ...
   }

注意:

- ``val`` 始终为集合中对应索引的值拷贝，因此它一般只具有只读性质，对它所做的任何修改都不会影响到集合中原有的值
- 通过 ``for range`` 遍历的返回值具有一定的规律:

  - 数组、切片、字符串返回索引和值
  - map返回键和值
  - 通道(channel) 只返回通道内的值

举例:

.. literalinclude:: go_startup_tips/for_range.go
   :language: go
   :caption: ``for...range`` 获得map的键和值

参考
==========

- ``《Head First Go语言程序设计》``
- `Go 语言中 = 和 := 有什么区别 <https://segmentfault.com/q/1010000007160096>`_
