.. _download_gluster_rpm_createrepo:

====================================
下载GlusterFS rpm软件包并构建仓库
====================================

社区版本
==========

从 :ref:`gluster_releases` 的官方文档以及对应安装 ``gluster9`` 软件仓库包，可以从安装的仓库配置文件 ``/etc/yum.repos.d/CentOS-Gluster-9.repo`` 获得实际安装包下载位置是: 

.. literalinclude:: download_gluster_rpm_createrepo/gluster-9_download_url
   :caption: 下载glusterfs 9的网址
   :emphasize-lines: 2

不过，现在CentOS 7系列已经不再更新，全部归档到 `vault CentOS网站 <http://vault.centos.org/>`_ ，所以实际下载位置是:

- `CentOS 7.2.1511 对应 gluster 3.8 <https://vault.centos.org/7.2.1511/storage/x86_64/>`_
- ...

需要注意的是 `vault CentOS网站 <http://vault.centos.org/>`_ 归档了了不同的CentOS 7版本，虽然你依然可以现在并使用旧版CentOS，但是在这个归档网站只提供了较为陈旧的GlusterFS版本，例如:

- CentOS 7.2.1511 只提供 gluster-3.8 版本
- CentOS 7.8.2003 则最高只提供 gluster-8.1 版本 (CentOs 7.9.2009没有提供发行版，只有升级方式)

这和我最初预期的不同，我最初根据 :ref:`gluster_releases` 激活 CentOS SIG 仓库是显示提供 ``gluster-9`` 安装包的。

仔细核对了一下，原来在 `CentOS 7 mirror网站 <http://mirror.centos.org/centos-7/>`_ 是提供了 `CentOS 7.9.2009 storage x86_64 gluster-9 <http://mirror.centos.org/centos-7/7.9.2009/storage/x86_64/gluster-9/>`_ 提供了较新的 ``9.6.1`` 版本(2022年8月19日发布，是9.x最新版本)

.. warning::

   很不幸， ``gluster-9`` 只能在CentOS 7.9最新版本上部署，对于早期历史版本，例如 CentOS 7.2，社区并没有对应维护GlusterFS的稳定版本。

(策略修改)自编译软件包
===========================

- 在 :ref:`centos` 7.2 环境中完成 :ref:`build_glusterfs_11_for_centos_7` ，然后 :ref:`gluster11_rpm_createrepo` 。
- :ref:`deploy_centos7_gluster11`

