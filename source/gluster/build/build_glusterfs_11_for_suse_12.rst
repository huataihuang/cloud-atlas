.. _build_glusterfs_11_for_suse_12:

==============================
SUSE 12环境编译glusterfs 11
==============================

GlusterFS官方文档 `GlusterFS Install Guide <https://docs.gluster.org/en/latest/Install-Guide/Install/>`_ 介绍了gluster官方软件仓库中提供了主流发行版的安装软件包。其中Red Hat/CentOS和Ubuntu/Debian提供软件仓库方式自动安装，SUSE发行版则通过 :ref:`suse_obs` 的下载仓库提供了不同SUSE版本的安装软件包。

SUSE的 :ref:`suse_obs` 只提供了较新发布版本对应的 `GlusterFS SUSE安装包 <http://download.opensuse.org/repositories/home:/glusterfs:/>`_ ，例如 Tumbleweed, SLES 15, and OpenSUSE Leap 15.1。

.. note::

   本文实践是在 :ref:`suse_linux` 12 SP5环境，编译最新的 GlusterFS 11，以配合 :ref:`build_glusterfs_11_for_centos_7` 所部署的 :ref:`deploy_sles12sp5_gluster11_client` 

但是实际上线上生产环境，依然运行着非常古老的SUSE Linux版本，例如 SELS 12 SP3，官方下载仓库只提供了非常陈旧的已经不再维护的发行包。为了能够在实际生产环境稳定运行，需要自己编译安装GlusterFS稳定版本。

.. note::

   我在SUSE Enterprise Linux Server SELS 12 SP3版本上折腾了很久才完成GlusterFS的软件包编译，过程曲折，也迫使我对SUSE Linux比较深入的学习和探索，积累了一些经验。整个探索过程我记录在 :ref:`build_glusterfs_scratch` ，不过太冗长了，所以我重新在这里整理一个完整的正确方法，提供一个简明指南。如果你对为何我采用这个步骤有疑问，也可以参考原始记录 :ref:`build_glusterfs_scratch` 。

编译准备工作
=============

在服务器上安装完 :ref:`suse_linux` 12 SP5

在开始编译之前，首先要对编译工作环境进行配置:

SUSE SDK
-------------

要在 :ref:`suse_linux` 环境编译软件，首先需要 SUSE 开发SDK。对于企业内部大规模批量部署，建议采用 :ref:`suse_deploy_smt` 。不过，suse SMT需要订购服务，所以还是采用 直接下载 `SUSE Linux enterprise Software Development Kit Downloads <https://www.suse.com/download/sle-sdk/>`_ ，将 下载 SLE SDK iso镜像，然后通过 :ref:`suse_iso_repo` 方式添加到主机repo后，就可以通过 zypper安装依赖软件包。

- 根据编译安装依赖包，添加以下本地iso仓库 :ref:`suse_iso_repo` :

.. literalinclude:: build_glusterfs_11_for_suse_12/mount_sles12_iso
   :caption: 挂载SUSE Linux 安装光盘和SDK光盘的ISO镜像

然后检查仓库:

.. literalinclude:: build_glusterfs_11_for_suse_12/zypper_repos
   :caption: 执行 ``zypper repos`` 检查添加的ISO仓库

显示如下:

.. literalinclude:: build_glusterfs_11_for_suse_12/zypper_repos_output
   :caption: 执行 ``zypper repos`` 检查添加的ISO仓库

接下来就可以安装所有编译GlusterFS所依赖的开发库以及开发工具了。

安装开发库和工具
-------------------

