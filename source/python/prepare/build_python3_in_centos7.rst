.. _build_python3_in_centos7:

================================
在CentOS 7环境源码编译Python 3
================================

我在 :ref:`centos` 7 的古老环境中部署 :ref:`virtualenv` 遇到异常，让我非常头疼。由于历史原因不得不维护一些旧OS系统，实在是非常浪费精力。

一狠心，我决定从 :ref:`upgrade_developer_toolset_on_centos7` 开始，完整把所有开发、程序运行环境全部重新编译升级一遍，做出一个类似 :ref:`docker` 容器化干净的系统:

- 参考 :ref:`lfs` 完全从源码编译整个Developer Toolkit :ref:`upgrade_developer_toolset_on_centos7`
- 源码编译最新的 Python 3
- 采用 :ref:`virtualenv` 运行自己开发的Python程序

编译
=======

- 在 CentOS 上准备一些必要工具:

.. literalinclude:: build_python3_in_centos7/prepare
   :caption: 在CentOS 7上准备工具

- 安装python编译需要的所有软件包:

.. literalinclude:: build_python3_in_centos7/install_python_build_prerequisites
   :caption: 在CentOS 7上安装编译Python3所需的所有依赖

也可以直接安装:

.. literalinclude:: build_python3_in_centos7/install_python_build_prerequisites_manually
   :caption: 在CentOS 7上安装编译Python3所需的所有依赖(手工)

需要注意，  EPEL 安装 ``openssl11-devel`` 不能被默认找到，需要执行以下方法来为后续 ``configure --with-openssl=DIR`` 做准备:

.. literalinclude:: build_python3_in_centos7/epel_openssl11-devel
   :caption: 通过 EPEL 安装的 ``openssl11-devel`` 需要创建软链接以便后续 ``configure`` 传递路径

对于 :ref:`ubuntu_linux` 则直接安装

.. literalinclude:: build_python3_in_centos7/install_python_build_prerequisites_manually_debian
   :caption: 在Debian上安装编译Python3所需的所有依赖(手工)

.. note::

   ``configure`` 参数可以参考 `3.11.4 Documentation » Python Setup and Usage » 3. Configure Python <https://docs.python.org/3/using/configure.html>`_

- 编译Python，激活速度优化:

.. literalinclude:: build_python3_in_centos7/build_python
   :caption: 编译python3

参数说明:

- ``--enable-optimizations`` 激活 ``Profile Guided Optimization (PGO)`` ，Clang编译器需要 ``llvm-profdata`` 程序
- ``--with-lto`` 激活 ``Link Time Optimization (LTO) `` 对于最佳性能，推荐采用 ``--enable-optimizations --with-lto`` (PGO + LTO)，Clang编译器需要 ``llvm-ar``
- ``--with-computed-gotos`` 在评估循环是激活计算gotos，对于支持的编译器默认激活
- ``--with-system-ffi`` 使用已经安装的 ``ffi`` 库来编译 ``_ctypes`` 扩展模块，这个是默认系统依赖的
- ``with-ensurepip=[upgrade|install|no]`` 默认是 ``upugrade`` ，当使用 ``install`` 参数时会运行 ``python -m ensurepip --altinstall``
- ``--with-openssl=DIR`` 传递非系统默认openssl目录，此时会自动检测 ``runtime library`` ；或者直接使用 ``--with-openssl-rpath=[no|auto|DIR]`` 指定 ``DIR``

.. note::

   ``make altinstall`` 之后，安装在 ``/usr/local/bin`` 目录下的 ``python3.11`` 和 ``pip3.11`` 就可以用来构建 :ref:`virtualenv`


一些异常及处理
=================

初次报错
---------

- 系统需要 ``openssl-1.1.1`` 或更高版本才能支持 ssl 模块(CentOS 7使用的是openssl-1.0.2)，需要注意 EPEL 安装 openssl11 位置非默认，需要传递 ``configure`` 参数 ``--with-openssl=DIR``

我的初次编译报错如下(上文已经逐个修正)::

   The necessary bits to build these optional modules were not found:
   _bz2                  _curses               _curses_panel
   _dbm                  _gdbm                 _hashlib
   _lzma                 _ssl                  _tkinter
   _uuid                 readline
   To find the necessary bits, look in setup.py in detect_modules() for the module's name.
   
   
   The following modules found by detect_modules() in setup.py have not
   been built, they are *disabled* by configure:
   _sqlite3
   
   
   Failed to build these modules:
   _ctypes
   
   
   Could not build the ssl module!
   Python requires a OpenSSL 1.1.1 or newer

再次报错(部分解决)
--------------------

- 虽然安装了 ``uuid-devel`` ，但是依然报错没有支持 ``_uuid`` 模块::

   The necessary bits to build these optional modules were not found:
   _tkinter              _uuid
   To find the necessary bits, look in setup.py in detect_modules() for the module's name.

- 对应解决方法: ``_uuid`` 需要安装 ``libuuid-devel`` 解决

- 我还是没有解决 ``_tkinter`` : ``_tkinter`` 似乎需要 ``tk-devel`` (我最初以为是要安装 ``tkinter`` )，但是我安装了还是有 ``_tkinter`` 模块无法找到(虽然我也已经安装了 ``tkinter`` 软件包)，但是还是有这个报错( 奇怪了 )。我自检查了 ``configure`` 输出，确实发现:

.. literalinclude:: build_python3_in_centos7/tkinter
   :caption: ``configure`` 依然报错找不到 ``_tkinter`` ，虽然我已经安装了 ``tk-devel`` 软件包
   :emphasize-lines: 29

.. note::

   我还没有解决最后编译的Python 3不支持 ``_tkinter`` 模块问题，这个模块是做tk图形开发，在服务器端用不上。不过，比较奇怪，看起来我配置应该没有错才对...留待以后再尝试了(生产环境魔改的aliOS真是蛋疼)

参考
======

- `Compile and Install Python 3 on CentOS 7 Linux from source <https://linuxconfig.org/compile-and-install-python-3-on-centos-7-linux-from-source>`_
- `Build, compile and install Python from source code <https://www.build-python-from-source.com/>`_ 网站提供了不同版本组合的源代码编译方式
- `How to compile python3 on RHEL with SSL? SSL cannot be imported <https://stackoverflow.com/questions/69539286/how-to-compile-python3-on-rhel-with-ssl-ssl-cannot-be-imported>`_
