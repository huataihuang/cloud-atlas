.. _ceph_var_disk:

================================
``/var/lib/ceph`` 目录独立存储
================================

我在运维了一段时间Ceph存储，发现 :ref:`warn_mon_disk_low` 线上Ceph ``MON_DISK_LOW`` 。这个问题在于虚拟机初始分配存储空间极小(为了节约磁盘)，而Ceph在运行时需要确保 ``/var/lib/ceph`` 运行目录有足够空间，所以会不断检测该目录所在磁盘剩余空间百分比。如果没有特别配置， ``/var/lib/ceph``
实际上占用的是根文件系统空间，初始配置根磁盘空间不足就会带来上述告警。

在部署 :ref:`zdata_ceph` ，运行 :ref:`kvm` 虚拟机采用的是物理主机 :ref:`hpe_dl360_gen9` 的系统磁盘 ``/dev/sda`` 上划分 :ref:`linux_lvm` 实现的 :ref:`libvirt_lvm_pool` 。所以，要为虚拟机添加一个独立磁盘，就可以将上述 ``/var/lib/ceph`` 完整迁移过去

虚拟机独立磁盘添加
======================

- 首先检查 ``zcloud`` 物理主机上已经构建的虚拟机存储卷::

   lvs

注意，是部分基础虚拟机(也就是物理服务器一起动就必须运行的虚拟机，如提供其他虚拟机作为存储使用的 ceph 存储服务器 ``z-b-data-X`` )使用了物理服务器 ``zcloud`` 上的 :ref:`linux_lvm` ::

   LV         VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   z-b-data-1 vg-libvirt -wi-ao----  6.00g
   z-b-data-2 vg-libvirt -wi-ao----  6.00g
   z-b-data-3 vg-libvirt -wi-ao----  6.00g
   z-b-mon-1  vg-libvirt -wi-ao----  6.00g
   z-b-mon-2  vg-libvirt -wi-ao----  6.00g
   z-dev      vg-libvirt -wi-ao---- 16.00g
   z-fedora35 vg-libvirt -wi-a-----  6.00g
   z-iommu-2  vg-libvirt -wi-a-----  6.00g
   z-ubuntu20 vg-libvirt -wi-a-----  6.00g
   z-udev     vg-libvirt -wi-ao---- 16.00g
   z-vgpu     vg-libvirt -wi-a-----  6.00g 

- 在 :ref:`libvirt_lvm_pool` 上为每个 ``z-b-data-X`` 添加一个对应LVM卷，例如 ``z-b-data-1`` 添加 ``z-b-data-1_ceph`` ， ``z-b-data-2`` 添加 ``z-b-data-2_ceph`` 以此类推。注意，这个lvm卷采用 ``virsh`` 的内置命令 ``vol-create-as`` 来构建，而不是直接使用LVM的 ``lvcrete`` 创建，这样可以省却导入libvirt存储池的繁琐步骤::

   virsh vol-create-as images_lvm z-b-data-1_ceph 2G
   virsh vol-create-as images_lvm z-b-data-2_ceph 2G
   virsh vol-create-as images_lvm z-b-data-3_ceph 2G

再次使用 ``lvs`` 命令检查可以看到::

   LV              VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   z-b-data-1      vg-libvirt -wi-ao----  6.00g
   z-b-data-1_ceph vg-libvirt -wi-a-----  2.00g
   z-b-data-2      vg-libvirt -wi-ao----  6.00g
   z-b-data-2_ceph vg-libvirt -wi-a-----  2.00g
   z-b-data-3      vg-libvirt -wi-ao----  6.00g
   z-b-data-3_ceph vg-libvirt -wi-a-----  2.00g
   ...

- 准备一个摹本文件:
