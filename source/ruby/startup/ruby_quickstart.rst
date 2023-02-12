.. _ruby_quickstart:

========================
Ruby快速起步
========================

简单执行
==========

类似于 :ref:`nodejs` ，可以通过简单的 ``helloruby.rb`` 来体验终端输出 ``Hello World`` :

.. literalinclude:: ruby_quickstart/helloruby.rb
   :language: ruby
   :caption: 输出 ``Hello, Ruby.`` 的简单一行ruby脚本

执行ruby脚本:

.. literalinclude:: ruby_quickstart/run_helloruby.rb
   :language: bash
   :caption: 运行 ``helloruby.rb``

输出::

   Hello, Ruby.

交互执行
===========

``irb`` 提供了交互方式运行 Ruby 脚本命令，类似于 ``python`` 命令不带参数进入交互模式::

   irb

测试上述简单执行命令::

   irb(main):001:0> print("Hello, Ruby.\n")
   Hello, Ruby.
   => nil
   irb(main):002:0>

``nil`` 是 ``print`` 方法的返回值



参考
========

- 「Ruby基础教程」
