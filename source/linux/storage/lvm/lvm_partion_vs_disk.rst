.. _lvm_partion_vs_disk:

===========================================
构建LVM卷管理应该使用分区还是直接使用磁盘?
===========================================

我在构建 :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` 采用的是多层架构:

- :ref:`mdadm_raid10` 作为将多个(12块 :ref:`nvme` )存储设备合并成一个大存储块设备
- :ref:`deploy_lvm_mdadm_raid10` 在 :ref:`mdadm` 软RAID设备 ``md10`` 上构建 :ref:`linux_lvm` ，实现灵活的存储隔离和分配
- :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` 通过LVM块设备上构建 :ref:`xfs` 作为 ``bricks`` 来构建一个跨多服务器的GlusterFS存储

每次实践都会让我思考一些技术细节，就像 :ref:`mdadm_raid10` 我思考 :ref:`mdadm_partion_vs_disk` ，对于在 :ref:`mdadm` 软RAID设备 ``md10`` : 应该直接使用 ``/dev/md10`` 块设备还是在 :ref:`mdadm` MD设备上划分分区，采用分区来构建 :ref:`linux_lvm` ?

我参考了一些资料综合自己的思考:

- 在块设备上使用 :ref:`linux_lvm` 使用完整磁盘或磁盘上的分区，性能上没有区别:

  - 分区只是一个标识，没有处理逻辑、也不占用空间，所以可以认为只是画了一条线，对性能和稳定性没有影响

- 增加一个 :ref:`parted` 划分磁盘分区的 **优点** 是:

  - 提供了一个清晰的逻辑标签，也就是可以在分区上设置 ``LVM`` 标记，这样任何应用程序或者后续维护人员只需要使用 ``fdisk -l`` 就能看到这个分区是使用了 :ref:`linux_lvm` ，不会忽略掉这个分区的使用目的(不会误以为磁盘无数据)

- 增加一个 :ref:`parted` 划分磁盘分区的 **缺点** 是:

  - 块对齐不需要分区(当然使用 :ref:`parted` 的 ``-a optimize`` 参数分区会帮助完成块对齐)，LVM倾向于自己处理块对齐(见 `lvm2 WHATS_NEW <https://www.mirrorservice.org/sites/sourceware.org/pub/lvm2/WHATS_NEW>`_ 2017年12月18日发布的 Version 2.02.177)
  - 调整磁盘大小的时候不需要再处理分区扩展缩小(节省步骤)，分区调整有时候需要重启服务器才能识别(特别是系统分区)，对于大量的虚拟机运维非常麻烦
  - 不需要使用各种分区工具 :ref:`parted` , ``fdisk`` , ``kpartx`` 来管理卷和磁盘

我最初还是想加一个磁盘分区的，毕竟分区能够标记 ``LVM`` ，这样任何人一看就明白磁盘的用途，但是我觉得 `Should I partitionning a disk LVM? <https://serverfault.com/questions/973709/should-i-partitionning-a-disk-lvm>`_ 的理由也很充分，如果不存在 :ref:`mdadm_partion_vs_disk` 提到的系统缺陷UEFI可能破坏 :ref:`linux_software_raid` 元数据的这种问题，直接使用软RAID块设备来构建 LVM 不失为一个简洁的方法: (在LVM的 ``LV`` 逻辑卷上，我们依然会使用分区来标记文件系统类型(其实也可以省略))

我个人在部署的时候，我想我还是会在每个数据层上使用分区，来帮助标签块设备的用途(没有其他目的，毕竟是完整使用磁盘):

- 每个块设备层都通过分区FLAG来标签，以便能够清晰了解运维目标
- 不影响性能，没有空间损失
- 稍微增加一点工具复杂度，但是对我个人而言不难

参考
======

- `What is the best practice for adding disks in LVM <https://unix.stackexchange.com/questions/76588/what-is-the-best-practice-for-adding-disks-in-lvm>`_
- `Should I partitionning a disk LVM? <https://serverfault.com/questions/973709/should-i-partitionning-a-disk-lvm>`_ 这个文档清晰且较新
