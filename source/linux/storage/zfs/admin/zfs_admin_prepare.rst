.. _zfs_admin_prepare:

===========================
ZFS管理准备
===========================

我在ZFS管理实践的准备工作主要有:

- :ref:`apple_silicon_m1_pro` 的MacBook Pro 2022，采用 :ref:`asahi_linux`
- :ref:`intel_core_i7_4850hq` 的MacBook Pro 2013，采用 :ref:`arch_linux`

由于笔记本电脑只有1块 :ref:`nvme` 设备，所以和我在 :ref:`priv_cloud_infra` 的3块NVMe构建 :ref:`ovmf` 虚拟化集群不同，采用将一块磁盘通过 :ref:`parted` 划分成多个分区，然后在分区上建立 ``zpool`` ，以满足 :ref:`docker_zfs_driver` 和 `libvirt_zfs_pool` 。

前置工作
==========

首先需要完成 :ref:`archlinux_zfs` 的以下安装(选择其中之一):

- :ref:`archlinux_archzfs`
- :ref:`archlinux_zfs-dkms`

磁盘分区
==========

使用 :ref:`parted` 对磁盘进行分区

:ref:`apple_silicon_m1_pro` 的MacBook Pro 2022
------------------------------------------------

:ref:`apple_silicon_m1_pro` 的MacBook Pro 2022自身存储 500GB ，使用 ``parted`` 检查:

.. literalinclude:: zfs_admin_prepare/parted_nvme_print
   :language: bash
   :caption: 使用parted检查NVMe磁盘分区

输出显示空闲空间在 ``181GB~495GB`` 之间:

.. literalinclude:: zfs_admin_prepare/parted_nvme_print_output
   :language: bash
   :caption: NVMe磁盘分区显示可用空间位于 181GB~495GB 之间
   :emphasize-lines: 12,13

规划如下:

  - 50GB 用于数据存储
  - 150GB用于 :ref:`libvirt_zfs_pool` 构建虚拟机集群
  - 剩余空间(约114GB) 用于 :ref:`docker_zfs_driver` 构建 :ref:`kind`

- 分区:

.. literalinclude:: zfs_admin_prepare/parted_nvme_libvirt_docker
   :language: bash
   :caption: parted划分分区: 200GB libvirt zfs pool, 剩余 docker zfs driver

完成后再次检查 ``parted /dev/nvme0n1 print`` 可以看到如下分区输出:

.. literalinclude:: zfs_admin_prepare/parted_nvme_libvirt_docker_output
   :language: bash
   :caption: parted分区后状态(新增3个分区用于zpool)
   :emphasize-lines: 13-15

:ref:`intel_core_i7_4850hq` 的MacBook Pro 2013
-------------------------------------------------

:ref:`intel_core_i7_4850hq` 的MacBook Pro 2013存储 1TB ，使用 ``parted`` 检查:

.. literalinclude:: zfs_admin_prepare/mobile_cloud_x86_parted_nvme_print
   :language: bash
   :caption: X86移动云ZFS磁盘准备: 使用parted检查NVMe磁盘分区

输出显示空闲空间:

.. literalinclude:: zfs_admin_prepare/mobile_cloud_x86_parted_nvme_print_output
   :language: bash
   :caption: X86移动云ZFS磁盘准备: 使用parted检查NVMe磁盘分区空闲是 64.0GB~1024GB

可以看到空间是 ``64.0GB~1024GB`` ，规划如下:

  - 创建分区3，完整分配 ``64.0GB~1024GB`` ，这个分区构建 ``zpool-data`` 但是挂载到 ``/var/lib/docker`` ，因为 :ref:`docker_zfs_driver` 是采用完整的 zfs pool来构建的
  - 在 ``zpool-data`` 存储池下构建存储 ``docs`` 卷，用于存储个人数据
  - 在 ``zpool-data`` 存储池构建用于 :ref:`kind` 需要的 :ref:`k8s_nfs` / :ref:`k8s_iscsi` / :ref:`k8s_hostpath` 等，来模拟 :ref:`k8s_persistent_volumes`

- 分区:

.. literalinclude:: zfs_admin_prepare/mobile_cloud_x86_parted_nvme_libvirt_docker
   :language: bash
   :caption: X86移动云ZFS磁盘parted划分分区: 所有剩余磁盘空间全部作为 zpool-data 分区

完成后检查 ``parted /dev/nvme0n1 print`` 可以看到新增加的第3个分区:

.. literalinclude:: zfs_admin_prepare/mobile_cloud_x86_parted_nvme_libvirt_docker_output
   :language: bash
   :caption: X86移动云ZFS磁盘parted划分分区: 新建的第3个分区作为zpool
   :emphasize-lines: 10

接下来操作
==============

- :ref:`docker_zfs_driver`
- :ref:`libvirt_zfs_pool`
- :ref:`zfs_nfs`
