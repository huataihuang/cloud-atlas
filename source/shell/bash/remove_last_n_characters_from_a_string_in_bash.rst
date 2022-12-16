.. _remove_last_n_characters_from_a_string_in_bash:

===================================
在Bash中实现删除字符串最后n个字符
===================================

Bash内置了删除字符串指定数量字符的功能，非常简单:

- 假设字符串变量 ``$var`` 内容是 ``myfile.rtf`` ，需要删除 ``.rtf`` ，则使用::

   var2=${var%.rtf}

- 如果要删除 ``.`` 以及之后的字符，则可以使用通配符::

   var2=${var%.*}

- 如果要删除少量字符，可以使用 ``?`` 指代字符，例如要删除最后4个字符，则使用:;

   var2=${var%????}

这里每个 ``?`` 表示一个字符

- 最新的bash还支持如下方式删除最后4个字符::

   var2=${var:0:${#var}-4}

这里 ``${#var}`` 其实就是获得变量 ``$var`` 的字符串长度

也可以简写成::

   var2=${var::-4}

- 如果要删除最后哦一个字符，可以采用::

   var2=${var:0:-1}

.. note::

   也可以使用 :ref:`sed` 来删除最后的字符(行编辑)

参考
=======

- `How to remove last n characters from a string in Bash? <https://stackoverflow.com/questions/27658675/how-to-remove-last-n-characters-from-a-string-in-bash>`_
