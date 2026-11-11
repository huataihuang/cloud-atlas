.. _python_dictionary:

==========================
Python 字典(dictionary)
==========================

字典(dictionary)语法
======================

Python 字典(Dictionary)是一种可变的映射数据结构，用于以 **键值对** ( ``key:value`` )的形式来存储数据。整个字典用花括号 ``{}`` 包裹， **键必须唯一且为不可变类型** (如字符串、数字或 :ref:`python_tuple` )，值可以是任意数据类型。

为什么字典(Dictionary)语法要求:

- **键的唯一性** : 字典中的键必须是唯一的，如果重复定义同一个键，后面的值会覆盖前面的值
- **键的不可变性(Hashable)** : 字典的键必须是 **不可变类型** (如字符串、数字、元组)。如果尝试用列表(list)或字典本身作为键，Python会抛出 ``TypeError: unhashable type`` 错误。原因是Python字典的底层是通过 **哈希表(Hash Table)** 实现的，为了能够快速通过键找到对应的值，Python需要计算键的哈希值(Hash Value)。

正是因为这个哈希寻址要求，字典(Dictionary)天然要求键必须是不可变的。现代Python(3.6+)的字典底层结构有 **两个协同工作的数组** :

- ``Indices (索引表)`` : 一个只存储索引(整数)的精简数组。它的槽位(Slot)很多是空的，用来处理哈希冲突。
- ``Entries (实体表/密集数组)`` : 一个按元素插入顺序紧凑排列的列表。每个Entry实际存储 **三个核心字段** : ``{hash(哈希值), key (键指针), value (值指针)}``

元组(tupple)作为字典的键
--------------------------

元组作为字典的键在现实中有一些经典案例:

- 地图中的坐标(二维或三维)天然就是元组形式，这在游戏中非常常见。因为元组具有不可变性质，这意味着坐标不会被意外修改
- 多字段联合主键: 在处理数据库或表格数据时，用 ``(user_id, course_id)`` 作为字典键，来记录某个用户选修某门课程的成绩或状态
- 函数缓存(Memorization): 当一个函数有多个输入参数时，很多高级缓存机制(例如Python标准库中的 ``@lru_cache`` )在底层就是把这些参数打包成一个元组作为键，来缓存函数的计算结果，避免重复计算

List vs. Dictionary
----------------------

和 :ref:`python_list` 不同，列表是使用方法( ``append`` , ``insert`` )，而字典是使用直接赋值( ``dict['key'] = value`` )，根本原因在于它们的 **数据结构类型和核心设计理念完全不同：一个是序列(Sequence)，另一个是映射(Mapping)** 。

- 列表是"序列" (Sequence) :

  - 列表中的元素是有序排列的，并且每一个元素都有一个固定的，从0开始递增的整数索引(Index)，如 ``0,1,2...``
  - 因为列表关心的是"位置"，所以向列表中加入数据，需要知道位置: 列表最后加数据用 ``append()`` ，列表中间插数据用 ``insert()``

- 字典是"映射" (Mapping)

  - 字典中没有"第几个索引"的概念，它是一对一的键值对( ``key-value`` )集合，通过key来找value
  - 由于不关心在内存中位置，所以直接按照键key赋值

字典的操作
============

- 简单的给字典键值加数据: 一个游戏"外星人"颜色调整

.. literalinclude:: python_dictionary/alien.py
   :language: python
   :caption: 简单加数据给字典

- 修订数据的案例

.. literalinclude:: python_dictionary/alien_move.py
   :language: python
   :caption: 修改字典数据

- 遍历字典

.. literalinclude:: python_dictionary/user.py
   :language: python
   :caption: 遍历字典打印

- 下面一个案例更好更清晰

注意，遍历字典的时候总是会遍历 ``key`` ，所以可以用 ``for name in favorite_languages.keys()`` 也可以用 ``for name in favorite_languages`` 但是在实际编程中，最优雅且符合 Pythonic 规范的修改方式是使用 ``.items()`` 同时解构出 `name`` (键) 和 ``language`` (值):

  - SIM118 (关于 ``.keys()`` ): 在 Python 中，直接对字典进行循环（for name in favorite_languages）默认遍历的就是它的键，显式调用 ``.keys()`` 是多余的
  - PLC0206 (关于 ``.items())`` ): 如果在循环内部需要通过键去获取字典的值（即代码中的 ``favorite_languages[name]`` ），更好的做法是直接使用 ``.items()`` 方法 **同时拿到键和值，避免二次查表**

.. literalinclude:: python_dictionary/favorite_languages.py
   :language: python
   :caption: 遍历字典，按匹配的key打印特定输出

当程序逻辑只需要处理字典中的 ``key`` 或者 ``value`` 时，确实可以直接使用 ``favorite_languages.keys()`` 或者 ``favorite_languages.values()`` 来仅提取key或value，这种方法是完全可行的，但是要注意:

**仅提取key或value并不会带来额外的性能负担，也不会带来额外的速度提升** :

- **零拷贝的视图对象** ( ``View Objects`` ): 实际上不管是使用 ``.keys()`` , ``.values()`` 还是 ``items()`` ，都不是像列表那样占用额外的内存去存储数据的副本，而是 ``视图`` (Views)!!! 它们仅仅是字典底层数据的动态"窗口"，和数据库视图一样，完全不占用存储空间
- **内存开销几乎为零** : 不管是直接迭代字典 ``for k in dict`` ，还是使用 ``dict.keys()`` , ``dict.values()`` ，本质上不复制数据
- **为什么Linter建议去掉.keys()** : 因为Python的设计哲学强调"优雅且唯一的最优解“，因此直接写 ``for name in favorite_languages:`` 已经天然代表了"遍历键"，再写 ``.keys()`` 被认为是冗余的语法。

注意，如果遍历值 ``for language in favorite_languages.values():`` ，有些情况下可能想要去重(即多个相同语言合并成一个)，则为了剔除重复项，可以使用集合( ``set`` )，即写成 ``for language in set(favorite_languages.values()):``

字典(dictionary) vs. 集合(set)
=================================

在Python中，集合 ``set`` 也是使用花括号 ``{}`` ，和字典很容易混淆。但两者是有区别的:

.. csv-table:: 字典(dictionary) vs. 集合(set)
   :file: python_dictionary/dict_set.csv
   :widths: 10,45,45
   :header-rows: 1
