.. _resize_ext4_rootfs:

=======================
调整ext4根文件系统大小
=======================


- Linux支持在线扩展Ext4文件系统，但是不能在线缩小Ext4
- Xen和KVM虚拟机都支持虚拟机运行时调整虚拟机块设备大小，但是如果启动虚拟磁盘设备的分区在使用中，就不能在线修改
- 只能调整分区的结束位置，但是不能调整分区的开始位置(会导致数据丢失)。并且这种操作是高风险操作，建议做好数据备份之后再操作。
- 建议在文件系统之下使用LVM卷管理，这样对卷进行扩展，实际上只是添加新的PV，不会修改现有的PV，风险相对较低。

在线扩展rootfs
=================

.. warning::

   通过 ``fdisk`` 修改磁盘分区大小，必须确保分区起始扇区和原先一致，且扩展后的扇区范围没有覆盖其他分区，否则会导致数据丢失。

.. note::

   以下在线扩展根分区操作是我的一次实践记录，当时环境中分区 ``/dev/vda3`` 没有占满整个磁盘，并且 ``/dev/vda3`` 之后的磁盘空间是空白(没有 ``/dev/vda4`` )，所以才能通过fdisk调整分区 ``/dev/vda3`` 的结束位置而不影响现有数据。

对于具有海量数据的服务器，通过备份，格式化磁盘，然后再恢复数据方式来静态扩展文件系统分区不仅非常麻烦，有时候还因为必须持续在线或者海量小文件存储而无法实现。如果能够在线扩展文件系统，对于业务场景会非常有帮助。

- 本案例能够直接不卸载根文件系统，直接通过fdisk命令修改 ``/dev/vda3`` 分区大小，然后 ``resize2fs`` 修改EXT4文件系统大小，原因是因为该磁盘恰好只分配了 ``/dev/sda3`` ，磁盘后续都是连续空白。

- 检查磁盘分区::

   #fdisk -l /dev/vda
   
   Disk /dev/vda: 128.8 GB, 128849018880 bytes, 251658240 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: dos
   Disk identifier: 0x000cb9dd
   
      Device Boot      Start         End      Blocks   Id  System
   /dev/vda1   *        2048     2099199     1048576   83  Linux
   /dev/vda2         2099200     6293503     2097152   82  Linux swap / Solaris
   /dev/vda3         6293504   125829119    59767808   83  Linux  <= 注意：这里vda3没有完全分配完磁盘空间，并且没有后续的vda4，所以才能通过fdisk修改分区大小

- 首先删除 ``vda3`` 对应分区，然后重新添加 ``vda3`` 分区，注意 **分区起始扇区和原先相同，结束扇区则增大** ，以便能够使用更多磁盘空间::

   #fdisk /dev/vda
   Welcome to fdisk (util-linux 2.23.2).
   
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.
   
   
   Command (m for help): p   <= 打印当前磁盘分区
   
   Disk /dev/vda: 128.8 GB, 128849018880 bytes, 251658240 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: dos
   Disk identifier: 0x000cb9dd
   
      Device Boot      Start         End      Blocks   Id  System
   /dev/vda1   *        2048     2099199     1048576   83  Linux
   /dev/vda2         2099200     6293503     2097152   82  Linux swap / Solaris
   /dev/vda3         6293504   125829119    59767808   83  Linux   <= 这个是需要扩展的分区3
   
   Command (m for help): d   <= 删除分区
   Partition number (1-3, default 3): 3   <= 选择分区3，即删除
   Partition 3 is deleted
   
   Command (m for help): p   <= 再次打印当前磁盘分区
   
   Disk /dev/vda: 128.8 GB, 128849018880 bytes, 251658240 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: dos
   Disk identifier: 0x000cb9dd
   
      Device Boot      Start         End      Blocks   Id  System
   /dev/vda1   *        2048     2099199     1048576   83  Linux
   /dev/vda2         2099200     6293503     2097152   82  Linux swap / Solaris  <= 可以看到分区3已经消失
   
   Command (m for help): n     <= 添加新分析，也就是再次添加分区3
   Partition type:
      p   primary (2 primary, 0 extended, 2 free)
      e   extended
   Select (default p): p     <= 设置新增加的分区是主分区
   Partition number (3,4, default 3): 3     <= 分区3
   First sector (6293504-251658239, default 6293504): 6293504  <= 关键点：重建的分区3起始扇区必需和原先删除的分区3完全一致
   Last sector, +sectors or +size{K,M,G} (6293504-251658239, default 251658239):  <= 关键点：重建的分区3的结束扇区值扩大了，完整占据磁盘剩余空间
   Using default value 251658239
   Partition 3 of type Linux and of size 117 GiB is set
   
   Command (m for help): p   <= 再次打印当前磁盘分区
   
   Disk /dev/vda: 128.8 GB, 128849018880 bytes, 251658240 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: dos
   Disk identifier: 0x000cb9dd
   
      Device Boot      Start         End      Blocks   Id  System
   /dev/vda1   *        2048     2099199     1048576   83  Linux
   /dev/vda2         2099200     6293503     2097152   82  Linux swap / Solaris
   /dev/vda3         6293504   251658239   122682368   83  Linux   <= 确认重建的分区3正确
   
   Command (m for help): w   <= 将分区表信息写回磁盘保存
   The partition table has been altered!
   
   Calling ioctl() to re-read partition table.
   
   WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
   The kernel still uses the old table. The new table will be used at
   the next reboot or after you run partprobe(8) or kpartx(8)
   Syncing disks.

