.. _bash_string:

==================
Bash字符串处理
==================

字符串大小写
==============

字符串大小写转换在Bash中有非常巧妙的方法，无需第三方工具，内置提供了参数扩展:

.. literalinclude:: bash_string/bash_upper_lower_case
   :language: bash
   :caption: 使用bash内置参数扩展实现字符串大小写转换

参考
======

- `Matching Uppercase and Lowercase Letters With Regex in Shell <https://www.baeldung.com/linux/shell-case-insensitive-matching>`_
