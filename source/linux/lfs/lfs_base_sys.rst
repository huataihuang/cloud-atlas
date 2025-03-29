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

安装Libtool
==============

Libtool 软件包包含 GNU 通用库支持脚本。它提供一致、可移植的接口，以简化共享库的使用

.. literalinclude:: lfs_base_sys/libtool
   :caption: 安装Libtool

安装GDBM
==========

GDBM 软件包包含 GNU 数据库管理器。它是一个使用可扩展散列的数据库函数库，功能类似于标准的 UNIX dbm。该库提供用于存储键值对、通过键搜索和获取数据，以及删除键和对应数据的原语。

.. literalinclude:: lfs_base_sys/gdbm
   :caption: 安装GDBM

安装Gperf
===============

Gperf 根据一组键值，生成完美散列函数

.. literalinclude:: lfs_base_sys/gperf
   :caption: 安装Gperf

安装Expat
=============

Expat 软件包包含用于解析 XML 文件的面向流的 C 语言库

.. literalinclude:: lfs_base_sys/expat
   :caption: 安装Expat

安装Inetutils
===============

Inetutils 软件包包含基本网络程序

.. literalinclude:: lfs_base_sys/inetutils
   :caption: 安装Inetutils

安装less
==========

Less 软件包包含一个文本文件查看器

.. literalinclude:: lfs_base_sys/less
   :caption: 安装Less

安装Perl
==========

.. literalinclude:: lfs_base_sys/perl
   :caption: 安装Perl

安装XML::Parser
==================

XML::Parser 模块是 James Clark 的 XML 解析器 Expat 的 Perl 接口

.. literalinclude:: lfs_base_sys/xml-parser
   :caption: 安装XML::Parser

安装Intltool
=============

Intltool 是一个从源代码文件中提取可翻译字符串的国际化工具

.. literalinclude:: lfs_base_sys/intltool
   :caption: 安装Intltool

安装Autoconf
=============

Autoconf 软件包包含生成能自动配置软件包的 shell 脚本的程序

.. literalinclude:: lfs_base_sys/autoconf
   :caption: 安装Autoconf

安装Automake
===============

Automake 软件包包含自动生成 Makefile，以便和 Autoconf 一同使用的程序

.. literalinclude:: lfs_base_sys/automake
   :caption: 安装Automake

安装OpenSSL
================

OpenSSL 软件包包含密码学相关的管理工具和库。它们被用于向其他软件包提供密码学功能，例如 OpenSSH，电子邮件程序和 Web 浏览器 (以访问 HTTPS 站点)。

.. literalinclude:: lfs_base_sys/openssl
   :caption: 安装OpenSSL

安装Kmod
===========

Kmod 软件包包含用于加载内核模块的库和工具

.. literalinclude:: lfs_base_sys/kmod
   :caption: 安装Kmod

安装Elfutils中的Libelf
=========================

Libelf 是一个处理 ELF (可执行和可链接格式) 文件的库

.. literalinclude:: lfs_base_sys/libelf
   :caption: 安装Libelf

安装Libffi
==============

Libffi 库提供一个可移植的高级编程接口，用于处理不同调用惯例。这允许程序在运行时调用任何给定了调用接口的函数。

FFI 是 Foreign Function Interface (跨语言函数接口) 的缩写。FFI 允许使用某种编程语言编写的程序调用其他语言编写的程序。特别地，Libffi 为 Perl 或 Python 等解释器提供使用 C 或 C++ 编写的共享库中子程序的能力。

.. literalinclude:: lfs_base_sys/libffi
   :caption: 安装Libffi

安装Python
==============

Python 3 软件包包含 Python 开发环境。它被用于面向对象编程，编写脚本，为大型程序建立原型，或者开发完整的应用。Python 是一种解释性的计算机语言。

.. literalinclude:: lfs_base_sys/python
   :caption: 安装Python

安装Flit-Core
==============

Flit-core 是 Flit (一个用于简单的 Python 模块的打包工具) 中用于为发行版进行构建的组件

.. literalinclude:: lfs_base_sys/flit-core
   :caption: 安装Flit-Core

安装Wheel
===========

Wheel 是 Python wheel 软件包标准格式的参考实现

.. literalinclude:: lfs_base_sys/wheel
   :caption: 安装Wheel

安装Setuptools
==================

Setuptools 是一个用于下载、构建、安装、升级，以及卸载 Python 软件包的工具

