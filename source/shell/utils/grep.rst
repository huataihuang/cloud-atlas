.. _grep:

==============
grep
==============

常用参数
==========

- ``-o`` : 这个参数可以指定只输出匹配上的字符串，而不是打印匹配的整行内容::

   grep -o "Unix" example.txt

则输出只有::

   Unix
   Unix
   ...

- ``-r`` : 递归所有子目录进行过滤::

   grep -r "string-name" *

- ``-i`` : 忽略字符大小写::

   grep -i "linux" welcome.txt

- ``-c`` 统计匹配数量::

   grep -c "Linux" welcome.txt

- ``-v`` 反转统计，也就是没有匹配上的行::

   grep -v "Linux" welcome.txt

- ``-n`` 输出时在开头显示出匹配上的行号::

   grep -n "Linux" welecome.txt

- ``-w`` 强制完全(精确)匹配单词，例如 ``open`` 去匹配时候就不会匹配上 ``opensource`` 这个单词::

   grep -w "open" welcome.txt

- ``-A`` (after) 和 ``-B`` (before) 表示匹配后输出匹配行的前多少行和后多少行::

   grep -A 4 "open" welcome.txt
   grep -B 4 "open" welcome.txt

参考
======

- `Grep Command in Linux/UNIX <https://www.digitalocean.com/community/tutorials/grep-command-in-linux-unix>`_
