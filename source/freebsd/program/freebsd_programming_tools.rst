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

构建 :ref:`nvim` 开发环境
===========================

- 下载我自己的 :ref:`nvim_ide` 配置仓库:

.. literalinclude:: freebsd_programming_tools/nvim
   :caption: 下载nvim配置 

我这里遇到和 :ref:`linux_desktop` 不一样的报错( ``:MasonLog`` 查看)

.. literalinclude:: freebsd_programming_tools/masonlog
   :caption: 安装nvim lsp-server 报错
   :emphasize-lines: 6

看起来 ``lua-language-server`` 和 ``clangd``  并不支持FreeBSD? 不可能啊

另外由于路径中没有 ``python3`` (只有 ``python3.11`` 所以还有python比昂管报错，以及访问go下载仓库软件报错

参考 `Use Language Servers for Development in the FreeBSD Src Tree <https://docs.freebsd.org/en/articles/freebsd-src-lsp/>`_ 原来在FreeBSD上，可以使用 ``ccls`` Language server(发行版支持，可以直接用 ``pkg`` 安装)，也可以像Linux一样使用 ``clangd`` 但是需要先安装 ``llvm15``

- 在 ``dev`` jail 中安装 ``ccls`` :

.. literalinclude: freebsd_programming_tools/install_ccls
   :caption: 安装ccls

这个空间要求很大(2G):

.. literalinclude: freebsd_programming_tools/install_ccls_output
   :caption: 安装ccls输出信息

- 修改 ``~/.config/nvim/lua/lsp.lua`` :

.. note::

   需要 :ref:`go_proxy`

.. warning::

   暂时没有时间继续，后续再研究

参考
======

- `Chapter 2. Programming Tools <https://docs.freebsd.org/en/books/developers-handbook/tools/>`_
- `How to Install Development Tools (GCC, CMake, etc.) on FreeBSD Operating System <https://www.siberoloji.com/how-to-install-development-tools-gcc-cmake-etc-on-freebsd/>`_
- `Use Language Servers for Development in the FreeBSD Src Tree <https://docs.freebsd.org/en/articles/freebsd-src-lsp/>`_
- `GitHub: ranjithshegde/ccls.nvim <https://github.com/ranjithshegde/ccls.nvim>`_ 配置ccls语言服务器的neovim插件，待研究
- `how can i install clangd on freebsd? <https://forums.freebsd.org/threads/how-can-i-install-clangd-on-freebsd.87736/>`_
- `Running LazyVim starter on alpine docker container: How do I get lua-language-server running working with Mason? <https://www.reddit.com/r/neovim/comments/15dr01d/running_lazyvim_starter_on_alpine_docker/>`_
- `failed to install lua-language-server #995 <https://github.com/mason-org/mason.nvim/issues/995>`_ 在alpine linux解决平台兼容性报错的方法，可以借鉴
