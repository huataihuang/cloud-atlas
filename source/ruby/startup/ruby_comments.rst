.. _ruby_comments:

===============
Ruby注释
===============

- ``#`` 开头的行，则整行都是注释
- 某行中间出现 ``#`` ，则 ``#`` 之后部分就是注释
- 多行注释: ``=begin`` 和 ``=end`` 之间扩起的部分都是注释( 这和 :ref:`clang` 的多行注释 ``/* */`` 不同)

.. literalinclude:: ruby_comments/multi_lines_comment.ruby
   :caption: 多行注释

参考
========

- 「Ruby基础教程」
