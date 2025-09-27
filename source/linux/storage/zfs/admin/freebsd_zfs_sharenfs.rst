.. _freebsd_zfs_sharenfs:

==============================
FreeBSD通过NFS共享ZFS数据集
==============================

我在 :ref:`freebsd_zfs_stripe` 构建了测试环境FreeBSD存储，其中 ``zdata`` 存储池用于存储测试数据，也包括我日常开发学习的 ``docs`` 数据集。由于我在多个测试环境中需要共享数据，我规划将 ``zdata`` 存储池的数据集用于:

- :ref:`k8s_nfs` 构建用于k8s的pod共享存储数据
- 日常学习开发使用 :ref:`docker_container_nfs` 将 ``docs`` 数据集挂载到 :ref:`debian_tini_image` 运行容器 ``debian-dev`` 来方便工作

FreeBSD内建OpenZFS和NFS
========================

FreeBSD内建集成了OpenZFS和NFS使得其非常容易实现NFS共享: OpenZFS提供了一个 ``sharenfs`` 属性，可以在OpenZFS文件系统上非常方便地管理NFS共享已经集成到脚本和监控维护流程中。

FreeBSD集成的NFS服务器和客户端支持 ``NFSv3`` 和 ``NFSv4`` 协议

准备工作
==========

已经在 :ref:`zfs-jail` 中构建了 ``zdata/docs`` 卷集:

.. literalinclude:: ../../../../freebsd/container/jail/zfs-jail/create_zfs
   :caption: 创建卷集 ``zdata/docs``

Host主机设置
===============

- 在host主机上配置 ``/etc/rc.conf`` :

.. literalinclude:: freebsd_zfs_sharenfs/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 启用NFS

- 对ZFS数据集启动 ``sharenfs`` 属性，并且相应配置允许的客户端IP:

.. literalinclude:: freebsd_zfs_sharenfs/zfs_sharenfs
   :caption: 设置ZFS数据集 ``sharenfs`` 属性

- 启动NFS服务:

.. literalinclude:: freebsd_zfs_sharenfs/start_nfs
   :caption: 启动NFS服务

这里执行 ``service nfsd start`` 时输出信息如下:

.. literalinclude:: freebsd_zfs_sharenfs/start_nfs_output
   :caption: 启动 ``nfsd`` 时信息

检查ZFS数据集 ``zdata/docs`` 属性:

.. literalinclude:: freebsd_zfs_sharenfs/zfs_get_sharenfs
   :caption: 检查 ZFS数据集 ``zdata/docs`` 的 ``sharenfs`` 属性

输出信息如下:

.. literalinclude:: freebsd_zfs_sharenfs/zfs_get_sharenfs_output
   :caption: 检查 ZFS数据集 ``zdata/docs`` 的 ``sharenfs`` 属性

客户端
=======

我的客户端实际上是想实现 :ref:`docker_container_nfs` ，也就是在客户端host主机上挂载ZFS NFS服务器的输出卷，然后再将通过 ``docker volume`` 映射到容器内部使用:

- 在客户端Host主机上配置 ``/etc/fstab`` :

.. literalinclude:: freebsd_zfs_sharenfs/fstab
   :caption: 客户端Host主机 ``/etc/fstab``

- 在客户端执行挂载:

.. literalinclude:: freebsd_zfs_sharenfs/mount
   :caption: 客户端执行挂载

异常排查
---------

- 客户端挂载报错

.. literalinclude:: freebsd_zfs_sharenfs/mount_error
   :caption: 客户端执行挂载报错
   :emphasize-lines: 1

为什么服务器端拒绝了客户端挂载? 我发现是我前面实践时设置了 ``sharenfs="-rw,-alldirs,-network=192.168.7.0/24"`` 导致，由于暂时没有找到合适的参考文档，所以我简化成 ``sharenfs=on`` ，这样基本使用就没有问题(完全依靠客户端的 ``uid/gid`` 权限设置)

.. warning::

   我这里的简化案例设置了 ``sharenfs=on`` ，只能用于测试环境简单使用，相当于默认参数 ``sec=sys,rw,crossmnt,no_subtree_check``

docker容器
============

在客户端Host实现了简单的NFS挂载之后，启动 :ref:`debian_tini_image` 的 ``acloud-dev`` :

.. literalinclude:: ../../../../container/colima/images/debian_tini_image/dev/run_acloud-dev_container
   :language: bash
   :caption: 运行包含开发环境的ARM环境debian镜像

此时登陆到 ``acloud-dev`` 容器中，就可以看到host主机挂载的NFS共享( ``df -h`` 输出信息):

.. literalinclude:: freebsd_zfs_sharenfs/container_df
   :caption: 在 ``acloud-dev`` 容器中检查 ``df -h`` 输出可以看到NFS挂载
   :emphasize-lines: 6

.. note::

   需要保证NFS客户端和NFS服务端的用户 ``uid/gid`` 一致，这样才能正常读写共享文件。这里的用户是 ``admin`` ，其NFS客户端和服务器端都采用了相同的 ``uid/gid``

异常排查
==========

我重启了FreeBSD服务器和树莓派(Raspberry Pi OS, :ref:`debian` 12)，结果发现客户端再次无法挂载NFS:

.. literalinclude:: freebsd_zfs_sharenfs/nfs_protocol_error
   :caption: 无法挂载NFS服务器，提示协议不支持

