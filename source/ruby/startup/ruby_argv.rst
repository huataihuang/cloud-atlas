.. _ruby_argv:

===================
Ruby参数处理
===================

Ruby 提供了一个内置预定义数组 ``ARGV`` ，用来接收用户命令的参数:

.. literalinclude:: ruby_argv/happy_birth.rb
   :language: ruby
   :caption: ``happy_birth.rb``

注意， ``参数里得到的数据都是字符串`` ，所以如果要进行计算则需要做类型转换: 例如 ``to_i`` 方法转换为整数:

.. literalinclude:: ruby_argv/argv_num.rb
   :language: ruby
   :caption: 参数转换成整数进行计算

执行 ``ruby argv_num.rb 6 3`` 输出结果:

.. literalinclude:: ruby_argv/argv_num.rb_output
   :caption: 参数转换成整数进行计算的输出案例

参考
========

- 「Ruby基础教程」
