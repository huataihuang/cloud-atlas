.. _vim_ctags:

=================
vim结合ctags
=================

在编程过程中，函数转跳(从函数会话快速跳到函数定义或相反)是常用功能，vim可以结合 ``ctags`` 工具实现

.. note::

   另一个常用的程序转跳工具是 ``cscope`` ，更适合大型项目使用，能够为C，lex 和 yacc 源代码文件构建一个符号交叉引用表(symbol cross-reference table)。请参考 :ref:`nvim_escope`

安装
======

- 在 macOS 上使用 :ref:`homebrew` 安装(其实 XCode command line tools 也提供 ``ctags`` 但是使用参数和我们常用的Linux环境ctags不同):

.. literalinclude:: vim_ctags/install
   :caption: 在macOS上使用 :ref:`homebrew` 安装 ``ctags``

- 在 :ref:`ubuntu_linux` 上可以安装 ``universal-ctags`` (相对较新，建议安装) 或 ``exuberant-ctags``

.. literalinclude:: vim_ctags/install_universal-ctags
   :caption: 安装 ``universal-ctags``

使用
=======

在源代码项目目录下执行递归生成 ``tags`` :

.. literalinclude:: vim_ctags/ctags
   :caption: 在源代码项目目录下执行 ``ctags`` 创建包含索引的名为 ``tags`` 文件

现在打开 ``vim`` 或 ``nvim`` ，可以使用如下快捷键进行函数转跳:

- ``ctrl + ]`` 从 函数实例和类型 跳到函数定义的位置
- ``ctrl + T`` / ``ctrl + o`` 从 函数定义 重新返回函数实例
- 结合 ``ctrl + W`` 和 ``ctrl + ]`` 可以开启一个新窗口跳到函数定义位置(此时vim窗口会划分为2个窗口)
- 结合 ``ctrl + W`` 和 ``ctrl + 方向键`` 在上述两个窗口间来回跳

.. note::

   ``ctrl+方向键`` 在macOS中默认是 ``Mission Control`` 快捷键，有冲突，需要修改 ``System Settings >> Keyboard >> Keyboard Shutcuts...``

参考
=======

- `Getting started with ctags + Vim on MacOS <https://galea.medium.com/getting-started-with-ctags-vim-on-macos-87bcb07cf6d>`_
- `vim跳转到函数定义处 <https://www.cnblogs.com/qscfyuk/p/14877790.html>`_
