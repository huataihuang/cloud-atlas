.. _docker_macos_kind_nfs_sharing_nfs_ssh_tunnel:

===============================================================================
(正在探索)Docker Desktop for mac部署kind容器通过 ``SSH Tunnel`` 使用共享NFS卷
===============================================================================

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

:ref:`ssh_tunneling_remote_port_forwarding` 实现容器访问NFS
=============================================================

- 根据上文部署 :ref:`macos_nfs` 中 ``rpcinfo -p`` 可以获得NFS访问的端口，并且参考 `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config>`_ 也可以了解到NFS访问的端口列表:

.. csv-table:: NFS端口列表
   :file: docker_macos_kind_nfs_sharing_nfs_ssh_tunnel/nfs_ports.csv
   :widths: 20,80
   :header-rows: 1

- 在 :ref:`macos` 物理主机上，修改 ``~/.ssh/config`` 配置添加以下内容( :ref:`ssh_key` 认证 + :ref:`ssh_multiplexing` )，实现 :ref:`ssh_tunneling_remote_port_forwarding` : 在 ``kind`` 网桥上连接的所有pod容器将能够通过 NFS 挂载 ``dev-gw`` 实际挂载 :ref:`macos` 物理主机上 NFS 输出:

.. literalinclude:: docker_macos_kind_nfs_sharing_nfs_ssh_tunnel/ssh_config
   :language: bash
   :caption: 配置macOS物理主机用户目录 ``~/.ssh/config`` 添加 ``dev-gw`` 远程服务器端口转发配置

.. note::

   中间转发服务器 ``dev-gw`` 的 ``/etc/ssh/sshd_config`` 必须配置::

      GatewayPorts yes

   否则 :ref:`ssh_tunneling_remote_port_forwarding` 时，该服务器转发端口只监听回环地址 ``127.0.0.1`` ，就会导致远程NFS客户端无法访问

- 上述SSH配置完成后，只需要执行一条简单的ssh命令就完成 :ref:`ssh_tunneling_remote_port_forwarding` ，并且SSH通道始终打开，方便NFS访问::

   ssh dev-gw

测试
========

在Docker容器 ubuntu 测试客户端测试 :ref:`ubuntu_nfs` :

- 安装Ubuntu的NFS客户端:

.. literalinclude:: ../../linux/ubuntu_linux/storage/ubuntu_nfs/instatll_nfs_client
   :language: bash
   :caption: Ubuntu安装NFS客户端

- 挂载NFS服务器测试，注意，NFS服务器使用 ``dev-gw`` 在 ``docker network`` 中的网络IP ``172.22.0.12`` ，而服务器端的目录则是 :ref:`macos` 物理主机前面配置的 :ref:`macos_nfs` 输出目录::

   mkdir /studio
   mount -t nfs 172.22.0.12:/Users/huataihuang/docs/studio /studio

这里有一个提示错误::

   mount.nfs: rpc.statd is not running but is required for remote locking.
   mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
   mount.nfs: Operation not permitted

修改参数，添加 ``-o nolock`` ::

   mount -t nfs -o nolock 172.22.0.12:/Users/huataihuang/docs/studio /studio

此时提示错误::

   mount.nfs: Operation not permitted

这个问题在 :ref:`docker_container_nfs` 已经排查过，是因为Docker容器安全限制，需要在运行容器时添加参数 ``--cap-add sys_admin`` 

- 重新启动一个 ``fedora-dev-tini`` 容器，在 :ref:`fedora_tini_image` 运行 ``fedora-dev-tini`` 容器的命令基础上加上 ``--cap-add sys_amdin`` 参数:

.. literalinclude:: docker_macos_kind_nfs_sharing_nfs_ssh_tunnel/run_fedora-dev-tini_container_sys_admin
   :language: bash
   :caption: 运行 ``fedora-dev-tini`` 容器命令添加 ``--cap-add sys_admin`` 实现容器内NFS挂载权限
   :emphasize-lines: 2

测试挂载::

   mkdir /stuido
   mount -t nfs -o nolock,nfsvers=3,tcp 172.22.0.12:/Users/huataihuang/docs/studio /studio

非常奇怪，我在 ``dev-gw`` 服务器上观察发现没有任何连接到NFS相关监听端口，而 ``fedora-dev-tini`` 过了很久只显示一个输出::

   mount.nfs: Connection refused

