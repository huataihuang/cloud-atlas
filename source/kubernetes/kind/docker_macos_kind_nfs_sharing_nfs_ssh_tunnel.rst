.. _docker_macos_kind_nfs_sharing_nfs_ssh_tunnel:

=====================================================================
Docker Desktop for mac部署kind容器通过 ``SSH Tunnel`` 使用共享NFS卷
=====================================================================

我在 :ref:`docker_macos_kind_nfs_sharing` 折腾了很久也没有成功，原因是 :ref:`docker_desktop` for mac使用了Linux VM来运行Docker容器，导致和物理主机macOS隔离， :ref:`docker_bind_mount` 到容器内部后无法作为文件系统NFS输出。

:ref:`docker_macos_kind_port_forwarding` 实现了在物理主机 :ref:`macos` 直接SSH登陆到 :ref:`kind` 运行的pod中的容器，那么，带来一种可能:

- 使用 :ref:`ssh_tunneling_remote_port_forwarding` 让 :ref:`kind` 运行的pod中的容器反过来直接通过 SSH Tunnel 访问到物理主机的NFS服务

  - ``dev-gw`` 已经实现了SSH登陆，和 :ref:`kind` 集群的节点连接在同一个 ``kind`` 自定义bridge上
  - :ref:`ssh_tunneling_remote_port_forwarding` 将必要的NFS访问端口都映射到 ``dev-gw`` 上，相当于在 ``dev-gw`` 提供了NFS服务
  - 所有 :ref:`kind` 集群的 pod 就可以通过 NFS 方式访问 :ref:`macos` 物理主机目录，实现数据持久化(也方便在物理主机上维护数据)

准备工作
=============

- :ref:`docker_macos_kind_port_forwarding` 部署好中间容器 ``dev-gw``

部署 :ref:`macos_nfs`
-----------------------

采用 :ref:`macos_nfs` 部署一个共享的 NFS 输出 ``docs`` :

- 在 :ref:`macos` 物理主机上启动NFS服务:

.. literalinclude:: ../../apple/macos/macos_nfs/macos_enable_nfs
   :language: bash
   :caption: macOS主机上启动NFS服

- 检查nfs服务:

.. literalinclude:: ../../apple/macos/macos_nfs/rpcinfo
   :language: bash
   :caption: 使用rpcinfo检查本机的portmapper

输出信息:

.. literalinclude:: ../../apple/macos/macos_nfs/rpcinfo_output
   :language: bash
   :caption: 使用rpcinfo检查本机的portmapper的输出信息

- 配置 ``/etc/exports`` :

.. literalinclude:: docker_macos_kind_nfs_sharing_nfs_ssh_tunnel/exports
   :language: bash
   :caption: 配置物理主机 :ref:`macos` 的 ``/etc/exports`` 设置NFS输出目录

.. note::

   ``-maproot=501:20`` 将远程root用户映射到本地用户 ``uid=501,gid=20`` ，这样才能读写目录

- 重启nfs服务:

.. literalinclude:: ../../apple/macos/macos_nfs/restart_nfs
   :language: bash
   :caption: 重启 :ref:`macos` 的nfs服务

- 在网络中一台Linux主机上尝试挂载一次NFS卷验证::

   sudo mkdir /studio
   sudo mount -t nfs <macos_nfs_server_ip>:/Users/huataihuang/docs/studio /studio

如果没有异常挂载成功，则在 :ref:`macos` 服务端检查共享:

.. literalinclude:: ../../apple/macos/macos_nfs/showmount
   :language: bash
   :caption: 检查服务器端输出挂载(已经在Linux挂载NFS)

输出可以看到远程的NFS客户端IP地址以及挂载本机的卷信息::

   All mounts on localhost:
   192.168.6.200:/Users/huataihuang/docs/studio

准备就绪，接下来就可以结合 :ref:`ssh_tunneling_remote_port_forwarding` 将NFS输出给 :ref:`docker_desktop` for mac 虚拟机中运行的 :ref:`kind` 容器挂载NFS了

参考
=======

- `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config>`_ 提供了需要暴露的端口信息列表参考



