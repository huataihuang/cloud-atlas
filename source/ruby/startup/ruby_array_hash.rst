.. _ruby_array_hash:

======================
Ruby 数组和散列
======================

在Ruby中，数组(array)和散列(hash)这样保存对象的对象，被称为容器(container)。

数组(array)
============

数组(array)和一个按顺序保存多个对象的对象，是基本容器之一。一般称数组对象或Array对象。

数组采用 ``[ ]`` 括起，并且数组的每个元素之间使用逗号 ``,`` 分隔。数组中每个对象都有一个表示其位置的编号，称为索引(index)。通过索引，可以把对象存放到指定位置，也能够从数组的指定位置读取对象。

- 在Ruby中，如果指定了数组中不存在的索引值时，则数组的大小会随之改变。这是因为Ruby的数组默认就是动态数组(大小按实际情况自动调整)
- 任何对象都可以作为数组元素保存到数组中(时间、文件等对象也可以作为数组元素)
- 数组元素可以是不同对象的混合保存

获取数组大小
--------------

使用 ``size`` 方法可以获得数组大小::

   <array_name>.size

数组输出
-----------

Ruby提供了一个非常方便的数组迭代器，也就是 ``each`` 方法:

.. literalinclude:: ruby_array_hash/array_each.rb
   :caption: ruby的each方法可以方便对数组遍历操作，语法简洁

``each`` 方法输出示例:

.. literalinclude:: ruby_array_hash/array_each_example.rb
   :language: ruby
   :caption: ruby的each方法可以方便对数组遍历输出

散列(hash)
=============

散列(hash)是键值对 (key-value pair)的一种数据结构，一般以字符串或符号(symbol)作为键，来保存对应的对象。

在Ruby中，符号(symbol)和字符串对象很相似，符号也是对象，变作为名称标签来使用，用来表示方法等的对象的名称。

创建符号，只需要在标识符的开头加上 ``:`` 就可以了:

.. literalinclude:: ruby_array_hash/symbol_exmaple.rb
   :caption: 符号的案例

另外，从ruby 1.9开始，符号(symbol)的表示方法有所简化，可以写成：

.. literalinclude:: ruby_array_hash/symbol_compare.rb
   :caption: Ruby 1.9之后的symbol表示方法

字符串作为键和符号作为键的区别主要是性能和内存使用上的差异:

- 字符串是可变的，每次创建一个字符串，即使内容相同也会在内存中创建一个新的对象。因此在使用字符串作为key的时候，每次查找键都会进行字符串内容对比，就会稍微慢一些
- 符号(symbol)是不可变的，而且具有唯一性。相同的符号在内存中只会存在一个实例，因此使用符号作为键时，查找速度更快(查找时符号的对比是基于对象ID)，内存使用也更高效。

散列的循环
---------------

ruby提供了 ``each`` 方法可以遍历散列中所有元素，逐个取出其元素的键和对应的值。循环数组时时按照索引顺序遍历元素，循环散列则按照键值对遍历元素。

.. literalinclude:: ruby_array_hash/symbol_each.rb
   :caption: ``each`` 方法遍历散列
   :language: ruby

参考
========

- 「Ruby基础教程」
