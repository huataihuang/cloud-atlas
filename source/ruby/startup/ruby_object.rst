.. _ruby_object:

=================
Ruby对象
=================

Ruby是 **面向对象** 脚本语言，在Ruby中字符串、数值、时间等各种数据都是对象:

以 :ref:`ruby_quickstart` 最简单的一行代码程序为例:

.. literalinclude:: ruby_quickstart/helloruby.rb
   :language: ruby
   :caption: 输出 ``Hello, Ruby.`` 的简单一行ruby脚本

``print`` 是方法， ``Hello, Ruby.\n`` 就是对象。在Ruby这样的面向对象的语言中，所有对象的操作，都是通过执行一种方法来实现的。

.. note::

   和 ``print`` 方法类似但稍有区别的是 ``puts`` 方法:

   ``puts`` 方法在输出结果的末尾一定会输出 **换行符**

``p`` 方法
===========

``print`` 和 ``puts`` 方法，输出数值 ``1`` 和 字符串 ``"1"`` 时候都是单纯的 **1** ，此时无法判断结果是数值对象还是字符串对象，但是 ``p`` 方法会区别:

.. literalinclude:: ruby_object/print_vs_p
   :language: ruby 
   :caption: 使用 ``print`` 和 ``p`` 方法对于输出对象的区别

- 使用 ``p`` 方法可以方便程序调试:

.. literalinclude:: ruby_object/print_p_debug.rb
   :language: ruby 
   :caption: 使用 ``print`` 输出程序执行结果，使用 ``p`` 输出调试信息

- 执行 ``ruby ruby_object/print_p_debug`` 可以看到输出:

.. literalinclude:: ruby_object/print_p_debug.rb_output
   :language: ruby 
   :caption: 执行  ``print`` 和 ``p`` 方法可以看到不同的输出，显然 ``p`` 特别适合调试程序

中文编码
============

Ruby脚本开头可以使用 ``魔法注释`` (magic comment) 来指定程序编码，对于中文，可以使用 ``UTF-8`` :

.. literalinclude:: ruby_object/magic_comment_utf-8.rb
   :language: ruby 
   :caption: 在程序开头可以使用 ``魔法注释`` 指定程序编码

从 Ruby 2.0 开始，如果没有指定魔法注释，则默认使用 ``UTF-8`` 编码

对于命令行， ``ruby`` 可以使用 ``-E`` 参数指定编码::

   ruby -E UTF-8 <脚本文件名>

参考
========

- 「Ruby基础教程」
