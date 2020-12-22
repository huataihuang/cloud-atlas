.. _build_gluser_suse:

=======================
SUSE编译glusterfs
=======================

源代码编译安装
================

- 下载源代码::

   wget https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/glusterfs-6.10.tar.gz
   tar xfz glusterfs-6.10.tar.gz
   cd glusterfs

- 安装编译依赖::

   zypper in -y autoconf automake bison flex gcc gettext-tools \
       libasan0 libatomic1 libgomp1 libitm1 libopenssl-devel libtsan0 \
       linux-glibc-devel python-netifaces python-simplejson python-xattr \
       rpm-build systemd-rpm-macros zlib-devel sqlite3 \
       fdupes libtool pkgconfig python3 fuse glibc-devel libaio-devel

.. note::

   需要参考CentOS编译依赖进行安装，但是很多开发依赖需要使用SUSE的SDK和Update仓库，待实践。

- 生成配置脚本::

   ./autogen.sh

- 执行 configure 脚本::

   ./configure

提示报错::

   checking for UUID... no
   checking for uuid.h... no
   checking uuid/uuid.h usability... no
   checking uuid/uuid.h presence... no
   checking for uuid/uuid.h... no
   configure: error: libuuid is required to build glusterfs

- 解决方法是搜索::

   zypper info libuuid-devel

参考 `netdata - Imposible install on Suse Enterprise 12 #1162 <https://github.com/netdata/netdata/issues/1162>`_ 建议::

   add the SDK and SLE-SDK12-SP1-Updates Repos to your System

   # zypper info libuuid-devel

   Firstly register your System at Suse Customer Center.

   https://scc.suse.com/

   Or, if you have an SMT Server add the System to your SMT Server, or SuSE Manager System.
   Suse will provide a registration code for your System.
   Add the Registration Code to your System.
   This Step has to be accomplished with Yast2.
   If the System is registered and the Registration Code is valid, you will be able to to activate the necessary Repositories with Yast2.

   Keep in mind that SuSE auto generates unique Repository URL's for your System.
   All you need is a valid Evaluation Subscription.

原来，SUSE的很多开发包都是位于 SDK 和 SLE-SDK12-SP3-Updates 软件仓库，你需要添加这些仓库，类似::

   SLE-Module-Legacy12-Debuginfo-Pool
   SLE-Module-Legacy12-Debuginfo-Updates
   SLE-Module-Legacy12-Pool
   SLE-Module-Legacy12-Source-Pool
   SLE-Module-Legacy12-Updates
   SLES12-SP1-Debuginfo-Pool
   SLES12-SP1-Debuginfo-Updates
   SLES12-SP1-Pool
   SLES12-SP1-Source-Pool
   SLES12-SP1-Updates
   SLE-SDK12-SP1-Debuginfo-Pool
   SLE-SDK12-SP1-Debuginfo-Updates
   SLE-SDK12-SP1-Pool
   SLE-SDK12-SP1-Source-Pool
   SLE-SDK12-SP1-Updates
   SLE-Module-Toolchain12-Debuginfo-Pool
   SLE-Module-Toolchain12-Debuginfo-Updates
   SLE-Module-Toolchain12-Pool
   SLE-Module-Toolchain12-Updates

为了能够完成编译安装，所需的软件包，需要 :ref:`suse_deploy_smt` ，对于缺少 ``libuuid-devel`` 开发包或者其他devel软件包，也可以直接下载 `SUSE Linux enterprise Software Development Kit Downloads <https://www.suse.com/download/sle-sdk/>`_

由于我没有 SMT mirror credential ，所以采用直接下载 SLE SDK iso镜像，然后通过 :ref:`suse_iso_repo` 方式添加到主机repo后，就可以通过 zypper安装依赖软件包。

添加suse本地iso仓库
====================

