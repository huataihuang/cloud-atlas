.. _awk:

============
awk
============

换行符替换成 ``\n``
======================

提供给 :ref:`machine_learning` 训练的数据采用每条记录一行，对于大段的文本，采用将换行符替换成 ``\n`` ，可以采用以下简单命令:

.. literalinclude:: awk/replace_new_line_n
   :language: bash
   :caption: ``awk`` 替换换行符

这里 ``printf`` 是格式化打印，其中 ``%s`` 表示占位字符串，也就是打印的变量占位。如果没有跟着 \\n ，就会把每一行(每一行用变量 ``$0`` 表示)直接打印，此时就会连接在一起变成一行。为了能够将换行符变成 ``\n`` ，这里巧妙地使用了在 ``$0`` 占位符之后加上 \\n ，由于是两个 \ ，表示不转义，实际上就是加上 ``\n`` 。这样每打印一次 ``$0`` 都会加上 ``\n`` ，也就实现了换行符替换成 ``\n`` 了。

参考
========

- `Replace newlines with literal \n <https://stackoverflow.com/questions/38672680/replace-newlines-with-literal-n>`_
