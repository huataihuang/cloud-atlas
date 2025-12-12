.. _lfs_gcc_1:

============================
LFS GCC-14.2.0 - 第一遍
============================

GCC 依赖于 GMP、MPFR 和 MPC 这三个包。由于宿主发行版未必包含它们，我们将它们和 GCC 一同构建。将它们都解压到 GCC 源码目录中，并重命名解压出的目录，这样 GCC 构建过程就能自动使用它们：

.. literalinclude:: lfs_gcc_1/build
   :caption: 第一遍构建gcc

注意，刚刚构建的 GCC 安装了若干内部系统头文件。其中的 ``limits.h`` 一般来说应该包含对应的系统头文件 ``limits.h`` 。也就是 ``$LFS/usr/include/limits.h`` 。然而，在构建GCC的时候， ``$LFS/usr/include/limits.h`` 还不存在，因此GCC安装的内部头文件是一个不完整的、自给自足的文件，不包含系统头文件提供的扩展特性。这对于构建临时的Glibc已经足够，但是后续工作需要完整的内部头问加。所以必须执行下面的命令创建溢恶完整版本的内部头文件( 否则后续编译M4会出现 :ref:`m4_make_err_limit.h` 错误):

.. literalinclude:: lfs_gcc_1/limits.h
   :caption: 生成完整的limits.h
   :language: bash

异常排查
==============

.. note::

   以下报错仅在我使用了特殊的 :ref:`linux_jail_ext` 实践 LFS 12.4 遇到，之前在物理主机上实践 LFS 12.2 时没有遇到

报错一
------------

我在 :ref:`linux_jail_ext` 环境编译 ``make`` 有如下报错:

.. literalinclude:: lfs_gcc_1/build_error
   :caption: 编译报错

检查 ``config.log`` 发现有如下错误:

.. literalinclude:: lfs_gcc_1/config.log
   :caption: 没有正确检测gcc版本

我手工检查:

.. literalinclude:: lfs_gcc_1/gcc_v
   :caption: Rocky Linux 9 自带 gcc ``11.5.0``
   :emphasize-lines: 2,8

我最初以为是 gcc 版本过低导致不兼容 ``-V`` 参数，但是实践上我对比了不同的 :ref:`ubuntu_linux` :ref:`alpine_linux` 等最新版本gcc都是同样情况。然后仔细查看了 ``gcc --help`` 发现 ``-V`` 参数实际上是::

   -v      Display the programs invoked by the compiler.

那么为何会出现上述报错?

我没有找到问题原因，看起来似乎 Rocky Linux 9系统有什么地方和我之前使用的 :ref:`fedora` 系统有所区别。我准备将 :ref:`linux_jail` 切换到 Fedora 系统再次尝试
