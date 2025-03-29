.. _install_suse:

=================
SUSE安装
=================

SUSE 12 SP3安装
=================

SUSE企业版安装十分简单，从安装介质启动后自动开始安装，不需要任何交互。只要连接了Internet会自动添加Update Repository并且下载更新软件包。所以，只要联网环境安装，初始安装就能够得到该发行版的最新更新。

这个安装过程可能是最简便的安装步骤了:

- 安装过程可以选择服务器角色，默认是Gnome桌面，并且使用了btrfs作为文件系统。也可以选择KVM或者XEN作为虚拟化服务器:

.. figure:: ../../_static/linux/suse_linux/sles12_system_role.png
   :scale: 75

- 可以选择分区设置，默认是采用Btrfs作为根文件系统，可以充分利用Btrfs内建的卷管理，动态划分分区卷:

.. figure:: ../../_static/linux/suse_linux/sles12_partition.png
   :scale: 75

.. note::

   请参考 :ref:`btrfs_in_studio` 了解我的一些实践经验。
