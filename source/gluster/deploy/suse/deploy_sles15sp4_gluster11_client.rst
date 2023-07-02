.. _deploy_sles15sp4_gluster11_client:

======================================
在SLES 15 sp4中部署GlusterFS 11客户端
======================================

部署方案
=========

:ref:`suse_linux` 作为主要的企业级Linux发行版，不仅在欧洲应用广泛，也在中国的金融、运营商和电力等关键领域得到采用。本文采用模拟多磁盘服务器构建GlusterFS集群:

- :ref:`install_opensus_leap` 作为基础操作系统( 运行在 :ref:`priv_cloud_infra` )

在生产系统中，需要平衡不同操作系统的服务端和客户端搭配:

- 服务器端采用RHEL/CentOS7 :ref:`deploy_centos7_gluster11` ，客户端采用 :ref:`suse_linux` SLES 15 SP4

准备
============

- 安装 glusterfs 客户端时候会安装操作系统依赖软件包，所以挂载安装光盘镜像:

.. literalinclude:: deploy_sles15sp4_gluster11_client/zypper_add_sles15sp4_iso
   :caption: 安装 glusterfs 客户端需要安装操作系统依然软件包，所以挂载SLES 15 SP4光盘镜像

- 从 `opensuse.org 软件仓库 glusterfs SLES15SP4-11 / 15.4 / x86_64 <http://download.opensuse.org/repositories/home:/glusterfs:/SLES15SP4-11/15.4/x86_64/>`_ 下载安装包，同样通过 :ref:`gluster11_rpm_createrepo` 添加到仓库路径中
