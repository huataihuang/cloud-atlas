.. _extend_ext4_on_lvm:

========================
扩展LVM上的EXT4文件系统
========================

本文案例是我的一次紧急扩容，为在线已经 100% 的LVM卷上EXT4文件系统在线扩容(不影线业务)。实践中有一点点困扰，包括 :ref:`lvm_device_excluded_by_filter`

- 添加一个分区作为 pv ::

   #pvcreate /dev/sda5
   WARNING: ext4 signature detected on /dev/sda5 at offset 1080. Wipe it? [y/n]: y
     Wiping ext4 signature on /dev/sda5.
     Physical volume "/dev/sda5" successfully created.

- 检查pv::

   pvs

输出显示::

   PV         VG      Fmt  Attr PSize    PFree
   /dev/dfb1  vg-data lvm2 a--     5.82t       0
   /dev/sda5          lvm2 ---  <263.72g <263.72g


::

   #pvdisplay
     --- Physical volume ---
     PV Name               /dev/dfb1
     VG Name               vg-data
     PV Size               5.82 TiB / not usable 2.00 MiB
     Allocatable           yes (but full)
     PE Size               4.00 MiB
     Total PE              1525878
     Free PE               0
     Allocated PE          1525878
     PV UUID               UbqdoA-z6Wx-xtuV-Q0c1-IuaF-YNWE-QNUayx
   
     "/dev/sda5" is a new physical volume of "<263.72 GiB"
     --- NEW Physical volume ---
     PV Name               /dev/sda5
     VG Name
     PV Size               <263.72 GiB
     Allocatable           NO
     PE Size               0
     Total PE              0
     Free PE               0
     Allocated PE          0
     PV UUID               Ka4Xkc-OkBz-NRnV-PQR7-UcU9-sTTe-ZirUli

::

   #vgdisplay
     --- Volume group ---
     VG Name               vg-data
     System ID
     Format                lvm2
     Metadata Areas        1
     Metadata Sequence No  4
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                1
     Open LV               0
     Max PV                0
     Cur PV                1
     Act PV                1
     VG Size               5.82 TiB
     PE Size               4.00 MiB
     Total PE              1525878
     Alloc PE / Size       1525878 / 5.82 TiB
     Free  PE / Size       0 / 0
     VG UUID               VnvQM9-hcX6-gVqL-Nlsl-q7GP-CIC6-Dwbx6n

现在需要将最后的完全空闲的 ``/dev/sda5`` 加入 ``VG`` vg-data::

   vgextend vg-data /dev/sda5

提示::

   Volume group "vg-data" successfully extended

- 此时检查可以看到 ``vg-data`` 空闲 就是刚添加的磁盘空间 ::

   #vgdisplay
     --- Volume group ---
     VG Name               vg-data
     System ID
     Format                lvm2
     Metadata Areas        2
     Metadata Sequence No  5
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                1
     Open LV               0
     Max PV                0
     Cur PV                2
     Act PV                2
     VG Size               <6.08 TiB
     PE Size               4.00 MiB
     Total PE              1593389
     Alloc PE / Size       1525878 / 5.82 TiB
     Free  PE / Size       67511 / 263.71 GiB
     VG UUID               VnvQM9-hcX6-gVqL-Nlsl-q7GP-CIC6-Dwbx6n

- 当前磁盘::

   #df -h
   ...
   /dev/mapper/vg--data-lv--thanos  5.8T  5.8T     0 100% /home/t4.new

- 扩容lvm::

   lvextend -l +100%FREE /dev/vg-data/lv-thanos

提示信息::

   Size of logical volume vg-data/lv-thanos changed from 5.82 TiB (1525878 extents) to <6.08 TiB (1593389 extents).
   Logical volume vg-data/lv-thanos successfully resized.

- 对挂载的EXT4文件系统进行扩容::

   resize2fs -p /dev/mapper/vg--data-lv--thanos

提示信息::

   resize2fs 1.43.5 (04-Aug-2017)
   Filesystem at /dev/mapper/vg--data-lv--thanos is mounted on /home/t4.new; on-line resizing required
   old_desc_blocks = 746, new_desc_blocks = 779
   The filesystem on /dev/mapper/vg--data-lv--thanos is now 1631630336 (4k) blocks long.

- 再次检查::

   #df -h
   ...
   /dev/mapper/vg--data-lv--thanos  6.1T  5.8T     0 100% /home/t4.new

奇怪，怎么扩容到6.1T，还是显示100%使用，没有空闲出空间?

- 检查文件系统是否具备 ``resize_inode`` 功能，执行::

   tune2fs -l /dev/mapper/vg--data-lv--thanos | grep resize_inode

