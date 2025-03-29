.. _lfs_chroot_build_tools:

=================================
进入 Chroot 并构建其他临时工具
=================================

构建临时系统最后缺失的部分：在构建一些软件包时必要的工具。由于已经解决了所有循环依赖问题，现在即可使用“chroot”环境进行构建，它与宿主系统 (除正在运行的内核外) 完全隔离。

为了隔离环境的正常工作，必须它与正在运行的内核之间建立一些通信机制。这些通信机制通过所谓的虚拟内核文件系统实现，将在进入 ``chroot`` 环境前挂载它们。用 ``findmnt`` 命令检查它们是否挂载好。

从现在开始，直到 "进入 Chroot 环境"，所有命令必须以 root 用户身份执行，且 LFS 变量必须正确设定。在进入 ``chroot`` 之后，仍然以 root 身份执行所有命令，但幸运的是此时无法访问构建 LFS 的计算机的宿主系统。不过仍然要小心，因为错误的命令很容易摧毁整个 LFS 系统。

改变所有者
============

.. note::

   本书中后续的所有命令都应该在以 root 用户登录的情况下完成，而不是 lfs 用户。另外，请再次检查 $LFS 变量已经在 root 用户的环境中设定好。

- 执行以下命令，将 $LFS/* 目录的所有者改变为 root(避免chroot之后，新系统中没有lfs用户，其id会被其他用户占用):

.. literalinclude:: lfs_chroot_build_tools/chown
   :caption: 修订 ``$LFS/*`` 目录的所有者改变为 ``root``

准备虚拟内核文件系统
======================

.. note::

   这段步骤其实和 :ref:`gentoo_linux` 安装过程类似，见 :ref:`install_gentoo_on_mbp`

用户态程序使用内核创建的一些文件系统和内核通信。这些文件系统是虚拟的：它们并不占用磁盘空间。它们的内容保留在内存中。必须将它们被挂载到 $LFS 目录树中，这样 chroot 环境中的程序才能找到它们。

- 创建这些文件系统的挂载点

.. literalinclude:: lfs_chroot_build_tools/mkdir
   :caption: 创建虚拟内核文件系统挂载点

- 挂载和填充 ``/dev``

在 LFS 系统的正常引导过程中，内核自动挂载 devtmpfs 到 /dev，并在引导过程中，或对应设备被首次发现或访问时动态地创建设备节点。udev 守护程序可能修改内核创建的设备节点的所有者或访问权限，或创建一些新的设备节点或符号链接，以简化发行版维护人员或系统管理员的工作。如果宿主系统支持 devtmpfs，我们可以简单地将 devtmpfs 挂载到 $LFS/dev 并依靠内核填充其内容。

如果宿主系统支持 devtmpfs，我们可以简单地将 devtmpfs 挂载到 $LFS/dev 并依靠内核填充其内容。因此，为了在任何宿主系统上都能填充 $LFS/dev，只能绑定挂载宿主系统的 /dev 目录。绑定挂载是一种特殊挂载类型，它允许通过不同的位置访问一个目录树或一个文件。运行以下命令进行绑定挂载：

.. literalinclude:: lfs_chroot_build_tools/mount_bind
   :caption: 绑定挂载 ``/dev``

- 挂载虚拟内核文件系统

.. literalinclude:: lfs_chroot_build_tools/mount
   :caption: 挂载虚拟内核文件系统

显式挂载一个 tmpfs：

.. literalinclude:: lfs_chroot_build_tools/mount_tmpfs
   :caption: 显式挂载一个 tmpfs

进入 chroot 环境
==================

现在已经准备好了所有继续构建其余工具时必要的软件包，可以进入 chroot 环境并完成临时工具的安装。在安装最终的系统时，会继续使用该 chroot 环境。以 root 用户身份，运行以下命令以进入当前只包含临时工具的 chroot 环境：

.. literalinclude:: lfs_chroot_build_tools/chroot
   :caption: 进入 chroot 环境

.. warning::

   本章剩余部分和后续各章中的命令都要在 chroot 环境中运行。如果因为一些原因 (如重新启动计算机) 离开了该环境，必须确认虚拟内核文件系统挂载好，然后重新进入chroot环境，才能继续安装LFS

创建目录
==========

- 创建一些位于根目录中的目录

.. literalinclude:: lfs_chroot_build_tools/chroot_mkdir
   :caption: 在chroot环境中创建必要目录

.. warning::

   FHS(Filesystem Hierarchy Standard) 不要求 /usr/lib64目录，而且 LFS 编辑团队决定不使用它。LFS 和 BLFS 中的一些命令只有在该目录不存在时才能正常工作。

   应该经常检查并确认该目录不存在，因为往往容易无意地创建该目录，而它的存在可能破坏系统。

- 创建必要的文件和符号链接

.. literalinclude:: lfs_chroot_build_tools/chroot_file_link
   :caption: 创建必要的文件和符号链接

安装Gettext
==============

.. literalinclude:: lfs_chroot_build_tools/gettext
   :caption: 对于临时工具只要安装 Gettext 中的三个程序

安装Bison
=============

.. literalinclude:: lfs_chroot_build_tools/bison
   :caption: 安装Bison(语法分析器生成器)

安装Perl
============

.. literalinclude:: lfs_chroot_build_tools/perl
   :caption: 安装Perl

安装Python
=============

.. literalinclude:: lfs_chroot_build_tools/python
   :caption: 安装Python

.. note::

   一些 Python 3 模块目前无法构建，这是因为它们的依赖项尚未安装。这些模块会在后续构建

安装Texinfo
===============

.. literalinclude:: lfs_chroot_build_tools/texinfo
   :caption: 安装Texinfo

清理和备份临时系统
=====================

- 清理

.. literalinclude:: lfs_chroot_build_tools/cleanup
   :caption: 清理

- 备份

.. literalinclude:: lfs_chroot_build_tools/backup
   :caption: 备份

还原(除非执行出错，否则不需要还原)
-------------------------------------

- 以下命令是出错时恢复，参考备用，无需执行:

.. literalinclude:: lfs_chroot_build_tools/restore
   :caption: 如果出错时需要恢复(正常情况下无需执行)
