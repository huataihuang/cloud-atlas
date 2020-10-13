.. _build_gluser_suse:

=======================
SUSE编译glusterfs
=======================

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

报错和处理
============

- 缺少::

   libuuid-devel

- 解决方法是搜索::

   zypper info libuuid-devel

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

参考: `Imposible install on Suse Enterprise 12 #1162 <https://github.com/netdata/netdata/issues/1162>`_

源代码编译安装
================

- 下载源代码::

   wget https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/glusterfs-6.10.tar.gz
   tar xfz glusterfs-6.10.tar.gz
   cd glusterfs

参考
======

- `File glusterfs.spec of Package glusterfs  <https://build.opensuse.org/package/view_file/openSUSE:Factory/glusterfs/glusterfs.spec?expand=0>`_
- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
