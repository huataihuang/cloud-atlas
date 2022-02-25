.. _edge_pi_alpine:

====================
边缘云Alpine Linux
====================

Alpine安装
===========

:ref:`alpine_install_pi` 可以提供轻量级的运行环境，配合 :ref:`k3s` 可以实现ARM环境的 :ref:`kubernetes` ，并进一步实现 :ref:`infra_service`

- 下载 `alpine-rpi-3.15.0-aarch64.tar.gz <https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/aarch64/alpine-rpi-3.15.0-aarch64.tar.gz>`_ 


在 :ref:`edge_cloud_infra` 中:

- :ref:`pi_3` 采用TF卡作为存储
- :ref:`pi_4` 采用外接USB磁盘

安装 :ref:`alpine_linux` 采用 ``sys`` 模式，也就是直接设置磁盘分区作为可读写 ``rw`` 模式

- TF卡或者外接USB磁盘需要划分2个分区:

  - 分区1是 ``fat32`` ，256MB
  - 分区2是 ``ext4`` ，TF卡使用全部剩余空间，USB外接磁盘则划分32GB(以便将剩余空间用于部署分布式存储 :ref:`ceph` )

.. literalinclude:: ../../linux/alpine_linux/alpine_install_pi/fdisk_p.txt
   :language: bash
   :linenos:
   :caption: sys安装模式alpine linux分区(这里sdb磁盘是因为经过TF卡读卡器转换)

- 磁盘文件系统格式化::

   sudo partprobe
   sudo mkdosfs -F 32 /dev/sdb1
   sudo mkfs.ext4 /dev/sdb2

- 挂载::

   sudo mount /dev/sdb1 /mnt

- 解压缩::

   cd /mnt
   sudo tar zxvf ~/Downloads/alpine-rpi-3.15.0-aarch64.tar.gz

完成解压缩后，系统已经初步安装好，现在将TF卡插入 :ref:`pi_3` 主机，连接电源、显示器和键盘后启动

- 执行 ``setup-alpine`` 命令:

  - 主机名设置(第一台案例): ``x-k3s-m-1.edge.huatai.me``
  - 提示有2个网卡 ``eth0 wlan0`` ，默认选择 ``eth0`` ，并配置固定IP地址 ``192.168.7.11`` ，默认网关 ``192.168.7.200``
  - 最后要在 ``save config`` 时回答 ``none`` ; 然后还要 ``save cache``

- 更新软件::

   apk update

- 挂载分区2

.. note::

   这里 :ref:`pi_3` 使用TF卡，所以分区2是 ``/dev/mmcblk0p2``

   对于 :ref:`pi_4` 使用USB外接SSD磁盘，则分区2是 ``/dev/sda2``

   实际方法完全一致，仅设备名区别

::

   mount /dev/mmcblk0p2 /mnt
   export FORCE_BOOTFS=1
   # 这里添加一步创建boot目录
   mkdir /mnt/boot
   setup-disk -m sys /mnt

- 重新以读写模式挂载第一个分区，准备进行更新::

   mount -o remount,rw /media/mmcblk0p1  # An update in the first partition is required for the next reboot.

- 清理掉旧的 ``boot`` 目录中无用文件::

   rm -f /media/mmcblk0p1/boot/*
   cd /mnt       # We are in the second partition
   rm boot/boot  # Drop the unused symbolink link

- 将启动镜像和 ``init ram`` 移动到正确位置::

   mv boot/* /media/mmcblk0p1/boot/
   rm -Rf boot
   mkdir media/mmcblk0p1   # It's the mount point for the first partition on the next reboot

- 创建软连接::

   ln -s media/mmcblk0p1/boot boot

- 更新 ``/etc/fstab`` ::

   echo "/dev/mmcblk0p1 /media/mmcblk0p1 vfat defaults 0 0" >> etc/fstab
   sed -i '/cdrom/d' etc/fstab   # Of course, you don't have any cdrom or floppy on the Raspberry Pi
   sed -i '/floppy/d' etc/fstab
   cd /media/mmcblk0p1

- 因为下次启动，需要标记root文件系统是第二个分区，所以需要修订 ``/media/mmcblk0p1/cmdline.txt`` ，完成修订后 ``/media/mmcblk0p1/cmdline.txt`` 内容如下::

   modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 root=/dev/mmcblk0p2

.. note::

   注意，对于使用外接USB磁盘，上述命令中 ``mmcblk0p`` 都需要修订成 ``sda`` ，即:

   - ``mmcblk0p1`` 改成 ``sda1``
   - ``mmcblk0p2`` 改成 ``sda2``

由于树莓派没有硬件时钟，需要解决 :ref:`alpine_pi_clock_skew` ，所以还需要执行以下步骤:

- 创建空文件::

   /etc/init.d/.use-swclock

- 修改 ``/lib/rc/sh/init.sh`` ，在 ``mount proc`` 段落后添加::

   if [ -e /etc/init.d/.use-swclock  ]; then
       "$RC_LIBEXECDIR"/sbin/swclock /etc/init.d
   fi

- 修改 ``/etc/fstab`` ，将最后一列指示文件系统fsck的功能关闭( ``0 0`` )::

   #UUID=7ffc2989-d85a-4600-a9b2-25d45090f466      /       ext4    rw,relatime 0 1
   UUID=7ffc2989-d85a-4600-a9b2-25d45090f466       /       ext4    rw,relatime 0 0

- 重启系统::

   reboot

alpine linux系统初始安装
==========================

- 安装必要系统软件::

   sudo apk update && sudo apk upgrade
   sudo apk add sudo curl

- 修订 ``/etc/sudoers`` ::

   %wheel ALL=(ALL) NOPASSWD: ALL

我自己的账号 ``huatai`` 位于 ``wheel`` 组，这样就可以 ``sudo`` 执行命令无需输入密码
