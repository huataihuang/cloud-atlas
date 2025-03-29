.. _lfs_libstdc++:

==================================
LFS GCC-14.2.0 中的 Libstdc++
==================================

Libstdc++ 是 C++ 标准库，需要它才能编译 C++ 代码 (GCC 的一部分用 C++ 编写)。但在构建第一遍的 GCC时我们不得不暂缓安装它，因为 Libstdc++ 依赖于当时还没有安装到目标目录的 Glibc。 

.. literalinclude:: lfs_libstdc++/build
   :caption: 安装目标系统的 Libstdc++
