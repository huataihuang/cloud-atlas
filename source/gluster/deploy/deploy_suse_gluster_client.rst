
===========================
SUSE平台Gluster客户端部署
===========================

SUSE系统环境可以使用 ``lsb-release -a`` 命令检查版本::

   LSB Version:    n/a
   Distributor ID: SUSE
   Description:    SUSE Linux Enterprise Server 12 SP3
   Release:        12.3
   Codename:       n/a

在项目上使用的SUSE是作为GlusterFS客户端，访问在CentOS 7上所 :ref:`deploy_gluster6` 。

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



源代码编译安装
================

- 下载源代码::

   wget https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/glusterfs-6.10.tar.gz
   tar xfz glusterfs-6.10.tar.gz
   cd glusterfs

.. note::

   从官方文档看提供了Fedora/Ubuntu/CentOS的编译指南，但是缺乏SUSE编译说明。并且当前安装升级SUSE不易，所以暂时没有实践。还是采用SUSE官方提供的安装包安装。

参考
======

- `GlusterFS : Install <https://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_15&p=glusterfs&f=1>`_
