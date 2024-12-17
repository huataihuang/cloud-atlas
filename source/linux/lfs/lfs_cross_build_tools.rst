.. _lfs_cross_build_tools:

========================================
LFS 交叉编译临时工具
========================================

前面已经完成了交叉工具链，现在可以使用自己构建的交叉工具链来编译一些基本工具。这些基本工具将被安装到最终位置。虽然目前基本操作仍然依赖宿主机的工具，但是链接的时候会使用刚刚安装的库。最后，通过 ``chroot`` 进入环境之后，就可以真正使用这些工具。

.. warning::

   一定要使用 ``lfs`` 用户身份来完成工具编译。如果使用root用户身份进行构建，可能会导致宿主机操作系统破坏。

安装M4
==========

.. literalinclude:: lfs_cross_build_tools/m4
   :caption: 安装m4

.. _m4_make_err_limit.h:

M4编译报错(limits.h)
------------------------

我在 ``make`` 时候遇到报错:

.. literalinclude:: lfs_cross_build_tools/m4_make_err
   :caption: 编译m4报错
   :emphasize-lines: 7,18

这个报错参考 `Problems with  compiling the M4 packet for my LFS system (LFS 10.1)  <https://www.linuxquestions.org/questions/linux-newbie-8/problems-with-compiling-the-m4-packet-for-my-lfs-system-lfs-10-1-a-4175699442/>`_ ，是因为忘记执行 ``生成完整的limits.h`` 步骤导致的，返回到 :ref:`lfs_gcc_1` 执行一次::

   cd $LFS/sources
   VERSION=14.2.0
   cd gcc-${VERSION}

.. literalinclude:: lfs_cross_toolchain/lfs_gcc_1/limits.h
   :caption: 生成完整的limits.h
   :language: bash

然后重新编译 M4 就可以成功

安装Ncurses
=============

.. literalinclude:: lfs_cross_build_tools/ncurses
   :caption: 安装Ncurses

安装Bash
==============

.. literalinclude:: lfs_cross_build_tools/bash
   :caption: 安装Bash

安装Coreutils
====================

.. literalinclude:: lfs_cross_build_tools/coreutils
   :caption: 安装Coreutils

安装Diffutils
==================

.. literalinclude:: lfs_cross_build_tools/diffutils
   :caption: 安装Diffutils

安装File
============

.. literalinclude:: lfs_cross_build_tools/file
   :caption: 安装File

安装Findutils
================

.. literalinclude:: lfs_cross_build_tools/findutils
   :caption: 安装Findutils

安装Gawk
==================

.. literalinclude:: lfs_cross_build_tools/gawk
   :caption: 安装Gawk

安装Grep
================

.. literalinclude:: lfs_cross_build_tools/grep
   :caption: 安装Grep

安装Gzip
============

.. literalinclude:: lfs_cross_build_tools/gzip
   :caption: 安装Gzip

安装Make
===========

.. literalinclude:: lfs_cross_build_tools/make
   :caption: 安装Make

安装Patch
==============

.. literalinclude:: lfs_cross_build_tools/patch
   :caption: 安装Patch

安装Sed
============

.. literalinclude:: lfs_cross_build_tools/sed
   :caption: 安装Sed

安装Tar
=============

.. literalinclude:: lfs_cross_build_tools/tar
   :caption: 安装Tar

安装Xz
==============

.. literalinclude:: lfs_cross_build_tools/xz
   :caption: 安装Xz

安装Binutils - 第二遍
========================

Binutils 构建系统依赖附带的 libtool 拷贝链接内部静态库，但源码包内附带的 libiberty 和 zlib 不使用 libtool。这个区别可能导致构建得到的二进制程序和库错误地链接到宿主发行版的库。绕过这个问题:

.. literalinclude:: lfs_cross_build_tools/binutils
   :caption: 安装Binutils - 第二遍

安装GCC - 第二遍
=======================

如同第一次构建 GCC 时一样，需要使用 GMP、MPFR 和 MPC 三个包。解压它们的源码包，并将它们移动到 GCC 要求的目录名

.. literalinclude:: lfs_cross_build_tools/gcc
   :caption: 安装GCC - 第二遍(部分步骤和第一遍不认同)
   :emphasize-lines: 29-31
