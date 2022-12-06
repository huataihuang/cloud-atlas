.. _losetup:

=======================
losetup块设备映射工具
=======================

``loop`` 设备是一种将自身数据映射到常规文件的块或者其他块设备的特殊块设备。 ``loop`` 设备可以像一个文件系统一样被挂载。

上述概念可能不容易理解。但是实际上在虚拟机镜像上我们经常会用到这个 ``loop`` 设备: 

- 一个虚拟机的 ``raw`` 虚拟磁盘，如何挂载到物理主机上处理，就是通过  ``loop`` 设备来实现
- 使用 ``dd`` 命令生成的磁盘文件，可以通过 ``loop`` 设备实现映射块文件，这样就能在虚拟磁盘文件中模拟多磁盘实验环境 -- :ref:`archlinux_zfs_virtual_disks`

.. _mount_vm_raw_disk:

挂载raw格式虚拟机磁盘
==========================

在 :ref:`virt-builder` 构建虚拟机镜像，也尝试从Fedora官方现在ARM版本的虚拟机镜像import到 :ref:`libvirt` 中运行，以验证自己部署的 :ref:`archlinux_arm_kvm` 是否工作正常。

这时候，遇到一个问题，就是启动了 Fedora 37 Server ARM虚拟机后，不知道密码(实际上初次启动时有一个设置交互，但是当时不熟悉错过了)。这时就需要使用 ``losetup`` 来挂载 ``.raw`` 虚拟机镜像进行密码修改:

- 设置 ``loop`` 映射::

   losetup -f -P Fedora-Server-37-1.7.aarch64.raw

- 检查 ``loop`` ::

   losetup -l

显示::

   NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE                                             DIO LOG-SEC
   /dev/loop0         0      0         0  0 /data/docs/Downloads/Fedora-Server-37-1.7.aarch64.raw   0     512

- 检查分区::

   fdisk -l /dev/loop0

可以看到虚拟机磁盘的分区::

   Disk /dev/loop0: 7 GiB, 7516192768 bytes, 14680064 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x5c5e303a

   Device       Boot   Start      End  Sectors  Size Id Type
   /dev/loop0p1 *       2048  1230847  1228800  600M  6 FAT16
   /dev/loop0p2      1230848  3327999  2097152    1G 83 Linux
   /dev/loop0p3      3328000 14680063 11352064  5.4G 8e Linux LVM

- 扫描LVM卷组PV::

   lvm pvscan

此时可以看到2个卷组，一个是已经属于本地操作系统的 ``vg-libvirt`` ，另一个就是虚拟磁盘上的卷组 ``fedora`` ::

     PV /dev/loop0p3     VG fedora          lvm2 [5.41 GiB / 0    free]
     PV /dev/nvme0n1p9   VG vg-libvirt      lvm2 [<201.08 GiB / 80.00 MiB free]
     Total: 2 [<206.49 GiB] / in use: 2 [<206.49 GiB] / in no VG: 0 [0   ]

- 扫描LVM卷组VG::

   lvm vgscan

显示::

   Found volume group "fedora" using metadata type lvm2
   Found volume group "vg-libvirt" using metadata type lvm2

- 导入卷组 ``fedora`` ::

   lvm vgimport fedora

此时报错::

   Volume group "fedora" is not exported

添加 ``--force`` 命令强制导入::

   vgimport --force fedora --devices /dev/loop0p3

此时还是会提示::

   WARNING: Volume groups with missing PVs will be imported with --force.
   Volume group "fedora" is not exported

不过卷组已经导入，用 ``lvs`` 命令可以看到::

     LV               VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
     root             fedora     -wi-------  5.41g

使用 ``lvdisplay`` 可以看到 ``/dev/fedora/root`` 的LV路径

- 重要：卷组需要激活才能使用 ( ``-a`` 表示 active，后面跟 ``y`` 表示激活，跟 ``n`` 表示关闭激活 )::

   vgchange -ay fedora

此时提示::

   1 logical volume(s) in volume group "fedora" now active

此时在 ``/dev/mapper/`` 目录下欧 ``fedora-root`` 设备::

   ls -lh /dev/mapper/

可以看到::

   lrwxrwxrwx 1 root root       7 Dec  7 00:14 fedora-root -> ../dm-6

- 可以挂载文件系统了::

   mount /dev/mapper/fedora-root /mnt

此时使用 ``df -h`` 就可以看到挂载好的文件系统::

   Filesystem               Size  Used Avail Use% Mounted on
   ...
   /dev/mapper/fedora-root  5.4G  2.5G  3.0G  46% /mnt

修改挂载的 ``/mnt/etc/shadow`` 将::

   root:!locked::0:99999:7:::

修改成::

   root:::0:99999:7:::

- 再从系统中取消掉 ``fedora`` 激活，并export::

   vgchange -an fedora

   # 不要执行vgexport，这使得虚拟机不能自动导入这个lvm
   #lvm vgexport fedora

- 完成操作后，可以取消 ``loop`` 设备映射::

   losetup --detach /dev/loop0

参考
======

- `10+ losetup command examples in Linux <https://www.golinuxcloud.com/losetup-command-in-linux/>`_
- `losetup - Unix, Linux Command <https://www.tutorialspoint.com/unix_commands/losetup.htm>`_
- `Moving a volume group to another system <https://tldp.org/HOWTO/LVM-HOWTO/recipemovevgtonewsys.html>`_
