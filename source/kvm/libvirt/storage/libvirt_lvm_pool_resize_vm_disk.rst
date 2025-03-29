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

物理机上操作
----------------------------------

- 和 :ref:`kvm_vdisk_live` 案例相似， ``virsh blockresize`` 支持虚拟机镜像在线调整，也支持 :ref:`libvirt_lvm_pool` 

注意，这里必须指定Host主机上设备文件路径 ``--path /dev/vg-libvirt/z-dev``

想要将 16G 扩展成 32G 使用相似命令::

   sudo virsh blockresize z-dev --path /dev/vg-libvirt/z-dev --size 32G

出现报错::

   error: Failed to resize block device '/dev/vg-libvirt/z-dev'
   error: internal error: unable to execute QEMU command 'block_resize': Cannot grow device files

检查了存储池::

   virsh pool-info images_lvm

显示空还有剩余::

   Name:           images_lvm
   UUID:           11d759bf-32ad-4a4a-a137-d5d3bef0b2cf
   State:          running
   Persistent:     yes
   Autostart:      yes
   Capacity:       258.08 GiB
   Allocation:     92.00 GiB
   Available:      166.08 GiB

.. note::

   使用 ``lvresize`` 命令可以在Host主机上调整VM的卷大小，但是虚拟机不重启无法在guest内部刷新磁盘大小。所以要结合使用 ``virsh blockresize`` 命令，可以在线同步修改虚拟机磁盘大小，也支持 :ref:`libvirt_lvm_pool` 的LVM卷

参考 `Extend KVM Volume <https://serverfault.com/questions/707002/extend-kvm-volume>`_ 分为2步完成:

  - 先使用系统级命令 ``lvresize`` 修改LVM卷大小
  - 然后再使用 ``virsh blockresize`` 修订则成功

.. literalinclude:: libvirt_lvm_pool_resize_vm_disk/lvresize_32g
   :language: bash
   :caption: 修订z-dev虚拟机的LVM卷到32G容量

提示信息::

   Size of logical volume vg-libvirt/z-dev changed from 16.00 GiB (4096 extents) to 32.00 GiB (8192 extents).
   Logical volume vg-libvirt/z-dev successfully resized.

.. literalinclude:: libvirt_lvm_pool_resize_vm_disk/virsh_blockresize_32g
   :language: bash
   :caption: virsh blocksize命令刷新z-dev虚拟机libvirt卷容量

提示信息::

   Block device '/dev/vg-libvirt/z-dev' is resized

虚拟机内部操作
----------------

- 完成后在虚拟机 ``z-dev`` 内部检查::

   lsblk

可以看到 ``vda`` 磁盘已经增长到16G::

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
   vda    252:0    0   16G  0 disk
   ├─vda1 252:1    0  256M  0 part /boot/efi
   └─vda2 252:2    0  15.7G 0 part /

注意，此时由于GPT分区没有扩展，所以使用 ``fdisk -l /dev/vda`` 会提示分区表的备份(位于设备末尾)没有正确位于设备末尾(最前面2行提示)::

   GPT PMBR size mismatch (33554431 != 67108863) will be corrected by write.
   The backup GPT table is not on the end of the device.
   Disk /dev/vda: 32 GiB, 34359738368 bytes, 67108864 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 8A2359A8-F37E-405B-AD00-8036DCC8E610

   Device      Start      End  Sectors  Size Type
   /dev/vda1    2048   526335   524288  256M EFI System
   /dev/vda2  526336 33554398 33028063 15.7G Linux filesystem

- 安装 ``cloud-utils-growpart`` (提供 ``growpart`` 工具):

.. literalinclude:: libvirt_lvm_pool_resize_vm_disk/dnf_install_cloud-utils-growpart
   :language: bash
   :caption: RedHat系虚拟机内部通过dnf安装cloud-utils-growpart

如果使用 debian/ubuntu ，则安装 ``cloud-guest-utils`` 来获得 ``growpart`` :

.. literalinclude:: libvirt_lvm_pool_resize_vm_disk/apt_install_cloud-guest-utils
   :language: bash
   :caption: Debian/Ubuntu系虚拟机内部通过apt安装cloud-guest-utils

- 扩展分区:

.. literalinclude:: libvirt_lvm_pool_resize_vm_disk/growpart_vda2
   :language: bash
   :caption: 在虚拟机内部通过growpart命令扩展分区2

提示信息::

   CHANGED: partition=2 start=526336 old: size=33028063 end=33554399 new: size=66582495 end=67108831

- 使用 :ref:`xfs_growfs` 在线扩展XFS文件系统:

.. literalinclude:: libvirt_lvm_pool_resize_vm_disk/xfs_growfs_root_fs
   :language: bash
   :caption: 在虚拟机内部通过XFS的维护命令xfs_growfs将根目录分区扩展

提示信息::

   meta-data=/dev/vda2              isize=512    agcount=11, agsize=376704 blks
            =                       sectsz=512   attr=2, projid32bit=1
            =                       crc=1        finobt=1, sparse=1, rmapbt=0
            =                       reflink=1    bigtime=0 inobtcount=0
   data     =                       bsize=4096   blocks=4128507, imaxpct=25
            =                       sunit=0      swidth=0 blks
   naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
   log      =internal log           bsize=4096   blocks=2560, version=2
            =                       sectsz=512   sunit=0 blks, lazy-count=1
   realtime =none                   extsz=4096   blocks=0, rtextents=0
   data blocks changed from 4128507 to 8322811

此时检查 ``df -h`` 可以看到根分区已经扩展到最大32GB::

   ...
   /dev/vda2        32G   15G   17G  47% /
   ...

如果VM内部使用了LVM
=======================

如果虚拟机内部使用了LVM，最简单的方法是使用 :ref:`kvm_libguestfs` 工具对应的 ``virt-resize`` ，可以将容器内部的磁盘文件系统或者LVM卷大小进行调整，详细案例可以参考:

- `virt-resize - Resize a virtual machine disk <https://libguestfs.org/virt-resize.1.html>`_
- `Resizing a KVM disk image on LVM, The Easy Way <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-easy-way/>`_

参考
=========

- `Resizing a KVM disk image on LVM, The Hard Way <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-hard-way/>`_ 和 `Resizing a KVM disk image on LVM, The Easy Way <https://dnaeon.github.io/resizing-a-kvm-disk-image-on-lvm-the-easy-way/>`_ 注意，这两个文档原文是虚拟机内部使用了LVM卷管理，当扩展虚拟机磁盘之后，如何在虚拟机内部调整guest操作系统LVM，和我的案例不同，但是思路可以参考
