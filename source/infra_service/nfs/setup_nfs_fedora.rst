.. _setup_nfs_fedora:

=======================
Fedora 配置NFS
=======================

软件包
===========

Fedora v14 开始默认NFS是 NFS v4 ，提供如下软件包:

- ``nfs-utils`` : 为内核NFS服务器和相关工具提供了一个守护进程(daemon)
- ``nfs-utils-libs`` 是 ``nfs-utils`` 软件包的相关命令和服务的支持库
- ``system-config-nfs`` 是NFS服务共享配置的图形管理工具

安装
========

- 只需要安装 ``nfs-utils`` :

.. literalinclude:: setup_nfs_fedora/install_nfs
   :language: bash
   :caption: 在 :ref:`redhat_linux` ( :ref:`fedora` )上安装NFS

.. note::

   在 :ref:`redhat_linux` 早期版本， ``portmap`` 服务用于将RPC程序编号映射到IP地址和端口组合。现在 ``portmap`` 服务已经被 ``rpcbind`` 取代，以启用IPv6支持。

参考
======

- `Fedora WIKI: Administration Guide Draft/NFS <https://fedoraproject.org/wiki/Administration_Guide_Draft/NFS>`_