- 根据编译安装依赖包，添加以下本地iso仓库 :ref:`suse_iso_repo` ::

   # 安装盘
   zypper ar -c -t yast2 "iso:/?iso=/home/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso" "SLES 12 SP3"
   # SDK盘
   zypper ar -c -t yast2 "iso:/?iso=/home/SLE-12-SP3-SDK-DVD-x86_64-GM-DVD1.iso" "SLES 12 SP3 SDK-1"
   zypper ar -c -t yast2 "iso:/?iso=/home/SLE-12-SP3-SDK-DVD-x86_64-GM-DVD2.iso" "SLES 12 SP3 SDK-2"

然后检查仓库::

   zypper repos

显示如下::

   # | Alias             | Name              | Enabled | GPG Check | Refresh
   --+-------------------+-------------------+---------+-----------+--------
   1 | SLES 12 SP3       | SLES 12 SP3       | Yes     | (r ) Yes  | Yes    
   2 | SLES 12 SP3 SDK-1 | SLES 12 SP3 SDK-1 | Yes     | ( p) Yes  | No     
   3 | SLES 12 SP3 SDK-2 | SLES 12 SP3 SDK-2 | Yes     | ( p) Yes  | No     
   4 | SLES12-SP3-12.3-0 | SLES12-SP3-12.3-0 | No      | ----      | ----

- 安装需要的软件依赖::

   zypper in -y libuuid-devel acl-devel libxml2-devel liburcu-devel

这里有一个提示::

   checking for TIRPC... no
   checking rpc/rpc.h usability... yes
   checking rpc/rpc.h presence... yes
   checking for rpc/rpc.h... yes
   configure: WARNING:
            ---------------------------------------------------------------------------------
            libtirpc (and/or ipv6-default) were enabled but libtirpc-devel is not installed.
            Disabling libtirpc and ipv6-default and falling back to legacy glibc rpc headers.
            This is a transitional warning message. Eventually it will be an error message.
            ---------------------------------------------------------------------------------

看文档 CentOS 7是使用 ``./configure --without-libtirpc`` ，所以也使用这个配置方式避免错误::

   ./configure --without-libtirpc

.. note::

   在使用 ``./configure`` 时会提示某些头文件缺失，则对应安装软件包 ``xxxx-devel``

最终配置输出::

   GlusterFS configure summary
   ===========================
   FUSE client          : yes
   Infiniband verbs     : no
   epoll IO multiplex   : yes
   fusermount           : yes
   readline             : yes
   georeplication       : yes
   Linux-AIO            : yes
   Enable Debug         : no
   Enable ASAN          : no
   Enable TSAN          : no
   Use syslog           : yes
   XML output           : yes
   Unit Tests           : no
   Track priv ports     : yes
   POSIX ACLs           : yes
   SELinux features     : yes
   firewalld-config     : no
   Events               : yes
   EC dynamic support   : x64 sse avx
   Use memory pools     : yes
   Nanosecond m/atimes  : yes
   Server components    : yes
   Legacy gNFS server   : no
   IPV6 default         : no
   Use TIRPC            : no
   With Python          : 3.4
   Cloudsync            : no

.. note::

   一些有用的 ``configure`` 参数:

   - ``--enable-debug`` 对于开发过程调试特别有用
   - ``--enable-gnfs`` 用于支持传统的gNFS
   - ``--enable-asan`` 如果要帮助修复内存问题

- 编译::

   make

- 安装::

   sudo make install

.. note::

   glusterfs可以安装到任何目标目录，但是 ``mount.glusterfs`` 脚本需要位于 ``/sbin/mount.glusterfs`` 这样才能通过 ``mount -t glusterfs`` 来挂载。

在SUSE SELS 12 SP3 上执行 ``make install`` 遇到报错::

   Making install in extras
   Making install in init.d
   /usr/bin/install: cannot stat 'glustereventsd-SuSE': No such file or directory
   Makefile:561: recipe for target 'SuSE' failed
   make[3]: *** [SuSE] Error 1
   Makefile:453: recipe for target 'install-am' failed
   make[2]: *** [install-am] Error 2
   Makefile:659: recipe for target 'install-recursive' failed
   make[1]: *** [install-recursive] Error 1
   Makefile:575: recipe for target 'install-recursive' failed
   make: *** [install-recursive] Error 1

