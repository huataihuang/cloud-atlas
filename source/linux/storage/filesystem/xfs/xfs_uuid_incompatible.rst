.. _xfs_uuid_incompatible:

==========================
xfs随机uuid内核不兼容处理
==========================

我在 :ref:`centos_gluster_init` 时遇到过 XFS 文件系统无法挂载的报错:

.. literalinclude:: xfs_uuid_incompatible/mount_xfs_err
   :caption: 挂载XFS文件系统报错 ``wrong fs type, bad option, bad superblock``
   :emphasize-lines: 1,5

根据提示，执行 ``dmesg | tail`` 查看，原来是服务器内核不支持挂载参数:

.. literalinclude:: xfs_uuid_incompatible/dmesg_superblock_incompatible
   :caption: 内核不兼容xfs文件系统参数报错

这个问题在我之前的实践中( :ref:`deploy_centos7_gluster6` 没有遇到过(之前的操作系统内核版本应该是 4.19 ，但这次遇到的内核版本是是非常古老的 ``3.10.0-xxx`` 

XFS默认格式化的时候，会为文件系统设置一个随机的UUID，类似 ``c1b9d5a2-f162-11cf-9ece-0020afc76f16`` ，这个uuid也可以设置为 ``nil`` 意味着文件系统UUID设置成没有UUID。但是，对于旧版本内核，在激活了CRC的文件系统中，这会导致不兼容而无法挂载文件系统。

解决方法是恢复初始的UUID并移除不兼容的功能开关:

.. literalinclude:: xfs_uuid_incompatible/xfs_restore_origianal_uuid_remove_incapatible_feature_flag
   :caption: 移除xfs默认生成的文件系统UUID并移除不兼容旧版内核功能标记


参考
=======

- `Unmountable XFS filesystem <https://unix.stackexchange.com/questions/247550/unmountable-xfs-filesystem>`_
