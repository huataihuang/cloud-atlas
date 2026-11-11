.. _python_if:

================
Python if语句
================

python的 ``if`` 判断语句的语法:

.. literalinclude:: python_if/if_grammar.py
   :caption: ``if`` 判断语句语法

说明:

  - **冒号** : 每个条件语句结尾必须带有冒号 ``:``
  - **缩进** : Python依靠缩进(通常为4个空格)来划分代码块，没有大括号 ``{}``
  - **elif** : 是 ``else if`` 的简写，可以有多个或没有
  - **else** : 为可选部分，只能有一个

- 一个简单的案例就能看懂:

.. literalinclude:: python_if/cars.py
   :language: python
   :caption: 判断汽车品牌并按条件打印品牌

- 上面这个代码我写得啰嗦了，实际上应该结合 :ref:`python_list` ( ``in`` 或者 ``not in`` )来简化 ``or`` 判断:

.. literalinclude:: python_if/cars_optimize.py
   :language: python
   :caption: 采用列表优化or判断

- 结合 ``if`` 判断的 ``for`` 循环检查列表:

.. literalinclude:: python_if/topping.py
   :language: python
   :caption: ``for`` 循环检查列表并使用 ``if`` 判断

需要注意，在列表处理前做一个列表判断是否为空可以增加更多选项，判断语句非常简单 ``if requested_topping:`` 则 ``True`` 表示列表中有内容(非空)。

- 下面一个例子是类似于 《麦兜故事》里经典的 `鱼丸粗面 <https://www.bilibili.com/video/BV1hq4y167gF/>`_ 判断顾客点的配料是否有货:

.. literalinclude:: python_if/topping_available.py
   :language: python
   :caption: 判断配料是否有货

