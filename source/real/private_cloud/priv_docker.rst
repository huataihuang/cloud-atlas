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

为了能够充分发挥SSD性能，并且学习和实践 :ref:`btrfs` ，采用 :ref:`docker_btrfs_driver` 将Docker存储迁移到Btrfs中。

创建运行容器
================

- 部署 :ref:`docker_studio` 使用 ``systemd`` 的docker容器 ``Dockerfile`` :

.. literalinclude:: ../../docker/admin/docker_studio/ssh/Dockerfile
   :language: dockerfile
   :linenos:
   :caption:

- 构建docker镜像并运行(采用 :ref:`auto_start_containers` )::

   export DOCKER_BUILDKIT=1
   docker build -t local:fedora34-systemd-ssh .

   docker run --privileged=true --hostname fedora34-dev --name fedora34-dev \
       -p 222:22 -p 280:80 -p 2443:443 -v /home/huatai/dev:/home/admin/dev --restart unless-stopped \
       -dti local:fedora34-systemd-ssh

.. note::

   ``fedora34-dev`` 作为开发环境
