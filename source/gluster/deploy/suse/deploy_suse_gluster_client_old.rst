.. _deploy_suse_gluster_client_old:

===============================
SUSE平台Gluster客户端部署(旧版)
===============================

SUSE系统环境可以使用 ``lsb-release -a`` 命令检查版本::

   LSB Version:    n/a
   Distributor ID: SUSE
   Description:    SUSE Linux Enterprise Server 12 SP3
   Release:        12.3
   Codename:       n/a

在项目上使用的SUSE是作为GlusterFS客户端，访问在CentOS 7上所 :ref:`deploy_centos7_gluster6` 。

.. note::

   SUSE也使用rpm包进行软件安装，但是使用了独特的包管理工具 :ref:`zypper`

软件包
==========

`官方提供 Install Gluster <https://www.gluster.org/install/>`_ 提供：

- 不同版本的源代码
- 针对 `不同发行版的glusterfs二进制软件包 <https://www.gluster.org/download/>`_
  - `最新版本glusterfs下载 <https://download.gluster.org/pub/gluster/glusterfs/LATEST/>`_
  - `6.x系列旧稳定版本glusterfs下载 <https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/>`_

为了配合服务端版本，采用 6.x 系列::

   RPMs for Tumbleweed, SLES 12SP4, SLES 15, and OpenSUSE Leap 15.1 are in
   the repos of the OpenSUSE Build Service at

   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP4-6/

   http://download.opensuse.org/repositories/home:/glusterfs:/Tumbleweed-6/

   http://download.opensuse.org/repositories/home:/glusterfs:/SLES15-6/SLE_15/

   http://download.opensuse.org/repositories/home:/glusterfs:/Leap15.1-6/openSUSE_Leap_15.1/

.. note::

   SUSE提供的软件包是按照 ``SUSE版本+glusterfs版本`` 命名目录的，例如 ``SLES12SP3-3.13`` 表示SUSE Enterprise Server 12 SP3 的 GlusterFS 3.13 版本。安装软件包对操作系统有版本要求，例如GlusterFS 6.x，则需要SUSE 12 SP4。 

GlusterFS 4.x
===============

可以用于SLES 12 SP3的GlusterFS最高版本 4.1.10-101.1 可以从 :

http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/

下载对应软件包::

   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/glusterfs-4.1.10-101.1.x86_64.rpm
   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/glusterfs-devel-4.1.10-101.1.x86_64.rpm
   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/libgfapi0-4.1.10-101.1.x86_64.rpm
   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/libgfchangelog0-4.1.10-101.1.x86_64.rpm
   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/libgfxdr0-4.1.10-101.1.x86_64.rpm
   http://download.opensuse.org/repositories/home:/glusterfs:/SLES12SP3-4.1/SLE_12_SP3/x86_64/libglusterfs0-4.1.10-101.1.x86_64.rpm

- 按照 :ref:`suse_iso_repo` 设置好本地安装光盘镜像作为软件源

- 一些依赖包::

   librdmacm.so.1()(64bit) is needed by glusterfs-4.1.10-101.1.x86_64
   librdmacm.so.1(RDMACM_1.0)(64bit) is needed by glusterfs-4.1.10-101.1.x86_64
   libacl-devel is needed by glusterfs-devel-4.1.10-101.1.x86_64
   libuuid-devel is needed by glusterfs-devel-4.1.10-101.1.x86_64
   pkgconfig(sqlite3) is needed by glusterfs-devel-4.1.10-101.1.x86_64
   pkgconfig(uuid) is needed by glusterfs-devel-4.1.10-101.1.x86_64

由于 ``libacl-devel`` 和 ``libuuid-devel`` 没有包含在SLES 12 SP3安装光盘中，需要通过SDK和update安装源安装，暂时不能解决，所以我没有选择安装 ``glusterfs-devel`` 。

