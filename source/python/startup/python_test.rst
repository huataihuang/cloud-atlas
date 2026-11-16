.. _python_test:

=================
Python测试
=================

pytest
==========

``pytest`` 是用于测试的第三方包:

.. literalinclude:: python_test/install_pytest
   :caption: 安装pytest

或者使用发行版安装

.. literalinclude:: python_test/install_pytest_apt
   :caption: apt安装pytest

测试举例
==========

一个简单的例子是 ``names.py`` 调用 ``name_function.py`` 中的 ``get_formatted_name`` 函数，输出正确的话应该是将输入的 ``first_name`` 和 ``last_name`` 拼接成 ``full_name`` (首字母大写)。使用 ``pytest`` 来自动运行针对函数的测试，实际上就是使用断言 ``assert`` 来确认输入某个字符案例，输出是否符合预期:

- ``names.py`` :

.. literalinclude:: python_test/names.py
   :language: python
   :caption: ``names.py``

- ``name_function.py`` :

.. literalinclude:: python_test/name_function.py
   :language: python
   :caption: ``name_function.py``

- ``test_name_function.py`` :

.. literalinclude:: python_test/test_name_function.py
   :language: python
   :caption: ``test_name_function.py``

测试要点:

- ``pytest`` 会搜索目录下所有 ``test_`` 开头的文件并运行其中所有测试
- ``test_name_function.py`` 定义的测试函数 ``test_first_last_nme()`` ，每个以 ``test_`` 开头的函数会被 ``pytest`` 调用并运行
- 断言(assertion) ``assert`` 关键字就是声称满足特定的条件

- 在目录下运行 ``pytest`` 命令，就会看到输出:

.. literalinclude:: python_test/pytest_output
   :caption: 运行 ``pytest`` 输出
   :emphasize-lines: 7

模拟失败测试
---------------

修订 ``name_function.py`` ，假设现在添加了一个 ``middle`` 形参，本意是为这个函数增加一个处理 ``middle name`` 的功能:

.. literalinclude:: python_test/name_function_middle.py
   :language: python
   :caption: 增加 ``middle`` 形参的函数修改

再次执行 ``pytest`` 就会看到测试不通过

.. literalinclude:: python_test/pytest_output_err
   :caption: 测试未通过
   :emphasize-lines: 14,16

这是因为测试用例需要保证只有 ``fist name`` 和 ``last name`` 的案例通过，这是一个功能要求。现在新编写的 ``name_function.py`` 显然破坏了这个功能，也就是要允许输入2个参数时候就生成2个字段的 ``full_name`` 而不是类型报错

修订 ``name_function.py`` 改成 ``middle`` 形参可选:

.. literalinclude:: python_test/name_function_middle_fix.py
   :language: python
   :caption: 修复，增加判断，middle可选

此时运行 ``pytest`` 就证明了只输入2个参数用例恢复正常。

增加测试用例
--------------

上面的两个输入参数正常了，但是软件开发的新功能是也要能够适应输入3个参数的情况，所以修订 ``test_name_function.py`` 增加3个参数的测试用例:

.. literalinclude:: python_test/test_name_function_middle.py
   :language: python
   :caption: ``test_name_function.py`` 增加测试middle参数
   :emphasize-lines: 10

现在测试 ``pytest -v`` 可以详细看到2个测试用例都通过了:

.. literalinclude:: python_test/pytest_output_middle
   :caption: 测试2个用例
   :emphasize-lines: 8,9
