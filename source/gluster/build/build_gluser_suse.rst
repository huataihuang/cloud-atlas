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

上述报错在 `Bug 1541261 - "glustereventsd-SuSE.in" is missing in extras/init.d  <https://bugzilla.redhat.com/show_bug.cgi?id=1541261>`_ 提到::

   git clone https://github.com/gluster/glusterfs
   cd glusterfs
   git checkout v3.12.3
   ./autogen.sh
   ./configure --enable-gnfs
   make
   make install

此时安装过程失败，导致库文件尚未复制，例如挂载目录依然会报错::

   /usr/local/sbin/glusterfs: error while loading shared libraries: libglusterfs.so.0: cannot open shared object file: No such file or directory
   Mount failed. Please check the log file for more details.

上述安装报错和 ``glustereventsd`` 相关，可以看到 ``configure`` 输出中是有 ``Events`` 支持的。

运行GlusterFS
==================

从源代码安装通常不安装任何init脚本，所以需要手工启动 ``glusterd`` 服务::

   glusterd

在启动了上述daemon进程之后，就可以运行 ``gluster`` 命令来使用GlusterFS。

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

从git版本编译
==============

- 下载代码::

   git clone git@github.com:gluster/glusterfs.git
   cd glusterfs
   git checkout v6.10

- 编译::

   ./autogen.sh
   ./configure --without-libtirpc
   cd extras/LinuxRPM
   make glusterrpms
   
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

参考
======

- `File glusterfs.spec of Package glusterfs  <https://build.opensuse.org/package/view_file/openSUSE:Factory/glusterfs/glusterfs.spec?expand=0>`_
- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
