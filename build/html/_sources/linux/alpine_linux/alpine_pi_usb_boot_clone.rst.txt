.. _alpine_pi_usb_boot_clone:

===============================================
树莓派4 USB存储启动Alpine Linux(clone方式)
===============================================

.. warning::

   本文尝试通过clone方式通过USB存储启动Alpine Linux，但是我的实践尚未成功，启动树莓派会进入"彩虹"状态，所以后续还要探索...

在通过 :ref:`alpine_pi_clone` 复制部署好用于 :ref:`k3s` 管控节点的3个服务器 ``x-k3s-m-1`` / ``x-k3s-m-2`` / ``x-k3s-m-3`` 之后，需要部署3个工作节点。工作节点采用

磁盘分区::

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

复制系统
============

和 :ref:`alpine_pi_clone` 相似复制系统，但是需要注意，使用USB外接移动硬盘，对于系统识别的磁盘名字是 ``/dev/sda`` ，所以在 Alpine Linux 配置中，挂载启动分区是 ``media/sda1``

将移动SSD硬盘插入主机，按照上文做好磁盘分区，然后进行格式化::

   sudo mkdosfs -F 32 /dev/sdf1
   sudo mkfs.ext4 /dev/sdf2

- 挂载系统::

    mount /dev/sdf2 /mnt
    mkdir -p /mnt/media/sda1
    mount /dev/sdf1 /mnt/media/sda1

.. note::

   请注意，移动硬盘是 ``/dev/sda1`` 所以这里设置的挂载目录必须是 ``/mnt/media/sda1``

- 复制系统::

   cd /mnt
   tar zxvf ~/alpine-sys.tar.gz 

- 原始的alpine linux使用TF卡，所以启动目录是 ``media/mmcblk0p1`` ，而且打包压缩时候也是这个目录。但是，对于我们后面需要使用SSD移动硬盘，需要把 ``media/mmcblk0p1`` 全部移动到 ``media/sda1`` 下::

   mv media/mmcblk0p1/* media/sda1/
   rm -r media/mmcblk0p1

- 然后还需要修正软连接::

   unlink boot
   ln -s media/sda1/boot ./boot

- 检查磁盘分区UUID::

   blkid /dev/sdf2

显示输出::

   /dev/sdf2: UUID="61747208-e1a5-43be-be15-a576e4b41e76" TYPE="ext4" PARTUUID="ab86aefd-02"

- 修订配置 ``boot/cmdline.txt``  ::

   root=UUID=61747208-e1a5-43be-be15-a576e4b41e76 modules=sd-mod,usb-storage,ext4 quiet rootfstype=ext4

- 修订 ``etc/fstab`` ::

   UUID=61747208-e1a5-43be-be15-a576e4b41e76       /       ext4    rw,relatime 0 0
   ...
   /dev/sda1  /media/sda1  vfat defaults 0 0

``boot/config-rpi`` 中有配置会被 ``boot/cmdline.txt`` 覆盖，所以不调整::

   CONFIG_CMDLINE="console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait"

- 修订主机名和IP地址配置:

  - ``etc/hostname``
  - ``etc/hosts``
  - ``etc/network/interfaces``

- 卸载::

   cd /
   umount /mnt/media/sda1
   umount /mnt

- 将clone的USB接口SSD移动硬盘插入 :ref:`pi_4` ，然后加电启动验证