``librdmacm.so.1`` 是支持 RDMA 的驱动，在 `RPM phone.net <http://rpm.pbone.net/>`_ 搜索有openSUSE 12.2 的软件包，但是没有找到SUSE SLES 12 SP3的包。根据 mellanox 的官网文档 `SUSE Linux Enterprise Server (SLES) 12 SP3 Driver
User Manual <https://www.mellanox.com/pdf/prod_software/SUSE_Linux_Enterprise_Server_(SLES)_12_SP3_Driver_User_Manual.pdf>`_ ， ``librdmacm`` 是 RDMA cm library::

   librdmacm-utils - Tools and Example test programs for the librdmacm library
   librdmacm1 - librdmacm provides a userspace RDMA Communication Management API.

通过 zypper 安装glusterfs软件包会自动安装依赖的 ``librdmacm1`` 软件包

- 只安装应用包不安装开发包::

   zypper in glusterfs-4.1.10-101.1.x86_64.rpm  libgfchangelog0-4.1.10-101.1.x86_64.rpm \
       libglusterfs0-4.1.10-101.1.x86_64.rpm libgfrpc0-4.1.10-101.1.x86_64.rpm \
       libgfapi0-4.1.10-101.1.x86_64.rpm libgfxdr0-4.1.10-101.1.x86_64.rpm

客户端挂载
============

- 创建本地挂载目录::

   mkdir -p /data/backup

- 添加 ``/etc/fstab`` 添加::

   192.168.1.11:/backup  /data/backup glusterfs defaults,_netdev,direct-io-mode=enable,backupvolfile-server=192.168.1.12 0 0

- 挂载::

   mount /data/backup

异常排查
----------

Mount failed
~~~~~~~~~~~~~

- 提示报错::

   Mount failed. Please check the log file for more details.

- 检查客户端日志 ``/var/log/glusterfs/mnt-backup`` 日志::

   [2020-10-12 03:10:37.950022] I [MSGID: 100030] [glusterfsd.c:2751:main] 0-/usr/sbin/glusterfs: Started running /usr/sbin/glusterfs version 4.1.10 (args: /usr/sbin/glusterfs --direct-io-mode=enable --process-name fuse --volfile-server=192.168.1.11 --volfile-server=192.168.1.12 --volfile-id=/backup /data/backup)
   [2020-10-12 03:10:37.955799] I [MSGID: 101190] [event-epoll.c:617:event_dispatch_epoll_worker] 0-epoll: Started thread with index 1
   pending frames:
   frame : type(0) op(0)
   patchset: git://git.gluster.org/glusterfs.git
   signal received: 11
   time of crash: 
   2020-10-12 03:10:37
   configuration details:
   argp 1
   backtrace 1
   dlfcn 1
   libpthread 1
   llistxattr 1
   setfsid 1
   spinlock 1
   epoll.h 1
   xattr.h 1
   st_atim.tv_nsec 1
   package-string: glusterfs 4.1.10
   ...

参考 `glusterfs mount client crash <https://www.jianshu.com/p/07453caca0d4>`_ 做一些排查

- 设置 ``/etc/security/limits.conf`` ::

   #*               soft    core            0
   *               soft    core            unlimited

- 设置coredump目录::

   # cat /proc/sys/kernel/core_pattern
   # |/usr/lib/systemd/systemd-coredump %P %u %g %s %t %e

   echo "/var/crash/core.%e.%p" > /proc/sys/kernel/core_pattern

- 设置 bashrc::

   ulimit -c 102400

这里这是允许core文件1G

- 执行挂载命令::

   mount /data/backup

- 然后检查 ``/var/crash`` 目录下，就可以看到生成了一个core文件 ``core.glusterepoll0.59404`` ::

   -rw------- 1 root root 64M Oct 13 12:01 core.glusterepoll0.59404

- 执行gdb命令检查::

   gdb /usr/sbin/glusterfs -c core.glusterepoll0.59404

注意，需要debuginfo软件包，否则提示::

   Missing separate debuginfos, use: zypper install glusterfs-debuginfo-4.1.10-101.1.x86_64

不过，opensuse提供的下载软件包没有dubuginfo，这步排查暂时放弃。后续我实际是通过自己编译源代码来完成部署( :ref:`build_glusterfs_suse` )。

参考
======

- `GlusterFS : Install <https://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_15&p=glusterfs&f=1>`_
