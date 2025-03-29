.. _alpine_pi_clone:

==============================
Clone Alpine Linux (树莓派)
==============================

完成 :ref:`alpine_install_pi` 之后，我需要构建多个树莓派环境的Alpine Linux，这样可以部署 :ref:`k3s` 集群。从头开始安装系统显然太繁琐了，最简单的方法，就是先配置好一台主机，然后通过clone方式完成复制。这样，只需要修订一些配置，就可以快速完成系统部署。

初始模版主机
===============

模版主机是采用 ``sys`` 模式安装的系统，磁盘分区如下::

   Disk /dev/mmcblk0: 59 GB, 63864569856 bytes, 124735488 sectors
   60906 cylinders, 64 heads, 32 sectors/track
   Units: sectors of 1 * 512 = 512 bytes

   Device       Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
   /dev/mmcblk0p1 *  1,0,1       256,63,32         2048     526335     524288  256M  c Win95 FAT32 (LBA)
   /dev/mmcblk0p2    257,0,1     489,63,32       526336  124735487  124209152 59.2G 83 Linux

启动后，系统挂载::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                     455.7M         0    455.7M   0% /dev/shm
   /dev/mmcblk0p2           58.0G    156.9M     54.9G   0% /
   tmpfs                   182.3M    100.0K    182.2M   0% /run
   /dev/mmcblk0p1          252.0M     51.1M    201.0M  20% /media/mmcblk0p1

操作系统归档
===============

通过 :ref:`recover_system_by_tar` 可以备份和恢复Ubuntu这样的操作系统，对于Alpine Linux也类似。不过，可能更为简单(没有 ``grub`` )，可以通过TF卡取出进行备份，然后再clone到新的TF卡。

- 源模版Alpine Linux的文件系统挂载::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                     455.7M         0    455.7M   0% /dev/shm
   /dev/mmcblk0p2           58.0G    158.0M     54.9G   0% /
   tmpfs                   182.3M    100.0K    182.2M   0% /run
   /dev/mmcblk0p1          252.0M     51.1M    201.0M  20% /media/mmcblk0p1

需要将::

   /dev/mmcblk0p2           58.0G    158.0M     54.9G   0% /
   /dev/mmcblk0p1          252.0M     51.1M    201.0M  20% /media/mmcblk0p1

完成clone出来

- Alpine Linux自带的 ``tar`` 是基于 ``BusyBox`` 的，所以不支持 GNU tar 的 ``--one-file-system`` 参数，所以处于谨慎，我还是将TF卡取出，挂载在标准Linux的 ``/mnt`` 目录下进行备份和恢复::

   mount /dev/sdf2 /mnt
   mount /dev/sdf1 /mnt/media/mmcblk0p1


- 在源模版系统上对整个系统备份::

   cd /mnt
   tar -cvpzf alpine-sys.tar.gz --exclude=alpine-sys.tar.gz --exclude=var/cache .

.. note::

   这里使用了相对路径，因为我是进入 ``/mnt`` 挂载目录下进行打包的

   此外，根据 `GNU tar: Crossing File System Boundaries <https://www.gnu.org/software/tar/manual/html_node/one.html>`_ 说明，如果使用 ``--one-file-system`` 就只会打包指定目录的单个文件系统，不会打包该文件系统下其他挂载，所以，如果使用 ``--one-file-system .`` 就不会打包 ``media/mmcblk0p1`` ，除非明确指出::

      tar -cvpzf alpine-sys.tar.gz --exclude=alpine-sys.tar.gz --exclude=var/cache \
          --one-file-system . media/mmcblk0p1

   不过，对于我这个特殊的采用挂载TF卡的打包，可以不使用 ``--one-file-system`` ，这样会完整打包所有子目录，也就包括了 ``media/mmcblk0p1``

- 将归档文件移动到HOME目录，然后卸载挂载::

   mv alpine-sys.tar.gz ~/  
   umount /mnt/media/mmcblk0p1
   umount /mnt

准备TF卡
===========

将新TF卡插入读卡器，然后插入模版主机的USB接口，此时，这个TF卡识别为 ``/dev/sdf`` 

- 对新TF卡进行分区，分区1是FAT32，分区2是EXT4::

   Disk /dev/sdf: 59.49 GiB, 63864569856 bytes, 124735488 sectors
   Disk model: MassStorageClass
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x00000000

   Device     Boot  Start       End   Sectors  Size Id Type
   /dev/sdb1  *      2048    526335    524288  256M  c W95 FAT32 (LBA)
   /dev/sdf2       526336 124735487 124209152 59.2G 83 Linux

- 文件系统格式化::

   sudo mkdosfs -F 32 /dev/sdf1
   sudo mkfs.ext4 /dev/sdf2

复制系统
===========

- 同样挂载系统::

   mount /dev/sdf2 /mnt
   mkdir -p /mnt/media/mmcblk0p1
   mount /dev/sdf1 /mnt/media/mmcblk0p1

- 恢复备份::

   cd /mnt
   tar zxvf ~/alpine-sys.tar.gz

- 由于磁盘的UUID不同，需要修订恢复后的磁盘挂载配置:

  - ``boot/cmdline.txt``
  - ``etc/fstab``

通过 ``blkid`` 命令获取磁盘的UUID::

   blkid /dev/sdf2

可以看到输出::

   /dev/sdf2: UUID="7ffc2989-d85a-4600-a9b2-25d45090f466" TYPE="ext4"

将获得的这个 ``UUID`` 替换上述两个配置文件中对应内容

- 修订主机名和IP地址配置:

  - ``etc/hostname``
  - ``etc/hosts``
  - ``etc/network/interfaces``

- 卸载::

   cd /
   umount /mnt/media/mmcblk0p1
   umount /mnt

- 将clone后的TF卡插入 :ref:`pi_3` 就可以以配置好的Alpine Linux启动
