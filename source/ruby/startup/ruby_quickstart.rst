.. _ruby_quickstart:

========================
Ruby快速起步
========================

安装ruby
============

- :ref:`macos` 内置ruby 2.6系列，对于体验和使用最新Ruby版本，可以采用 :ref:`macos_install_ruby` 安装使用 :ref:`homebrew` 提供的最新版本

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

.. note::

    Ruby在调用方法时候可以省略 ``()`` ，所以::

       print("Hello, Ruby.\n")

    和::

       print "Hello, ruby.\n"

    是一样的(类似 :ref:`shell` )

单双引号区别
===============

和 :ref:`shell` 类似， ``''`` 会忽略字符串中 \\ 转义符号， ``""`` 则能够处理类似 ``\n`` 这样的特殊转义符号

参考
========

- 「Ruby基础教程」
