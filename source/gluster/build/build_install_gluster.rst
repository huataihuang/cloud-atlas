.. _build_install_gluster:

===========================
源代码编译安装GlusterFS
===========================

编译GlusterFS环境
==================

编译GlusterFS需要以下软件包:

- GNU Autotools
  - Automake
  - Autoconf
  - Libtool
- lex (generally flex)
- GNU Bison
- OpenSSL
- libxml2
- Python 2.x
- libaio
- libibverbs
- librdmacm
- readline
- lvm2
- glib2
- liburcu
- cmocka
- libacl
- sqlite
- fuse-devel

Fedora编译需要
---------------

- 使用dnf在Fedora上安装以下编译环境::

   dnf install automake autoconf libtool flex bison openssl-devel  \
    libxml2-devel python-devel libaio-devel libibverbs-devel      \
    librdmacm-devel readline-devel lvm2-devel glib2-devel         \
    userspace-rcu-devel libcmocka-devel libacl-devel sqlite-devel \
    fuse-devel redhat-rpm-config rpcgen libtirpc-devel make

Ubuntu编译需要
----------------

- 使用apt在Ubuntu上安装编译环境::

   sudo apt-get install make automake autoconf libtool flex bison  \
    pkg-config libssl-dev libxml2-dev python-dev libaio-dev       \
    libibverbs-dev librdmacm-dev libreadline-dev liblvm2-dev      \
    libglib2.0-dev liburcu-dev libcmocka-dev libsqlite3-dev       \
    libacl1-dev

CentOS/Enterprise Linux v7
----------------------------

- 使用 yum 在CentOS / Enterprise Linux 7上安装编译环境::

   yum install autoconf automake bison cmockery2-devel dos2unix flex   \
    fuse-devel glib2-devel libacl-devel libaio-devel libattr-devel    \
    libcurl-devel libibverbs-devel librdmacm-devel libtirpc-devel     \
    libtool libxml2-devel lvm2-devel make openssl-devel pkgconfig     \
    pyliblzma python-devel python-eventlet python-netifaces           \
    python-paste-deploy python-simplejson python-sphinx python-webob  \
    pyxattr readline-devel rpm-build sqlite-devel systemtap-sdt-devel \
    tar userspace-rcu-devel


参考
======

- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
