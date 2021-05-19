.. _build_gluser_suse:

========================
SUSE编译glusterfs
========================

GlusterFS官方文档 `GlusterFS Install Guide <https://docs.gluster.org/en/latest/Install-Guide/Install/>`_ 介绍了gluster官方软件仓库中提供了主流发行版的安装软件包。其中Red Hat/CentOS和Ubuntu/Debian提供软件仓库方式自动安装，SUSE发行版则通过 :ref:`suse_obs` 的下载仓库提供了不同SUSE版本的安装软件包。

不过，SUSE的 :ref:`suse_obs` 只提供了较新发布版本对应的 `GlusterFS SUSE安装包 <http://download.opensuse.org/repositories/home:/glusterfs:/>`_ ，例如 Tumbleweed, SLES 15, and OpenSUSE Leap 15.1。

但是实际上线上生产环境，依然运行着非常古老的SUSE Linux版本，例如 SELS 12 SP3，官方下载仓库只提供了非常陈旧的已经不再维护的发行包。为了能够在实际生产环境稳定运行，需要自己编译安装GlusterFS稳定版本。

.. note::

   我在SUSE Enterprise Linux Server SELS 12 SP3版本上折腾了很久才完成GlusterFS的软件包编译，过程曲折，也迫使我对SUSE Linux比较深入的学习和探索，积累了一些经验。整个探索过程我记录在 :ref:`build_gluser_scratch` ，不过太冗长了，所以我重新在这里整理一个完整的正确方法，提供一个简明指南。如果你对为何我采用这个步骤有疑问，也可以参考原始记录 :ref:`build_gluser_scratch` 。

编译准备工作
=============

我的SUSE SLES 12 SP3环境是在 :ref:`kvm` 虚拟环境中采用 :ref:`create_vm` 方法，创建了SLES 12 SP3环境，所有编译工作都在这个虚拟机中完成。最后再将编译得到的rpm包复制到 :ref:`suse_local_repo` 中提供在线服务器安装。

在开始编译之前，首先要对编译工作环境进行配置:

SUSE SDK
-------------

要在 :ref:`suse_linux` 环境编译软件，首先需要 SUSE 开发SDK。对于企业内部大规模批量部署，建议采用 :ref:`suse_deploy_smt` 。不过，suse SMT需要订购服务，所以还是采用 直接下载 `SUSE Linux enterprise Software Development Kit Downloads <https://www.suse.com/download/sle-sdk/>`_ ，将 下载 SLE SDK iso镜像，然后通过 :ref:`suse_iso_repo` 方式添加到主机repo后，就可以通过 zypper安装依赖软件包。

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

接下来就可以安装所有编译GlusterFS所依赖的开发库以及开发工具了。

安装开发库和工具
-------------------

