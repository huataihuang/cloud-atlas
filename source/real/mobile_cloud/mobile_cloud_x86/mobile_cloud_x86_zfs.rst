.. _mobile_cloud_x86_zfs:

=========================
X86移动云ZFS
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

我考虑采用 :ref:`zfs` 来构建物理主机的文件系统原因:

- **放弃** :strike:`通过ZFS卷作为虚拟机的磁盘` ( :ref:`libvirt` 已经支持ZFS卷 )
- **放弃** (由于X86 :ref:`mbp15_late_2013` 笔记本性能有限改为直接运行 :ref:`kind` 所以X86移动云不部署Ceph )采用3个虚拟机构建 :ref:`ceph` (边缘云计算架构Linaro已经完全基于 :ref:`openstack` 和 :ref:`ceph` )
- **放弃** (实践发现笔记本难以支持大量虚拟机和 :ref:`kvm_nested_virtual` 所以X86 :ref:`mbp15_late_2013` 笔记本放弃虚拟化，改为在 :ref:`priv_cloud_infra` 二手服务器构建 )在 :ref:`ceph` 基础上构建 :ref:`openstack` 和 :ref:`kubernetes`

- 在 :ref:`zfs` 基础上采用 `docker_zfs_driver` 运行容器
- 构建 :ref:`kind` 来作为开发环境

准备工作
==========

磁盘分区
------------

按照 :ref:`zfs_admin_prepare` 完成文件系统分区:

- 空闲空间是 ``64.0GB~1024GB`` ，规划如下:

  - 创建分区3，完整分配 ``64.0GB~1024GB`` ，这个分区构建 ``zpool-data`` 但是挂载到 ``/var/lib/docker`` ，因为 :ref:`docker_zfs_driver` 是采用完整的 zfs pool来构建的
  - 在 ``zpool-data`` 存储池下构建存储 ``docs`` 卷，用于存储个人数据
  - 在 ``zpool-data`` 存储池构建用于 :ref:`kind` 需要的 :ref:`k8s_nfs` / :ref:`k8s_iscsi` / :ref:`k8s_hostpath` 等，来模拟 :ref:`k8s_persistent_volumes`

- 分区:

.. literalinclude:: ../../../linux/storage/zfs/admin/zfs_admin_prepare/mobile_cloud_x86_parted_nvme_libvirt_docker
   :language: bash
   :caption: X86移动云ZFS磁盘parted划分分区: 所有剩余磁盘空间全部作为 zpool-data 分区

完成后检查 ``parted /dev/nvme0n1 print`` 可以看到新增加的第3个分区:

.. literalinclude:: ../../../linux/storage/zfs/admin/zfs_admin_prepare/mobile_cloud_x86_parted_nvme_libvirt_docker_output
   :language: bash
   :caption: X86移动云ZFS磁盘parted划分分区: 新建的第3个分区作为zpool
   :emphasize-lines: 10

Docker准备
-----------

- :ref:`mobile_cloud_x86_docker` ，完成Docker初始安装

- 停止Docker:

.. literalinclude:: ../../../docker/storage/docker_zfs_driver/systemctl_stop_docker
   :language: bash
   :caption: 停止Docker服务，为存储驱动修改做准备

- 将 ``/var/lib/docker`` 备份并清理该目录下所有内容:

.. literalinclude:: ../../../docker/storage/docker_zfs_driver/backup_docker_dir
   :language: bash
   :caption: 备份/var/lib/docker目录

- 在分区 ``/dev/nvme0n1p`` 构建 ``zpool`` ( 名为 ``zpool-data`` )并挂载到 ``/var/lib/docker/`` 目录(开启 :ref:`zfs_compression` ):

.. literalinclude:: mobile_cloud_x86_zfs/zpool_create_zpool-data
   :language: bash
   :caption: zpool create创建名为zpool-data存储池，挂载到/var/lib/docker

待续...
