.. _go_string_literals:

=====================
Go语言字符串文字
=====================

3种字符串符号
================

和 :ref:`shell` 有点类似，但又不同的是 ` 符号: 在shell中表示 ` ` 符号表示执行语句返回结果，而在Go里面则表示原始字符串。主要特点是可以跨多行，反引号扩起的字符串中，除了不能再次出现反引号字符外其他任何字符都可以出现，所以常常被用来作为模版。

双引号在Go中的意思和shell相同，表示解释的字符串文字，也就是可以包含任何字符，除了原始换行符或未经转义的双引号。在双引号中的反斜线\是被转义的。

单引号在Go中表示一个符文字元，也就是一个符文常数，即代表单一的Unicode字符。

参考
======

- `The Go Programming Language Specification: String literals <http://docscn.studygolang.com/ref/spec#String_literals>`_
- `学习Golang中的多线字符串（附代码） <https://juejin.cn/post/7130469957166432287>`_
