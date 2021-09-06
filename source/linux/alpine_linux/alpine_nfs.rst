.. _alpine_nfs:

=========================
Alpine Linux配置NFS
=========================

NFS客户端
============

.. note::

   NFS客户端的关键:

   - 安装 ``nfs-utils``
   - 启动 ``nfsmount`` 服务(实际上是启动 ``rpcbind`` / ``statd`` / ``sm-notify`` )

- ``/etc/fstab`` 配置NFS客户端挂载::

   192.168.6.1:/System/Volumes/Data/Users/dev /mnt nfs rw,noauto 0 0

- 挂载服务器::

   mount /mnt

在部署 :ref:`alpine_kvm` 时，我采用了 :ref:`macos_nfs` 作为服务器，在没有安装 ``nfs-utils`` 之前，如果直接mount NFS，会出现如下报错::

   mount: mounting 192.168.6.1:/System/Volumes/Data/Users/dev on /mnt failed: Connection refused

如果安装好 ``nfs-utils`` ::

   apk add nfs-utils

则再次挂载，则提示报错::

   flock: unrecognized option: e
   BusyBox v1.33.1 () multi-call binary.
   
   Usage: flock [-sxun] FD|{FILE [-c] PROG ARGS}
   
   [Un]lock file descriptor, or lock FILE, run PROG
   
   	-s	Shared lock
   	-x	Exclusive lock (default)
   	-u	Unlock FD
   	-n	Fail rather than wait
   mount.nfs: rpc.statd is not running but is required for remote locking.
   mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
   mount.nfs: Protocol not supported
   mount: mounting 192.168.6.1:/System/Volumes/Data/Users/dev on /mnt failed: Connection refused

上述报错是因为没有在客户端启动相应服务，通过 ``nfsmount`` 服务启动::

   rc-service nfsmount start

提示信息::

    * Caching service dependencies ...      [ ok ]
    * Starting rpcbind ...                  [ ok ]
    * Starting NFS statd ...                [ ok ]
    * Starting NFS sm-notify ...            [ ok ]
    * Mounting NFS filesystems ...          [ ok ]

再次挂载，就可以正确完成

- 如果要在系统启动时挂载，则执行服务添加::

   rc-update add nfsmount

NFS服务
=========

- 对于NFS服务，则需要启动 ``nfs`` 服务::

   rc-service nfs start

- 要在启动时启动nfs::

   rc-update add nfs

参考
======

- `Alpine Linux Wiki: Settting up a nfs-server <https://wiki.alpinelinux.org/wiki/Setting_up_a_nfs-server>`_
