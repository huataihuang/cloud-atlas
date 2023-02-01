.. _docker_macos_kind_nfs_sharing:

========================================================
(未成功)Docker Desktop for mac部署kind容器使用共享NFS卷
========================================================

.. warning::

   本文方案实践尚未成功，可能是因为 :ref:`docker_desktop` for mac 的物理主机文件系统 ``APFS 加密文件系统`` 影响。所以后续我准备切换到 :ref:`mobile_cloud_x86_kind` 再做实践。

   在 :ref:`docker_container_nfs` 使用 :ref:`docker_systemd` 来运行NFS服务器，和本文区别仅是 ``init`` 差异，所以应该也解决不了Docker卷的 ``does not support NFS export`` 问题。

.. note::

   我在 :ref:`docker_volume` 学习过程仔细阅读了Docker官方文档 `docker docs: Storage >> Volumes <https://docs.docker.com/storage/volumes/>`_ 发现:

   - :ref:`docker_volume` 是指运行Docker服务的主机上的卷，也就是说在 :ref:`docker_desktop` for mac中，是指运行于 :ref:`xhyve` 中的Linux虚拟机

**在 Docker Desktop for mac 实践物理主机目录 mount 到容器内部再 NFS sharing 目前没有成功** ，我改变方案，采用 :ref:`docker_macos_kind_nfs_sharing_nfs_ssh_tunnel`

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

异常排查
-----------

执行 ``exprotfs -a`` 提示错误::

   exportfs: /docs does not support NFS export

执行 ``rpc.nfsd`` 提示错误::

   rpc.nfsd: Unable to request RDMA services: Protocol not supported

- 参考 `itsthenetwork/nfs-server-alpine <https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/>`_ ，在容器中运行NFS服务器， ``docker run`` 需要使用参数 ``--privileged`` :

.. literalinclude:: docker_macos_kind_nfs_sharing/run_dev-gw_container_volume_docs_privileged
   :language: bash
   :caption: 运行 ``dev-gw`` 容器: 卷 ``docs`` 以及增加运行参数 ``--privileged``

不过， ``--privileged`` 参数不能解决 ``exportfs: /docs does not support NFS export`` ， `itsthenetwork/nfs-server-alpine <https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/>`_ 提到了 ``OverlayFS`` 不支持NFS输出，需要使用 :ref:`docker_volume` 挂载到容器内部。不过，我确实是使用了::

   DOCS_DIR="/Users/huataihuang/docs"
   docker run ... -v  ${DOCS_DIR}:/docs ...

参考 `directory does not support NFS #61 <https://github.com/ehough/docker-nfs-server/issues/61>`_ ，我尝试改为 ``bind mount`` :

.. literalinclude:: docker_macos_kind_nfs_sharing/run_dev-gw_container_bind_mount_docs_privileged
   :language: bash
   :caption: 运行 ``dev-gw`` 容器: 使用  ``bind mount`` 卷 ``docs`` 以及增加运行参数 ``--privileged``

但是报错依旧是 ``exportfs: /docs does not support NFS export``

.. note::

   我怀疑在 :ref:`macos` 上运行的 ``Docker Desktop for mac`` 的底层文件系统 ``APFS 加密文件系统`` 影响了容器化运行NFS输出，所以我后续准备在 :ref:`mobile_cloud_x86_kind` 重新实践(底层使用 :ref:`zfs`)

.. note::

   `docker docs: Volumes <https://docs.docker.com/storage/volumes/>`_ 应该能够直接创建自带NFS输出的Docker卷，待实践

参考
======

- `GitHub: mjstealey/nfs-in-docker <https://github.com/mjstealey/nfs-in-docker>`_  提供了 `docker-entrypoint.sh <https://github.com/mjstealey/nfs-in-docker/blob/master/server/docker-entrypoint.sh>`_ 参考脚本
- `NFS Docker Volumes: How to Create and Use <https://phoenixnap.com/kb/nfs-docker-volumes>`_
- `docker docs: Volumes <https://docs.docker.com/storage/volumes/>`_
- `itsthenetwork/nfs-server-alpine <https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/>`_ 给出了很多有关容器中运行NFS服务器的思路和建议
