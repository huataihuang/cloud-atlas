.. _python_tkinter:

================
Python Tkinter
================

Tkinter是Python的默认GUI库，它基于Tk工具集。Tk工具集最初是为工具命令语言(Tcl)设计的。Tk流行后被移植到许多脚本语言中，包括Perl(Perl/Tk)，Ruby(Ruby/Tk)和Python(Tkinter)。借助Tk开发GUI的可移植行和灵活性，加上脚本语言的简洁和系统语言的强劲，可以快速开发各种GUI程序。

安装和使用Tkinter
===================

类似于线程模块，系统中的Tkinter可能没有默认开启。可以通过尝试导入Tkinter模块来判断是否能被Python解释器使用::

   >>> import Tkinter
   >>>

如果Python解释器在编译时没有启用Tkinter，导入过程将失败。这时就不得不重新编译Python解释器来访问Tkinter。

macOS的tkinter with Tcl/Tk
============================

现在macOS系统默认也提供了Python 3(例如macOS 11 Big Sur内建Python 3.7.3)，但是很不幸，并没有包含Tcl/Tk支持的tkinter。但是，从Python官方网站下载的最新Python 3.x则内建了Tcl/Tk 8.6.8，所以非常便于使用。

.. note::

   2020苹果发布了macOS 11 Big Sur，需要使用 `Python 3.9.1 才能支持macOS 11 Big Sur <https://www.python.org/downloads/release/python-391/>`_ 。

安装了Python官方的Python 3.9.1之后，该python3解释器位于 ``/usr/local/bin/python3`` ，请确保用户执行路径 ``/usr/local/bin/`` 优先于 ``/usr/bin/`` 以便覆盖系统提供的Python 3.7。

参考
=====

- 「Python核心编程(第2版)」
- `IDLE and tkinter with Tcl/Tk on macOS <https://www.python.org/download/mac/tcltk/>`_
