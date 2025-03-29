.. _debug_nfs_ssh_tunnel:

===============================================================================
排查通过 ``SSH Tunnel`` 使用共享NFS卷
===============================================================================

在 :ref:`docker_macos_kind_nfs_sharing_nfs_ssh_tunnel` 采用 :ref:`ssh_tunneling` 来打通 :ref:`docker_desktop` 中容器访问 :ref:`docker_macos_vm` 之外的物理主机( :ref:`macos` )的NFS共享。存在的技术难点其实和 :ref:`run_nfs_behind_firewall` 是一样的。

排查和折腾过程记录在此，也算经验积累:

实践环境
==========

首先完成:

- :ref:`docker_macos_kind_port_forwarding` 在容器和 :ref:`macos` 之间部署了一台中间桥接容器 ``dev-gw``
- :ref:`macos_nfs_sharing` 物理主机的一个目录
- :ref:`nfs_ssh_tunnel` 

此时的实践环境已经具备，通过 :ref:`ssh_tunneling` 建立起NFS clinet 和 server之间的网络同路就类似于 :ref:`run_nfs_behind_firewall`

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

.. literalinclude:: ../../kubernetes/kind/docker_macos_kind_nfs_sharing_nfs_ssh_tunnel/run_fedora-dev-tini_container_sys_admin
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

排查方法参考 `mount.nfs: requested NFS version or transport protocol is not supported <https://thelinuxcluster.com/2020/08/24/mount-nfs-requested-nfs-version-or-transport-protocol-is-not-supported/>`_ 添加 ``-v`` 参数可以详细输出信息 :

.. literalinclude:: debug_nfs_ssh_tunnel/mount_nfs_ssh_tunnel
   :language: bash
   :caption: ``mount -t nfs`` 使用 ``-v`` 参数，但不指定NFS版本

此时会看到NFS客户端先尝试 NFS v4 系列，然后再尝试 NFS v3 系列，但是在RPC调用时失败(连接拒绝):

.. literalinclude:: debug_nfs_ssh_tunnel/mount_nfs_ssh_tunnel_output
   :language: bash
   :caption: ``mount -t nfs`` 使用 ``-v`` 参数，但不指定NFS版本的输出信息
   :emphasize-lines: 12,15

通过 ``-v`` 可以看到，客户端 ``portmap`` 会尝试 RPC ，失败

改为 ``-o vers=3,tcp`` 就看到客户端会连接服务器端口::

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

修改 ``/etc/exports`` :

.. literalinclude:: ../../kubernetes/kind/docker_macos_kind_nfs_sharing_nfs_ssh_tunnel/exports
   :language: bash
   :caption: macOS NFS服务器配置 /etc/exports 增加NFS客户端IP地址范围
   :emphasize-lines: 9


再次挂载NFS(指定NFS v3):

.. literalinclude:: debug_nfs_ssh_tunnel/mount_nfs_v3_ssh_tunnel
   :language: bash
   :caption: 使用NFS v3, tcp 挂载macOS共享的NFS目录

输出显示 ``portmap query failed: RPC: Unable to receive - Connection reset by peer`` :

.. literalinclude:: debug_nfs_ssh_tunnel/mount_nfs_v3_ssh_tunnel_output
   :language: bash
   :caption: 使用NFS v3, tcp 挂载macOS共享的NFS目录的输出信息显示RPC失败

``portmap query failed: RPC: Unable to receive - Connection reset by peer`` 是什么意思呢？

`mount.nfs: portmap query failed: RPC: Unable to receive - Connection refused in Centos 7 client <https://serverfault.com/questions/1016675/mount-nfs-portmap-query-failed-rpc-unable-to-receive-connection-refused-in>`_ 提供了一个排查思路::

   rpcinfo -l <nfsserver> 100003 3

我这里实践::

   # rpcinfo -l 172.22.0.12 100003 3
      program vers  tp_family/name/class    address		  service
       100003  3    inet/udp/clts           172.22.0.12.8.1          nfs
       100003  3    inet/tcp/cots_ord       172.22.0.12.8.1          nfs

**我想起来以前尝试过穿透防火墙设置NFS，需要特殊的固定端口配置，否则挂载时，服务器端和客户端协商会打开随机端口进行连接，此时就会被防火墙阻塞。这个问题在我的 SSH Tunneling 也存在**

参考 `NFS client mount fails behind firewall <https://serverfault.com/questions/372731/nfs-client-mount-fails-behind-firewall>`_ 看来还需要在服务器端做不少配置来来确保服务器端返回连接客户端不采用随机端口...

`Fixing Ports Used by NFSv3 Server <https://www.systutorials.com/fixing-ports-used-by-nfs-server/>`_ 介绍了Linxu上如何配置固定端口 ``/etc/sysconfig/nfs`` ，不知道有没有办法移植到 macOS 上

参考
=======

- `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config>`_ 提供了需要暴露的端口信息列表参考
- `NFS client mount fails behind firewall <https://serverfault.com/questions/372731/nfs-client-mount-fails-behind-firewall>`_



