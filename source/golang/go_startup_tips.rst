.. _go_startup_tips:

====================
Go起步Tips
====================

.. note::

   本文随手记，比较杂乱

Go是静态类型语言，也就是编译时即确定变量类型，变量类型不可错误使用，否则编译时报错。

变量类型
=============

``reflect`` 包提供了 ``TypeOf`` 函数可以返回参数类型:

.. literalinclude:: go_startup_tips/reflect_typeof.go
   :language: go
   :caption: 使用 reflect.TypeOf 获取类型

参考
==========

- ``《Head First Go语言程序设计》``
