.. _macos_nfs4:

============================
macOS系统 ``NFS v4`` 服务
============================

我在 :ref:`colima_mounttype_9p` 实践中遇到的I/O性能问题让我非常困扰，即使做了 ``cpuType`` 的微调，但依然让我无法忍受。和gemini讨论之后，我决定放弃 :ref:`colima` 内置的 ``sshfs`` 和  ``9p`` **mountType** ，改为采用 :ref:`colima_mount_nfs` 来实现共享存储，以期能够提升容器的I/O性能。

macOS 已经完全内置了极为成熟的 NFS（包括 v2, v3, v4）服务端和客户端软件堆栈，所以无需通过 :ref:`homebrew` 安装任何额外软件就可以完成配置。

.. warning::

   虽然我反复尝试，但是我还是没有解决NFS v4输出，所以我最终啊还是回退到 :ref:`macos_nfs3`

NFS说明
===========

- NFS v3 的行为：传统的 NFS v3 需要依赖 rpcbind（Portmapper）服务。它会随机动态分配一堆端口（如 2049, 111, 锁管理器端口等）。
- NFS v4 的进化：NFS v4 规范高度简化了网络结构，只需要固定监听 ``2049`` 端口，完全脱离了对 ``rpcbind`` 的依赖。
- macOS 内核内置的 nfsd 在提供 NFS v4 服务时，默认依然固执地去寻找 rpcbind。如果你在 Colima 中强制指定 nfsvers=4.1 挂载，而 Mac 端没有做特殊配置，内核会因为端口握手死锁，导致挂载直接卡死或报 Connection refused。

配置
=========

- 配置 ``/etc/nfs.conf`` 开启NFS v4支持，并设置只监听 ``2049`` 端口

.. literalinclude:: macos_nfs4/nfs.conf
   :caption: 开启NFS v4

更为优化的性能配置:

.. literalinclude:: macos_nfs4/nfs_tunning.conf
   :caption: 开启NFS v4的优化配置

- 配置 ``/etc/exports`` 

.. literalinclude:: macos_nfs4/exports
   :caption: 输出 /Users/admin 目录

- 重启nfsd

.. literalinclude:: macos_nfs4/restart_nfsd
   :caption: 重启nfsd

- 检查nfsd状态

.. literalinclude:: macos_nfs4/status
   :caption: 检查nfsd状态

输出显示

.. literalinclude:: macos_nfs4/status_output
   :caption: 检查nfsd状态,可以看到nfsd运行中

检查 ``rpcinfo -p`` 输出可以看到 ``2049`` 端口已经处于正常的监听状态

.. literalinclude:: macos_nfs4/rpcinfo
   :caption: 检查2049端口处于监听状态
   :emphasize-lines: 18-21

**奇怪，为何 nfsd 显示的版本居然还是 v2 和 v3 ，并没有看到 v4** 并且，并没有如预期的那样只启动NFS v4的 ``nfsd`` 和 ``rpcbind`` 并关闭掉 v2/v3 的不再需要的服务

gemini提供了解释: NFSv3 和 NFSv4 在文件系统导出上的底层设计有本质区别

- NFSv3：传统的离散导出，给出 ``/Users/admin`` ，就会直接把这个绝对路径暴露出去
- NFSv4: **伪根文件系统（Pseudo-root file system）约束** NFSv4 要求服务端必须构建一个单一的、虚拟的全局目录树。所有的导出路径，都必须是这个 ``伪根（/）`` (Pseudo-root)目录下的子目录

所以不需要修订 ``/etc/nfs.conf`` ，而是需要修订 ``/etc/exports`` 增加一个 **伪根**

- 修改 ``/etc/exports`` :

.. literalinclude:: macos_nfs4/exports_pseudo-root
   :caption: 添加"伪根"(pseudo-root)的/etc/exports
   :emphasize-lines: 2

- 重启nfsd

.. literalinclude:: macos_nfs4/restart_nfsd
   :caption: 重启nfsd