上述报错在 `Bug 1541261 - "glustereventsd-SuSE.in" is missing in extras/init.d  <https://bugzilla.redhat.com/show_bug.cgi?id=1541261>`_ 提到但是没有解决。

我搜索了一下，原来 ``extras/init.d/`` 目录下有 ``glustereventsd-Redhat`` ``glustereventsd-Redhat.in`` 以及 ``glustereventsd-Debian`` 和 ``glustereventsd-Debian.in`` ，但是就是没有对应的 ``glustereventsd-SuSE`` 。

此时安装过程失败，导致库文件尚未复制，例如挂载目录依然会报错::

   /usr/local/sbin/glusterfs: error while loading shared libraries: libglusterfs.so.0: cannot open shared object file: No such file or directory
   Mount failed. Please check the log file for more details.

上述安装报错和 ``glustereventsd`` 相关，可以看到 ``configure`` 输出中是有 ``Events`` 支持的。

运行GlusterFS
==================

从源代码安装通常不安装任何init脚本，所以需要手工启动 ``glusterd`` 服务::

   glusterd

在启动了上述daemon进程之后，就可以运行 ``gluster`` 命令来使用GlusterFS。

** ``以下编译软件包的步骤仅供参考，我依然在摸索`` **

编译软件包
===========

在基于RPM的系统中，可以比较容易完成RPM包构建::

   cd extras/LinuxRPM
   make glusterrpms

执行 ``make glusterrpms`` 之前，需要确保系统已经安装以下软件包::

   zypper in -y git

我在执行上述操作时遇到报错，显示上述操作应该在git源代码目录下执行，直接使用 ``tar.gz`` 软件包会出现问题::

   (cd . && git diff && echo ===== git log ==== && git log) > glusterfs-6.10/ChangeLog
   Not a git repository
   To compare two paths outside a working tree:
   usage: git diff [--no-index] <path> <path>
   Makefile:1009: recipe for target 'gen-ChangeLog' failed
   make[3]: *** [gen-ChangeLog] Error 129
   Makefile:675: recipe for target 'distdir' failed
   make[2]: *** [distdir] Error 2
   Makefile:771: recipe for target 'dist' failed
   make[1]: *** [dist] Error 2
   make[1]: Leaving directory '/root/huatai.huang/glusterfs-6.10'
   Makefile:546: recipe for target 'prep' failed
   make: *** [prep] Error 2

从git版本编译rpm
====================

- 下载代码::

   git clone git@github.com:gluster/glusterfs.git
   cd glusterfs
   git checkout v6.10

- 编译::

   cd extras/LinuxRPM
   ./make_glusterrpms

.. note::

   ``make glusterrpms`` 可以看到实际参数是::

      cd ../.. && \
      rm -rf autom4te.cache && \
      ./autogen.sh && \
      ./configure --enable-gnfs --with-previous-options

   如果要调整 configure 配置，请编辑 ``Makefile.am`` 配置文件，调整选项，例如关闭RDMA
   
编译rpm包依赖报错::

   error: Failed build dependencies:
           python2-devel is needed by glusterfs-6.10-0.0.x86_64
           libtirpc-devel is needed by glusterfs-6.10-0.0.x86_64
           userspace-rcu-devel >= 0.7 is needed by glusterfs-6.10-0.0.x86_64
           libcurl-devel is needed by glusterfs-6.10-0.0.x86_64
           fuse-devel is needed by glusterfs-6.10-0.0.x86_64
           libibverbs-devel is needed by glusterfs-6.10-0.0.x86_64
           librdmacm-devel >= 1.0.15 is needed by glusterfs-6.10-0.0.x86_64
   Makefile:561: recipe for target 'rpms' failed
   make: *** [rpms] Error 1   

所以对应安装::

   zypper in -y python2-devel libtirpc-devel userspace-rcu-devel \
     libcurl-devel fuse-devel libibverbs-devel librdmacm-devel

