.. _alpine_local_backup:

========================
Alpine Linux本地备份
========================

Alpine Linux以diskless模式启动时，只会从启动设备中加载一些必要的软件包。然后，本地修改内存中的数据(操作系统加载到内存中运行)是可能的，例如，安装软件包或者修改 ``/etc`` 目录中配置文件。这些修改通过一个 overlay 文件保存 ( ``.apkovl`` )，就好像 :ref:`docker` 使用了分层的overlay文件系统，这样就能够在启动时自动加载，恢复到保存的状态。

``.apkovl`` 文件包含了自定义配置，可以使用 Alpine的本地备份工具 ``lbu`` 保存到可写入存储中。

.. note::

   如果是以 ``sys`` 磁盘模式来安装Alpine，也就是传统的将操作系统安装到本地磁盘，是不需要使用 ``lbu`` 来保存系统状态。

.. warning::

   默认情况下， ``lbu commit`` 只保存 ``/etc`` 目录下的修改，但不包括 ``/etc/init.d/`` 子目录。不过，可以使用 ``lbu include`` 来包含更多指定文件或者目录来进行备份。

保存和加载自定义ISO镜像
========================

- 刚完成 ``dd`` 命令将ISO复制到U盘的分区::

   Disk /dev/sda: 28.67 GiB, 30765219840 bytes, 60088320 sectors
   Disk model:  SanDisk 3.2Gen1
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x65428faa

   Device     Boot Start     End Sectors  Size Id Type
   /dev/sda1  *        0 1224703 1224704  598M  0 Empty
   /dev/sda2         460    3339    2880  1.4M ef EFI (FAT-12/16/32)

Alpine的 ``diskless mode`` ISO镜像会尝试从系统分区加载一个 ``.apkovl`` 卷，这样就可以将定制的运行状态保存到一个可写入分区的 ``.apkovl`` 文件，然后在启动是自动加载。

.. note::

   当主机重启时，在网络启动之前是无法使用远程软件仓库的。这意味着重启后本地启动介质中软件包较为陈旧，除非使用 ``local package cache`` 来把软件包更新持久化到本地可写入的存储设备。

本地包缓存(local package cache)，是使用 ``.apkovl`` 文件中保存的数据，将增加和更新过的软件包自动复制到内存中。

要使用内部磁盘的分区，需要手工修改 ``/etc/fstab`` ，并且保存配置:

- 使用diskless系统从ISO启动系统

- 根据需要，创建和格式化一个分区，例如，我使用U盘( ``/dev/sdb`` )的剩余空间创建一个分区 - 使用 ``cfdisk`` 较为方便，我发现 ``parted`` 似乎无法查看ISO镜像中的分区::

   cfdisk /dev/sdb

交互模式完成简单分区::

                                                                                                  Disk: /dev/sdb
                                                                               Size: 28.65 GiB, 30765219840 bytes, 60088320 sectors
                                                                                        Label: dos, identifier: 0x65428faa

       Device                      Boot                                   Start                      End                  Sectors                  Size                 Id Type
       /dev/sdb1                   *                                          0                  1224703                  1224704                  598M                  0 Empty
       /dev/sdb2                                                            460                     3339                     2880                  1.4M                 ef EFI (FAT-12/16/32)
   >>  /dev/sdb3                                                        1224704                 60088319                 58863616                 28.1G                 83 Linux

完成后，使用 ``fdisk -l /dev/sdb`` 可以看到::

   Disk /dev/sdb: 29 GB, 30765219840 bytes, 60088320 sectors
   29340 cylinders, 64 heads, 32 sectors/track
   Units: sectors of 1 * 512 = 512 bytes

   Device  Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
   /dev/sdb1 *  0,0,1       597,63,32            0    1224703    1224704  598M  0 Empty
   /dev/sdb2    1023,254,63 1023,254,63        460       3339       2880 1440K ef EFI (FAT-12/16/32)
   /dev/sdb3    76,59,48    668,82,54      1224704   60088319   58863616 28.0G 83 Linux

另外一种方法，是在第一次制作alipine linux U盘时，就通过fdisk命令创建好分区3，并且使用 ``mkfs.ext4`` 把文件系统建立好，这样就可以直接用于 ``setup-alpine``

.. note::

   我的实践发现，似乎还是在最初通过 ``dd`` 命令将ISO文件dump到U盘时候，同时使用 ``fdisk`` 命令添加一个 ``/dev/sdb3`` 比较方便。alpine linux提供的系统 ``fdisk`` 是busybox工具，功能比较简陋，并且默认使用 CHS 来计算分区，实在使用不便。

- 格式化分区::

   apk add e2fsprogs

   mkfs.ext4 /dev/sdb3

- 挂载分区::

   mkdir /media/sdb3
   mount /dev/sdb3 /media/sdb3

- 检查挂载::

   df -h

