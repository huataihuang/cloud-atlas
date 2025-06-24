.. _remove_add_characters:

====================
删除和添加字符
====================

最近在 :ref:`vnet_thin_jail` 遇到一个需要重建软链接的脚本命令需要编写，也就是常见的字符删除和添加

移除文件中的第一行
======================

- 移除文件中的第一行:

.. literalinclude:: remove_add_characters/remove_first_line
   :caption: 移除第一行

通常我们知道 ``tail -n x`` 表示取文件中倒数 ``x`` 行内容；然而，还有一个参数 ``tail -n +x`` 表示正向的取 ``x`` 行开始的内容: ``tail -n +1`` 表示从第1行开始的内容，而 ``tail -n +2`` 表示从第2行开始的内容，以此类推。所以要移除第一行内容就可以使用:

.. literalinclude:: remove_add_characters/remove_first_line_save
   :caption: 移除第一行形成新文件

删除一行的前n个字符
=====================

删除一行的前4个字符可以使用 ``cut`` 命令参数 ``-c 5-`` 表示按照 ``c`` haracters的第 ``5`` 个字符开始截取:

.. literalinclude:: remove_add_characters/remove_first_4_characters
   :caption: 删除前4个字符 

参考
======

- `How can I remove the first line of a text file using bash/sed script? <https://stackoverflow.com/questions/339483/how-can-i-remove-the-first-line-of-a-text-file-using-bash-sed-script>`_