但是提示错误::

   'libibverbs-devel' not found in package names. Trying capabilities.
   'librdmacm-devel' not found in package names. Trying capabilities.
   'python2-devel' not found in package names. Trying capabilities.
   'userspace-rcu-devel' not found in package names. Trying capabilities.
   No provider of 'userspace-rcu-devel' found.

根据搜索

- `libibverbs是InfiniBand/iWARP/RoCE硬件在用户空间的直接访问库和驱动 <https://software.opensuse.org/package/libibverbs>`_ 只有在InfiniBand架构和RDMA协议使用时需要这个用户空间库
- ``python2-devel`` 在suse是名为 ``pyton-devel``
- `userspace-rcu是用户空间Read-Copy-Update库 <https://software.opensuse.org/package/userspace-rcu>`_ 但是没有在官方发行版提供，从 `userspace-rcu from devel:libraries:c_c++ project <https://software.opensuse.org/download.html?project=devel%3Alibraries%3Ac_c%2B%2B&package=userspace-rcu>`_ 可以看到提供了 SLE 12 SP4平台的安装仓库，但是没有提供 SLE 12 SP3的安装包。

再次安装库依赖::

   zypper in -y python2-devel libtirpc-devel \
         libcurl-devel fuse-devel libibverbs-devel


``librdmacm-devel`` 安装会提示::

   'librdmacm-devel' not found in package names. Trying capabilities.
   'rdma-core-devel' providing 'librdmacm-devel' is already installed.

所以跳过 ``librdmacm-devel`` 安装。

不过编译提示需要 ``userspace-rcu-devel`` ::

   rpmbuild --define '_topdir /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild' --with gnfs -bb rpmbuild/SPECS/glusterfs.spec
   error: Failed build dependencies:
           userspace-rcu-devel >= 0.7 is needed by glusterfs-6.10-0.0.x86_64
   Makefile:561: recipe for target 'rpms' failed
   make: *** [rpms] Error 1

Userspace RCU
---------------

liburce是RCU(read-copy-update)库，这个数据同步库提供了随着核心数量线性增长的读取端访问。 ``liburcu-cds`` 提供在RCU上高效的数据结构，这些数据结构包括 hash表，队列，堆栈和双向链表(doubly-linked lists)。

`GitHub urcu/userspace-rcu项目 <https://github.com/urcu/userspace-rcu>`_ 提供软件包源代码::

   tar xfz userspace-rcu-0.12.1.tar.gz
   cd userspace-rcu-0.12.1
   ./configure
   make
   make install
   ldconfig

然后重新编译 glusterfs ::

   make glusterrpms

但是报错依旧。

由于SUSE官方没有提供 ``userspace-rcu`` ，我是通过上述方式自己编译安装了 ``userspace-rcu`` ，但是 rpmbuild 会检查 ``BuildRequires:    userspace-rcu-devel >= 0.7`` ，导致无法通过。

ugly修复方式:

我发现如果直接执行 ``extras/LinuxRPM/make_glusterrpms`` 实际上使用的是源代码库初始目录下的 ``glusterfs.spec`` ，这个文件来源是 ``glusterfs.spec.in`` ，所以可以采用修订这个文件，去掉依赖检查就可以跳过这个问题。

