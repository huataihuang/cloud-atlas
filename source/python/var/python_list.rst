.. _python_list:

=================
Python列表
=================

列表(list)由一系列按特定顺序排列的元素组成。列表中通常包含多个元素(任何都可以加入列表，列表的元素可以没有任何关系)，因此给列表指定一个表示复数的名称(如letters, digits 或 names)是好方法。

在Python中，用方括号 ``[]`` 表示列表，用逗号分隔其中的元素。

访问列表元素
=============

Python中，第一个列表元素的索引是 ``0`` ，最后一个列表元素的索引是 ``-1``

修改、添加和删除元素
=======================

.. literalinclude:: python_list/motorcycles.py
   :language: python
   :caption: 对列表的操作

注意， ``remove()`` 只会删除列表中遇到的第一个匹配值，这就带来一个问题，如果在列表中有多个 "ducati" 需要删除该如何处理呢？

- 比较直观但是比较低效的方法是使用 ``while`` 循环结合 ``remove`` （原地修改列表):

.. literalinclude:: python_list/list_remove_target.py
   :language: python
   :caption: while循环移除列表中对象
   
- 另一种是使用列表推导式，重新构建一个不包含该目标值的新列表，这是一种推荐且简洁的方法:

.. literalinclude:: python_list/list_rebuild.py
   :language: python
   :caption: 重新构建一个不包含该目标值的新列表

在这里 ``[...]`` 相当于一个"工厂流水线":

.. literalinclude:: python_list/list_rebuild_line.py
   :language: python
   :caption: "工厂流水线"

- ``for m in motorcycles`` 表示从原列表 ``motorcycles`` 中取出每一个元素，并把当前取出的元素临时命名为变量 ``m``
- ``if m != target`` 这是一个过滤条件，只有当当前元素 ``m`` 不等于要删除的目标值 ``target`` 时，它才会被允许通过
- ``m`` (最左侧的表达式) : 通过了条件筛选的元素 ``m`` 会被放入新列表中

