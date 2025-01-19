.. _lfs_base_sys:

======================
LFS安装基本系统软件
======================

概述
=======

- LFS不推荐在编译中使用自定义优化:

  - 虽然使用自定义优化编译可能会使程序运行稍快一点，但是由于源代码和编译工具的复杂相互作用，仍然存在编译不正确的风险
  - 除非LFS手册明确说明外，设置 ``-march`` 和 ``-mtune`` 是未经验证的，可能子啊工具链软件包(binutils,gcc和glibc)中引发问题
  - LFS采用软件包默认配置启用的优化选项，原因是认为软件包维护者已经测试了这些配置并认为他们是安全的，这样不太可能导致构建失败
  - 通常默认配置已经启用了 ``-O2`` 或 ``-O3`` ，因此即使不使用任何自定义优化情况下，得到的系统应该仍然会运行很快并保持稳定

- LFS不建议构建和安装静态库:

  - 在现代 Linux 系统中，多数静态库已经失去存在的意义
  - 将静态库链接到程序中可能是有害的
  - 如果静态库存在安全问题，则需要所有使用这个静态库的程序重新链接到新版本库，这是非常困难的，甚至可能无法查明有哪些程序需要重新链接 (以及如何重新链接)
  - LFS手册在安装过程删除或者禁止安装多数静态库: 通常传递 ``--disable-static`` 选项给 ``configure`` 来达到这个目的；不过极个别情况，特别是 ``Glibc`` 和 ``GCC`` ，静态库在一般软件包的构建过程中仍然很关键，就不能禁用静态库

软件包管理
===========

LFS 或 BLFS 不介绍任何包管理器的原因:

- 处理软件包管理会偏离这两本手册的目标 —— 讲述如何构建 Linux 系统
- 存在多种软件包管理的解决方案，它们各有优缺点。很难找到一种让所有读者满意的方案

升级问题
=========

- 内核可以独立升级，不需要重构任何软件包: 内核态与用户态的接口十分清晰；升级内核 **不需要** 一同更新Linux API头文件
- Glibc升级需要额外处理以防止损坏系统
- 如果更新一个包含共享库的软件包，并且共享库的名称发生改变，则所有动态链接到这个库的软件包都要重新编译，以链接到新版本的库。注意，不能删除旧版本的库，直到将所有依赖它的软件包都重新编译完成
- 如果更新共享库的库文件版本号降低，则需要删除就版本软件包安装的库，这是因为 ``ldconfig`` 命令会将符号链接到版本号更大(看起来更"新")的旧版本库。也就是不得不降级软件包或者软件包作者更改库文件版本号格式时，需要注意这个操作。
- 如果更新包含共享库的软件包，且共享库的名称没有改变，则需要重启所有链接到该库的程序以生效(例如升级ssl库需要重启ssh服务)
- 如果一个可执行程序或共享库被覆盖，则正在使用该程序或库中代码或数据的进程可能崩溃。解决方法时先删除就版本，再安装新版本。Coreutils提供的 ``install`` 已经实现了这个过程，多数软件使用这个安装命令安装二进制文件和库。

跟踪安装程序
=============

使用 ``strace`` 能够记录安装脚本执行过程中所有系统调用

.. warning::

   从现在开始的操纵是在 ``chroot`` 环境中进行，每次ssh登陆到服务器上都需要重新完成 :ref:`lfs_chroot_build_tools` 开头部分
 
   所有操作以 ``root`` 身份完成，由于是 ``chroot`` 之后操作，所以对Host主机没有影响

安装Man-pages
================

.. literalinclude:: lfs_base_sys/man-pages
   :caption: 安装Man-pages(手册页是描述 C 语言函数、重要的设备文件以及主要配置文件)

安装Iana-Etc
================

.. literalinclude:: lfs_base_sys/iana-etc
   :caption: 安装 iana-etc

``Iana-Etc`` 安装了:

- ``/etc/protocols`` 描述 TCP/IP 子系统中可用的各种 DARPA Internet 协议
- ``/etc/services``  提供 Internet 服务的可读文本名称、底层的分配端口号以及 协议类型之间的对应关系

安装Glibc
=============

.. literalinclude:: lfs_base_sys/glibc
   :caption: 安装 glibc

配置Glibc
------------

- 由于 Glibc 的默认值在网络环境下不能很好地工作，需要创建配置文件 /etc/nsswitch.conf

.. literalinclude:: lfs_base_sys/create_nsswitch.conf
   :caption: 创建新的 ``/etc/nsswitch.conf``

添加时区数据
-------------

- 安装并设置时区数据:

.. literalinclude:: lfs_base_sys/zoneinfo
   :caption: 设置时区数据

说明:

  - ``zic -L /dev/null ...`` 该命令创建没有闰秒的 POSIX 时区。一般的惯例是将它们安装在 zoneinfo 和 zoneinfo/posix 两个目录中。必须将 POSIX 时区安装到 zoneinfo，否则若干测试套件会报告错误。
  - ``zic -L leapseconds ...`` 该命令创建正确的，包含闰秒的时区。
  - ``zic ... -p ...`` 该命令创建 posixrule 文件。我们使用纽约时区，因为 POSIX 要求与美国一致的夏令时规则。

- 创建 ``/etc/localtime``

.. literalinclude:: lfs_base_sys/localtime
   :caption: 设置本地时区

配置动态加载器
-----------------

默认情况下，动态加载器 ( ``/lib/ld-linux.so.2`` ) 在 ``/usr/lib`` 中搜索程序运行时需要的动态库

- 有两个目录 ``/usr/local/lib`` 和 ``/opt/lib`` 经常包含附加的共享库，所以现在将它们添加到动态加载器的搜索目录中

.. literalinclude:: lfs_base_sys/ld.so.conf
   :caption: 配置动态加载器

- 此外动态加载器可以搜索目录，如下配置:

.. literalinclude:: lfs_base_sys/ld.so.conf.d
   :caption: 配置动态加载器的搜索目录

安装Zlib
==============

.. literalinclude:: lfs_base_sys/zlib
   :caption: 安装Zlib

安装Bzip2
=============

.. literalinclude:: lfs_base_sys/bzip2
   :caption: 安装Bzip2

安装Xz
===========

.. literalinclude:: lfs_base_sys/xz
   :caption: 安装Xz

安装Lz4
============

.. literalinclude:: lfs_base_sys/lz4
   :caption: 安装Lz4

安装Zstd
==============

.. literalinclude:: lfs_base_sys/zstd
   :caption: 安装Zstd

安装File
=============

.. literalinclude:: lfs_base_sys/file
   :caption: 安装File

安装Readline
==============

.. literalinclude:: lfs_base_sys/readline
   :caption: 安装Readline

安装M4
==========

.. literalinclude:: lfs_base_sys/m4
   :caption: 安装M4

安装Bc
========

.. literalinclude:: lfs_base_sys/bc
   :caption: 安装Bc

安装Flex
=========

.. literalinclude:: lfs_base_sys/flex
   :caption: 安装Flex

安装Tcl
===========

.. literalinclude:: lfs_base_sys/tcl
   :caption: 安装Tcl

安装Expect
=============

- 测试验证PTY 是否在 chroot 环境中正常工作:

.. literalinclude:: lfs_base_sys/tty
   :caption: 返回输出ok则表明PTY在chroot环境工作

如果不正常则需要检查前面虚拟内核文件系统，确认 ``devpts`` 文件系统是否正确挂载。并重新进入chroot环境。这是确保Expect测试套件能正常工作，避免产生隐蔽问题。

.. literalinclude:: lfs_base_sys/expect
   :caption: 安装Expect

安装DejaGNU
===============

DejaGNU 包含私用GNU工具进行测试套件的框架，使用 ``expect`` 编写，后者又使用了Tcl(工具命令语言):

.. literalinclude:: lfs_base_sys/dejagnu
   :caption: 安装DejaGNU

安装Pkgconf
===============

``pkgconf`` 软件包是 ``pkg-config`` 的接替者，用于在软件包安装的配置和生成阶段向构建工具传递头文件或库文件搜索路径的工具。

.. literalinclude:: lfs_base_sys/pkgconf
   :caption: 安装Pkgconf

安装Binutils
==============

.. literalinclude:: lfs_base_sys/binutils
   :caption: 安装Binutils

安装GMP
=========

GMP 软件包包含提供任意精度算术函数的数学库

.. literalinclude:: lfs_base_sys/gmp
   :caption: 安装GMP

.. warning::

   GMP 中的代码是针对本机处理器高度优化的。在偶然情况下，检测处理器的代码会错误识别 CPU 的功能，导致测试套件或使用 GMP 的其他程序输出消息 Illegal instruction (非法指令)。如果发生这种情况，需要使用选项 ``--build=none-pc-linux-gnu`` 重新配置 GMP 并重新构建它。

安装MPFR
============

MPFR 软件包包含多精度数学函数

.. literalinclude:: lfs_base_sys/mpfr
   :caption: 安装MPFR

安装MPC
==========