- 在 ``fedora-dev-tini`` 主机上检查 ``telnet 172.22.0.12 111`` 端口是打开的

- 检查 ``rpcinfo`` ::

   # rpcinfo -p 172.22.0.12
   172.22.0.12: RPC: Remote system error - Connection refused

发现 ``dev-gw`` 拒绝了连接，但是在 ``dev-gw`` 上使用::

   $ netstat -an
   Active Internet connections (servers and established)
   Proto Recv-Q Send-Q Local Address           Foreign Address         State
   tcp        0      0 0.0.0.0:2049            0.0.0.0:*               LISTEN
   tcp        0      0 0.0.0.0:1017            0.0.0.0:*               LISTEN
   tcp        0      0 0.0.0.0:1021            0.0.0.0:*               LISTEN
   tcp        0      0 0.0.0.0:1003            0.0.0.0:*               LISTEN
   tcp        0      0 0.0.0.0:685             0.0.0.0:*               LISTEN
   tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
   tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN
   tcp        0      0 127.0.0.11:35477        0.0.0.0:*               LISTEN
   ...

可以看到端口是监听的，但是没有客户端连接

尝试 systemd NFS客户端
======================

之前在 :ref:`docker_container_nfs` 中提到: 

方法一：在容器内部安装 ``nfs-utils`` ，就如同常规到NFS客户端一样，在容器内部直接通过rpcbind方式挂载NFS共享输出，这种方式需要每个容器独立运行rpcbind服务，并且要使用 :ref:`docker_systemd` ，复杂且消耗较多资源。不过，优点是完全在容器内部控制，符合传统SA运维方式。

.. note::

   :ref:`kind` 在node节点是使用了完整的 :ref:`systemd` 来实现的，所以部署 :ref:`k8s_nfs` 是满足节点提供 rpcbind 服务的。

   对啊，要在Docker容器中测试NFS挂载，必须也是运行 :ref:`systemd` 的Docker容器

- 重新部署 :ref:`fedora_image` (内置 :ref:`systemd` ) ，使用镜像是 ``fedora-ssh`` ，执行以下运行命令::

   docker run -itd --privileged=true -p 1122:22 --network kind \
       --hostname fedora-ssh --name fedora-ssh fedora-ssh

.. note::

   :ref:`fedora` 配置NFS方法采用 :ref:`setup_nfs_centos7` 相同客户端方式

- 安装NFS客户端::

   dnf install nfs-utils

- 果然，使用 :ref:`systemd` 的Docker容器，挂载时会自动启动 ``rpc-statd.service`` ::

   # mount -t nfs 172.22.0.12:/Users/huataihuang/docs/studio /studio
   Created symlink /run/systemd/system/remote-fs.target.wants/rpc-statd.service → /usr/lib/systemd/system/rpc-statd.service.
   mount.nfs: Protocol not supported

不过，还是报错::

   mount.nfs: Protocol not supported

排查方法参考 `mount.nfs: requested NFS version or transport protocol is not supported <https://thelinuxcluster.com/2020/08/24/mount-nfs-requested-nfs-version-or-transport-protocol-is-not-supported/>`_ 添加 ``-vvvv`` 参数可以详细输出信息 ::

   # mount -t nfs -vvvv 172.22.0.12:/Users/huataihuang/docs/studio /studio
   mount.nfs: timeout set for Thu Feb  2 00:01:08 2023
   mount.nfs: trying text-based options 'vers=4.2,addr=172.22.0.12,clientaddr=172.22.0.13'
   mount.nfs: mount(2): Protocol not supported
   mount.nfs: trying text-based options 'vers=4,minorversion=1,addr=172.22.0.12,clientaddr=172.22.0.13'
   mount.nfs: mount(2): Protocol not supported
   mount.nfs: trying text-based options 'vers=4,addr=172.22.0.12,clientaddr=172.22.0.13'
   mount.nfs: mount(2): Protocol not supported
   mount.nfs: trying text-based options 'addr=172.22.0.12'
   mount.nfs: prog 100003, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100003 vers 3 prot TCP port 2049
   mount.nfs: prog 100005, trying vers=3, prot=17
   mount.nfs: portmap query retrying: RPC: Unable to receive - Connection refused
   mount.nfs: prog 100005, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100005 vers 3 prot TCP port 975
   mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
   mount.nfs: Protocol not supported

通过 ``-vvvv`` 可以看到，客户端 ``portmap`` 会尝试 RPC ，失败::

   mount.nfs: portmap query retrying: RPC: Unable to receive - Connection refused

