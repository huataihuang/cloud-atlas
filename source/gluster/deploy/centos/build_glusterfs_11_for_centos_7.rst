.. _build_glusterfs_11_for_centos_7:

==============================
CentOS 7环境编译GlusterFS 11
==============================

.. note::

   本文实践在CentOS 7上完成，其他平台编译方法摘录原文以备参考

编译所需软件包
================

编译GlusterFS需要如下工具软件包:

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
- liburing-devel

Fedora
---------

.. literalinclude:: build_glusterfs_11_for_centos_7/build_requirements_for_fedora
   :language: bash
   :caption: Fedora环境编译GlusterFS安装的编译工具软件包

Ubuntu
------------

.. literalinclude:: build_glusterfs_11_for_centos_7/build_requirements_for_ubuntu
   :language: bash
   :caption: Ubuntu环境编译GlusterFS安装的编译工具软件包

RHEL/CentOS 7
---------------

.. literalinclude:: build_glusterfs_11_for_centos_7/build_requirements_for_centos7
   :language: bash
   :caption: RHEL/CentOS7环境编译GlusterFS安装的编译工具软件包


参考
======

- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
- `Compiling RPMS <https://docs.gluster.org/en/latest/Developer-guide/compiling-rpms/#common-steps>`_
