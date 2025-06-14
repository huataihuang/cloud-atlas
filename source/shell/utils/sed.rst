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

将分隔符替换为换行
====================

``sed`` 可以直接使用 ``\n`` 作为换行符号的字符替换，例如，需要将文档中的 ``,`` 替换为换行符::

   sed 's/,/\n/g' sample.txt

变量的困扰
===========

我最近遇到一个头疼的问题，就是我要将文件中的开头和结尾替换成一长串的 ``文件系统目录`` (作为 :ref:`rsync` 参数)，我开始以为很简单，就是::

   sed "s/^/${dir_string}/g" file

但是，实际上始终报错，系统参数 ``s`` 错误。我觉得很奇怪，做了很多尝试才发现，当 ``${dir_string}`` 变量被bash展开以后填入到 ``sed`` 中，会导致 ``sed`` 将路径中的 ``/`` 误判为字符串匹配指令之间的分隔符。这个问题我暂时没有找到解决方法，目前采用单是一个变通方法: 反过来做

先创建一个模版文件 ``sync_template`` 将同步命令写好，然后将最后一级子目录作为模版中需要替换的全大写字符长:

.. literalinclude:: sed/sync_template
   :language: bash
   :caption: 将替换字符串简化，避免 ``/`` 符号出现在替换字符串变量中

这样就能避免替换字符长复杂化，就直接执行::

   dir="01GQZ0NMD4790X3ZAEG6PKVXE7"
   cat sync_template | sed "s/DATA/${dir}/g"

FreeBSD平台的sed
======================

在BSD系统(包括 :ref:`macos` )， ``sed`` 的参数 ``-i`` 需要一个后缀，不能和linux平台一样 ``-i`` 参数是可选的。所以不能直接使用 ``-i`` 参数表示直接修改文件，而是要先给予一个 ``''`` 空白。另外，搜索和替换使用的是 ``@`` 符号，所以以下是一个案例:

.. literalinclude:: sed/bsd_sed
   :caption: BSD平台的sed案例

这样就能够把 ``line`` 单词替换成 ``new`` 单词

参考
========

- `Sed Command in Linux/Unix with examples <https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/>`_
- `Linux sed Command: How To Use the Stream Editor <https://phoenixnap.com/kb/linux-sed>`_
- `sed, a stream editor <https://www.gnu.org/software/sed/manual/sed.html>`_ gnu sed官方手册，最全面的参考
- `Removing the Last Character of a File <https://www.baeldung.com/linux/remove-last-char-in-file>`_
- `sed -i on FreeBSD [duplicate] <https://stackoverflow.com/questions/49934684/sed-i-on-freebsd>`_
