.. _mobile_cloud_libvirt_lvm_pool:

===================================
移动云计算libvirt LVM卷管理存储池
===================================

在 :ref:`mobile_cloud_infra` 由于ARM架构的 :ref:`asahi_linux` 内核对ZFS支持不佳，所以采用更为成熟可靠的 :ref:`linux_lvm` 作为 :ref:`libvirt_lvm_pool` :

创建LVM存储卷
================

准备工作
----------

磁盘分区规划: 分区9作为 :ref:`linux_lvm` 构建 :ref:`ceph` 的KVM虚拟机集群

.. csv-table:: 移动云计算的磁盘分区
   :file: ../../../linux/storage/btrfs/btrfs_mobile_cloud/mobile_cloud_parted.csv
   :widths: 20,20,30,30
   :header-rows: 1

- 磁盘采用 :ref:`btrfs_mobile_cloud` 划分磁盘分区:

.. literalinclude:: ../../../linux/storage/btrfs/btrfs_mobile_cloud/parted_nvme_btrfs
   :language: bash
   :caption: parted分区: 50G data, 48G docker, 216G libvirt
   :emphasize-lines: 4,7

创建LVM存储卷
----------------

- 检查当前存储卷::

   virsh pool-list --all

在 :ref:`archlinux_arm_kvm` 部署安装的 :ref:`libvirt` 没有自动创建存储池，所以当前没有任何存储池::

    Name   State   Autostart
   ---------------------------

- 创建 :ref:`linux_lvm` 的PV和VG:

.. literalinclude:: mobile_cloud_libvirt_lvm_pool/mobile_cloud_libvirt_lvm_create
   :language: bash
   :caption: 创建vg-libvirt卷

这里有一个提示(未明)::

     Using metadata size 960 KiB for non-standard page size 16384.
     Using metadata size 960 KiB for non-standard page size 16384.
     Volume group "vg-libvirt" successfully created

- 此时检查 ``vgs`` 输出可以看到已经建立的卷组::

     VG         #PV #LV #SN Attr   VSize    VFree   
     vg-libvirt   1   0   0 wz--n- <201.08g <201.08g

在livirt中使用LVM卷组
-----------------------

- 定义 ``images_lvm`` 存储池: 使用逻辑卷组 ``vg-libvirt`` 目标磁盘 ``/dev/nvme0n1p9`` ，并且启动激活:

.. literalinclude:: mobile_cloud_libvirt_lvm_pool/virsh_pool_lvm
   :language: bash
   :caption: 定义使用LVM卷组的libvirt存储池

- 此时使用 ``virsh pool-list`` 可以看到存储池::

    Name         State    Autostart
   ----------------------------------
    images_lvm   active   yes

- 接下来就可以使用以下命令为 :ref:`archlinux_arm_kvm` 创建VM使用的磁盘(卷)，类似:


