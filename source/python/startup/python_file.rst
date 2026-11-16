.. _python_file:

================
Python文件处理
================

读文件
========

简单的方法:

- ``from pathlib import Path`` ，通过 ``path = Path("文件名")`` 实例化
- 读取内容 ``contents = path.read_text()``
- 文件内容分行存入列表 ``lines = contents.splitlines()``

接下来就是列表处理，非常简单就能查找文件内容

.. literalinclude:: python_file/file_reader.py
   :language: python
   :caption: 读取文件内容

写文件
=========

.. note::

   Python只能将字符串写入文本文件。如果要将数值数据存储到文本文件，必须先用函数 ``str()`` 将其转为字符串格式。

.. literalinclude:: python_file/write_message.py
   :language: python
   :caption: 写入文件

注意 ``pathlib`` 在内部实现了一个 ``with`` 语句来处理文件句柄的打开和关闭，类似于:

.. literalinclude:: python_file/write_text.py
   :language: python
   :caption: ``path.write_text()`` 内部实现了一个文件句柄的打开和关闭

使用 ``Path.write_text()`` (Python 3.4+引入)是常用的写入单条内容的常用方法，也可以多条内容拼接好，一次性用 ``path.write_text()`` 写入文件。

注意， ``path.write_text()`` 是 **一次性覆写!!!**

另一种常用方法是使用传统的 ``open()`` ，就不需要 ``from pathlib import Path`` ，是Python内置函数；不过从Python 3.4引入的 ``pathlib`` 现在是常用的面向对象的编程方法。两种流派在生产实践中都非常常见。

.. literalinclude:: python_file/open_write.py
   :language: python
   :caption: 多行写入文件

为避免对现有文件的破坏，可以使用 ``x`` 模式，则只会在文件不存在时创建

.. literalinclude:: python_file/safe_write.py
   :language: python
   :caption: 仅在文件不存在时创建

.. csv-table:: 传统 ``open()`` **vs** ``pathlib.Path``
   :file: python_file/open_vs_path.csv
   :widths: 20,40,40
   :header-rows: 1

分析文本
===========

- 统计文件中单词数量(程序中使用了 ``try ... except .. else`` 避免文件无法读取抛异常):

.. literalinclude:: python_file/word_count.py
   :language: python
   :caption: 统计文件单词数量

存储数据
==========

模块 ``json`` 能够简单的Python数据结构转为JSON格式字符串，并且在程序再次运行时从文件中加载数据。这是一种通用的轻量级数据格式。

.. literalinclude:: python_file/greet_user.py
   :language: python
   :caption: 将用户名存储在json文件中