- 根据GlusterFS官方 `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_ 文档，在SUSE SELS 12 SP5的安装和Red Hat RHEL编译环境相似的软件包:

.. literalinclude:: build_glusterfs_11_for_suse_12/zypper_install_build_tools
   :caption: 执行 ``zypper install`` 安装必要编译依赖

.. note::

   使用 ``zypper in`` 执行会提示一些在CentOS上软件包名找不到对应软件包，则通过搜索尽可能找到兼容包:

   .. literalinclude:: build_glusterfs_11_for_suse_12/zypper_install_build_tools_commit
      :caption: ``zypper install`` 安装依赖的一些调整说明

   当后续在编译GlusterFS执行 ``./configure`` 时会提示某些头文件缺失，则对应安装软件包 ``xxxx-devel``

   GlusterFS的编译依赖 ``userspace-rcu-devel`` ，这个软件包仅见于 SUSE SELS 15 ，对于早期SUSE发行版对应软件包名是 ``liburcu-devel`` ，不过需要修订spec文件。见下文。

.. note::

   之前 :ref:`build_glusterfs_6_for_suse_12` 实践经验有所调整::

      'rdma-core-devel' providing 'libibverbs-devel' is already installed.
      'rdma-core-devel' providing 'librdmacm-devel' is already installed.

   也就是说在 12SP5 只要安装一个 ``rdma-core-devel`` 就可以取代 ``libibverbs-devel`` 和 ``librdmacm-devel``

.. note::

   在后续编译过程中，执行 ``./configure`` 时会提示某些头文件缺失，则对应安装软件包 ``xxxx-devel``

下载代码库
============

- `GlusterFS官方下载 <https://download.gluster.org/pub/gluster/glusterfs>`_ 源代码包 ``glusterfs-11.0`` :

.. literalinclude:: build_install_glusterfs/download_glusterfs_11_tgz
   :caption: 下载 ``glusterfs-11.0`` 源代码tgz包

编译准备
===========

- 编译配置:

.. literalinclude:: build_install_glusterfs/config_glusterfs
   :caption: 配置glusterfs

.. literalinclude:: build_install_glusterfs/config_glusterfs_output
   :caption: 配置glusterfs

编译
========

- 编译::

   make

编译报错 ``error: field 'available' has incomplete type``
-----------------------------------------------------------

编译报错:

.. literalinclude:: build_install_glusterfs/make_error1
   :caption: 编译出错，不兼容类型 error: field 'available' has incomplete type

这个问题在 `compiling on SLES 12-SP5 fails : glusterfs/async.h error: field available has incomplete type #1515 <https://github.com/gluster/glusterfs/issues/1515>`_ 有说明，原因似乎需要将 ``urcu`` 升级到更高版本(可能需要 0.10 以上版本)，而SLES 12.5提供的 ``liburcu-devel`` 是 ``0.8.8`` 

从 `Userspace RCU <https://liburcu.org/>`_ 下载最新版本:

.. literalinclude:: build_install_glusterfs/build_liburcu
   :caption: 自行编译安装 ``Userspace RCU``

.. note::

   编译 ``Userspace RCU`` 需要C++11 feature支持，所以 :ref:`upgrade_gcc_on_suse12.5` 完成后在执行上述 `Userspace RCU <https://liburcu.org/>`_ 编译

完成 ``Userspace RCU`` 编译安装之后，重新完成一次 ``GlusterFS`` 的 ``.configure`` 和 ``make`` 就可以顺利完成

安装
=======

- 在SuSE SLES12 SP3上虽然编译可以顺利完成，但是源代码中缺少一个对应SuSE脚本，所以会导致 ``sudo make install`` 执行失败中断。由于SuSE运行环境接近RedHat，所以借用Redhat版本复制脚本::

   cp extras/init.d/glustereventsd-Redhat extras/init.d/glustereventsd-SuSE
   cp extras/init.d/glustereventsd-Redhat.in extras/init.d/glustereventsd-SuSE.in

上述fix步骤重要，否则会导致安装不完整，会无法正常运行

- 安装::

   sudo make install

.. note::

   安装后可能需要执行一次 ``ldconfig`` 确保动态库加载，否则直接执行 ``gluster`` 可能会报找不到库文件，参见 :ref:`build_glusterfs_6_for_suse_12`

- 将编译后的 ``glusterfs`` 源代码目录复制到相同操作系统环境中，并且按照上文方式安装了所有依赖库，就可以同样执行 ``sudo make install`` 进行安装。

编译RPM
======================

- 参考 :ref:`build_glusterfs_11_for_centos_7` ，在构建rpm包之前，首先安装必要的依赖包:

