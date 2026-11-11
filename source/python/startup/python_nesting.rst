.. _python_nesting:

=========================
Python 嵌套(数据结构)
=========================

复杂的数据结构往往是几种基础组合:

- 列表中嵌套字典: 当需要很多行记录时，可以使用列表中嵌套字典(相当于一张数据库表)
- 字典中嵌套列表: 当需要在字典中将一个键关联到多个值，就可以在字典中嵌套一个列表
- 字典中嵌套字典: 比较简单的是字典使用相同的结构(类似关系型数据库)，但是也允许嵌套的字典有不同结构，那样for循环内部的代码会很复杂
- 列表中嵌套列表: Python 中处理矩阵、二维网格、坐标系、图像像素或无表头表格数据时最经典、最高频的结构

.. csv-table:: 嵌套数据结构
   :file: python_nesting/nesting.csv
   :widths: 30,35,35
   :header-rows: 1

.. note::

   gemini给出的一些案例很清晰易懂

列表中嵌套字典 (A list of dictionaries)
==========================================

当需要存储一组结构相同、但属性不同的实体时（例如游戏里的多个敌人、数据库里的多条用户记录）:

.. literalinclude:: python_nesting/aliens.py
   :language: python
   :caption: 定义一个包含多个外星人字典的列表

字典中嵌套列表 (A dictionary with a list)
=============================================

当一个主键需要对应多个同类属性或子项时（例如一个人喜欢多种编程语言，或者一个班级有多名学生）:

.. literalinclude:: python_nesting/favorite_languages.py
   :language: python
   :caption: 一个人记录多个编程语言

字典中嵌套字典 (A dictionary of dictionaries)
===============================================

当需要为一个复杂的主实体存储多维度的详细配置或子属性时（例如用户的个人档案、服务器配置）:

.. literalinclude:: python_nesting/users.py
   :language: python
   :caption: 用户记录

列表嵌套列表（List of Lists）
===============================

一个简单的游戏棋盘或者二维坐标网格:

.. literalinclude:: python_nesting/matrix.py
   :language: python
   :caption: 矩阵
