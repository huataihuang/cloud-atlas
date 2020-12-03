.. _sphinx_show_code:

================
Sphinx展示代码
================

在Sphinx中展示代码只需要在行末尾加上 ``::`` ，之后的代码部分只要缩进就可以展示。

Syntax高亮代码功能是通过Pygments实现的:

- 每个代码段可以指定"高亮语言"，通过 ``highlight::`` 指令设置::

   .. highlight:: c

      ...

- 对于不同语言的代码段，也有一个 ``code-block`` 直接指定代码高亮语言::

   .. code-block:: ruby

      Some Ruby code.

行号
=====

Pygments可以生成代码段的行号，对于需要高亮代码，需要指定 ``linenothreshold`` ::

   .. highlight:: python
      :linenothreshold: 5

使用 code-block ，有一个 ``linenos`` 开关选项可以启用行号::

   .. code-block:: ruby
      :linenos:

      Some more Ruby code.

可以强调指定行::

   .. code-block:: python
      :emphasize-lines: 3,5

      def some_function():
          interesting = False
          print 'This line is highlighted.'
          print 'This one is not...'
          print '...but this one is.'

代码包含
=========

可以包含外部代码文件::

   .. literalinclude:: example.py

以下举例一个ruby代码以及高亮和行号::

   .. literalinclude:: example.rb
      :language: ruby
      :emphasize-lines: 12,15-18
      :linenos:

可以指定代码的编码::

   .. literalinclude:: example.py
      :encoding: latin-1

对于Python模块，可以选择一个类、函数或方法::

   .. literalinclude:: example.py
      :pyobject: Timer.start

还提供了代码 diff ::

   .. literalinclude:: example.py
      :diff: example.py.orig

标题和名字
============

命名提供了代码显示的名字::

   .. code-block:: python
      :caption: this.py
      :name: this-py

      print 'Explicit is better than implicit.'

可以指定代码的缩进字符数量::

   .. literalinclude:: example.rb
      :language: ruby
      :dedent: 4
      :lines: 10-15

参考
======

- `Sphinx Doc: Showing code examples <https://www.sphinx-doc.org/en/1.5/markup/code.html>`_
