.. _share_zfs_dataset_between_jails:

===========================
在多个Jail之间共享ZFS数据集
===========================

ZFS文件系统是单机文件系统(不是cluster filesystem)，所以不能直接在两台服务器之间共享挂载。所以，当在多个jail之间使用一个ZFS dataset时，实际上是通过 ``nullfs`` 来实现(见 :ref:`share_folder_between_jails` )。另外一种方案是使用 :ref:`zfs_nfs` ，即本文实践。

参考
======

- `Using ZFS inside a jail <https://github.com/DtxdF/AppJail/wiki/zfs>`_
- `any way to mount zfs pool on multiple noded?  <https://www.reddit.com/r/zfs/comments/1fs1k2o/any_way_to_mount_zfs_pool_on_multiple_noded/>`_
- `ZFS Share a ZFS dataset with multiple jails <https://forums.freebsd.org/threads/share-a-zfs-dataset-with-multiple-jails.93405/>`_
- `Mounting and Sharing ZFS File Systems <https://docs.oracle.com/cd/E19253-01/819-5461/gaynd/index.html>`_