- 刷新内核对磁盘分区的识别

注意，由于是修改正挂载的磁盘分区，所以需要通过 ``partprobe`` 或者 ``kpartx`` 来通知重新识别。

不过， ``partprobe`` 方式并不能使得内核识别正在使用的根磁盘分区::

   #partprobe
   Error: Partition(s) 3 on /dev/vda have been written, but we have been unable to inform the kernel of the change, probably because it/they are in use.  As a result, the old partition(s) will remain in use.  You should reboot now before making further changes.

这里可以通过检查磁盘分区在内核中信息验证没有生效::

   cat /proc/partitions | grep vd

显示如下::

   253        0  125829120 vda
   253        1    1048576 vda1
   253        2    2097152 vda2
   253        3   59767808 vda3

参考 `Does RHEL 7 support online resize of disk partitions? <https://access.redhat.com/solutions/199573>`_ 使用 ``partx`` 的 ``-u`` 参数可以更新::

   partx -u /dev/vda

此时没有任何输出信息，实际已经更新完成。

再次检查分区大小信息，可以看到已经更新::

   #cat /proc/partitions | grep vd
    253        0  125829120 vda
    253        1    1048576 vda1
    253        2    2097152 vda2
    253        3  122682368 vda3

.. note::

   - RHEL7内核包含了从 `block: add partition resize function to blkpg ioctl <http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c83f6bf98dc1f1a194118b3830706cebbebda8c4>`_ 的BLKPG ioctl的修改来支持 ``BLKPG_RESIZE_PARTITION`` 操作。
   - 当前RHEL7的 ``util-linux`` 工具包包含的 ``partx`` 和 ``resizepart`` 程序是唯一支持 ``BLKPG_RESIZE_PARTITION`` 的BLKPG ioctl操作的用户端命令。

- 检查磁盘::

   tune2fs -l /dev/vda3

- 扩展EXT4文件系统

.. note::

   ``resize2fs`` 命令支持ext2/ext3/ext4文件系统重定义大小。如果文件系统是umount状态，则可以通过 ``resize2fs`` 工具扩展或收缩文件系统。如果文件系统是mount状态，则只支持扩展文件系统。注意：要在线扩展文件系统，需要内核和文件系统都支持on-line resize。（现代Linux发行版使用的内核 2.6 可以支持在线resize挂载状态的ext3和ext4；其中，ext3文件系统需要使用 ``resize_inode`` 特性)

::

   esize2fs [ -fFpPMbs ] [ -d debug-flags ] [ -S RAID-stride ] [ -z undo_file ] device [ size ]

