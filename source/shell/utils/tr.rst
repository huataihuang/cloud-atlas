.. _tr:

=========
tr
=========

.. _replace_multi_spaces_with_single_space:

多个空格合并成一个空格
========================

很多时候需要压缩一行文本中不断变化的空白符号，将多个空白改成一个空白，然后再替换成 ``,`` 分隔: 也就是转换成 ``.csv`` 文件：

``tr`` 命令有一个 ``-s`` 参数可以实现 ``squeeze-repeats`` 功能: 即将重复的某个字符替换成单个字符

举例::

   cat multi_spaces_file.txt | tr -s ' ' | sed 's/ /,/g' > file.csv

参考
======

- `How to replace multiple spaces with a single space using Bash? <https://stackoverflow.com/questions/50259869/how-to-replace-multiple-spaces-with-a-single-space-using-bash>`_
