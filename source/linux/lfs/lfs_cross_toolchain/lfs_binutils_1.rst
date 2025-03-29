.. _lfs_binutils_1:

===================================
LFS binutils-2.43.1 - 第一遍
===================================

.. note::

   我合并了多个步骤为一个执行脚本命令，然后添加一些注释

.. literalinclude:: lfs_binutils_1/build
   :caption: 构建binutils

``binutils`` 非常重要，因为 ``glibc`` 和 ``gcc`` 都会对可用的链接器和汇编器进行测试，以决定可以启用它们自带的哪些特性

配置选项说明
==============

- ``--prefix=$LFS/tools`` 告诉配置脚本将 Binutils 程序安装在 $LFS/tools 目录中
- ``--with-sysroot=$LFS`` 告诉构建系统，交叉编译时在 ``$LFS`` 中寻找目标系统的库
- ``--target=$LFS_TGT``  由于 LFS_TGT 变量中的机器描述和 config.guess 脚本的输出略有不同, 这个开关使得 configure 脚本调整 Binutils 的构建系统，以构建交叉链接器
- ``--disable-nls`` 临时工具不需要的国际化功能
- ``--enable-gprofng=no`` 临时工具不需要的 gprofng 工具
- ``--disable-werror`` 防止宿主系统编译器警告导致构建失败
- ``--enable-new-dtags`` 使得链接器使用“runpath”标记在可执行程序和共享库中嵌入库文件搜索路径，而非传统的“rpath”标记。这样能使得调试动态链接的可执行程序更容易，且能绕过一些软件包的测试套件中潜藏的问题。
- ``--enable-default-hash-style=gnu`` 默认情况下，链接器会为共享库和动态链接的可执行文件同时生成 GNU 风格的散列表和经典的 ELF 散列表。散列表仅供动态链接器进行符号查询。LFS 系统的动态链接器 (由 Glibc 软件包提供) 总是使用查询更快的 GNU 风格散列表。因此经典 ELF 散列表完全没有意义。该选项使得链接器在默认情况下只生成 GNU 风格散列表，以避免为生成和存储经典 ELF 散列表浪费时间和空间。