- 现在我们检查一下当前挂载的 ``/dev/vda3`` 磁盘文件系统，挂载为 ``/`` 分区，当前大小是 ``56G`` ::

   #df -h
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/vda3        56G  2.4G   51G   5% /
   ...

- 执行以下命令扩展文件系统(默认扩展成分区大小，也可以指定文件系统大小)::

   resize2fs /dev/vda3

显示输出::

   resize2fs 1.43.5 (04-Aug-2017)
   Filesystem at /dev/vda3 is mounted on /; on-line resizing required
   old_desc_blocks = 4, new_desc_blocks = 8
   The filesystem on /dev/vda3 is now 30670592 (4k) blocks long.

- 再次检查挂载的 ``/`` 分区，可以看到空间已经扩展到 ``116G`` ::

   #df -h
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/vda3       116G  2.4G  108G   3% /
   ...

现在就可以毫无障碍地使用扩展过的根文件系统

- 强制系统重启进行fsck

RHEL 6等早期使用SysVinit和Debian使用Upstart早期版本，都支持在根分区的文件系统上 ``/forcefsck`` 文件来激活强制对根文件系统进行fsck，这是通过 ``/etc/rc.sysinit`` 脚本来实现的::

   touch /forcefsck

这样系统重启会强制进行fack。

不过，在systemd系统中，需要通过 ``systemd-fsck`` 服务来设置 `systemd-fsck@.service <https://www.freedesktop.org/software/systemd/man/systemd-fsck@.service.html>`_ 。

参考 `archliux - fsck <https://wiki.archlinux.org/index.php/fsck>`_ 使用以下命令检查分区设置的fsck检查频率（默认是每30次启动会做一次fsck，不过，当前文件系统设置了 ``-1`` 强制不检查，或者设置 ``0`` 也是不检查）::

   #dumpe2fs -h /dev/vda3 | grep -i "mount count"
   dumpe2fs 1.43.5 (04-Aug-2017)
   Mount count:              6
   Maximum mount count:      -1

修改检查 ``/dev/vda3`` 频率，设置成 ``1`` ，则每次重启都会检查::

   tune2fs -c 1 /dev/vda3

显示::

   tune2fs 1.43.5 (04-Aug-2017)
   Setting maximal mount count to 1

现在我们重启操作系统，从VNC终端检查虚拟机可以看到虚拟机启动时进行了文件系统fsck。

- 既然已经做过fsck了，我们现在恢复原先默认关闭fsck的设置::

   tune2fs -c -1 /dev/vda3

离线收缩rootfs
=================

.. warning::

   收缩文件系统风险很大，至少我的实践是失败的(在线扩容则每次都能够成功)。所以我强烈建议你在尝试收缩文件系统之前做好数据备份，随时做好从备份中恢复的准备。

.. note::

   Ext4文件系统只支持离线收缩，不能在线挂载情况下收缩文件系统，所以限制比较多。对于数据量较少的情况，我觉得还是通过备份恢复方式更简便(既然已经离线了，用备份恢复方式和收缩文件系统差别不大了)。

在 :ref:`ubuntu64bit_pi` 会发现首次启动操作系统，就会自动扩展根文件系统占据整个磁盘的剩余空间。对于部署服务器来说，合理的分区方式是根文件系统只占用较少空间，将主要存储空间保留给LVM卷管理，或者 :ref:`btrfs` / :ref:`zfs` 实现动态存储分配管理。

.. note::

   在通过resize2fs缩小文件系统时，我特意先选择比目标磁盘空间小1G的大小，这样可以确保fdisk调整文件系统分区时不会出现冲突。等fdisk调整到目标磁盘空间后，再次执行resize2fs，让EXT4文件系统恰好扩展到完整的分区大小。

   我先后做过两次磁盘ext4 resizefs，第一次是直接对 :ref:`ubuntu64bit_pi` 的安装后磁盘分区进行调整，此时文件系统分区表是树莓派默认的dos分区; 第二次是我实现 :ref:`usb_boot_ubuntu_pi_4` 采用最近安装的Ubuntu for Raspberry Pi，此时文件系统分区表是GPT。所以两者在分区的扇区上有细微的差别。 

