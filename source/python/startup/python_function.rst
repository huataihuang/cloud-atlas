.. _python_function:

==================
Python函数
==================

实参和形参
===========

- 形参(parameter)是函数的所需输入信息
- 实参(argument)是调用函数时传递给函数的信息

.. literalinclude:: python_function/confirmed_user.py
   :caption: 函数以及参数的案例
   :language: python

Python是 **动态类型语言** 函数调用时不会强制检查暗黄实参和形参的类型是否匹配。也就是说，即使定义了形参是字符串，传入的是int也不会抛异常。

但是，IDE(PyCharm/ :ref:`vscode` )会给出自动补全和警告，静态检查会在运行前发现类型错误。虽然不是强制，但是强烈建议定义形参的类型，能起到"文档作用"，告诉调用者"这里期望什么类型"。

函数调用
==========

- 函数构建应该在形参上提供类型指引(如果没有默认值)

.. literalinclude:: python_function/describe_pet.py
   :language: python
   :caption: 函数调用，形参和实参的对应

返回字典
============

函数可以返回任何类型的值，包括列表和字典等比较复杂的数据结构

- 在python 3.9+，允许使用一种可选形参的方式，例如 ``build_person(first_name: str, last_name: str | None, age: str | None,)`` ，也就是传递参数 ``first_name`` 是必须的，另外两个参数可选
- 在python 3.10+，可以使用一种字典值类型的"联合类型"写法，相当于旧写法的 ``Union[str,int]`` ，现在可以写成 ``dict[str, str | int]`` 表示这个字典的值可以是字符串也可以是整数

.. literalinclude:: python_function/build_person.py
   :language: python
   :caption: 构建person的字典

传递列表
============

向函数传递列表，能够传递大量数据。此外，还可以传递更复杂的数据结构

.. literalinclude:: python_function/greet_users.py
   :language: python
   :caption: 为传入的人名打印简单问候

上述代码片段，gemini的改进建议:

- 列表改成 ``Sequence`` ，因为只是传递一系列数据，没有使用list特有的方法(如 ``.append()`` , ``.pop()`` )，所以使用list有大才小用
- 打印最好由调用方返程，函数内部仅提供数据处理，并且函数返回列表能够被进一步进行处理，而不是仅仅在函数中固定进行打印
- 增加异常处理能力，避免传入函数的是空

.. literalinclude:: python_function/greet_users_optimize.py
   :language: python
   :caption: 改进的传入的人名打印简单问候

在函数中修改列表
--------------------

将列表传递给函数以后，函数就可以对其进行修改。在函数中对这个列表中所做的任何修改都是永久的，这样能够高效地处理大量数据。

.. literalinclude:: python_function/printing_models.py
   :language: python
   :caption: 模拟打印设计文件

上述程序中，由于向 ``print_models`` 函数传入了列表 ``unprinted_designs`` ，所以能够通过修订列表来做整体修改。但是这个函数完成之后， ``unprinted_designs`` 已经被清空，所以如果需要保留这个列表，需要用另外一种传入副本的方式来实现。这里有一个技巧，就是采用 ``print_models(unprinted_designs[:], completed_models)`` ，注意这里传递 ``unprinted_designs`` 列表时使用了 ``[:]`` 。不过，通常函数都是使用现成的列表以避免花实践和内存创建副本，从而提高效率，在处理大型列表时尤其如此。

传递任意数量的实参
--------------------

有时候不知道函数需要接受多少个实参，所以python提供一种允许函数从调用语句中收集任意数量实参的方法:

.. literalinclude:: python_function/topping.py
   :caption: 制作披萨传入不同的配料，任意数量的实参是元组(不可修改)

这里有需要注意的是:

- 传入的 ``tappings`` 是 :ref:`python_tuple` :

  - 元组是不可修改的数据对象，函数内部拿到的 ``tappings`` 是调用时的快照，如果是列表就有可能被函数内部或外部的任意一方意外修改，都会产生 **难以追踪的副作用**
  - 元组是hashable的，不可变的对象可以安全第共享、缓存、用作字典键
  - CPython内部对元组的处理比列表更省内存、更快(定长、无需扩容)

- 在Python函数中，像 ``*tappings`` 这样的形参，单个 ``*`` 表示传入的是元组 ``tuple``

使用任意数量的 ``关键字`` 实参
--------------------------------

有时候需要接受任意数量的实参，但是预先不知道传递给函数的会是什么样的信息，这时候，可以将函数编写成能够接受任意数量的 **键值对** : 这里的案例是创建用户简介，知道将受到有关用户的信息，但是不确定是什么样的信息，这样通过接受任意数量的关键字实参来实现:

.. literalinclude:: python_function/user_profile.py
   :language: python
   :caption: 传入用户信息(不定数量kv)

函数存储在模块中
===================

使用函数的优点之一是可以将代码块和主程序分离。通过给函数指定描述性名称，能让程序容易理解得多。并且，将函数存储在称为模块的独立文件中，再将模块导入(import)主程序。 ``import`` 语句可以在当前运行的程序文件中使用模块中的代码。

通过将函数存储在独立的文件中，可以隐藏程序代码的细节，将重点放在程序的高层逻辑上。而且能在众多不同的程序中复用函数。

.. literalinclude:: python_function/import
   :caption: 导入函数

可以导入模块，也可以导入模块中的特定函数。

另外，为了避免导入函数的名称太长或者避免导入函数与程序中既有的名称冲图，还可以在导入函数的时候为函数起一个别名(alias):

.. literalinclude:: python_function/import_alias
   :caption: 导入函数时将函数重命名为一个独一无二的别名
