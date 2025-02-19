.. _ruby_lib:

==============
Ruby引用库
==============

可以将不同的 :ref:`ruby_func` 存放到不同文件进行组织，然后通过 ``require`` 方法来引用库: 库名可以省略后缀 ``.rb`` 。以下是案例，分别由 ``use_grep.rb`` 来引用包含 ``grep/rb`` :

- ``grep.rb`` :

.. literalinclude:: ruby_lib/grep.rb
   :language: ruby
   :caption: ``grep.rb``
