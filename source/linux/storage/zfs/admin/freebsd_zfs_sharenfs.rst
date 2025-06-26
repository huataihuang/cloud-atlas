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

.. literalinclude:: ../../../../docker/colima/images/debian_tini_image/dev/run_acloud-dev_container
   :language: bash
   :caption: 运行包含开发环境的ARM环境debian镜像

此时登陆到 ``acloud-dev`` 容器中，就可以看到host主机挂载的NFS共享( ``df -h`` 输出信息):

.. literalinclude:: freebsd_zfs_sharenfs/container_df
   :caption: 在 ``acloud-dev`` 容器中检查 ``df -h`` 输出可以看到NFS挂载
   :emphasize-lines: 6

.. note::

   需要保证NFS客户端和NFS服务端的用户 ``uid/gid`` 一致，这样才能正常读写共享文件。这里的用户是 ``admin`` ，其NFS客户端和服务器端都采用了相同的 ``uid/gid``

参考
======

- `Share ZFS datasets with NFS <https://wiki.freebsd.org/ZFS/ShareNFS>`_
- `NFS Shares with ZFS <https://klarasystems.com/articles/nfs-shares-with-zfs/>`_
- `32.3. Network File System (NFS) <https://docs.freebsd.org/en/books/handbook/network-servers/#network-nfs>`_
