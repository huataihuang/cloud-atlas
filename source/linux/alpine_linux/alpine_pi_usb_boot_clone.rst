.. _alpine_pi_usb_boot_clone:

===============================================
树莓派4 USB存储启动Alpine Linux(clone方式)
===============================================

在通过 :ref:`alpine_pi_clone` 复制部署好用于 :ref:`k3s` 管控节点的3个服务器 ``x-k3s-m-1`` / ``x-k3s-m-2`` / ``x-k3s-m-3`` 之后，需要部署3个工作节点。工作节点采用USB SSD，所以先采用 :ref:`alpine_install_pi_usb_boot` ，然后以这个USB SSD磁盘的模版clone出后续同样硬件环境的Alpine Linux。

备份模版系统
=============

- 目前已经 :ref:`alpine_install_pi_usb_boot` 安装好 ``x-k3s-a-0`` 系统，登陆到这台模版主机上

- 检查磁盘分区和挂载::

   df -h

可以看到分区挂载::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                     924.3M         0    924.3M   0% /dev/shm
   /dev/sda2                31.2G    248.3M     29.4G   1% /
   tmpfs                   369.7M    160.0K    369.6M   0% /run
   /dev/sda1               252.0M     52.9M    199.2M  21% /media/sda1

- 使用标准fdisk检查磁盘分区::

   Disk /dev/sde: 953.86 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd
   
   Device     Boot  Start      End  Sectors  Size Id Type
   /dev/sde1  *      2048   526335   524288  256M  c W95 FAT32 (LBA)
   /dev/sde2       526336 67635199 67108864   32G 83 Linux

如果使用alpine linux内置fdisk查看::

   Disk /dev/sda: 954 GB, 1024175636480 bytes, 2000343040 sectors
   124515 cylinders, 255 heads, 63 sectors/track
   Units: sectors of 1 * 512 = 512 bytes

   Device  Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
   /dev/sda1 *  0,32,33     32,194,34         2048     526335     524288  256M  c Win95 FAT32 (LBA)
   /dev/sda2    32,194,35   114,24,38       526336   67635199   67108864 32.0G 83 Linux

- 按照 :ref:`alpine_pi_clone` 对整个操作系统进行打包::

   cd /
   tar -cvpzf alpine-sys-ssd.tar.gz --exclude=alpine-sys-ssd.tar.gz --exclude=var/cache --exclude=dev --exclude=proc --exclude=sys --exclude=tmp --exclude=run .

复制系统
============

将目标主机使用的USB SSD磁盘插入到一台主机，例如我在 ``zcloud`` 上完成操作，使用标准fdisk进行分区::

   fdisk /dev/sde

将移动SSD硬盘插入主机，按照上文做好磁盘分区，然后进行格式化::

   sudo mkdosfs -F 32 /dev/sde1
   sudo mkfs.ext4 /dev/sde2

- 挂载系统::

    mount /dev/sde2 /mnt
    mkdir -p /mnt/media/sda1
    mount /dev/sde1 /mnt/media/sda1

.. note::

   请注意，使用SSD移动硬盘启动Alpine Linux时，这个移动硬盘分区是 ``/dev/sda1`` 所以这里设置的挂载目录必须是 ``/mnt/media/sda1``

- 复制系统::

   cd /mnt
   tar zxvf ~/alpine-sys-ssd.tar.gz 

- 检查磁盘分区UUID::

   blkid /dev/sde2

显示输出::

   /dev/sde2: UUID="c5e2356d-6fda-468b-be80-7eb798038100" TYPE="ext4" PARTUUID="ab86aefd-02"

这个分区UUID需要订正到clone后的系统中，这样才能保证新系统启动时正确挂载磁盘

- 修订配置 ``boot/cmdline.txt``  ::

   root=UUID=c5e2356d-6fda-468b-be80-7eb798038100 modules=sd-mod,usb-storage,ext4 quiet rootfstype=ext4

- 修订 ``etc/fstab`` ::

   UUID=c5e2356d-6fda-468b-be80-7eb798038100       /       ext4    rw,relatime 0 0
   ...
   /dev/sda1  /media/sda1  vfat defaults 0 0

- 修订主机名和IP地址配置:

  - ``etc/hostname``
  - ``etc/hosts``
  - ``etc/network/interfaces``

- 卸载::

   cd /
   umount /mnt/media/sda1
   umount /mnt

- 将clone的USB接口SSD移动硬盘插入 :ref:`pi_4` ，然后加电启动验证
