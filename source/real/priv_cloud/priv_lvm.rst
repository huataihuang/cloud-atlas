.. _priv_lvm:

=====================
私有云数据层LVM卷管理
=====================

在 :ref:`priv_cloud_infra` 规划了 ``数据存储层(data)`` ，其中采用了三个 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` :ref:`ovmf` 虚拟机pass-through读写 :ref:`samsung_pm9a1` 。这样，这三个虚拟机内部都会有一块完整NVMe磁盘，规划:

- 500GB: :ref:`zdata_ceph` 用于虚拟机存储
- 300GB: 也就是本文构建用于基础服务的 :ref:`linux_lvm` 部署各种基础服务( 详见 :ref:`priv_cloud_infra` 规划 )
- 200GB: 保留给未来技术实践分布式存储

.. note::

   :ref:`deploy_lvm` 详述技术细节，本文为精简

构建LVM卷可以将分区按需(不同应用)划分成独立磁盘块设备(卷)，即将NVMe磁盘上的分区2划分

- 首先将分区2准备如下:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/parted_nvme
   :language: bash
   :caption: parted创建nvme分区2作为LVM卷

- 完成后分区如下:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/parted_print_nvme
   :language: bash
   :caption: nvme分区

LVM洛基卷创建
===============

- 在分区2上创建LVM物理卷PV:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/pvcreate
   :language: bash
   :caption: pvcreate创建PV

- 在分区2上创建LVM的卷组VG:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/vgcreate
   :language: bash
   :caption: vgcreate创建VG

- 在 ``vg-data`` 卷组上创建名为 ``lv-etcd`` 的LVM卷，大小 8G ，用于 :ref:`etcd` 部署:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/lvcreate
   :language: bash
   :caption: lvcreate创建LVM卷

- 最终检查::

   sudo lvdisplay vg-data/lv-etcd

可以看到部署的LVM卷:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/lvdisplay
   :language: bash
   :caption: lvdisplay检查LVM

文件系统
========

- LVM卷上创建文件系统:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/mkfs
   :language: bash
   :caption: LVM卷上创建文件系统

创建 ``/etc/fstab`` 挂载条目:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/fstab
   :language: bash
   :caption: 在 /etc/fstab 中增加挂载LVM卷配置

- 然后创建挂载目录并挂载:

.. literalinclude:: ../../linux/storage/lvm/deploy_lvm/mount_lvm
   :language: bash
   :caption: 挂载LVM卷

现在我们获得了一个可以部署 :ref:`priv_etcd` 的存储挂载