显示::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                       7.8G         0      7.8G   0% /dev/shm
   /dev/sdb1               598.0M    598.0M         0 100% /media/sdb1
   tmpfs                     7.8G     23.9M      7.8G   0% /
   tmpfs                     3.1G    112.0K      3.1G   0% /run
   /dev/loop0               99.4M     99.4M         0 100% /.modloop
   /dev/sdb3                27.5G     24.0K     26.0G   0% /media/sdb3

.. note::

   我的实践发现，这个挂载分区步骤必须手工完成 ``setup-alpine`` 交互命令并没有提供挂载 ``sdb3`` 功能，而是只是将 ``/media/sdb3`` 作为 ``lbu`` 备份位置。只有挂载了磁盘分区才能确保备份存储是持久化保存到磁盘的。

- 然后在 ``setup-alpine`` 中就可以使用这个 ``sdb3`` 作为存储配置以及apk缓存目录 ``/media/sdb3/cache`` :

- (可选,因为 ``setup-alpine`` 会自动添加)将挂载 ``sdb3`` 的配置写入 ``/etc/fstab`` ::

   echo "/dev/sdb3 /media/sdb3 ext4 noatime,ro 0 0" >> /etc/fstab

.. note::

   你会注意到上述前述配置中将 ``/dev/sdb3`` 挂载为只读 ``ro`` 模式，不过这不影响 ``lbu`` 工具，因为 ``lbu`` 在执行数据写入时会临时将挂载目录 ``remount`` 成读写模式，所以这里配置只读也没有关系。

   这步添加 ``/etc/fstab`` 配置可以不用执行，因为 ``setup-alpine`` 交互脚本在配置本地lbu配置磁盘时，会自动添加一行 ``/etc/fstab`` 配置如下::

      /dev/sdb3 /media/sdb3 ext4 rw,relatime 0 0

   但是，我的另一次实践发现，即使没有添加 ``/etc/fstab`` 的这行配置，只要在 ``setup-alpine`` 中指定过 ``sdb3`` 作为lbu存储目标，并且已经挂载过，重启之后还是会挂载。这是因为在 ``/etc/mtab`` 中添加了::

      /dev/sdb3 /media/sdb3 ext4 ro,relatime 0 0

   导致的重启依然生效。

- (可选,因为 ``setup-alpine`` 会自动添加 )修改 ``/etc/lbu/lbu.conf`` 配置::

   LBU_MEDIA=sdb3

此外，如果分区足够大，甚至可以保留多个备份(例如3个备份)::

   BACKUP_LIMIT=3

- 最后执行以下命令持久化本地修改，这样下次系统启动会自动恢复所做修改::

   lbu commit

lbu常用修命令
===============

- lbu
- lbu commit (Same as 'lbu ci')
- lbu package (Same as 'lbu pkg')
- lbu status (Same as 'lbu st')
- lbu list (Same as 'lbu ls')
- lbu diff
- lbu include (Same as 'lbu inc' or 'lbu add')
- lbu exclude (Same as 'lbu ex' or 'lbu delete')
- lbu list-backup (Same as 'lbu lb')
- lbu revert

当执行 ``lbu commit`` 命令时，会将系统修改保存，此时 ``lbu`` 会生成一个类似 ``myboxname.apkovl.tar.gz`` (这里 ``myboxname`` 是主机名)。这个文件包含了被称为 ``apkovl`` 的修改内容，保存到指定的media中，例如上文案例中的 ``sdb3``

lbu实践
-----------

- 添加 ``/home`` 目录备份::

   lbu include /home

- 创建一个系统用户::

   adduser -h /home/huatai -s /bin/ash -S -u 502 huatai
   passwd huatai

- 安装 ``sudo`` 工具::

   apk add sudo
   vi /etc/sudoers

添加 ``/etc/sudoers`` 配置::

   huatai ALL=(ALL) NOPASSWD: ALL

- 然后提交备份::

   lbu ci

- 重启系统观察

Alpine Linux磁盘
===================

Alpine Linux磁盘划分采用 ``parted`` 和 ``fdisk`` 观察不同::

   # parted /dev/sda print
   Model:  USB  SanDisk 3.2Gen1 (scsi)
   Disk /dev/sda: 30.8GB
   Sector size (logical/physical): 512B/512B
   Partition Table: msdos
   Disk Flags:

   Number  Start  End     Size    Type     File system  Flags
    2      236kB  1710kB  1475kB  primary               esp
    3      627MB  30.8GB  30.1GB  primary  ext4

   # fdisk -l /dev/sda
   Disk /dev/sda: 28.67 GiB, 30765219840 bytes, 60088320 sectors
   Disk model:  SanDisk 3.2Gen1
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x65428faa

   Device     Boot   Start      End  Sectors  Size Id Type
   /dev/sda1  *          0  1224703  1224704  598M  0 Empty
   /dev/sda2           460     3339     2880  1.4M ef EFI (FAT-12/16/32)
   /dev/sda3       1224704 60088319 58863616 28.1G 83 Linux

参考
======

- `Alpine local backup <https://wiki.alpinelinux.org/wiki/Alpine_local_backup>`_
- `alpine-persistent-usb <https://github.com/IronOxidizer/alpine-persistent-usb>`_