可以看到::

   Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent 64bit flex_bg sparse_super large_file huge_file uninit_bg dir_nlink extra_isize

这说明文件系统是支持在线扩展的!

- 尝试卸载文件系统::

   umount /home/t4.new

- 然后重新做一次离线扩展::

   resize2fs -p /dev/mapper/vg--data-lv--thanos

提示::

   resize2fs 1.43.5 (04-Aug-2017)
   Please run 'e2fsck -f /dev/mapper/vg--data-lv--thanos' first.

- 好吧，先做一次fsck::

   e2fsck -f /dev/mapper/vg--data-lv--thanos

- 再做一次离线扩展::

   resize2fs -p /dev/mapper/vg--data-lv--thanos

提示::

   resize2fs 1.43.5 (04-Aug-2017)
   The filesystem is already 1631630336 (4k) blocks long.  Nothing to do!


我突然明白了:

- 磁盘空间太大(>5.8T)，添加200+对百分比没有太大影响
- 原先确实是100%使用，能够继续写入是因为默认有5%的 :ref:`reserved_space_for_root_on_filesystem` : 这点我在采用 :ref:`parallel_rsync` 同步备份数据时特意观察了一下，发现即使 ``df -h`` 显示磁盘空间已经使用了 100% ， ``rsync`` 依然在继续写入文件，没有报错(因为磁盘物理容量大约有6T，为root用户保留的 5% 空间就达到了惊人的 300G 空间，足够支持一段时间的超量写入)
- 当我使用 ``resize2fs`` 将文件系统扩展263G空间，实际上对于文件系统，仅仅是将原先超量写入root保留空间(约300G)再计算到 ``df -h`` 显示数据中，所以看上去依然是 100% 使用(之前可能写入root保留空间不少数据了)

再次扩展验证
=============

根据我上文推测， ``resize2fs`` 是可以在线扩展 EXT4 文件系统的，只不过刚才磁盘空间已经满了，数据是存储在 root 用户保留空间，所以扩展后还是显示 100%

准备了另一块大容量SSD磁盘，再次做扩展:

- 创建PV::

   #pvcreate /dev/dfa1
   WARNING: ext4 signature detected on /dev/dfa1 at offset 1080. Wipe it? [y/n]: y
     Wiping ext4 signature on /dev/dfa1.
     Physical volume "/dev/dfa1" successfully created.

- 扩展vg::

   #vgextend vg-data /dev/dfa1
     Volume group "vg-data" successfully extended

- 这次检查 ``vgdisplay`` 可以看到新增加的物理磁盘将 ``vg-data`` 扩大了 5.82TB::

   #vgdisplay
     --- Volume group ---
     VG Name               vg-data
     System ID
     Format                lvm2
     Metadata Areas        3
     Metadata Sequence No  7
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                1
     Open LV               1
     Max PV                0
     Cur PV                3
     Act PV                3
     VG Size               <11.90 TiB
     PE Size               4.00 MiB
     Total PE              3119267
     Alloc PE / Size       1593389 / <6.08 TiB
     Free  PE / Size       1525878 / 5.82 TiB
     VG UUID               VnvQM9-hcX6-gVqL-Nlsl-q7GP-CIC6-Dwbx6n

- 扩展 ``lv`` 到所有可用 ``vg`` ::

   #lvextend -l +100%FREE /dev/vg-data/lv-thanos
     Size of logical volume vg-data/lv-thanos changed from <6.08 TiB (1593389 extents) to <11.90 TiB (3119267 extents).
     Logical volume vg-data/lv-thanos successfully resized.

- 将文件系统扩展到整个可用空间::

   #resize2fs -p /dev/mapper/vg--data-lv--thanos
   resize2fs 1.43.5 (04-Aug-2017)
   Filesystem at /dev/mapper/vg--data-lv--thanos is mounted on /home/t4.new; on-line resizing required
   old_desc_blocks = 779, new_desc_blocks = 1524
   The filesystem on /dev/mapper/vg--data-lv--thanos is now 3194129408 (4k) blocks long.

- 再次检查 ``df -h`` ，正如所愿，磁盘空间整整翻倍::

   #df -h
   Filesystem                       Size  Used Avail Use% Mounted on
   ...
   /dev/mapper/vg--data-lv--thanos   12T  6.1T  5.3T  54% /home/t4

参考
=======

- `How to add an extra second hard drive on Linux LVM and increase the size of storage <https://www.cyberciti.biz/faq/howto-add-disk-to-lvm-volume-on-linux-to-increase-size-of-pool/>`_
- `Extending Mounted Ext4 File System on LVM in Linux <https://www.systutorials.com/extending-a-mounted-ext4-file-system-on-lvm-in-linux/>`_
