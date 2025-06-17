.. _freebsd_programming_tools:

===========================
FreeBSD编程工具
===========================

FreeBSD提供了很多开发工具，例如C和C++编译器以及汇编器，以及经典UNIX工具，如 :ref:`sed` 和 :ref:`awk` 。

FreeBSD提供的解释器(Interpreters)
====================================

FreeBSD提供了一系列解释器(解释型语言):

- BASIC
- Lisp
- Perl
- Scheme
- :ref:`lua`
- :ref:`python`
- :ref:`ruby`
- Tcl和Tk

编译器
========

FreeBSD默认提供 :ref:`clang` ``llvm`` ，所以不需要 ``gcc`` 就可以编写C语言程序并且 :ref:`freebsd_build_from_source`

- 核心系统已经安装了 ``clang`` (llvm) 以及 ``make`` ，所以通常不需要再安装

安装
=======

- 安装必要工具

.. literalinclude:: freebsd_programming_tools/install
   :caption: 安装开发工具

参考
======

- `Chapter 2. Programming Tools <https://docs.freebsd.org/en/books/developers-handbook/tools/>`_
