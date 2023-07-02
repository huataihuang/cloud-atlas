.. _deploy_centos7_suse15_gluster9:

========================================
在CentOS 7 和SUSE 15环境部署GlusterFS 9
========================================

部署方案
=========

在生产系统中，需要平衡不同操作系统的服务端和客户端搭配:

- 服务器端采用 :ref:`centos` 7 ，客户端擦用 :ref:`suse_linux` 15
- 由于CentOS 7已经进入EOL状态，所以社区已经不再将最新的 GlusterFS 10/11 移植到CentOS 7，所以通过 :ref:`centos_sig_gluster` 最多只能部署 GlusterFS 9
- SuSE 15 SP4是目前 :ref:`suse_linux` 15 最新稳定版本，也是主流发行版本，所以得到社区良好支持，可以部署 GlusterFS 9 / 10 / 11

方案一
--------

我最初考虑采用GlusterFS Current系列，也就是 GlusterFS 11，但是在目前(2023年6月)，这个Current系列只在年初发布过一次 11.0 版本，尚未进入稳定周期。不过，我也考虑到很快 GlusterFS 11会进入稳定周期，也是目前活跃开发主要版本，所以对于生产环境，预计在半年左右就可以投入采用。不过，CentOS 7目前还在大量运行，如果采用CentOS 7作为 :ref:`gluster_deploy_centos` 11，则需要自己维护 :ref:`build_install_glusterfs` :

- 下载源代码 :ref:`build_glusterfs_11_for_centos_7` 
- :ref:`createrepo` 构建自己的软件包仓库

方案二
---------

考虑到稳定周期以及 :ref:`centos` 和 :ref:`suse_linux` 同时具备的社区安装包，我选择 GlusterFS 9.x 系列:

- 当前最新的 GlusterFS 9.x 系列是 GlusterFS 9.6 ，已经迭代了 7 次，相对已经久经考验
- :ref:`centos` 7 和 :ref:`suse_linux` 15 恰好共同提供了 GlusterFS 9.x ，可以采用社区维护版本，也是得到广泛使用的验证编译版本

由于内部网络，无法直接访问Internet，也就无法直接访问社区软件仓库，所以采用如下方案:

- 从社区仓库通过 :ref:`wget` 镜像下安装包
- :ref:`download_gluster_rpm_createrepo` 

最终方案
----------

计划总是不如变化，我最初想采用方案二(考虑社区维护版本可以减轻自己的压力)，但是社区版本需要采用最新的操作 CentOS 7.9 ，然而对生产环境升级操作系统风险较大。

考虑到目前仅有 GlusterFS 10 / 11 是社区活跃开发版本，并且 GlusterFS 10很快会进入EOL，而我已经成功验证 :ref:`build_glusterfs_11_for_centos_7` ，所以，最终结合两个方案形成最终实施方案:

- GlusterFS服务器端:

  - 在CentOS 7.2平台 :ref:`build_glusterfs_11_for_centos_7`
  - 采用 :ref:`createrepo` 构建方便安装部署的软件包仓库
  - :ref:`deploy_centos7_gluster11` 

- GlusterFS客户端:
