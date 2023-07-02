.. _gluster11_rpm_createrepo:

==============================
构建GlusterFS 11 RPM软件仓库
==============================

由于 :ref:`download_gluster_rpm_createrepo` 实践过程中发现难以在低版本 CentOS 7.2 上部署 GlusterFs 9，所以调整方案，采用 :ref:`build_glusterfs_11_for_centos_7` ，同样也构建自己的安装RPM包仓库。

准备工作
==========

- 已经完成 :ref:`build_glusterfs_11_for_centos_7` ，在 ``extras/LinuxRPM`` 有所有编译好的RPM包
- 安装好 :ref:`createrepo` :

.. literalinclude:: ../../../linux/redhat_linux/admin/createrepo/install_createrepo
   :caption: 在CentOS/RHEL中安装 ``createrepo``

创建仓库
==========

- 将所有 :ref:`build_glusterfs_11_for_centos_7` 生成在 ``extras/LinuxRPM`` 所有编译好的RPM包复制到 ``glusterfs/11.0/CentOS/7.2`` 目录下

- (重要)在运行GlusterFS主机上需要社区提供的 ``userspace-rcu`` ( :ref:`build_glusterfs_11_for_centos_7` 则需要对应的 ``userspace-rcu-devel`` )，在 ``glusterfs/11.0/CentOS/7.2`` 目录中下载 ``userspace-rcu`` :

.. literalinclude:: gluster11_rpm_createrepo/download_userspace-rcu
   :caption: 在RPM仓库目录下添加下载社区提供的 ``userspace-rcu`` (运行依赖)

- 构建索引:

.. literalinclude:: ../../../linux/redhat_linux/admin/createrepo/createrepo_glusterfs
   :caption: 为 :ref:`build_glusterfs_11_for_centos_7` 构建的rpm包创建索引

- 执行以下脚本 ``./glusterfs_repo.sh 192.168.6.200`` (这里假设运行repo服务的主机是 ``192.168.6.200`` ):

.. literalinclude:: ../../../linux/redhat_linux/admin/createrepo/glusterfs_repo.sh
   :caption: ``glusterfs_repo.sh`` 脚本生成 ``glusterfs-11.repo``

- 将生成的 ``glusterfs-11.repo`` 复制到所有需要部署安装 ``glusterfs`` 的服务器上，然后执行以下命令验证仓库是否工作正常:

.. literalinclude:: gluster11_rpm_createrepo/yum_install_gluster
   :caption: 验证glusterfs-11仓库

如果一切正常，将看到如下输出:

.. literalinclude:: gluster11_rpm_createrepo/yum_install_gluster_output
   :caption: 验证glusterfs-11仓库输出信息

