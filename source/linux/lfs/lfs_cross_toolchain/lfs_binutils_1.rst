.. _lfs_binutils_1:

===================================
LFS binutils-2.42 - 第一遍
===================================

.. note::

   我合并了多个步骤为一个执行脚本命令，然后添加一些注释

.. literalinclude:: lfs_binutils_1/build
   :caption: 构建binutils

``binutils`` 非常重要，因为 ``glibc`` 和 ``gcc`` 都会对可用的链接器和汇编器进行测试，以决定可以启用它们自带的哪些特性

配置选项说明
==============

- ``--prefix=$LFS/tools`` 告诉配置脚本将 Binutils 程序安装在 $LFS/tools 目录中
- ``--with-sysroot=$LFS`` 高速构建系统，交叉编译时在 ``$LFS`` 中寻找目标系统的库
- ``--target=$LFS_TGT`` 
