.. _gpart_linux_zfs_partition:

===============================
gpart实践(linux分区及zfs分区)
===============================

在部署FreeBSD+Linux的混合系统时，我的实践将一个NVMe分为多个分区:

- :ref:`freebsd_root_on_zfs_using_gpt` FreeBSD安装过程自定义256G空间用于 ``zroot`` 存储池，实现FreeBSD on ZFS root
- 划分256G用于 :ref:`lfs` 构建，分区将分别实验(最终采用 :ref:`xfs` ):

  - :ref:`freebsd_ext`
  - :ref:`freebsd_ext4`
  - :ref:`freebsd_xfs`

- 单独划分一个分区用于构建 :ref:`freebsd_zfs_stripe` 实现独立的 ``zdata`` 存储池，后续可以进一步扩展