- 检查当前磁盘分区::

   fdisk -l /dev/sda

显示输出当前整个 ``/dev/sda2`` 大约占用了 ``953.6G`` ::

   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: gpt
   Disk identifier: F727B1EE-B292-40DF-ACB0-AAAD6A763492

   Device      Start        End    Sectors   Size Type
   /dev/sda1    2048     499711     497664   243M EFI System
   /dev/sda2  499712 2000343006 1999843295 953.6G Linux filesystem

- 检查当前磁盘空间::

   mount /dev/sda2 /mnt
   df -h

显示外接SSD移动硬盘占用空间仅 2.5G ::

   /dev/sda2       940G  2.5G  899G   1% /mnt

- 我计划将根目录收缩到30G左右，所以先卸载挂载磁盘::

   umount /mnt

- 在卸载到文件系统上执行 fsck ::

   e2fsck /dev/sda2

输出显示文件系统是干净的::

   e2fsck 1.44.1 (24-Mar-2018)
   writable: clean, 142569/62496768 files, 5140329/249980411 blocks

- 使用 ``resize2fs`` 命令收缩文件系统::

   resize2fs /dev/sda2 32G

提示信息::

   resize2fs 1.45.5 (07-Jan-2020)
   Please run 'e2fsck -f /dev/sda2' first.

- 按照提示再次执行 ``e2fsck -f /dev/sda2`` 显示输出::

   resize2fs 1.44.1 (24-Mar-2018)
   Please run 'e2fsck -f /dev/sda2' first.

   root@jetson:/# e2fsck -f /dev/sda2
   e2fsck 1.44.1 (24-Mar-2018)
   Pass 1: Checking inodes, blocks, and sizes
   Pass 2: Checking directory structure
   Pass 3: Checking directory connectivity
   Pass 4: Checking reference counts
   Pass 5: Checking group summary information
   writable: 142569/62496768 files (0.2% non-contiguous), 5140329/249980411 blocks

.. note::

   实际上只要 ``mount`` 过一次文件系统，如果要执行 ``resize2fs`` 就必须先执行一次 ``e2fsck -f`` 。

- 再次收缩文件系统::

   resize2fs /dev/sda2 32G

提示信息::

   resize2fs 1.44.1 (24-Mar-2018)
   Resizing the filesystem on /dev/sda2 to 8388608 (4k) blocks.
   resize2fs: A block group is missing an inode table while trying to resize /dev/sda2
   Please run 'e2fsck -fy /dev/sda2' to fix the filesystem
   after the aborted resize operation.

看似有些问题，这次resize2fs有问题，需要fack了::

   e2fsck -fy /dev/sda2

提示信息::

   e2fsck 1.44.1 (24-Mar-2018)
   ext2fs_check_desc: Corrupt group descriptor: bad block for block bitmap
   e2fsck: Group descriptors look bad... trying backup blocks...
   writable: recovering journal
   e2fsck: unable to set superblock flags on writable


   writable: ***** FILE SYSTEM WAS MODIFIED *****

   writable: ********** WARNING: Filesystem still has errors **********

- 我再次尝试 fsck ::

   e2fsck /dev/sda2

提示文件系统是干净的::

   e2fsck 1.44.1 (24-Mar-2018)
   Setting free inodes count to 62473043 (was 62386733)
   Setting free blocks count to 245963688 (was 244930381)
   writable: clean, 23725/62496768 files, 4016723/249980411 blocks

- 但是确实比较奇怪，此时我尝试挂在分区显示文件系统只有236M::

   mount /dev/sda2 /mnt
   df -h

显示::

   /dev/sda2       939G  236M  900G   1% /mnt

OMG，难道数据丢失了？

不过，进入 ``/mnt`` 目录下使用 ``du -sh`` 看到数据还存在::

   cd /mnt
   du -sh

输出还是之前的 4.5G ，看似数据没有丢失，只是当前收缩以后 ``df`` 显示不正确。

- 再次卸载文件系统，然后fsck以后，看看是否正确::

   umount /mnt
   fsck /dev/sda2