我了检查服务器已经启动了 ``nfsd`` ，并且ZFS的 ``sharenfs`` 显示如下 ``zfs get all /zdata/docs | grep -i nfs`` :

.. literalinclude:: freebsd_zfs_sharenfs/zfs_get_sharenfs
   :caption: 检查ZFS卷集的 ``sharenfs`` 设置

输出显示当前是非常简单的 ``on`` 状态:

.. literalinclude:: freebsd_zfs_sharenfs/zfs_get_sharenfs_output
   :caption: 显示ZFS卷集的 ``sharenfs`` 设置为 ``on`` 看起来没有问题

尝试详细信息输出:

.. literalinclude:: freebsd_zfs_sharenfs/mount_-v
   :caption:  执行 ``mount -v`` 检查输出信息

输出信息如下:

.. literalinclude:: freebsd_zfs_sharenfs/mount_-v_output
   :caption:  执行 ``mount -v`` 检查输出信息显示v4协议不支持，v3协议portmap查询失败

为何客户端尝试v4和v3协议都不成功？

- 在Linux的NFS客户端执行 ``rpcinfo`` 命令检查远程服务的nfs输出协议情况:

.. literalinclude:: freebsd_zfs_sharenfs/rpcinfo
   :caption: 检查NFS协议

输出信息:

.. literalinclude:: freebsd_zfs_sharenfs/rpcinfo_output
   :caption: 检查NFS协议
   :emphasize-lines: 2,3,6,7

可以看到服务器是支持 ``nfsv3`` 和 ``nfsv2`` 的 ``UDP`` 和 ``TCP`` 协议的(为何没有 ``nfsv4`` ?)

- 在Linux的NFS客户端执行 ``showmount`` 检查:

.. literalinclude:: freebsd_zfs_sharenfs/showmount
   :caption: 在客户端检查 ``showmount``

输出显示

.. literalinclude:: freebsd_zfs_sharenfs/showmount_output
   :caption: 在客户端检查 ``showmount`` 显示没有注册mountd服务

奇怪了

我检查了FreeBSD服务器的NFS启动配置 ``/etc/rc.conf`` :

.. literalinclude:: freebsd_zfs_sharenfs/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 启用NFS
   :emphasize-lines: 2

明明配置是激活 ``mountd`` 的

- 在服务器上检查NFS相关服务，发现 ``mountd`` 服务果然没有启动:

.. literalinclude:: freebsd_zfs_sharenfs/nfs_services
   :caption: 检查NFS相关服务
   :emphasize-lines: 4

我检查了之前的执行步骤，发现之前在服务器上执行启动 ``nfsd`` 时候，有一个 ``service mountd reload`` 动作:

.. literalinclude:: freebsd_zfs_sharenfs/start_nfs
   :caption: 启动NFS服务
   :emphasize-lines: 2

那么我再次执行 ``service mountd reload`` ，发现这个命令实际上要求 ``mountd`` 已经运行才行，现在我执行这条命令提示报错:

.. literalinclude:: freebsd_zfs_sharenfs/mountd_reload_error
   :caption: 执行 ``service mountd reload`` 报错

我尝试手工启动 ``mountd`` 服务:

.. literalinclude:: freebsd_zfs_sharenfs/start_mountd
   :caption: 手工启动 ``mountd``

发现原来 ``mountd`` 必须读取 ``/etc/exports`` 配置文件才能启动，当前没有这个文件，则拒绝启动:

.. literalinclude:: freebsd_zfs_sharenfs/start_mountd_error
   :caption: 手工启动 ``mountd`` 报错

按照ZFS手册，似乎是不需要配置 ``/etc/exports`` 配置就可以，所以我先尝试 ``touch`` 一个空配置文件，果然可以启动 ``mountd`` 服务了:

.. literalinclude:: freebsd_zfs_sharenfs/exports_mountd
   :caption: 创建 ``/etc/exports`` 空配置文件以后就能正常启动 ``mountd``

神奇了，现在再次在Linux NFS客户端执行 ``showmount`` :

.. literalinclude:: freebsd_zfs_sharenfs/showmount
   :caption: 在客户端检查 ``showmount``

就能够看到FreeBSD正常输出了NFS:

.. literalinclude:: freebsd_zfs_sharenfs/showmount_ok
   :caption: 在客户端检查 ``showmount`` 终于看到正常的NFS服务输出信息

- 现在再次手工 ``mount -v`` :

.. literalinclude:: freebsd_zfs_sharenfs/mount_-v
   :caption:  执行 ``mount -v`` 检查输出信息

**amazing** 终于成功了，输出信息如下:

.. literalinclude:: freebsd_zfs_sharenfs/mount_-v_ok_output
   :caption: 终于成功挂载NFS
   :emphasize-lines: 27

.. note::

   虽然 ZFS ``sharenfs`` 不需要配置 ``/etc/exports`` ，但是由于 ``mountd`` 启动时检查 ``/etc/exports`` 配置。如果该配置文件不存在(可以为空)就会拒绝启动 ``mountd`` 。由于NFS服务输出需要 ``mountd`` ，所以这个  ``mountd`` 不启动，客户端是看不到服务器输出的卷集的。

   有点搞...

参考
======

- `Share ZFS datasets with NFS <https://wiki.freebsd.org/ZFS/ShareNFS>`_
- `NFS Shares with ZFS <https://klarasystems.com/articles/nfs-shares-with-zfs/>`_
- `32.3. Network File System (NFS) <https://docs.freebsd.org/en/books/handbook/network-servers/#network-nfs>`_
