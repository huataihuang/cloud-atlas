.. _priv_docker:

======================================
私有云docker环境
======================================

.. note::

   我重新部署的基于 :ref:`hpe_dl360_gen9` 云计算环境，采用虚拟机运行Docker和Kubernetes。不过，我也在物理主机上部署了一个用于日常开发学习的Docker环境，主操作系统是 :ref:`ubuntu_linux` ，实践如下。

安装Docker运行环境
====================

- 参考 :ref:`install_docker_linux` 完成Docker软件初始安装::

   sudo apt install docker.io

- 将个人用户账号 ``huatai`` 添加到 ``docker`` 用户组方便执行docker命令::

   sudo usermod -aG docker $USER

- 然后验证docker运行::

   docker ps

将Docker存储迁移到Btrfs
=========================

为了能够充分发挥SSD性能，并且学习和实践 :ref:`btrfs` ，参考 :ref:`docker_btrfs_driver` 将Docker存储迁移到Btrfs中。
