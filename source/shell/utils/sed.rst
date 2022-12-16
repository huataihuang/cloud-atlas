.. _sed:

============
sed
============

``.`` 是metacharacter，需要转义
==================================

在 ``sed`` 替换 ``.`` (点)时候，需要在 ``.`` 点符号前面加上::

   \

做转义

.. literalinclude:: ../../devops/docs/pandoc/m2r
   :language: bash
   :caption: 通过SSH将本地Markdown文件上传服务器使用pandoc转换reStructuredText文件下载
   :emphasize-lines: 3,4

删除字符串的最后n个字符
==========================

:ref:`bash` 提供了 :ref:`remove_last_n_characters_from_a_string_in_bash` 

使用sed也可以类似实现，例如删除最后一个字符::

   var2=`echo $var2 | sed 's/.$//'`

删除最后2个字符::

   var2=`echo $var2 | sed 's/..$//'`

删除文件的最后一个字符
=========================

注意，是删除文件的最后一个字符，而不是每一行的最后一个字符。这里有一个小技巧::

   sed '$ s/.$//' sample.txt

请注意，这里 ``$`` 代表最后一行，所以才能实现只删除最后一行的最后一个字符，也就是文件的最后一个字符。

不要和::

   sed 's/.$//' sample.txt

混淆，这是删除每一行的最后一个字符


参考
========

- `Sed Command in Linux/Unix with examples <https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/>`_
- `Linux sed Command: How To Use the Stream Editor <https://phoenixnap.com/kb/linux-sed>`_
- `sed, a stream editor <https://www.gnu.org/software/sed/manual/sed.html>`_ gnu sed官方手册，最全面的参考
- `Removing the Last Character of a File <https://www.baeldung.com/linux/remove-last-char-in-file>`_
