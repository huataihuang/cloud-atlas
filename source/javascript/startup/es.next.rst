.. _es.next:

================
ES.Next
================

``ES.Next`` 术语指代新版本的JavaScript.

``ES.Next`` 模块
==================

``ES.Next`` 模块允许将代码奉承多个文件，以提高维护性和可测试性。通过将逻辑封装成容易重用的代码，并且由于变量和珊瑚仅限于模块的作用于(scope)，你可以在 ``不同模块内使用`` **相同的变量名** 而不产生冲突。

命名导出和默认导出
====================

:ref:`nodejs` 有两种导出类型:

- 命名导出( ``named exports`` )
- 默认导出( ``default exports`` )

使用命名导出被认为是最佳实践，因为命名导出为模块的功能定一个清晰且唯一的接口。而默认导出，则可能会以不同的名称导入相同的函数。不过，命名导出，重命名也是可选的，使用 ``as`` 语句完成。

根据 :ref:`typescript` 建议，如果一个模块有明确的目的和 ``一个导出`` ，则使用默认导出。否则，建议在模块导出多个item时候使用命名导出。

以下是默认导出的案例(使用 ``default`` 关键字:

.. literalinclude:: es.next/default.js
   :caption: 默认导出的例子 ``default.js``

以下是命名导出的案例:

.. literalinclude:: es.next/named.js
   :caption: 命名导出的例子 ``named.js``

这里的命名导出定义了匿名函数(anonymous function)，存储常量 ``getFooBar`` ，然后立即导出；后面又定义了两个匿名函数，然后作为命名导出来导出。

.. note::

   匿名函数: lambda表达式 参见 `为什么匿名函数叫lambda 表达式？ <https://www.zhihu.com/question/27448188>`_

   无需定义标识符(函数名)的函数或子程序，称为匿名函数lambda。lambda函数没有名字，是一种简单的、在同一行定义函数的方法。

导入模块
===========

导入 ``ES.next`` 模块的语法取决于创建的导出类型:

- 命名导出的导入需要使用花括号 ``{}`` 导入
- 默认导出的导入则不需要花括号导入

.. literalinclude:: es.next/import_default.js
   :caption: 导入默认导出

.. literalinclude:: es.next/import_named.js
   :caption: 导入命名导出

.. note::

   在JavaScript中，花括号 ``{}`` 表示对象，中括号 ``[]`` 表示数组(array)

定义变量
===========

JavaScript提供了三种不同的变量声明方法:

- ``var``
- ``let``
- ``const``

变量作用域:

- 全局(global)
- 模块(module)
- 函数(function)
- 块(block): 块作用域适用于任何用花括号 ``{}`` 括起来的代码块，是作用域最小单位

注意， ``函数作用域`` 可以包含 **多个** ``块作用域``

提升变量(Hoisted Variables)
=============================

注意，在 JavaScript 中， ``var`` 顶底变量会自动提升到范围的顶部。也就是说，在Java和C语言中，不能在变量声明前使用变量；而在JavaScript中，解析器会自动将所有使用 ``var`` 关键字定义的变量声明移动到范围的顶部，这样在写代码的时候，就可以先写使用变量，后写变量声明，这和先声明再使用的实际效果一致。

在现代JavaScript中引入了 ``let`` 关键字来补充 ``var`` :

- 使用 ``let`` 声明的 **块作用域变量** ，并且必须先声明再使用( ``let`` 声明的变量被视为 **非提升变量** )
- 使用 ``let`` 声明的 **全局变量** 不会添加到 ``window对象`` 中( ``var`` 全局变量会自动称为window对象的成员，全局对象和全局函数也是这样) 

现代JavaScript还引入了 ``const`` 关键字用于声明常量。和 ``let`` 一样， ``const`` 在全局声明是不会创建全局对象的属性，也被视为非提升类型(non-hoisted)，也就是说， ``const`` 常量在声明之前无法访问。

JavaScript中的常量域其他语言不同，只是看起来不可变( ``look immutable`` )。实际上只是对其值的只读引用。对原始数据( ``primitive data`` )类型的变量标识符不能直接修改值，但是对于对象和数组则是非原始类型数据，则即使使用了 ``const`` 也可以通过方法或者直接属性访问来改变值。(也就是 ``const`` 对于数组和对象是不能限制其中元素的修改)

- 以下程序片段演示 ``const`` 对原始数据变量和非原始数据变量(数组)的修改:

.. literalinclude:: es.next/primitive.js
   :caption: 对原始数据变量和非原始数据变量使用 ``const`` 的区别

箭头函数(Arrow Functions)
=============================

现代JavaScript引入了箭头函数(Arrow Functions)作为常规函数的替代方案。

简单来说 ``=>`` 箭头左方是函数的参数，箭头右方是函数的表达式，也就是简单计算以后要返回一个值:

.. literalinclude:: es.next/simple_arrow.js
   :caption: 简单的匿名函数改成箭头函数的例子
   :emphasize-lines: 5

箭头函数的两个概念:

- 箭头函数语法简单，只需要几个字符和一行代码
- 箭头函数使用了 ``词法作用域`` ，更为直观不易出错

箭头函数有些类似匿名函数lambda，但是区别在于: 箭头函数内部的 ``this`` 是词法作用域，由上下文确定。

- 箭头函数 ``this`` 总是指向词法作用域

.. literalinclude:: es.next/getAge.js
   :caption: 箭头函数的 ``this`` 调用案例(廖雪峰 JavaScript教程)

- 可以将传统的匿名函数逐步分解为最简单的箭头函数:

.. literalinclude:: es.next/lambda_arrow.js
   :caption: 传统匿名函数如何逐步转为简单的匿名函数

注意，只有当函数只有一个简单参数时，才能省略括号。如果函数由多个参数、无参数、默认参数、重组参数或其余参数，则需要在参数列表周围加上括号:

.. literalinclude:: es.next/multi_var_arrow.js
   :caption: 多参数箭头函数

词法作用域(Lexical Scope)
==========================

.. literalinclude:: es.next/scope.js
   :caption: 词法作用域案例

输出结果是:

.. literalinclude:: es.next/scope.js_output
   :caption: 词法作用域案例输出结果

参考
=======

- `Mozilla开发社区JavaScript箭头函数表达式 <https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions>`_
- `廖雪峰的官方网站: JavaScript教程 >> 箭头函数 <https://liaoxuefeng.com/books/javascript/function/arrow-function/>`_