- 将当前出错时 ``./rpmbuild/SPECS/glusterfs.spec`` ，所以修订 ``Makefile.am`` 文件，添加一个在 ``rpmbuild`` 之前去掉这个依赖检查::

   rpms:
           sed -i '/BuildRequires:    userspace-rcu-devel/d' ./rpmbuild/SPECS/glusterfs.spec
           rpmbuild --define '_topdir $(shell pwd)/rpmbuild' --with gnfs -bb rpmbuild/SPECS/glusterfs.spec
           mv rpmbuild/RPMS/*/* .

再次执行 ``./make_glusterrpms`` 脚本执行虽然没有报错，但是却只生成了 ``glusterfs-6.10-0.0.src.rpm`` ::

   ...
   cp ../../*.tar.gz ./rpmbuild/SOURCES
   # 请注意，这步就是复制源代码初始目录下的glusterfs.spec文件，所以只要修订这个文件就可以绕过依赖检查
   cp ../../glusterfs.spec ./rpmbuild/SPECS
   rpmbuild --define '_topdir /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild' -bs rpmbuild/SPECS/glusterfs.spec
   warning: Could not canonicalize hostname: linux-4xup
   Wrote: /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/SRPMS/glusterfs-6.10-0.0.src.rpm
   mv rpmbuild/SRPMS/* .
   rm -rf rpmbuild

注释掉 ``Makefile.am`` 中 ``rm -rf rpmbuild`` 然后我发现 ``rpmbuild/SPECS/glusterfs.spec`` 实际上是正确生成的。所以我参考 `SUSE Blog: Building Simple RPMs of Arbitrary Files <https://www.suse.com/c/building-simple-rpms-arbitary-files/>`_ 先创建一个 ``~/.rpmmacros`` 配置文件设置指定目录::

   %_topdir      /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild
   %_tmppath      /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/tmp

然后::

   cd rpmbuild/SOURCES
   rpmbuild -ba ../SPECS/glusterfs.spec

报错::

   + make -j64
   Makefile:80: *** missing separator.  Stop.
   error: Bad exit status from /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/tmp/rpm-tmp.w0glZb (%build)

参考 `Make error: missing separator <https://stackoverflow.com/questions/920413/make-error-missing-separator>`_ 原来 Makefile 中make希望是tab作为缩进符号(在Makefile中，make规则要求以tab开始)，但是如果是空格作为缩进符号就会有报错。例如::

   target: 
   \tcmd

这里 ``\t``  表示TAB(U+0009)，则语法就是正确的。

如果是::

   target:
   ...cmd

这里 ``.`` 表示空格(U+0020)，则语法就是错误的。

`Makefile - missing separator [duplicate] <https://stackoverflow.com/questions/14109724/makefile-missing-separator/14109796>`_ 也介绍了另外一种使用分号来分隔，就不需要使用tab::

   PROG = semsearch
   all: $(PROG)
   %: %.c
           gcc -o $@ $< -lpthread
   
   clean:
           rm $(PROG)

可以写成::

   PROG = semsearch
   all: $(PROG)
   %: %.c ; gcc -o $@ $< -lpthread
   
   clean: ; rm $(PROG)

可以参考 `make Other Special Variables <https://www.gnu.org/software/make/manual/html_node/Special-Variables.html#Special-Variables>`_ 使用 ``.RECIPEPREFIX`` 设置特定变量。

我验证了一下，实际上 ``extras/LinuxRPM/make_glusterrpms`` 执行报错也是提示上述 Makefile 的语法错误::

   + make -j64
   make[1]: Entering directory '/root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/BUILD/glusterfs-7.8'
   Makefile:80: *** missing separator.  Stop.
   make[1]: Leaving directory '/root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/BUILD/glusterfs-7.8'
   error: Bad exit status from /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/tmp/rpm-tmp.btZIq1 (%build)

检查 ``/root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/BUILD/glusterfs-7.8/Makefile`` 看指令前面确实是TAB，奇怪。

搞错了，我仔细看了 Makefile 的第80行，看上去像是脚本处理时候错误了，导致了多行内容叠在一起的语法错误::

   build_triplet = It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in
   the sources with an updated version.
   host_triplet = It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in
   the sources with an updated version.

观察glusterfs的源代码中 ``Makefile.in`` 文件，可以看到上述两个变量实际上是一个占位符::

   build_triplet = @build@
   host_triplet = @host@

也就是要按照上述提示，把环境参数提供给 ``configure`` 以便正确生成这两个填充内容。

通过 ``./configure --help`` 可以看到::

   System types:
     --build=BUILD     configure for building on BUILD [guessed]
     --host=HOST       cross-compile to build programs to run on HOST [BUILD]
   
显然在SUSE平台上运行导致了没有正确传递这个参数(脚本guess错误)

在 `How to determine proper input for autoconf's system type --build configure option? <https://stackoverflow.com/questions/56204454/how-to-determine-proper-input-for-autoconfs-system-type-build-configure-optio>`_ 讨论了这个问题。这个参数是针对系统架构来传递的参数，见 `What's the difference of “./configure” option “--build”, “--host” and “--target”? <https://stackoverflow.com/questions/5139403/whats-the-difference-of-configure-option-build-host-and-target?rq=1>`_ :

为了能够跨平台编译软件，可以指定编译主机( ``--build`` )和运行主机( ``--host`` )是不同的架构，例如::

   ./configure --build=powerpc --host=mips

仔细观察之前运行configure的数据就有::

   checking how to convert It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in
   the sources with an updated version. file names to It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in
   the sources with an updated version. format... func_convert_file_noop
   checking how to convert It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in

确实如我推测，没有正确检测出系统。

参考 `autoconf Hosts and Cross-Compilation <https://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Hosts-and-Cross_002dCompilation.html>`_ 系统猜测是通过运行源代码根目录下 ``config.guess`` 脚本结合 ``config.stub`` 配置来获得的，例如，运行glusterfs源代码目录下::

   ./config.guess

获得的输出就是::

   x86_64-suse-linux-gnu

看起来正常。

但是，我意外发现，在 ``extras/LinuxRPM/rpmbuild/BUILD/glusterfs-7.8/`` 目录下执行 ``./config.guess`` 就会输出错误的信息::

   It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.guess script
   in the sources with an updated version.

错误源头找到了。原因是这个脚本就是一个输出信息::

   #!/bin/sh
   #
   # This script is intentionally left empty. Distributions that package GlusterFS
   # may want to to replace it with an updated copy from the automake project.
   #
   
   cat << EOM
   It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.guess script
   in the sources with an updated version.
   EOM
   
   exit 0

看来需要把正确版本的 ``config.guess`` 复制过来。

但是执行显示::

   tardir=glusterfs-7.8 && tar --format=posix -chf - "$tardir" | GZIP=--best gzip -c >glusterfs-7.8.tar.gz
   if test -d "glusterfs-7.8"; then find "glusterfs-7.8" -type d ! -perm -200 -exec chmod u+w {} ';' && rm -rf "glusterfs-7.8" || { sleep 5 && rm -rf "glusterfs-7.8"; }; else :; fi
   make[1]: Leaving directory '/root/huatai.huang/glusterfs'
   mkdir -p rpmbuild/BUILD
   mkdir -p rpmbuild/SPECS
   mkdir -p rpmbuild/RPMS
   mkdir -p rpmbuild/SRPMS
   mkdir -p rpmbuild/SOURCES
   rm -rf rpmbuild/SOURCES/*
   cp ../../*.tar.gz ./rpmbuild/SOURCES
   cp ../../glusterfs.spec ./rpmbuild/SPECS
   cp ../../config.guess ./rpmbuild/BUILD/glusterfs-7.8
   rpmbuild --define '_topdir /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild' -bs rpmbuild/SPECS/glusterfs.spec
   warning: Could not canonicalize hostname: linux-4xup
   Wrote: /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/SRPMS/glusterfs-7.8-0.0.src.rpm
   mv rpmbuild/SRPMS/* .
   rpmbuild --define '_topdir /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild' --with gnfs -bb rpmbuild/SPECS/glusterfs.spec
   Executing(%prep): /bin/sh -e /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/tmp/rpm-tmp.ZZ9noY
   + umask 022
   + cd /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/BUILD
   + cd /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/BUILD
   + rm -rf glusterfs-7.8
   + /usr/bin/gzip -dc /root/huatai.huang/glusterfs/extras/LinuxRPM/rpmbuild/SOURCES/glusterfs-7.8.tar.gz
   + /bin/tar -xf -
   + STATUS=0

参考
======

- `File glusterfs.spec of Package glusterfs  <https://build.opensuse.org/package/view_file/openSUSE:Factory/glusterfs/glusterfs.spec?expand=0>`_
- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