然后尝试TCP端口 975 也失败(之前漏配置SSH)::

   mount.nfs: trying 172.22.0.12 prog 100005 vers 3 prot TCP port 975
   mount.nfs: portmap query failed: RPC: Remote system error - Connection refused


例如，我改为 ``-o vers=3,tcp`` 就看到客户端会连接服务器端口::

   mount.nfs: timeout set for Thu Feb  2 00:05:18 2023
   mount.nfs: trying text-based options 'vers=3,tcp,addr=172.22.0.12'
   mount.nfs: prog 100003, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100003 vers 3 prot TCP port 2049
   mount.nfs: prog 100005, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100005 vers 3 prot TCP port 975
   mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
   ...

既然端口 ``975`` 少了，我重新修订 ``~/.ssh/config`` 添加上 975端口，输出信息果然变化::

   # mount -t nfs -vvvv -o vers=3,tcp 172.22.0.12:/Users/huataihuang/docs/studio /studio
   mount.nfs: timeout set for Thu Feb  2 00:11:32 2023
   mount.nfs: trying text-based options 'vers=3,tcp,addr=172.22.0.12'
   mount.nfs: prog 100003, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100003 vers 3 prot TCP port 2049
   mount.nfs: prog 100005, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100005 vers 3 prot TCP port 975
   mount.nfs: mount(2): Permission denied
   mount.nfs: access denied by server while mounting 172.22.0.12:/Users/huataihuang/docs/studio

看起来是被macOS的NFS服务器拒绝了

参考 `Enabling network (NFS) shares in Mac OS X <https://knowledge.autodesk.com/support/autocad/learn-explore/caas/sfdcarticles/sfdcarticles/Enabling-network-NFS-shares-in-Mac-OS-X.html>`_ 看来需要设置macOS NFS服务器端的允许IP地址段

之前Linux物理服务器客户端测试，客户端IP地址和服务器端在同一个网段，似乎没有问题。但是这次是Docker容器，网段是 ``172.22.0.0/16`` 似乎就不行

修改 ``/etc/exports`` ::

   /Users/huataihuang/docs/studio -maproot=501:20 -network 172.22.0.0 -mask 255.255.0.0

再次挂载NFS，就不报告 ``access denied`` 了，改为::

   # mount -t nfs -vvvv -o vers=3,tcp 172.22.0.12:/Users/huataihuang/docs/studio /studio
   mount.nfs: timeout set for Thu Feb  2 00:26:01 2023
   mount.nfs: trying text-based options 'vers=3,tcp,addr=172.22.0.12'
   mount.nfs: prog 100003, trying vers=3, prot=6
   mount.nfs: trying 172.22.0.12 prog 100003 vers 3 prot TCP port 2049
   mount.nfs: portmap query failed: RPC: Unable to receive - Connection reset by peer
   mount.nfs: Connection reset by peer

``portmap query failed: RPC: Unable to receive - Connection reset by peer`` 是什么意思呢？

`mount.nfs: portmap query failed: RPC: Unable to receive - Connection refused in Centos 7 client <https://serverfault.com/questions/1016675/mount-nfs-portmap-query-failed-rpc-unable-to-receive-connection-refused-in>`_ 提供了一个排查思路::

   rpcinfo -l <nfsserver> 100003 3

我这里实践::

   # rpcinfo -l 172.22.0.12 100003 3
      program vers  tp_family/name/class    address		  service
       100003  3    inet/udp/clts           172.22.0.12.8.1          nfs
       100003  3    inet/tcp/cots_ord       172.22.0.12.8.1          nfs

**我想起来以前尝试过穿透防火墙设置NFS，需要特殊的固定端口配置，否则挂载时，服务器端和客户端协商会打开随机端口进行连接，此时就会被防火墙阻塞。这个问题在我的 SSH Tunneling 也存在**

参考 `NFS client mount fails behind firewall <https://serverfault.com/questions/372731/nfs-client-mount-fails-behind-firewall>`_ 看来还需要在服务器端做不少配置来来确保服务器端返回连接客户端不采用随机端口... ``resvport`` 是配置关键

参考
=======

- `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config>`_ 提供了需要暴露的端口信息列表参考
- `NFS client mount fails behind firewall <https://serverfault.com/questions/372731/nfs-client-mount-fails-behind-firewall>`_



