.. _suse_local_repo:

===================
SUSE本地软件仓库
===================

和RHEL/CentOS相似，我们可以通过构建 :ref:`centos_local_repo` 和 :ref:`centos_local_http_repo` 来加速整个网络海量服务器的软件包更新。对于维护SUSE服务器，同样有这个需求。

SUSE采用的是Red Hat相同的rpm包管理，所以实际上构建软件仓库非常相似。有两种类型软件仓库:

- 产品介质软件仓库: 产品介质软件仓库就是安装介质(CD/DVD)的副本仓库，也就是把iso镜像复制到管理服务器上，然后 ``loop-mounted`` ，或者通过NFS从一个远程服务器挂载。这种静态软件仓库不需要修改也不更新

- 更新和池软件仓库：更新和池软件仓库是由SUSE客户中心提供的，包含产品和扩展的所有更新和布丁。为了能够提供给本地局域网使用，需要从SUSE客户中心镜像这个软件仓库。由于更新仓库是定期更新的，所以必须保持和SUSE客户中心同步。对于这种方式，SUSE提供了订阅管理工具(Subscription Management Tool, SMT) 或 SUSE Manager。

复制产品介质仓库
===================

在产品介质仓库中的文件是固定不变的(从DVD复制)，不需要从远程源同步，只需要复制文件，然后通过NFS挂载产品仓库，或者直接挂载安装介质iso镜像文件就可以。

.. note::

   SUSE Linux Enterprise Server product repository必须直接从本地直接访问，不可以创建目录的符号软链接，否则会导致通过PXE启动失败。

- 产品介质必须复制到特定目录:

  - SUSE Linux Enterprise Server 12 SP4 DVD #1: 复制到 ``/srv/tftpboot/suse-12.4/x86_64/install`` 目录
  - SUSE OpenStack Cloud Crowbar 9 DVD #1: 复制到 ``/srv/tftpboot/suse-12.4/x86_64/repos/Cloud``

.. note::

   我的实践是 SLES 12 sp3 ，所以我复制目录是 ``/srv/tftpboot/suse-12.3/x86_64/install``

参考
=====

- `Software Repository Setup <https://documentation.suse.com/soc/9/html/suse-openstack-cloud-crowbar-all/cha-depl-repo-conf.html>`_
  - `Creating a Local Repository on SUSE <https://docs.datafabric.hpe.com/61/AdvancedInstallation/CreatingLocalReposSUSE.html>`_
