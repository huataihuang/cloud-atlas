.. _a-shell_commands:

====================
a-shell命令
====================

`GitHub: holzschu/a-Shell-commands <https://github.com/holzschu/a-Shell-commands/>`_ 提供了 ``a-shell`` 中通过 :ref:`webassembly` (wasm) 执行程序。一旦使用 WebAssembly (特定的 `WASI-sdk <https://github.com/holzschu/wasi-sdk>`_ )编译，二进制程序就可以在 ``a-shell`` 中分享使用。执行程序存放到 ``~/Document/bin/`` 目录下，后缀名是 ``.wasm`` 就能够通过WebAssembly JIT compiler调用。

设置仓库环境变量
====================

``$PKG_SERVER`` 定义了github服务器上的二进制程序仓库(也就是官方仓库)，如果没有定义这个环境变量，那么执行 ``pkg install XXXX`` 就会提示错误找不到包，例如 :ref:`a-shell_webassembly` 中安装 ``llvm`` 报错:

.. literalinclude:: a-shell_webassembly/install_llvm_err
   :caption: 安装 ``llvm`` 报错

这个报错就是因为没有设置 ``$PKG_SERVER`` 环境变量，导致无法查询软件仓库导致的

- 执行以下命令(持久化则添加到 ``~/Documents/.profile`` ):

.. literalinclude:: a-shell_commands/profile
   :caption: 添加环境变量 ``$PKG_SERVER`` 

- 完成 ``$PKG_SERVER`` 环境变量设置之后，执行 ``pkg search`` 命令，此时就会解决刚才没有任何输出到问题，直接显示出服务器能够提供的所有命令软件包。此时就可以执行 ``llvm`` 安装:

.. literalinclude:: a-shell_webassembly/install_llvm
   :caption: 安装 ``llvm`` 实现clang运行

以此类推，可以先搜索服务器提供的软件包，然后分别安装

python
========

``a-shell`` 内置了 :ref:`python` ，所以对于我 :ref:`write_doc` 所使用的 :ref:`sphinx_doc` 非常方便:

.. literalinclude:: ../../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

.. literalinclude:: ../../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

.. literalinclude:: ../../../devops/docs/write_doc/install_sphinx_doc
   :language: bash
   :caption: 通过virtualenv的Python环境安装sphinx doc

接下来就可以继续我的Cloud-Atlas写作了

JavaScript
=============

``a-shell`` 内置了WebKit的JS环境，可以直接使用 ``jsc`` 运行常规的JavaScript代码:

.. literalinclude:: a-shell_commands/jsc
   :caption: 使用 ``jsc`` 运行JavaScript脚本

vim
======

``a-shell`` 原作者编译原生 :ref:`vim` ，但是 :ref:`nvim` 非常复杂，难以移植。

git替代
=========

a-shell命令没有提供 :ref:`git` ，但是提供了一个原生iOS命令 ``lg2`` 作为 ``git`` 的clone，可以完成相同的工作

- 同步我的 Cloud-Atlas 仓库:

.. literalinclude:: a-shell_commands/lg2_clone
   :caption: ``a-shell`` 提供了类似 :ref:`git` 的工具 ``lg2`` 不过使用略有不同

``lg2`` 会提示没有配置 ``user.identifyFile`` ，然后让你确认是否使用在 ``~/Documents/.ssh/`` 目录下的SSH key（提供编号)，你确认key对应的编号就可以。此外， ``clone`` 目录是 ``cloud-atlas.git`` 。

参考
======

- `a-Shell-commands: Add git #17 <https://github.com/holzschu/a-Shell-commands/issues/17>`_
- `A guide to a-Shell: A guide for beginners <https://bianshen00009.gitbook.io/a-guide-to-a-shell/basic-tutorials/readme-1>`_
- `Packages available: Not Found #44 <https://github.com/holzschu/a-Shell-commands/issues/44>`_
