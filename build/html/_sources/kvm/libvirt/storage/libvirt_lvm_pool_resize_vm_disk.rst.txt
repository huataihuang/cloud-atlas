.. _libvirt_lvm_pool_resize_vm_disk:

===========================================
在libvirt LVM卷管理存储池中扩展虚拟机磁盘
===========================================

我在 :ref:`libvirt_lvm_pool` 中部署的虚拟机，初始都采用较小的容量，实际运行时，需要根据需求调整磁盘容量:

- 对于Host主机，每个VM实际就是一个LVM卷，所以Host物理主机可以直接调整VM的磁盘大小 - 并且可以在线调整
- 虚拟机内部使用了简单的XFS文件系统，支持在线扩容，所以可以直接在虚拟机内部实现 :ref:`xfs_growfs`

  - 虚拟机内部我没有使用LVM卷，主要是简化运维；不过即使虚拟机内部使用LVM卷，也可以通过将新扩容的空白vm磁盘部分创建新的 ``pv`` ，然后通过 ``vgextend`` 扩展到新的 ``vg`` 上实现 ``vg`` 扩容，最后通过 ``lvresize`` 实现 LVM 卷扩容，最后再使用文件系统对应工具来扩展文件系统

环境检查
==========

:ref:`libvirt_lvm_pool` 创建了使用LVM卷的虚拟机，例如 ``z-dev`` 

- 检查虚拟机::

   virsh dumpxml z-dev

可以看到磁盘部分::

    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='/dev/vg-libvirt/z-dev' index='1'/>
      <backingStore/>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </disk>

- 这个VM的虚拟磁盘在Host主机上就是 ``/dev/vg-libvirt/z-dev`` ，所以在Host主机上我们检查这个LVM卷::

   sudo lvs /dev/vg-libvirt/z-dev

可以看到::

   LV    VG         Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   z-dev vg-libvirt -wi-ao---- 6.00g

- 检查vg::

   sudo vgdisplay

可以看到VG是有充足空间的::

   --- Volume group ---
   VG Name               vg-libvirt
   System ID
   Format                lvm2
   ...
   VG Size               <258.08 GiB
   PE Size               4.00 MiB
   Total PE              66068
   Alloc PE / Size       15360 / 60.00 GiB
   Free  PE / Size       50708 / <198.08 GiB
   ...

使用 ``virsh blockresize`` (推荐)
----------------------------------

- 和 :ref:`kvm_vdisk_live` 案例相似， ``virsh blockresize`` 支持虚拟机镜像在线调整，也支持 :ref:`libvirt_lvm_pool` ::

   sudo virsh blockresize z-dev --path /dev/vg-libvirt/z-dev --size 16G

注意，这里必须指定Host主机上设备文件路径 ``--path /dev/vg-libvirt/z-dev``

- 完成后在虚拟机 ``z-dev`` 内部检查::

   lsblk

可以看到 ``vda`` 磁盘已经增长到16G::

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
   vda    252:0    0   16G  0 disk
   ├─vda1 252:1    0  256M  0 part /boot/efi
   └─vda2 252:2    0  5.7G  0 part /

- 安装 ``cloud-utils-growpart`` (提供 ``growpart`` 工具)::

   sudo dnf install cloud-utils-growpart

- 扩展分区::

   growpart /dev/vda 2

提示信息::

   CHANGED: partition=2 start=526336 old: size=12054528 end=12580864 new: size=33028063 end=33554399

- 使用 :ref:`xfs_growfs` 在线扩展XFS文件系统::

   xfs_growfs /

提示信息::

   meta-data=/dev/vda2              isize=512    agcount=4, agsize=376704 blks
            =                       sectsz=512   attr=2, projid32bit=1
            =                       crc=1        finobt=1, sparse=1, rmapbt=0
            =                       reflink=1    bigtime=0 inobtcount=0
   data     =                       bsize=4096   blocks=1506816, imaxpct=25
            =                       sunit=0      swidth=0 blks
   naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
   log      =internal log           bsize=4096   blocks=2560, version=2
            =                       sectsz=512   sunit=0 blks, lazy-count=1
   realtime =none                   extsz=4096   blocks=0, rtextents=0
   data blocks changed from 1506816 to 4128507

此时检查 ``df -h`` 可以看到根分区已经扩展到最大16GB::

   ...
   /dev/vda2        16G  4.1G   12G  26% /
   ...

使用lvresize (可选)
----------------------

.. note::

   使用 ``lvresize`` 命令可以在Host主机上调整VM的卷大小，但是虚拟机不重启无法在guest内部刷新磁盘大小。所以建议使用 ``virsh blockresize`` 命令，可以在线同步修改虚拟机磁盘大小，也支持 :ref:`libvirt_lvm_pool` 的LVM卷

- 使用 ``lvresize`` 扩展LVM卷::

   sudo lvresize -L+10G /dev/vg-libvirt/z-dev

提示信息::

   Size of logical volume vg-libvirt/z-dev changed from 6.00 GiB (1536 extents) to 16.00 GiB (4096 extents).
   Logical volume vg-libvirt/z-dev successfully resized.

- 此时检查卷，可以看到已经扩展到 16G ::

   sudo lvs /dev/vg-libvirt/z-dev

输出信息::

   LV    VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   z-dev vg-libvirt -wi-ao---- 16.00g

- 不过，此时在VM ``z-dev`` 内部还看不到磁盘变化::

   sudo fdisk -l /dev/vda

显示依然是6G::

   Disk /dev/vda: 6 GiB, 6442450944 bytes, 12582912 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 8A2359A8-F37E-405B-AD00-8036DCC8E610
   
   Device      Start      End  Sectors  Size Type
   /dev/vda1    2048   526335   524288  256M EFI System
   /dev/vda2  526336 12580863 12054528  5.7G Linux filesystem

看来这个方法不能动态通知到guest，所以需要重启虚拟机来刷新磁盘。

如果VM内部使用了LVM
=======================

如果虚拟机内部使用了LVM，最简单的方法是使用 :ref:`kvm_libguestfs` 工具对应的 ``virt-resize`` ，可以将容器内部的磁盘文件系统或者LVM卷大小进行调整，详细案例可以参考:

- `virt-resize - Resize a virtual machine disk <https://libguestfs.org/virt-resize.1.html>`_
- `Resizing a KVM disk image on LVM, The Easy Way <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-easy-way/>`_

参考
=========

- `Resizing a KVM disk image on LVM, The Hard Way <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-hard-way/>`_ 和 `Resizing a KVM disk image on LVM, The Easy Way <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-easy-way/>`_ 注意，这两个文档原文是虚拟机内部使用了LVM卷管理，当扩展虚拟机磁盘之后，如何在虚拟机内部调整guest操作系统LVM，和我的案例不同，但是思路可以参考
