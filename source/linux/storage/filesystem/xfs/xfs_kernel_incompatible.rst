.. _xfs_kernel_incompatible:

==========================
xfs内核不兼容处理
==========================

我在 :ref:`centos_gluster_init` 时遇到过 XFS 文件系统无法挂载的报错:

.. literalinclude:: xfs_kernel_incompatible/mount_xfs_err
   :caption: 挂载XFS文件系统报错 ``wrong fs type, bad option, bad superblock``
   :emphasize-lines: 1,5

根据提示，执行 ``dmesg | tail`` 查看，原来是服务器内核不支持挂载参数:

.. literalinclude:: xfs_kernel_incompatible/dmesg_superblock_incompatible
   :caption: 内核不兼容xfs文件系统参数报错

这个问题在我之前的实践中( :ref:`deploy_centos7_gluster6` 没有遇到过(之前的操作系统内核版本应该是 4.19 ，但这次遇到的内核版本是是非常古老的 ``3.10.0-xxx`` 

XFS默认格式化的时候，会为文件系统设置一个随机的UUID，类似 ``c1b9d5a2-f162-11cf-9ece-0020afc76f16`` ，这个uuid也可以设置为 ``nil`` 意味着文件系统UUID设置成没有UUID。但是，对于旧版本内核，在激活了CRC的文件系统中，这会导致不兼容而无法挂载文件系统。

上述这种内核不兼容报错在将XFS文件系统从 RHEL 8 改到 RHEL 7上经常会出现:

- RHEL 8 使用的XFS文件系统是 XFS v5，包含了大量的 RHEL 7 内核(kernel 3.10)不支持的功能
- ``mkfs.xfs`` (从 ``xfsprogs 3.2.4`` 开始)默认创建 XFS v5版本超级快，并提供大量增强功能，例如元数据CRC校验和。这种XFS v5 superblock需要内核 ``3.16`` 或更高版本支持，在默认的 RHEL 7/CentOS 7使用的Kernel 3.10 内核无法挂载
- 在搭配使用最新版本 ``xfsprogs`` 和老版本内核(例如 kernel 3.10)时，务必使用以下选项创建 ``v4`` 文件系统:

.. literalinclude:: xfs_kernel_incompatible/mkfs.xfs_v4
   :caption: ``mkfs.xfs`` 创建兼容旧版内核(3.16之前)的XFS v4 superblock

那么怎么验证使用 ``-m crc=0,finobt=0`` 参数格式化之后的 XFS superblock 是v4版本呢?

- 使用 ``xfs_db`` 检查:

.. literalinclude:: xfs_kernel_incompatible/xfs_db_check_version
   :caption: ``xfs_db`` 检查XFS superblock版本

如果是 v4 版本 xfs superblock，则输出::

   versionnum = 0xb4a4

如果是 ``v5`` 版本 xfs superblock，则输出::

   versionnum = 0xb4a5

此外，当将文件系统重新格式化成 XFS superblock v4 之后，就能够正常在 kernel 3.10 内核(RHEL 7/CentOS 7)挂载，此时内核消息输出也能看到是挂载XFS v4::

   [Sun Jul  2 21:28:43 2023] XFS (nvme0n1p1): Mounting V4 Filesystem
   [Sun Jul  2 21:28:43 2023] XFS (nvme0n1p1): Ending clean mount

其他方法(归档参考)
===================

- `Unmountable XFS filesystem <https://unix.stackexchange.com/questions/247550/unmountable-xfs-filesystem>`_ 的回答提供了以下移除默认参数的方法( **但是我实践没有成功** )

.. literalinclude:: xfs_kernel_incompatible/xfs_restore_origianal_uuid_remove_incapatible_feature_flag
   :caption: 移除xfs默认生成的文件系统UUID并移除不兼容旧版内核功能标记( ``我验证不成功`` )

参考
=======

- `Unmountable XFS filesystem <https://unix.stackexchange.com/questions/247550/unmountable-xfs-filesystem>`_
- `AppSync：从 Red Hat Linux 8.0 服务器装载到 Red Hat Linux 7.x 服务器失败 <https://www.dell.com/support/kbdoc/zh-cn/000181978/appsync-service-plan-failed-in-mount-copy-phase>`_
- `xfs Feature Incompatible With RedHat Compatible Kernel (RHCK) <https://docs.oracle.com/en/operating-systems/oracle-linux/6/relnotes6.9/ol6-rn-issues-xfs-superblock-compat.html>`_
- `Ceph CSI: "XFS Superblock has unknown read-only.." Or "wrong fs type, bad ... on /dev/rbd., missing codepage or.." <https://www.humblec.com/ceph-csi-xfs-superblock-has-unknown-read-only-or-wrong-fs-type-bad-on-dev-rbd4-missing-codepage-or/>`_