显示还是clean::

   fsck from util-linux 2.31.1
   e2fsck 1.44.1 (24-Mar-2018)
   writable: clean, 23725/62496768 files, 4016723/249980411 blocks

- 现在尝试使用 fdisk 命令重建分区 ``/dev/sda2`` ::

   Welcome to fdisk (util-linux 2.31.1).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.


   Command (m for help): p
   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: gpt
   Disk identifier: F727B1EE-B292-40DF-ACB0-AAAD6A763492

   Device      Start        End    Sectors   Size Type
   /dev/sda1    2048     499711     497664   243M EFI System
   /dev/sda2  499712 2000343006 1999843295 953.6G Linux filesystem
   
- 现在先删除 ``/dev/sda2`` 然后再把它加回来，只不过加回来时候分区结束位置提前(缩小)

先删除分区::

   Command (m for help): d
   Partition number (1,2, default 2):
   
   Partition 2 has been deleted.

然后再加回来，加回来时候分区只设置32G::

   Command (m for help): n
   Partition number (2-128, default 2): 
   First sector (499712-2000343006, default 499712): 
   Last sector, +sectors or +size{K,M,G,T,P} (499712-2000343006, default 2000343006): +32G
   
   Created a new partition 2 of type 'Linux filesystem' and of size 32 GiB.
   Partition #2 contains a ext4 signature.
   
   Do you want to remove the signature? [Y]es/[N]o: n

- 再次检查分区信息是否正确::

   Command (m for help): p
   
   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: gpt
   Disk identifier: F727B1EE-B292-40DF-ACB0-AAAD6A763492
   
   Device      Start      End  Sectors  Size Type
   /dev/sda1    2048   499711   497664  243M EFI System
   /dev/sda2  499712 67608575 67108864   32G Linux filesystem

和之前对比，只是 ``/dev/sda2`` 空间缩小了，其他一致，所以我们保存退出::

   Command (m for help): w
   The partition table has been altered.
   Calling ioctl() to re-read partition table.
   Re-reading the partition table failed.: Device or resource busy
   
   The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or kpartx(8).

- 按照提示刷新内核中sda分区表信息::

   partprobe /dev/sda

- 尝试挂载磁盘::

   mount /dev/sda2 /mnt

很不幸失败了::

   mount: /mnt: wrong fs type, bad option, bad superblock on /dev/sda2, missing codepage or helper program, or other error.

- fsck::

   e2fsck /dev/sda2

提示superblock记录和实际设备记录块不一致::

   e2fsck 1.44.1 (24-Mar-2018)
   The filesystem size (according to the superblock) is 249980411 blocks
   The physical size of the device is 8388608 blocks
   Either the superblock or the partition table is likely to be corrupt!
   Abort<y>?
   
.. note::

   最终我没有shrink成功，很遗憾，后续再看有没有机会实践了。

参考
=====

- `Does RHEL 7 support online resize of disk partitions? <https://access.redhat.com/solutions/199573>`_
- `Resize a Linux Root Partition Without Rebooting <https://devops.profitbricks.com/tutorials/increase-the-size-of-a-linux-root-partition-without-rebooting/>`_
- `How to resize ext4 root partition live without umount on Linux <https://linuxconfig.org/how-to-resize-ext4-root-partition-live-without-umount>`_
- `6.3. RESIZING AN EXT4 FILE SYSTEM <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/ext4grow>`_
- `5.3. RESIZING AN EXT4 FILE SYSTEM <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/ext4grow>`_
- `Reload Partition Table Without Reboot In Linux <https://www.teimouri.net/reload-partition-table-without-reboot-linux/#.XEbJLy2B3RY>`_
- `How to Shrink an ext2/3/4 File system with resize2fs <https://access.redhat.com/articles/1196333>`_
- `Is it possible to on-line shrink a EXT4 volume with LVM? <https://serverfault.com/questions/528075/is-it-possible-to-on-line-shrink-a-ext4-volume-with-lvm>`_ - 提供了一个通过initramfs在服务器启动时自动shrink文件系统的方法，比较巧妙，值得借鉴
