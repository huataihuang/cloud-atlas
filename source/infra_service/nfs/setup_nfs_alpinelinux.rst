.. _setup_nfs_alpinelinux:

=========================
alpine linux配置NFS服务
=========================

NFS客户端
============

- 安装 ``nfs-utils`` :

.. literalinclude:: setup_nfs_alpinelinux/apk_add_nfs-utils
   :language: bash
   :caption: alpine linux安装nfs-utils软件包

- 挂载NFS:

.. literalinclude:: setup_nfs_alpinelinux/mount_nfs
   :language: bash
   :caption: alpine linux挂载NFS

这里遇到一个报错::

   flock: unrecognized option: e
   BusyBox v1.35.0 (2022-11-19 10:13:10 UTC) multi-call binary.

   Usage: flock [-sxun] FD | { FILE [-c] PROG ARGS  }

   [Un]lock file descriptor, or lock FILE, run PROG

           -s      Shared lock
           -x      Exclusive lock (default)
           -u      Unlock FD
           -n      Fail rather than wait

参考
======

- `AlpineLinux 3.6: Install nfs-utils for NFS client <https://www.hiroom2.com/2017/08/22/alpinelinux-3-6-nfs-utils-client-en/>`_
- `alpine linux: Setting up a nfs-server <https://wiki.alpinelinux.org/wiki/Setting_up_a_nfs-server>`_
