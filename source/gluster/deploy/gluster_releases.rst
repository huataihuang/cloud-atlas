.. _gluster_releases:

======================
Gluster发布版本
======================

从 Gluster 10 major release开始，release发布周期从6个月改为1年，也就是每12个月进入下一个主版本。从 `Gluster Release Schedule <https://www.gluster.org/release-schedule/>`_ 可以看到当前活跃开发版本以及EOL版本列表。

对于选择具体的Gluster版本，需要根据操作系统版本结合考虑，请参考 `Gluster Community Packages <https://docs.gluster.org/en/latest/Install-Guide/Community-Packages/>`_ 。例如，对于 :ref:`suse_linux` ，可以看到当前主要SLES15企业版和Leap社区版都是 ``15.4`` 得到最好支持，即Gluster v9 / v10 /v11 都支持这个版本的操作系统。

`glusterfs下载网站 <https://download.gluster.org/pub/gluster/glusterfs/>`_ 提供了各个发行版的安装包(或者安装简单指引)

CentOS社区版本
==============

在 `glusterfs下载网站 <https://download.gluster.org/pub/gluster/glusterfs/>`_ 可以看到对不同GlusterFS版本的下载索引，例如 :ref:`deploy_centos7_suse15_suse12_gluster11` 采用 GlusterFS 11.x ，就可以根据说明看到实际软件包是由 CentOS Storage SIG 提供，也就是首先激活SIG(在 :ref:`build_install_glusterfs` 也同样需要激活):

- 激活 :ref:`centos_sig_gluster` :

.. literalinclude:: ../deploy/centos_sig_gluster/install_centos_storage_sig
   :caption: 安装CentOS Storage SIG Yum Repos

- 搜索社区为本机操作系统版本对应提供了哪些GlusterFS版本:

.. literalinclude:: gluster_releases/yum_search_gluster
   :language: bash
   :caption: 搜索社区为本机操作系统版本提供的glusterfs版本

对于 :ref:`centos` 7 系统，可以看到类似以下输出:

.. literalinclude:: gluster_releases/yum_search_gluster_centos7_output
   :caption: CentOS7的GlusterFS版本

这样就可以看到对于CentOS 7 我们可以安装的有 GlusterFs 5 ~ 9

- 安装指定版本仓库，例如 ``gluster9`` ，就可以在后续通过   ``yum install glusterfs`` 安装指定的 ``9`` release:

.. literalinclude:: gluster_releases/yum_install_gluster9_repo
   :caption: 安装 ``gluster9`` release仓库包

SuSE社区版本
=================



参考
=======

- `Gluster Release Schedule <https://www.gluster.org/release-schedule/>`_
