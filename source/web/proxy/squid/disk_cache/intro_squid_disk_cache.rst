.. _intro_squid_disk_cache:

=========================
Squid磁盘存储简介
=========================

对于Squid磁盘缓存需要掌握:

- 磁盘文件系统
- Squid的存储机制

这里的文件系统主要指类Unix系统实现，在Squid中称为UFS(Unix File System)。实际上，这是一个泛指，可以是Berkeley Fast File System(FFS)也可以是是Linux系统的ext2fs, xfs 或其他类似的文件系统。Squid是通过一系列系统调用功能来使用文件系统，例如 open(), close(), read(), write(), stat() 以及
unlink()。这些系统调用的参数或者是路径名(字符串)或者是文件描述符(整数)。文件系统对程序屏蔽了实现细节，通常使用内置数据结构，如inodes，而Squid并不关注这些。

Squid有不同的存储模式(schemes)，使用了不同的特性和技术来操作磁盘上的缓存数据:

- ufs
- aufs
- diskd
- coss
- null

前三种schemes使用了相同的目录结构，所以可以互换。 ``coss`` 是Squid的特殊优化文件系统； ``null`` 是最小化API实现，实际上不从磁盘读写数据。

对于底层是Unix文件系统，通常引用为 ``ufs`` ，这也是默认配置。对于其他类型，需要在编译 Squid 时候向 ``./configure`` 传递参数 ``enable-storeio=LIST`` 以支持其他存储schemes。

参考
============

- `Squid The definitive guide: Chapter 7. Disk Cache Basics <http://etutorials.org/Server+Administration/Squid.+The+definitive+guide/Chapter+7.+Disk+Cache+Basics/>`_
