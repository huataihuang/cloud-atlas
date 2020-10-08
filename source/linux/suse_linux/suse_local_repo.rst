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



参考
=====

- `Software Repository Setup <https://documentation.suse.com/soc/9/html/suse-openstack-cloud-crowbar-all/cha-depl-repo-conf.html>`_
  - `Creating a Local Repository on SUSE <https://docs.datafabric.hpe.com/61/AdvancedInstallation/CreatingLocalReposSUSE.html>`_
