.. _lfs:

======================================
LFS(Linux from scratch)
======================================

`linux from scratch <http://www.linuxfromscratch.org/>`_ 是一个提供如何一步步构建自己定制的Linux的项目。没有任何二进制发行版，只有文档指南。

很多人奇怪为何我们要经历重重困难从头开始构建Linux系统而不是直接下载一个已经存在的Linux发行版。以下是一些理由：

- LFS教会你Linux系统如何工作
- 构建LFS可以生成一个非常精巧的Linux系统
- LFS具备扩展性
- LFS提供了附加的安全

.. toctree::
   :maxdepth: 1

   intro_lfs.rst
   lfs_vm.rst
   lfs_partition.rst
   lfs_partition_optane.rst
   lfs_partition_freebsd.rst
   lfs_mba.rst
   lfs_prepare.rst
   lfs_build.rst
   lfs_cross_toolchain/index
   lfs_cross_build_tools.rst
   lfs_chroot_build_tools.rst
   lfs_base_sys.rst
   lfs_sys_config.rst
   lfs_boot.rst
   lfs_finish.rst
   lfs_use.rst
   lfs_plan.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