MPC 软件包包含一个任意高精度，且舍入正确的复数算术库

.. literalinclude:: lfs_base_sys/mpc
   :caption: 安装MPC

安装Attr
==========

Attr 软件包包含管理文件系统对象扩展属性的工具

.. literalinclude:: lfs_base_sys/attr
   :caption: 安装Attr

安装Acl
=========

Acl 软件包包含管理访问控制列表的工具，访问控制列表能够细致地自由定义文件和目录的访问权限

.. literalinclude:: lfs_base_sys/acl
   :caption: 安装Acl

安装Libcap
===============

Libcap 软件包为 Linux 内核提供的 POSIX 1003.1e 权能字实现用户接口。这些权能字是 root 用户的最高特权分割成的一组不同权限。

.. literalinclude:: lfs_base_sys/libcap
   :caption: 安装Libcap

安装Libxcrypt
=================

Libxcrypt 软件包包含用于对密码进行单向散列操作的现代化的库

.. literalinclude:: lfs_base_sys/libxcrypt
   :caption: 安装Libxcrypt

安装Shadow
==============

Shadow 软件包包含安全地处理密码的程序

.. literalinclude:: lfs_base_sys/shadow
   :caption: 安装Shadow

配置Shadow
------------

Shadow 软件包包含用于添加、修改、删除用户和组，设定和修改它们的密码，以及进行其他管理任务的工具

.. literalinclude:: lfs_base_sys/shadow_config
   :caption: 配置Shadow

安装GCC
=========

GCC 软件包包含 GNU 编译器集合，其中有 C 和 C++ 编译器

.. literalinclude:: lfs_base_sys/gcc
   :caption: 安装GCC

完成后通过以下方式验证确认编译和链接:

.. literalinclude:: lfs_base_sys/gcc_check
   :caption: 检查GCC安装

输出不应报错，应该显示类似如下结果(不同平台的动态链接器名称可能不同):

.. literalinclude:: lfs_base_sys/gcc_check_output
   :caption: 检查GCC安装输出

确认使用正确的启动文件:

.. literalinclude:: lfs_base_sys/gcc_check_log
   :caption: 检查GCC使用正确的启动文件

确认编译器能正确查找头文件:

.. literalinclude:: lfs_base_sys/gcc_check_log_1
   :caption: 检查GCC正确查找头文件

确认新的链接器使用了正确的搜索路径:

.. literalinclude:: lfs_base_sys/gcc_check_log_2
   :caption: 检查确认新的链接器使用了正确的搜索路径

确认使用了正确的 libc:

.. literalinclude:: lfs_base_sys/gcc_check_log_3
   :caption: 确认使用了正确的 lib

确认 GCC 使用了正确的动态链接器:

.. literalinclude:: lfs_base_sys/gcc_check_log_4
   :caption: 确认 GCC 使用了正确的动态链接器

以上输出不应有错误或没有输出，否则就需要检查问题原因并修复才能继续

在确认一切工作良好后，删除测试文件:

.. literalinclude:: lfs_base_sys/gcc_clean
   :caption: 删除测试文件

最后移动一个位置不正确的文件:

.. literalinclude:: lfs_base_sys/gcc_mv
   :caption: 移动一个位置不正确的文件

安装Ncurses
==============

- 安装Ncureses:

.. literalinclude:: lfs_base_sys/ncureses
   :caption: 安装Ncureses

安装Sed
=========

- 安装Sed:

.. literalinclude:: lfs_base_sys/sed
   :caption: 安装Sed

安装Psmisc
=============

Psmisc 软件包包含显示正在运行的进程信息的程序

.. literalinclude:: lfs_base_sys/psmisc
   :caption: 安装Psmisc

安装Gettext
==============

Gettext 软件包包含国际化和本地化工具，它们允许程序在编译时加入 NLS (本地语言支持) 功能，使它们能够以用户的本地语言输出消息

.. literalinclude:: lfs_base_sys/gettext
   :caption: 安装Gettext

安装Bison
============

Bison 软件包包含语法分析器生成器

.. literalinclude:: lfs_base_sys/bison
   :caption: 安装Bison

安装Grep
===========

Grep 软件包包含在文件内容中进行搜索的程序

.. literalinclude:: lfs_base_sys/grep
   :caption: 安装Grep

安装Bash
===========

.. literalinclude:: lfs_base_sys/bash
   :caption: 安装Bash

参考
========

- `Linux From Scratch - 版本 12.2-中文翻译版: 第 8 章 安装基本系统软件 <https://lfs.xry111.site/zh_CN/12.2/chapter08/introduction.html>`_
