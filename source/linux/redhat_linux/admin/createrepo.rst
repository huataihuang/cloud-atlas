.. _createrepo:

=====================
createrepo 创建仓库
=====================

在生产环境，经常需要自己编译和维护 :ref:`rpm` 包，提供内部系统安装。此时，构建自己的软件仓库，就能够非常方便使用 ``yum`` / :ref:`dnf` 进行规模化自动安装。

- 社区提供的软件安装包，通过 :ref:`wget_mirror_site` 完整下载社区安装包，然后通过 ``createrepo`` 建立软件包下载索引.
- 自己编译和维护安装包，例如 :ref:`build_glusterfs_11_for_centos_7`

安装 ``createrepo`` 工具
==========================

- 安装工具:

.. literalinclude:: createrepo/install_createrepo
   :caption: 在CentOS/RHEL中安装 ``createrepo``

配置
=======

- 将需要索引的rpm放到指定目录，例如， :ref:`build_glusterfs_11_for_centos_7` 后获得的所有rpm包存放到 ``glusterfs/11.0/CentOS/7.2`` 目录下

- 执行以下命令构建索引:

.. literalinclude:: createrepo/createrepo_glusterfs
   :caption: 为 :ref:`build_glusterfs_11_for_centos_7` 构建的rpm包创建索引

完成后，在rpm包目录下创建了一个 ``repodata`` 目录，其中就包含了rpm包目录的索引配置

- 创建repository配置文件:

.. literalinclude:: createrepo/glusterfs_repo.sh
   :caption: 创建一个简单的 ``glusterfs_repo.sh`` 脚本生成 ``glusterfs-11.repo``

参考
======

- `Creating and hosting your own rpm packages and yum repo <https://earthly.dev/blog/creating-and-hosting-your-own-rpm-packages-and-yum-repo/>`_
- `How to Create Your Own Repositories for Packages <https://www.percona.com/blog/how-to-create-your-own-repositories-for-packages/>`_
