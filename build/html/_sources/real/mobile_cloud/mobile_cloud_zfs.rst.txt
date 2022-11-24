.. _mobile_cloud_zfs:

=========================
移动云ZFS
=========================

在我使用的 :ref:`apple_silicon_m1_pro` MacBook Pro，我期望构建完全虚拟化的多服务器集群架构。对于底层存储，希望在一个 卷管理 上构建出存储给虚拟机使用。

有两种候选文件系统:

- :ref:`zfs`
- :ref:`btrfs`

经过实践探索( :ref:`archlinux_zfs-dkms` )， :ref:`asahi_linux` 内核激进采用v6.1，尚未得到 ``OpenZFS`` 支持，所以

- 在 :ref:`apple_silicon_m1_pro` MacBook Pro 采用 :ref:`btrfs`
- 在 X86_64 的 Macbook Pro 2013 采用 :ref:`zfs`

存储构想
==========

我考虑采用 :ref:`zfs` 来构建物理主机的文件系统:

- 通过ZFS卷作为虚拟机的磁盘( :ref:`libvirt` 已经支持ZFS卷 )
- 采用3个虚拟机构建 :ref:`ceph` (边缘云计算架构Linaro已经完全基于 :ref:`openstack` 和 :ref:`ceph` )
- 在 :ref:`ceph` 基础上构建 :ref:`openstack` 和 :ref:`kubernetes`


