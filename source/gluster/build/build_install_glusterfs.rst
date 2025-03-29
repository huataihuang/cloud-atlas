.. _build_install_glusterfs:

===========================
源代码编译安装GlusterFS
===========================

编译GlusterFS环境
==================

编译GlusterFS需要以下软件包:

.. literalinclude:: build_install_glusterfs/build_require
   :caption: 编译GlusterFS需要的软件包列表

Fedora编译需要
---------------

- 使用dnf在Fedora上安装以下编译环境:

.. literalinclude:: build_install_glusterfs/build_requirements_for_fedora
   :caption: 在Fedora编译GlusterFS需要的软件包

Ubuntu编译需要
----------------

- 使用apt在Ubuntu上安装编译环境:

.. literalinclude:: build_install_glusterfs/build_requirements_for_ubuntu
   :caption: 在Ubuntu编译GlusterFS需要的软件包

CentOS/Enterprise Linux v7需要(已实践)
---------------------------------------

- 需要先激活 :ref:`centos_sig_gluster` 以便能够安装 ``userspace-rcu-devel`` :

.. literalinclude:: ../deploy/centos_sig_gluster/install_centos_storage_sig
   :caption: 安装CentOS Storage SIG Yum Repos

- 使用 yum 在CentOS / Enterprise Linux 7上安装编译环境:

.. literalinclude:: build_install_glusterfs/build_requirements_for_centos7
   :language: bash
   :caption: 在CentOS 7编译GlusterFS需要的软件包

CentOS / Enterprise Linux v8需要
----------------------------------

- 激活build环境需要的仓库:

.. literalinclude:: build_install_glusterfs/enable_repos_centos8_for_glusterfs
   :caption: 为CentOS 8激活必要的编译所需仓库

- 使用 dnf 在CentOS 8上安装编译环境:

.. literalinclude:: build_install_glusterfs/build_requirements_for_centos8
   :caption: 在CentOS8编译GlusterFS需要的软件包

CentOS Stream 9需要
-------------------

- 激活build环境需要的仓库:

.. literalinclude:: build_install_glusterfs/enable_repos_centos9_for_glusterfs
   :caption: 为CentOS 9激活必要的编译所需仓库

.. note::

    CentOS Stream 9我还么有实践过，这里只摘录原文，编译需要的安装包可能同 CentOS 8(不确定)

源代码
===========

根据 `Gluster Community Packages <https://docs.gluster.org/en/latest/Install-Guide/Community-Packages/>`_ 信息，按照需求(发行版)下载

- `GlusterFS官方下载 <https://download.gluster.org/pub/gluster/glusterfs>`_ 源代码包，例如 ``glusterfs-11.0`` :

.. literalinclude:: build_install_glusterfs/download_glusterfs_11_tgz
   :caption: 下载 ``glusterfs-11.0`` 源代码tgz包

编译配置
==========

- 使用 ``autogen`` 生成 ``configure`` 脚本:

.. literalinclude:: build_install_glusterfs/autogen_glusterfs
   :caption: 使用 ``autogen`` 生成GusterFS的 ``configure`` 脚本

- 执行 ``configure`` ::

   ./configure

CentOS 7
-----------

- 针对CentOS 7使用以下编译配置:

.. literalinclude:: build_install_glusterfs/configure_glusterfs_for_centos7
   :caption: 执行 ``configure`` 脚本(注意关闭CentOS 7不支持选项)

编译和安装
============

- 编译和安装GlusterFS非常简单:

.. literalinclude:: build_install_glusterfs/glusterfs_make_install
   :caption: 执行编译和安装

编译RPMs
============

在基于 RPM 的系统中，如 :ref:`fedora` 可以非常容易直接构建RPM包

- 在 :ref:`fedora` / :ref:`centos` / RHEL 系统中安装依赖:

.. literalinclude:: build_install_glusterfs/install_rpm-build
   :caption: 安装 ``rpm-build`` 构建工具

.. note::

   这里我比官方文档多安装了一个 ``bash-completion`` ，原因是我在 :ref:`build_glusterfs_11_for_centos_7` 发现 ``pkg-config`` 依赖这个辅助功能

- 然后执行以下命令构建GlusterFS RPMs:

.. literalinclude:: build_install_glusterfs/glusterrpms
   :caption: 执行构建GlusterFS RPMs

构建GlusterFS RPMs输出信息显示，实际上构建参数增加了一个 ``--enable-gnfs``

参考
======

- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
