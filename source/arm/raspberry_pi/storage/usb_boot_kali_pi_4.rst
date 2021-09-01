.. _usb_boot_kali_pi_4:

=================================
树莓派4 USB存储启动Kali Linux
=================================

:ref:`arm_k8s_deploy` 我采用了不同的操作系统，包括 :ref:`ubuntu_linux` 以及 :ref:`kali_linux` 。同时，为了提高存储性能， :ref:`usb_boot_ubuntu_pi_4` ，获得了很大的性能提升。所以，我Kali Linux环境上也同样采用 :ref:`wd_passport_ssd` 来加速性能。本文实施方法类似 :ref:`usb_boot_ubuntu_pi_4` ，但是做了以下改进:

- 采用chroot方式来启动外接U盘中的Raspberry Pi OS操作系统，这样无需反复重启系统(也就是直接在Kali Linux系统中启用Raspberry Pi OS提供的刷机工具来更新firmwrae)
- 采用 :ref:`recover_system_by_tar` 方法来复制操作系统到外接移动硬盘，不采用 ``dd`` 命令可以避免强制要求目标磁盘空间大于源磁盘空间，也就是可以缩减外接磁盘空间，以腾出更多磁盘空间给 :ref:`ceph`

备份kali
============

在运行的Kali Linux系统上执行完整的系统备份，注意备份前检查磁盘分区::

   # df -h
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/root       118G   15G   98G  14% /
   devtmpfs        894M     0  894M   0% /dev
   tmpfs           927M     0  927M   0% /dev/shm
   tmpfs           371M  1.5M  370M   1% /run
   tmpfs           5.0M  4.0K  5.0M   1% /run/lock
   /dev/mmcblk0p1  126M   74M   52M  59% /boot
   ...

可以看到需要备份的分区有2个，所以等会我们分开备份和恢复

- 备份根盘::

   cd /
   tar -cpzf kali-backup.tar.gz --exclude=/kali-backup.tar.gz --exclude=/var/cache --one-file-system /

恢复kali
===========

将移动硬盘分区 - 分区和原先在SD卡中默认分区相同( ``/boot`` ``/`` 分区 )::

   /dev/sda1  *      2048   526335   524288  256M  c W95 FAT32 (LBA)
   /dev/sda2       526336 67635199 67108864   32G 83 Linux