.. literalinclude:: lfs_base_sys/setuptools
   :caption: 安装Setuptools

安装Ninja
=============

Ninja 是一个注重速度的小型构建系统

.. literalinclude:: lfs_base_sys/ninja
   :caption: 安装Ninja

安装Meson
============

Meson 是一个开放源代码构建系统，它的设计保证了非常快的执行速度，和尽可能高的用户友好性。

.. literalinclude:: lfs_base_sys/meson
   :caption: 安装Meson

安装Coreutils
================

Coreutils 软件包包含各种操作系统都需要提供的基本工具程序

.. literalinclude:: lfs_base_sys/coreutils
   :caption: 安装Coreutils

安装Check
============

Check 是一个 C 语言单元测试框架

.. literalinclude:: lfs_base_sys/check
   :caption: 安装Check

安装Diffutils
=================

Diffutils 软件包包含显示文件或目录之间差异的程序

.. literalinclude:: lfs_base_sys/diffutils
   :caption: 安装Diffutils

安装Gawk
============

Gawk 软件包包含操作文本文件的程序

.. literalinclude:: lfs_base_sys/gawk
   :caption: 安装Gawk

安装Findutils
=================

Findutils 软件包包含用于查找文件的程序。这些程序能直接搜索目录树中的所有文件，也可以创建、维护和搜索文件数据库 (一般比递归搜索快，但在数据库最近没有更新时不可靠)。Findutils 还提供了 xargs 程序，它能够对一次搜索列出的所有文件执行给定的命令。

.. literalinclude:: lfs_base_sys/findutils
   :caption: 安装Findutils

安装Groff
==============

Groff 软件包包含处理和格式化文本和图像的程序

.. literalinclude:: lfs_base_sys/groff
   :caption: 安装Groff

安装GRUB
==========

GRUB 软件包包含 “大统一” (GRand Unified) 启动引导器。

