.. _run_nfs_behind_firewall:

==========================
在防火墙之后运行NFS服务器
==========================

在企业环境，NFS存储服务器很可能部署在防火墙内，你会发现简单为NFS开启防火墙访问端口并不能使客户端正确挂载NFS共享目录。这个问题在 :ref:`docker_macos_kind_nfs_sharing_nfs_ssh_tunnel` 也突出存在，原因是 :ref:`ssh_tunneling` / :ref:`ssh_tunneling_remote_port_forwarding` 就像防火墙一样，只开启了少量且固定的访问NFS服务器端口映射。

此时的现象是: 执行 ``mount -t nfs`` 时使用 ``-v`` 参数观察:

挂载NFS(指定NFS v3):

.. literalinclude:: debug_nfs_ssh_tunnel/mount_nfs_v3_ssh_tunnel
   :language: bash
   :caption: 使用NFS v3, tcp 挂载macOS共享的NFS目录

输出显示 ``portmap query failed: RPC: Unable to receive - Connection reset by peer`` :

.. literalinclude:: debug_nfs_ssh_tunnel/mount_nfs_v3_ssh_tunnel_output
   :language: bash
   :caption: 使用NFS v3, tcp 挂载macOS共享的NFS目录的输出信息显示RPC失败

解析
=======

现在主要的NFS版本是 v3 和 v4 :

- NFS v3 提供了比 v2更好功能: 可变大小处理、改进的错误报告等。但是 NFS v3 与 NFS v2 客户端不兼容
- 最新版本的 NFS v4 提供了新的和改进的功能: 

  - 包括有状态操作
  - 与 NFS v2 和 NFS v3 的向后兼容性
  - **移除的端口映射器要求** (这个有意思)
  - 跨平台互操作性
  - 更好的命名空间处理
  - 带有 ACL 的内置安全性和 Kerberos

NFS v4不使用 ``portmapper`` (NFS v2 和 v3必须)，所以对NFS v4来说，只要求端口 ``2049`` 。对于 NFS v2 和 v3，需要附加的端口和服务，配置复杂。

NFS v2 和 v3 的服务要求
------------------------

NFS v2 和 v3 使用 ``portmap`` 服务，在Linux平台 ``portmap`` 服务处理远程过程调用(Remote Procedure Calls, RPC)，NFS v2 和 v3 用RPC来编码和解码客户端和服务器之间的请求。

为了实现NFS共享，以下服务是NFS v2 和 v3所必须的:

.. csv-table:: NFS v2/v3 的服务及功能
   :file: run_nfs_behind_firewall/nfs_v2_v3_require_service.csv
   :widths: 10, 90
   :header-rows: 1

.. note::

   NFS穿透防火墙的难点在于默认 ``rpcbind`` 是随机分配给客户端访问的服务端口( ``rquotad`` / ``lockd`` / ``mountd`` / ``statd`` )，这导致防火墙往往没有提供对应随机端口开放阻塞了NFS客户端请求连接。

固定NFS服务端口
==================

- 在 :ref:`redhat_linux` (如 :ref:`fedora` ) 系统上， ``/etc/sysconfig/nfs`` 提供了NFS相关服务端口配置选项:

.. literalinclude:: run_nfs_behind_firewall/sysconfig_nfs
   :language: bash
   :caption: Red Hat系列Linux使用 ``/etc/sysconfig/nfs`` 配置NFS参数，固定NFS服务端口


参考
=======

- `What Ports Does NFS Use <https://linuxhint.com/nfs-ports/>`_
- `Fixing Ports Used by NFSv3 Server <https://www.systutorials.com/fixing-ports-used-by-nfs-server/>`_
- `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config>`_ 更详细的信息参考(需要RedHat支持账号)

  - `How to configure a system as an NFSv3 server which sits behind a firewall with NFS clients outside of the firewall? <https://access.redhat.com/solutions/3258>`_
  - `How can I configure a system as an NFSv4 server which sits behind a firewall with NFS clients outside the firewall? <https://access.redhat.com/solutions/221933>`_

- `Firewall blocking NFS even though ports are open <https://www.linuxquestions.org/questions/linux-security-4/firewall-blocking-nfs-even-though-ports-are-open-294069/>`_
