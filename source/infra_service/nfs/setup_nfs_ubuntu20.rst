.. _setup_nfs_ubuntu20:

=======================
Ubuntu 20配置NFS服务
=======================

NFS服务器
=============

- 服务器端安装NFS服务::

   sudo apt install nfs-kernel-server

- 启动NFS服务器(同时激活操作系统启动时启动NFS)::

   sudo systemctl enable --now nfs-kernel-server.service

此时，在服务器上执行 ``ps aux | grep nfsd`` 可以看到启动了一系列 ``nfsd`` 进程

配置NFS服务
----------------

配置NFS服务的目录输出，配置文件是 ``/etc/exports`` : 我这里输出的是 :ref:`docker_btrfs_driver` 中 ``/var/lib/docker/data`` 目录

- 创建或修改 ``/etc/exportfs`` ::

   /var/lib/docker/data 192.168.0.0/16(rw,sync,no_root_squash,no_subtree_check)

参数配置说明可以参考 :ref:`setup_nfs_centos7`

- 然后执行输出::

   sudo exportfs -a

NFS客户端
==========

- 客户端安装::

   sudo apt install nfs-common

- 创建NFS挂载目录::

   sudo mkdir /data

- 手工挂载::

   sudo mount 192.168.6.200:/var/lib/docker/data /data

.. note::

   NFS客户端和服务器端的用户uid/gid要对齐，这样用户管理账号权限不会错乱

参考
======

- `Ubuntu doc: Network File System (NFS) <https://ubuntu.com/server/docs/service-nfs>`_
