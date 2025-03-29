.. _chattr:

===========================
chattr修改Linux文件属性
===========================

在一些特定的Linux运行环境，我们需要确保一些文件不会被用户误修改，此时作为 ``root`` 用户有一个特殊的文件属性修改命令 ``chattr`` 。这个 ``chattr`` 可以修改文件或目录，确保不被删除、修改或只允许文件添加内容(这个功能对于日志特别有用，即允许日志写入，但是不允许篡改)。



参考
======

- `chattr command in Linux with examples <https://www.geeksforgeeks.org/chattr-command-in-linux-with-examples/>`_
- `5 ‘chattr’ Commands to Make Important Files IMMUTABLE (Unchangeable) in Linux <https://www.tecmint.com/chattr-command-examples/>`_
