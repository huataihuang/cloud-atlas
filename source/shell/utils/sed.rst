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

参考
========

- `Sed Command in Linux/Unix with examples <https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/>`_
- `Linux sed Command: How To Use the Stream Editor <https://phoenixnap.com/kb/linux-sed>`_
- `sed, a stream editor <https://www.gnu.org/software/sed/manual/sed.html>`_ gnu sed官方手册，最全面的参考
