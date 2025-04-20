.. _swift_types_contants_variables:

========================
Swift的类型，常量和变量
========================

常量(contants)和变量(variables)具有数据类型，类型描述了数据的本质以及编译器处理数据的信息(分配多少内存，并进行类型检查)。

Swift 根据 ``""`` (双引号)扩起的字符串来推断变量的类型是 ``字符串`` ，也就是说 ``"2"`` 是字符串类型，而 ``2`` 是数值类型:

``+=`` 操作可以连接字符串，也能够累加数值，就取决于操作的变量类型: Swift 会自动判断

.. literalinclude:: swift_types_contants_variables/str_num_var.swift
   :language: swift
   :caption: 根据操作的变量类型来推断操作符

上述这种不明确指定变量类型而由Swift根据 ``""`` (双引号) 来判断其实不利于写出清晰的代码，所以通常应该类似C语言那样明确指定变量类型:

.. literalinclude:: swift_types_contants_variables/num_var.swift
   :language: swift
   :caption: 明确指定变量类型 ``Int``

这里需要注意Swift语句使用的 ``var`` 表示是变量声明(对应的常量声明则使用 ``let`` 关键字)，也就是语法如下:

.. literalinclude:: swift_types_contants_variables/var.swift
   :caption: 变量声明

类似，在定义常量时使用 ``let`` 关键字:

.. literalinclude:: swift_types_contants_variables/constant.swift
   :caption: 常量声明

如果常量名称是元组形式，则元组的每一项名称都会和初始化表达式中对应的值进行绑定:

.. literalinclude:: swift_types_contants_variables/constant_tuple.swift
   :language: swift
   :caption: 常量元组声明

.. warning::

   在没有给变量(variable)或常量(constant)赋值之前，Swift不允许你使用该变量或常量!

字符串插入(String Interpolation)
=================================

Swift提供了一个 ``string interpolation`` (字符串插入)功能，可以用来结合常量和变量插入到一个字符串中，形成一个新的字符串。你可以简单把这个语法功能理解为字符串连接，但是不需要反复使用 ``+=`` 这样的连接方式，而显得非常自然:

只需要在字符串中使用 ``\(变量或常量)`` 就可以在字符串中插入变量常量，就像写一个文档一样:

.. literalinclude:: swift_types_contants_variables/string_interpolation.swift
   :language: swift
   :caption: 字符串插入(String Interpolation)
