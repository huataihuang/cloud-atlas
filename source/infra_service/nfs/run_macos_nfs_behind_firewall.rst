.. _run_macos_nfs_behind_firewall:

=================================
在防火墙之后运行macOS的NFS服务器
=================================

.. warning::

   虽然参考 :ref:`run_nfs_behind_firewall` 设置固定端口，应该也能实现 :ref:`ssh_tunneling` 方式访问 :ref:`macos` 输出的NFS共享目录。但是实践还是没有成功，只能暂且记录以备后续再挑战...

我在 :ref:`docker_macos_kind_nfs_sharing_nfs_ssh_tunnel` 部署 :ref:`ssh_tunneling` / :ref:`ssh_tunneling_remote_port_forwarding` 实现类似 :ref:`run_nfs_behind_firewall` 架构，让运行在 :ref:`docker_desktop` 的Dcoker容器能够访问物理主机 :ref:`macos` 的 NFS 共享目录。

.. csv-table:: macOS NFS端口列表
   :file: run_macos_nfs_behind_firewall/macos_nfs_ports.csv
   :widths: 20,20,60
   :header-rows: 1

固定NFS服务端口
==================

.. note::

   NFS穿透防火墙的难点在于默认 ``rpcbind`` 是随机分配给客户端访问的服务端口( ``rquotad`` / ``lockd`` / ``mountd`` / ``statd`` )，这导致防火墙往往没有提供对应随机端口开放阻塞了NFS客户端请求连接。

- 在 :ref:`redhat_linux` (如 :ref:`fedora` ) 系统上 :ref:`run_macos_nfs_behind_firewall` 略有区别， :ref:`macos` 使用配置文件 ``/etc/nfs.conf`` 来设置NFS，详细参数可以查看 ``man nfs.conf`` :

.. literalinclude:: run_macos_nfs_behind_firewall/nfs.conf
   :language: bash
   :caption: :ref:`macos` 使用 ``/etc/nfs.conf``

- 重启nfsd:

.. literalinclude:: run_macos_nfs_behind_firewall/restart_nfs
   :language: bash
   :caption: :ref:`macos` 重启nfs

- 检查 ``rpcinfo -p`` :

.. literalinclude:: run_macos_nfs_behind_firewall/rpcinfo_output
   :language: bash
   :caption: rpcinfo 检查NFS相关服务端口(修订后)
   :emphasize-lines: 20,21,23,24,26-29

.. note::

   虽然 ``/etc/nfs.conf`` 配置了 ``nfs.lockd.port`` 和 ``nfs.statd.port`` 端口，但是没有观察到 ``status`` 和 ``nlockmgr`` 监听这两个指定端口，让我很迷惑

- 执行挂载:

.. literalinclude:: run_macos_nfs_behind_firewall/mount_macos_nfs
   :language: bash
   :caption: 使用NFS v3挂载macOS输出的NFS目录

**奔溃** 输出还是失败:

.. literalinclude:: run_macos_nfs_behind_firewall/mount_macos_nfs_output
   :language: bash
   :caption: 使用NFS v3挂载macOS输出的NFS目录显示还是失败

参考
=======

- `What Ports Does NFS Use <https://linuxhint.com/nfs-ports/>`_
- `Fixing Ports Used by NFSv3 Server <https://www.systutorials.com/fixing-ports-used-by-nfs-server/>`_
- `Running NFS Behind a Firewall <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-nfs-nfs-firewall-config>`_ 更详细的信息参考(需要RedHat支持账号)

  - `How to configure a system as an NFSv3 server which sits behind a firewall with NFS clients outside of the firewall? <https://access.redhat.com/solutions/3258>`_
  - `How can I configure a system as an NFSv4 server which sits behind a firewall with NFS clients outside the firewall? <https://access.redhat.com/solutions/221933>`_

- `Firewall blocking NFS even though ports are open <https://www.linuxquestions.org/questions/linux-security-4/firewall-blocking-nfs-even-though-ports-are-open-294069/>`_
