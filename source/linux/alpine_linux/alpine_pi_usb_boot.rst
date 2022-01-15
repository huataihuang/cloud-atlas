.. _alpine_pi_usb_boot:

================================
树莓派4 USB存储启动Alpine Linux
================================

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
   /dev/sde1  *      2048   526335   524288  256M  e W95 FAT16 (LBA)
   /dev/sde2       526336 67635199 67108864   32G 83 Linux
