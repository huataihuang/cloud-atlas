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

alpine linux容器的NFS客户端
==============================

相同的方法，在 :ref:`kind_run_simple_container` ，运行 :ref:`alpine_docker_image` 的 ``alpine-nginx`` 容器，我发现执行NFS挂载时候报错::

   flock: unrecognized option: e
   BusyBox v1.35.0 (2022-11-19 10:13:10 UTC) multi-call binary.

   Usage: flock [-sxun] FD | { FILE [-c] PROG ARGS  }

   [Un]lock file descriptor, or lock FILE, run PROG

           -s      Shared lock
           -x      Exclusive lock (default)
           -u      Unlock FD
           -n      Fail rather than wait

参考 `Privileged doesn't work #10000 <https://github.com/rancher/rancher/issues/10000>`_ ，在运行容器时候，需要添加一个 ``--privileged=true`` 参数。那么对于 ``kubernetes`` 的运行容器，则需要有一个配置

- 运行docker容器对比验证(没有 ``--privileged=true`` 参数 )::

   docker run --name alpine-nginx-nfs -it alpine-nginx:20221129-02 /bin/bash

容器内部使用 ``df -h`` 查看目录::

   Filesystem                Size      Used Available Use% Mounted on
   /dev/nvme0n1p8           44.7G      3.8G     40.6G   9% /
   tmpfs                    64.0M         0     64.0M   0% /dev
   shm                      64.0M         0     64.0M   0% /dev/shm
   /dev/nvme0n1p8           44.7G      3.8G     40.6G   9% /etc/resolv.conf
   /dev/nvme0n1p8           44.7G      3.8G     40.6G   9% /etc/hostname
   /dev/nvme0n1p8           44.7G      3.8G     40.6G   9% /etc/hosts
   tmpfs                    15.6G         0     15.6G   0% /proc/asound
   tmpfs                    64.0M         0     64.0M   0% /proc/kcore
   tmpfs                    64.0M         0     64.0M   0% /proc/keys
   tmpfs                    64.0M         0     64.0M   0% /proc/timer_list
   tmpfs                    15.6G         0     15.6G   0% /proc/scsi
   tmpfs                    15.6G         0     15.6G   0% /sys/firmware

- 运行docker容器对比验证( ``--privileged=true`` 参数 )::

   docker run --name alpine-nginx-nfs-priv --privileged=true -it alpine-nginx:20221129-02 /bin/bash

容器内部使用 ``df -h`` 查看目录::

   Filesystem                Size      Used Available Use% Mounted on
   /dev/nvme0n1p8           44.7G      3.9G     40.5G   9% /
   tmpfs                    64.0M         0     64.0M   0% /dev
   shm                      64.0M         0     64.0M   0% /dev/shm
   /dev/nvme0n1p8           44.7G      3.9G     40.5G   9% /etc/resolv.conf
   /dev/nvme0n1p8           44.7G      3.9G     40.5G   9% /etc/hostname
   /dev/nvme0n1p8           44.7G      3.9G     40.5G   9% /etc/hosts

参考
======

- `AlpineLinux 3.6: Install nfs-utils for NFS client <https://www.hiroom2.com/2017/08/22/alpinelinux-3-6-nfs-utils-client-en/>`_
- `alpine linux: Setting up a nfs-server <https://wiki.alpinelinux.org/wiki/Setting_up_a_nfs-server>`_
- `Privileged doesn't work #10000 <https://github.com/rancher/rancher/issues/10000>`_