- 根据GlusterFS官方 `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_ 文档，在SUSE SELS 12 SP3的安装和Red Hat RHEL编译环境相似的软件包::

   zypper in -y autoconf automake bison flex gcc gettext-tools \
       libasan0 libatomic1 libgomp1 libitm1 libopenssl-devel libtsan0 \
       linux-glibc-devel python-netifaces python-simplejson python-xattr \
       rpm-build systemd-rpm-macros zlib-devel sqlite3 \
       fdupes libtool pkgconfig python3 fuse glibc-devel libaio-devel

.. note::

   当后续在编译GlusterFS执行 ``./configure`` 时会提示某些头文件缺失，则对应安装软件包 ``xxxx-devel``

   GlusterFS的编译依赖 ``userspace-rcu-devel`` ，这个软件包仅见于 SUSE SELS 15 ，对于早期SUSE发行版对应软件包名是 ``liburcu-devel`` ，不过需要修订spec文件。见下文。

- 根据编译经验，还需要安装以下开发库::

   zypper in -y libuuid-devel acl-devel libxml2-devel liburcu-devel

   zypper in -y python2-devel libtirpc-devel \
     libcurl-devel fuse-devel libibverbs-devel librdmacm-devel

.. note::

   在后续编译过程中，执行 ``./configure`` 时会提示某些头文件缺失，则对应安装软件包 ``xxxx-devel``

下载代码库
============

- 下载代码::

   git clone git@github.com:gluster/glusterfs.git

- 检查软件代码仓库提供的所有release分支::

   cd glusterfs
   git branch -a | grep release

- 生产环境中，服务器端使用的RHEL/CentOS 7.x，部署的是GlusterFS 6.10版本，所以这里编译SUSE版本也同样使用 ``release-6`` 分支::

   git checkout release-6

编译准备
===========

- 编译配置::

   ./autogen.sh
   ./configure --enable-fusermount

配置输出::

   GlusterFS configure summary
   ===========================
   FUSE client          : yes
   Infiniband verbs     : yes
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
   Use TIRPC            : yes
   With Python          : 3.4
   Cloudsync            : yes

.. note::

   一些有用的 ``configure`` 参数:

   - ``--enable-debug`` 对于开发过程调试特别有用
   - ``--enable-gnfs`` 用于支持传统的gNFS
   - ``--enable-asan`` 如果要帮助修复内存问题

- 编译准备::

   make dist

编译
========

- 编译::

   make

- 在SuSE SLES12 SP3上虽然编译可以顺利完成，但是源代码中缺少一个对应SuSE脚本，所以会导致 ``sudo make install`` 执行失败中断。由于SuSE运行环境接近RedHat，所以借用Redhat版本复制脚本::

   cp extras/init.d/glustereventsd-Redhat extras/init.d/glustereventsd-SuSE
   cp extras/init.d/glustereventsd-Redhat.in extras/init.d/glustereventsd-SuSE.in

上述fix步骤重要，否则会导致安装不完整，会无法正常运行

- 安装::

   sudo make install

- 将编译后的 ``glusterfs`` 源代码目录复制到相同操作系统环境中，并且按照上文方式安装了所有依赖库，就可以同样执行 ``sudo make install`` 进行安装。

运行库问题
------------

我发现有些服务器上按照上文方法安装了glusterfs之后，执行 ``gluster`` 命令会出现库文件找不到报错::

   gluster: error while loading shared libraries: libglusterfs.so.0: cannot open shared object file: No such file or directory

在正常的服务器上执行 ``ldd /usr/local/sbin/gluster`` 可以看到库文件::

   ...
           libglusterfs.so.0 => /usr/local/lib/libglusterfs.so.0 (0x00007f6f29573000)
   ...

观察了报错服务器，实际上也已经安装成功了 ``/usr/local/lib/libglusterfs.so.0`` 。这说明是动态库加载没有刷新。

检查 ``/etc/ld.so.conf`` 内容已经包含了 ``/usr/local/lib/`` 目录，所以只需要刷新一次就可以::

   ldconfig

然后就可以正常运行

编译RPM(尚未完全成功)
======================

.. note::

   实际上目前在SUSE SLES12 SP3上编译RPM还是遇到了尚未克服的困难，我还需要继续探索，以下步骤是目前探索比较可行的步骤记录，供参考。

在 SUSE SLES 12 SP3 环境下编译RPM还需要做一些修订

- GlusterFS源代码中 ``glusterfs.spec`` 配置了 ``BuildRequires:    userspace-rcu-devel >= 0.7`` ，这个依赖需要修改成 SELS 12 SP3对应的 ``liburcu-devel`` (版本是 0.8)，所以修改源代码根目录下 ``glusterfs.spec.in`` ，将::

   BuildRequires:    userspace-rcu-devel >= 0.7

修改成::

   BuildRequires:    liburcu-devel >= 0.7

上述修改可以避免后续 ``make glusterrpms`` 出现以下报错::

   error: Failed build dependencies:
           userspace-rcu-devel >= 0.7 is needed by glusterfs-6.10-0.0.x86_64

- 设置 ``autoconf`` 环境变量::

   export ac_cv_build=x86_64-suse-linux-gnu
   export ac_cv_host=x86_64-suse-linux-gnu

.. note::

   在源代码根目录下有autoconf所依赖的 ``config.guess`` 脚本用来判断编译环境，执行 ``./config.guess`` 可以看到输出::

      x86_64-suse-linux-gnu

配置上述 ``autoconf`` 环境变量是因为我发现在源代码根目录下执行 ``./autoconf`` 是正确生成了 ``Makefile`` 中的配置::

   build_triplet = x86_64-suse-linux-gnu
   host_triplet = x86_64-suse-linux-gnu

但是在执行 ``cd extras/LinuxRPM/;make glusterrpms`` 生成的RPM源代码根目录 ``extras/LinuxRPM/rpmbuild/BUILD/glusterfs-6.10`` 下 ``Makefile`` ( ``Makefile.in`` )中没有正确替换，依然是::

   build_triplet = @build@
   host_triplet = @host@

配置上述两个环境变量 ``ac_cv_build`` 和 ``ac_cv_host`` 可以正确生成RPM源代码根目录 ``extras/LinuxRPM/rpmbuild/BUILD/glusterfs-6.10`` 下 ``Makefile.in`` 和 ``Makefile`` ，也避免了 ``make glusterrpms`` 报错::

   configure: WARNING: cache variable ac_cv_build contains a newline
   configure: WARNING: cache variable ac_cv_host contains a newline

这个报错实际上就会导致 ``extras/LinuxRPM/rpmbuild/BUILD/glusterfs-6.10`` 下 ``Makefile.in`` 和 ``Makefile`` 错误生成::

   build_triplet = It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in
   the sources with an updated version.
   host_triplet = It is not expected to execute this script. When you are building from a
   released tarball (generated with 'make dist'), you are expected to pass
   --build=... and --host=... to ./configure or replace this config.sub script in
   the sources with an updated version.

- 执行RPM编译::

   cd extras/LinuxRPM
   make glusterrpms

目前上述 ``make glusterrpms`` 还是会遇到有关 ``glusterd-geo-rep`` 错误::

   Processing files: glusterfs-geo-replication-6.10-0.0.x86_64
   error: File not found: /home/huatai/glusterfs/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-6.10-0.0.x86_64/usr/com/glusterd/hooks/1/gsync-create/post/S56glusterd-geo-rep-create-post.sh
   
   RPM build errors:
       File not found: /home/huatai/glusterfs/extras/LinuxRPM/rpmbuild/BUILDROOT/glusterfs-6.10-0.0.x86_64/usr/com/glusterd/hooks/1/gsync-create/post/S56glusterd-geo-rep-create-post.sh
   Makefile:561: recipe for target 'rpms' failed
   make: *** [rpms] Error 1

但是在  ``configure`` 增加 ``--disable-georeplication`` 还是不能解决，我预计需要修订 ``glusterfs-geo-replicatio`` 的 ``.spec`` 配置来fix。

待实践...

参考
======

- `File glusterfs.spec of Package glusterfs  <https://build.opensuse.org/package/view_file/openSUSE:Factory/glusterfs/glusterfs.spec?expand=0>`_
- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
