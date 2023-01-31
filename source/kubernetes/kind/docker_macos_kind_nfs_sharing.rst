.. _docker_macos_kind_nfs_sharing:

=================================================
Docker Desktop for mac部署kind容器使用共享NFS卷
=================================================

在 :ref:`kind_run_simple_container` 访问共享的NFS可以部署一种共享数据的发布模式:

- 容器内部不需要复制发布的文件，对于静态WEB网站会非常容易实现无状态pod部署
- 数据更新可以在中心化的 :ref:`nfs` 存储上实现，方便 :ref:`devops` 持续部署

我在 :ref:`docker_macos_kind_port_forwarding` 基础上进一步设置 ``dev-gw`` 容器提供NFS服务

准备工作
===========

- 调整 ``dev-gw`` 容器运行命令，将物理主机的 ``docs`` 目录作为卷映射到 ``dev-gw`` 内部:

.. literalinclude:: docker_macos_kind_nfs_sharing/run_dev-gw_container_volume_docs
   :language: bash
   :caption: 运行 ``dev-gw`` 容器: 物理主机的docs目录被卷映射进 ``dev-gw`` 为后续NFS服务提供存储目录

NFS服务配置
==============

- 采用 :ref:`ubuntu_nfs` 相似方法配置NFS服务，在 ``dev-gw`` 容器内部修改配置文件 ``/etc/exports`` 内容:

.. literalinclude:: docker_macos_kind_nfs_sharing/exports
   :language: bash
   :caption: 运行 ``dev-gw`` 容器内部添加 /etc/exports

- 在容器内部运行启动NFS服务进行验证::

     exportfs -a
     rpcbind
     rpc.statd
     rpc.nfsd
     rpc.mountd

我执行 ``exprotfs -a`` 提示错误::

   exportfs: /docs does not support NFS export

看来还有概念不清楚，也许我这个思路还存在问题，参考 `docker docs: Volumes <https://docs.docker.com/storage/volumes/>`_ 应该能够直接创建自带NFS输出的Docker卷，待实践

本文还需要探索，待续...

参考
======

- `GitHub: mjstealey/nfs-in-docker <https://github.com/mjstealey/nfs-in-docker>`_  提供了 `docker-entrypoint.sh <https://github.com/mjstealey/nfs-in-docker/blob/master/server/docker-entrypoint.sh>`_ 参考脚本
- `NFS Docker Volumes: How to Create and Use <https://phoenixnap.com/kb/nfs-docker-volumes>`_
- `docker docs: Volumes <https://docs.docker.com/storage/volumes/>`_