.. literalinclude:: build_glusterfs_11_for_suse_12/install_rpm-build
   :caption: 参考 :ref:`build_glusterfs_11_for_centos_7` 安装SUSE构建rpm的依赖软件包

.. note::

   :ref:`build_glusterfs_11_for_centos_7` 依赖的 ``mock`` rpm包在SUSE平台对应是 ``python-mock`` ，不过这个包 `pyton-mock安装包 <https://software.opensuse.org/package/python-mock>`_ 只在OpenSUSE12提供，位于 `python-mock from Cloud:Tools project <https://software.opensuse.org/download/package?package=python-mock&project=Cloud%3ATools>`_ （实际上就是 :ref:`openstack` 项目提供的工具包) 提供了仓库安装方法

- 执行rpm构建:

.. literalinclude:: build_install_glusterfs/glusterrpms_centos7
   :caption: 执行构建GlusterFS RPMs

编译RPM报错 ``error: Bad owner/group``
------------------------------------------

- 执行 ``make glusterrpms`` 报错:

.. literalinclude:: build_glusterfs_11_for_suse_12/make_glusterrpms_error1
   :caption: 执行 ``make glusterrpms`` 报错 ``error: Bad owner/group``

检查 ``/home/glusterfs-11.0/extras/LinuxRPM/rpmbuild/SOURCES/glusterfs-11.0.tar.gz`` 文件叔主就会看到系统缺少一个 ``1001`` 对应的 ``group`` :

.. literalinclude:: build_glusterfs_11_for_suse_12/tgz_owners
   :caption: ``glusterfs-11.0.tar.gz`` 文件属主group缺失
   :emphasize-lines: 2

原来这个软件包目录上是我从其他服务器上复制过来的 ``tar`` 包，所以解压缩以后属主group依然是另一个系统的用户group，在本地不存在。简单修复一下整个源代码目录属主为当前用户属主的组即可。

编译RPM报错 ``error: Failed build dependencies``
---------------------------------------------------

在 SUSE SLES 12 环境下编译RPM会有依赖错误:

.. literalinclude:: build_glusterfs_11_for_suse_12/make_glusterrpms_error2
   :caption: 执行 ``make glusterrpms`` 报错 ``error: Failed build dependencies``

所以编译RPM还需要做一些修订

- GlusterFS源代码中根目录下 ``glusterfs.spec`` 配置了 ``BuildRequires:    userspace-rcu-devel >= 0.7`` ，这个依赖需要修改成 SELS 12 SP3对应的 ``liburcu-devel`` (版本是 0.8)，所以修改源代码根目录下 ``glusterfs.spec.in`` ，将::

   BuildRequires:    userspace-rcu-devel >= 0.7

修改成::

   BuildRequires:    liburcu-devel >= 0.7

- 我尝试修改 ``extras/LinuxRPM`` 目录下的 ``Makefile.am`` 在 ``autogen:`` 段落将 ``./configure --enable-gnfs --with-previous-options`` 修订为 ``./configure --disable-linux-io_uring`` (注意，不是修改 ``Makefile.in`` ，这个 ``Makefile.in`` 和 ``Makefile`` 会被 ``Makefile.am`` 覆盖):

.. literalinclude:: build_glusterfs_11_for_suse_12/Makefile
   :caption: 修改 ``Makefile`` 设置 ``configure`` 参数
   :emphasize-lines: 5

不过，比较奇怪，虽然这里 ``autoconfig`` 输出信息已经是 ``./configure --disable-linux-io_uring`` ，但实际报错依旧

.. warning::

   实在没有时间和精力折腾了，虽然还是没能搞成SUSE的rpm包(其他折腾见 :ref:`try_fix_build_glusterfs_6_for_suse_12_makefile` )，但是项目工作还是能完成的(因为我通过源代码编译能 ``make install`` )，暂时就这样吧...

参考
======

- `File glusterfs.spec of Package glusterfs  <https://build.opensuse.org/package/view_file/openSUSE:Factory/glusterfs/glusterfs.spec?expand=0>`_
- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
