.. _typescript_type:

=======================
TypeScript 类型(type)
=======================

TypeScript语言既然命名中有 ``Type`` ，也就表明这项语言注重于类型检测: 和 ``静态类型检测`` 语言(在不运行代码情况下检测代码中的错误)一样，TypeScript在执行前检查程序是否有错误，并根据值的类型进行检查。

- 建议采用明确的变量类型声明，以便编译器能够自动找出明显的类型错误

对象
=======

- 使用 ``{}`` 创建对象:

.. literalinclude:: typescript_type/object_simple_example.ts
   :language: typescript
   :caption: 把值声明为object类型

- 结构中声明变量类型:

.. literalinclude:: typescript_type/object_simple_example_name.ts
   :language: typescript
   :caption: 简单的TypeScript对象

和类相同:

.. literalinclude:: typescript_type/object_simple_example_class.ts
   :language: typescript
   :caption: 类声明

类型别名(Type Aliases)
=========================

使用类型别名(Type Aliases, 建议命名采用首字母大写)可以帮助我们定义更容易理解的结构:

.. literalinclude:: typescript_type/type_aliases.ts
   :language: typescript
   :caption: 类型别名(Type Aliases)案例

并集(union)类型和交集(intersection)类型
========================================

TypeScript提供了特殊的类型运算符来处理类型的并集和交集:

- 并集使用 ``|``
- 交集使用 ``&``

.. literalinclude:: typescript_type/type_union_intersection.ts
   :language: typescript
   :caption: 并集(union)和交集(intersection)

数组(array)
==============

- 数组 ``[]`` 是特殊类型对象，支持拼接，推入，搜索和切片
- 一般情况下，数组中类型应该同质: 要么存储数字要么存储字符串，这样如果有不同类型的数据推入，TypeScript可以提示错误，方便程序排障

.. literalinclude:: typescript_type/array.ts
   :language: typescript
   :caption: 简单的数组类型示例

元组(tuple)
-------------

元组是数组的子类型，是定义数组的一种特殊方法:

- 元组长度固定
- 元组的各个索引位上的值具有固定的已知类型
- 声明元组的时候必须显式注解类型

.. literalinclude:: typescript_type/tuple.ts
   :language: typescript
   :caption: 简单的元组类型示例

元组支持可选的元素，在对象的类型中 ``?`` 表示可选:

.. literalinclude:: typescript_type/tuple_option.ts
   :language: typescript
   :caption: 简单的元组类型示例(可选字段)

枚举(enum)
================

.. literalinclude:: typescript_type/enum.ts
   :language: typescript
   :caption: 简单的枚举类型示例




参考
========

- O'REILLY 《TypeScript编程》
