.. _find:

==================
文件查找工具find
==================

查找多个匹配条件(or)的文件
===========================

有时候我们需要查找 ``匹配A`` 或者 ``匹配B`` 的文件，例如，我们需要找到 ``*.py`` 和 ``*.html`` 文件，则 ``find`` 工具也提供了一个 ``-o`` 参数表示 ``or`` 来连接多个参数::

   find Documents \( -name "*.py" -o -name "*.html" \)

例如，我在 :ref:`virt-install_location_iso_image` 找多个文件

查找控制递归目录深度
=======================

默认情况下， ``find`` 会搜索指定目录的所有子目录(递归)，但是有时候我们就是要限定目录深度，此时可以使用参数 ``--maxdepth 1`` 选项:

.. literalinclude:: find/find_maxdepth
   :caption: find命令控制递归目录深度

参考
======

- `Using find to locate files that match one of multiple patterns <https://stackoverflow.com/questions/1133698/using-find-to-locate-files-that-match-one-of-multiple-patterns>`_
