.. _upgrade_gcc_on_ubuntu22.04:

===========================
Ubuntu 22.04升级GCC
===========================

其实没有必要在 :ref:`ubuntu_linux` 22.04 上升级GCC，因为发行版提供的 gcc 11.3 已经足够新，支持足够的C feature。不过，我最近在 :ref:`upgrade_gcc_on_suse12.5` 编译GCC非常缓慢，考虑到服务器是多核处理器性能足够强劲，但是依然没有快速完成编译，显然是编译并行没有搞好。所以我想重新在我的 ``zcloud`` 上验证以下并行编译和非并行编译的差异。

- 编译准备: 安装基本GCC toolchain和扩展工具

.. literalinclude:: upgrade_gcc_on_ubuntu22.04/prepare_build_gcc
   :caption: 编译gcc准备(GCC工具链和扩展工具)

.. note::

   :ref:`ubuntu_linux` `的软件包命名规律和 :ref:`redhat_linux` 不同:

   .. literalinclude:: upgrade_gcc_on_ubuntu22.04/lib_dev
      :caption: ubuntu 和 CentOS 对开发库包名差异

- 编译安装GCC:

.. literalinclude:: upgrade_gcc_on_ubuntu22.04/build_gcc
   :caption: 编译gcc

.. note::

   GCC编译非常耗时，建议 :ref:`parallel_make` 

在 ``./configure`` 时，我遇到如下提示信息:

.. literalinclude:: upgrade_gcc_on_ubuntu22.04/configue_info
   :caption: configure输出信息显示缺少isl和makeinfo

则需要补充安装::

   # textinfo提供makeinfo
   # libisl-dev提供isl
   sudo apt install texinfo libisl-dev

参考
======

- `Building GCC 10 on Ubuntu Linux <https://solarianprogrammer.com/2016/10/07/building-gcc-ubuntu-linux/>`_
- `What is makeinfo, and how do I get it? <https://stackoverflow.com/questions/338317/what-is-makeinfo-and-how-do-i-get-it>`_
- `Prerequisites for GCC <https://gcc.gnu.org/install/prerequisites.html>`_ ::

   isl Library version 0.15 or later.
   Necessary to build GCC with the Graphite loop optimizations. It can be downloaded from https://gcc.gnu.org/pub/gcc/infrastructure/. 
   If an isl source distribution is found in a subdirectory of your GCC sources named isl, it will be built together with GCC. 
   Alternatively, the --with-isl configure option should be used if isl is not installed in your default library search path.

- `isl package in Ubuntu <https://launchpad.net/ubuntu/+source/isl>`_
