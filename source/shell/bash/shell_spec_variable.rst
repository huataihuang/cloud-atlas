.. _shell_spec_variable:

=====================
SHELL特殊变量
=====================

特殊变量
=========

.. csv-table:: SHELL特殊变量
   :file: shell_spec_variable/shell_spec_var.csv
   :widths: 20, 80
   :header-rows: 1

``$*`` 和 ``$@`` 区别
========================

``$*`` 和 ``$@`` 都表示传递给脚本或函数的所有参数，但是当被双引号 ``" "`` 包含时区别如下:

- ``$*`` 将所有参数作为一个整体，以 ``"$1 $2 ... $n"`` 的形式输出所有参数
- ``$@`` 将所有参数分开，以 ``"$1" "$2" … "$n"`` 的形式输出所有参数

``$?``
============

``$?`` 可以获取上一个命令的退出状态。所谓退出状态，就是上一个命令执行后的返回结果。

退出状态是一个数字，一般情况下，大部分命令执行成功会返回 ``0`` ，失败返回 ``1`` 。

不过，也有一些命令返回其他值，表示不同类型的错误。

检查脚本参数的案例
===================

- 要求传递的参数是某个目录，我们的脚本逻辑需要检查：

  - 是不是传递了一个参数
  - 传递的参数是不是一个存在的目录

.. literalinclude:: shell_spec_variable/check_shell_parameters.sh
   :language: bash
   :caption: 检查脚本参数是否传递以及参数是不是存在的目录

参考
======

- `Shell特殊变量：Shell $0, $#, $*, $@, $?, $$和命令行参数 <http://c.biancheng.net/cpp/view/2739.html>`_
- `Checking for the correct number of arguments <https://stackoverflow.com/questions/4341630/checking-for-the-correct-number-of-arguments>`_
