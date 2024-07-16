.. _lfs_gcc_1:

============================
LFS GCC-13.2.0 - 第一遍
============================

GCC 依赖于 GMP、MPFR 和 MPC 这三个包。由于宿主发行版未必包含它们，我们将它们和 GCC 一同构建。将它们都解压到 GCC 源码目录中，并重命名解压出的目录，这样 GCC 构建过程就能自动使用它们：

.. literalinclude:: lfs_gcc_1/build
   :caption: 第一遍构建gcc

注意，刚刚构建的 GCC 安装了若干内部系统头文件。其中的 ``limits.h`` 一般来说应该包含对应的系统头文件 ``limits.h`` 。也就是 ``$LFS/usr/include/limits.h`` 。然而，在构建GCC的时候， ``$LFS/usr/include/limits.h`` 还不存在，因此GCC安装的内部头文件是一个不完整的、自给自足的文件，不包含系统头文件提供的扩展特性。这对于构建临时的Glibc已经足够，但是后续工作需要完整的内部头问加。所以必须执行下面的命令创建溢恶完整版本的内部头文件( 否则后续编译M4会出现 :ref:`m4_make_err_limit.h` 错误):

.. literalinclude:: lfs_gcc_1/limits.h
   :caption: 生成完整的limits.h
   :language: bash
