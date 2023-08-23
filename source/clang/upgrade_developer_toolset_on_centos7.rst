.. _upgrade_developer_toolset_on_centos7:

===============================
更新CentOS 7的Develop Toolset
===============================

结合 `Red Hat Developer Toolset > 12 > User Guide > Chapter 1. Red Hat Developer Toolset <https://access.redhat.com/documentation/en-us/red_hat_developer_toolset/12/html/user_guide/chap-red_hat_developer_toolset>`_ 和 :ref:`lfs_linux` ``构建 LFS 交叉工具链和临时工具`` 章节可以知晓 :ref:`build_python3_in_centos7` 的Develop Toolset包括:

.. csv-table:: Develop Toolset(不包含debugger相关工具)
   :file: upgrade_developer_toolset_on_centos7/developer_toolset.csv
   :widths: 30,70
   :header-rows: 1

GCC
=======

- :ref:`upgrade_gcc_on_centos7` 部署安装的是 GCC 10.5.0，我在本文实践中会用这个版本GCC再次编译升级最新版本GCC

由于系统已经具备了 binutils, gcc 10.5.0 ，所以相当于 :ref:`lfs_linux` 再次进行，参考顺序:

- make-4.4.1
- binutils-3.8.2
- gcc-12.2
- elfutils

make
========

- 升级 make:

.. literalinclude:: upgrade_developer_toolset_on_centos7/build_make
   :caption: 升级make

- 配置 :ref:`parallel_make` ( ``~/.bashrc`` ):

.. literalinclude:: parallel_make/make_j

binutils
===========

- 升级 binutils:

.. literalinclude:: upgrade_developer_toolset_on_centos7/build_binutils
   :caption: 升级binutils

gcc
==========

- 升级gcc( 10.5.0 => 13.2 )

.. literalinclude:: upgrade_developer_toolset_on_centos7/build_gcc
   :caption: 升级gcc

elfutils
===========

- 升级elfutils

.. literalinclude:: upgrade_developer_toolset_on_centos7/build_elfutils
   :caption: 升级elfutils

.. note::

   在完成 Developer Toolkit 之后，从源代码 :ref:`build_python3_in_centos7`

参考
=====

- `Red Hat Developer Toolset > 12 > User Guide > Chapter 1. Red Hat Developer Toolset <https://access.redhat.com/documentation/en-us/red_hat_developer_toolset/12/html/user_guide/chap-red_hat_developer_toolset>`_ 根据Red Hat官方资料可以了解Developer Toolset涉及哪些软件包需要更新，以便一一手工升级
