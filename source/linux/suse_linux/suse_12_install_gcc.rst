.. _suse_12_install_gcc:

=============================
SUSE SLES 12 SP3安装gcc
=============================

在SUSE SLES 12上安装gcc建议采用 :ref:`suse_update_dev_tool` 方式升级安装开发工具链软件包。对于无法在线安装，我尝试使用下载软件包进行安装。

在 `devel:gcc:SLE-12 <http://download.opensuse.org/repositories/devel:/gcc/SLE-12/>`_ 提供了不同架构SLE-12的gcc开发工具包安装下载。

- 添加仓库::

   zypper ar -f http://download.opensuse.org/repositories/devel:/gcc/SLE-12/ devel:gcc

- 添加仓库以后检查::

   zypper ref

- 更新(dup)::

   zypper dup -r devel:gcc

创建本地仓库安装
=================

- 将仓库镜像到本地目录

- 在目录下执行创建仓库::

   createrepo

参考
=======

- `Re: Create a Local Repository <https://forums.opensuse.org/showthread.php/510466-Create-a-Local-Repository>`_
