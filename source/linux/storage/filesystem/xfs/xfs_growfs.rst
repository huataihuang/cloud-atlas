.. _xfs_growfs:

================================
xfs_growfs动态调整XFS文件系统
================================

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

但是，实际上没有完成扩展，使用 ``df -h`` 检查可以看到不变

- 如果使用 ``-d`` 参数来扩容最大化::

   xfs_growfs -d /

则提示::

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
   data size unchanged, skipping

但是可以看到最后提示 ``data size unchanged, skipping``

原来，我忘记先将分区扩展:

- 需要使用 ``growpart`` 工具，在 fedora 中需要安装 ``cloud-utils-growpart`` ，在 ubuntu 中需要安装 ``cloud-guest-utils`` ::

   sudo dnf install cloud-utils-growpart

- 先扩展分区::

   growpart /dev/vda 2

提示信息::

   CHANGED: partition=2 start=526336 old: size=12054528 end=12580864 new: size=33028063 end=33554399

- 此时再次检查磁盘就可以看到完整使用了磁盘::

   fdisk -l /dev/vda

显示::

   Disk /dev/vda: 16 GiB, 17179869184 bytes, 33554432 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 8A2359A8-F37E-405B-AD00-8036DCC8E610
   
   Device      Start      End  Sectors  Size Type
   /dev/vda1    2048   526335   524288  256M EFI System
   /dev/vda2  526336 33554398 33028063 15.7G Linux filesystem

- 再次扩容XFS就能够成功::

   xfs_growfs -d /

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

- 检查分区挂载::

   df -h

提示信息显示如下::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   /dev/vda2        16G  4.1G   12G  26% /
   ...

参考
========

- `How to grow/extend XFS filesytem in CentOS / RHEL using “xfs_growfs” command <https://www.thegeekdiary.com/how-to-grow-extend-xfs-filesytem-in-centos-rhel-using-xfs_growfs-command/>`_
- `How To resize an ext2/3/4 and XFS root partition without LVM <How To resize an ext2/3/4 and XFS root partition without LVM>`_
- `How to resize root partition online , on xfs filesystem? <https://stackoverflow.com/questions/38160794/how-to-resize-root-partition-online-on-xfs-filesystem>`_