.. warning::

   如果系统支持UEFI，并且希望使用UEFI来引导LFS，则需要按照BLFS的说明，安装支持UEFI的GRUB(以及依赖项)。所以，可以跳过安装BRUB，或者同时安装GRUB和BLFS中为UEFI提供的GRUB包，并使两者互补干扰(BLFS页面提供了两种方案分别的操作。

.. note::

   由于我的服务器使用了UEFI，所以我跳过这步，直接使用 `BLFS: GRUB-2.12 for EFI <https://www.linuxfromscratch.org/blfs/view/12.2/postlfs/grub-efi.html>`_

安装GRUB for EFI
===================

安装FreeTuype(GRUB依赖)
--------------------------

.. literalinclude:: lfs_base_sys/freetype
   :caption: 安装freetype

安装GRUB
-----------

.. literalinclude:: lfs_base_sys/grub
   :caption: 安装grub

安装Gzip
=============

Gzip 软件包包含压缩和解压缩文件的程序

.. literalinclude:: lfs_base_sys/gzip
   :caption: 安装Gzip

安装IPRoute2
==============

IPRoute2 软件包包含基于 IPv4 的基本和高级网络程序

.. literalinclude:: lfs_base_sys/iproute2
   :caption: 安装IPRoute2

安装Kbd
===========

Kbd 软件包包含按键表文件、控制台字体和键盘工具

.. literalinclude:: lfs_base_sys/kbd
   :caption: 安装Kbd

安装Libpipeline
===================

Libpipeline 软件包包含用于灵活、方便地处理子进程流水线的库

.. literalinclude:: lfs_base_sys/libpipeline
   :caption: 安装Libpipeline

安装Make
============

Make 软件包包含一个程序，用于控制从软件包源代码生成可执行文件和其他非源代码文件的过程。

.. literalinclude:: lfs_base_sys/make
   :caption: 安装Make

安装Path
============

Patch 软件包包含通过应用 “补丁” 文件，修改或创建文件的程序，补丁文件通常是 diff 程序创建的。

.. literalinclude:: lfs_base_sys/patch
   :caption: 安装Patch

安装Tar
==============

Tar 软件包提供创建 tar 归档文件，以及对归档文件进行其他操作的功能。Tar 可以对已经创建的归档文件进行提取文件，存储新文件，更新文件，或者列出文件等操作。

.. literalinclude:: lfs_base_sys/tar
   :caption: 安装Tar

安装Texinfo
=================

Texinfo 软件包包含阅读、编写和转换 info 页面的程序

.. literalinclude:: lfs_base_sys/texinfo
   :caption: 安装Texinfo

安装vim
==========

.. literalinclude:: lfs_base_sys/vim
   :caption: 安装Vim

安装MarkupSafe
=================

MarkupSafe 是一个为 XML/HTML/XHTML 标记语言实现字符串安全处理的 Python 模块。

.. literalinclude:: lfs_base_sys/markupsafe
   :caption: 安装MarkupSafe

安装Jinja2
============

Jinja2 是一个实现了简单的，Python 风格的模板语言的 Python 模块

.. literalinclude:: lfs_base_sys/jinja2
   :caption: 安装Jinja2

Systemd-256.4 中的 Udev
========================

Udev 软件包包含动态创建设备节点的程序。安装的只是 systemd-256.4 软件包的一部分 ，所以使用 systemd-256.4.tar.xz 作为源代码包

.. literalinclude:: lfs_base_sys/udev
   :caption: 安装Udev

安装Man-DB
============

Man-DB 软件包包含查找和阅读手册页的程序

.. literalinclude:: lfs_base_sys/man-db
   :caption: 安装Man-DB

安装Procps-ng
==================

Procps-ng 软件包包含监视进程的程序

.. literalinclude:: lfs_base_sys/procps-ng
   :caption: 安装Procps-ng

安装Util-linux
=================

Util-linux 软件包包含若干工具程序。这些程序中有处理文件系统、终端、分区和消息的工具

.. literalinclude:: lfs_base_sys/util-linux
   :caption: 安装Util-linux

安装E2fsprogs
=================

E2fsprogs 软件包包含处理 ext2 文件系统的工具。此外它也支持 ext3 和 ext4 日志文件系统。

.. literalinclude:: lfs_base_sys/e2fsprogs
   :caption: 安装E2fsprogs

安装Sysklogd
==================

Sysklogd 软件包包含记录系统消息 (例如在意外情况发生时内核输出的消息) 的程序

.. literalinclude:: lfs_base_sys/sysklogd
   :caption: 安装Sysklogd

安装SysVinit
===============

SysVinit 软件包包含控制系统启动、运行和关闭的程序

.. literalinclude:: lfs_base_sys/sysvinit
   :caption: 安装SysVinit

调试符号
================

许多程序和库在默认情况下被编译为带有调试符号的二进制文件 (通过使用 gcc 的 -g 选项)。这意味着在调试这些带有调试信息的程序和库时，调试器不仅能给出内存地址，还能给出子程序和变量的名称。

但是包含这些调试符号会显著增大程序或库的体积。移除调试符号的程序通常比移除调试符号前小 50% 到 80%。由于大多数用户永远不会用调试器调试系统软件，可以通过移除它们的调试符号，回收大量磁盘空间。

移除调试符号(可选)
---------------------

本节是可选的。如果系统不是为程序员设计的，也没有调试系统软件的计划，可以通过从二进制程序和库移除调试符号和不必要的符号表项，将系统的体积减小约 2 GB。对于一般的 Linux 用户，这不会造成任何不便。

大多数使用以下命令的用户不会遇到什么困难。但是，如果打错了命令，很容易导致新系统无法使用。因此，在运行 strip 命令前，最好备份 LFS 系统的当前状态。

``strip`` 命令的 ``--strip-unneeded`` 选项从程序或库中移除所有调试符号。它也会移除所有链接器 (对于静态库) 或动态链接器 (对于动态链接的程序和共享库) 不需要的符号表项。

需要注意的是，strip 命令会覆盖它正在处理的二进制程序或库文件。这可能导致正在使用该文件中代码或数据的进程崩溃。如果运行 strip 的进程受到影响，则可能导致正在被处理的程序或库完全损坏；这可能导致系统完全不可用。为了避免这种情况，将一些库和程序复制到 /tmp 中，在那里移除调试符号，再使用 install 命令重新安装它们。

.. literalinclude:: lfs_base_sys/remove_debug
   :caption: 移除调试符号

.. note::

   我的实践，在没有移除调试符号之前 ``/`` 根目录使用了 ``1.7G`` 空间，移除调试后， ``/`` 根目录使用 ``1.4G`` 空间，减少了300MB

清理系统
=========

- 清理系统:

.. literalinclude:: lfs_base_sys/clean_sys
   :caption: 清理系统

参考
========

- `Linux From Scratch - 版本 12.2-中文翻译版: 第 8 章 安装基本系统软件 <https://lfs.xry111.site/zh_CN/12.2/chapter08/introduction.html>`_
