.. _ruby_file:

================
Ruby文件处理
================

Ruby对文件的读写处理其实和其他高级语言是相似的:

- 创建文件对象，使用文件对象关联文件并打开( ``File.open()`` )
- 读写文件并处理逻辑
- 处理完成后必须明确关闭文件

.. literalinclude:: ruby_file/read_text.rb
   :language: ruby
   :caption: 读取文件

直接读取的简化
===============

**对于小文件** ( ``大文件全量加载非常消耗内存且缓慢`` )，完整的 ``open => read => close`` 过程可以简化缩写为一个 ``read`` 方法:

.. literalinclude:: ruby_file/read_text_simple.rb
   :language: ruby
   :caption: 简化read

最后，还能够 **浓缩** 为一句话的程序:

.. literalinclude:: ruby_file/read_text_oneline.rb
   :language: ruby
   :caption: 一句话简化read

.. warning::

   - 一下子读取全部文件内容非常耗时
   - 由于读取的文件内容会暂时保存在内存中，所以遇到大文件时，程序可能会因此崩溃

参考
========

- 「Ruby基础教程」
