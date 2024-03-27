.. _chroot_raspbian:

=========================
chroot Raspbian维护更新
=========================

在 :ref:`usb_boot_ubuntu_pi_4` ，我使用树莓派官方提供的Raspbian来更新树莓派硬件的firmware，并且用来调整bootloader配置。此时，我需要插入一块Raspbian的TF卡来启动系统，更新Raspbian系统，再更新firmware，然后再次重启系统，恢复到正常运行的Ubuntu。这个步骤比较繁琐，而且树莓派设备安装在桌子底下，每次插拔TF卡非常不方便。

这个世界的进步是由"懒人"推动的，我不想这么麻烦，所以我把树莓派Raspbian系统复制到Ubuntu中，通过chroot来运行。类似于 :ref:`docker` ，除了内核不切换，其他都可以自如修改。

.. note::

   最近一次在更新 :ref:`usb_boot_ubuntu_pi_4` :ref:`ubuntu64bit_pi` ，意外遇到磁盘无法写入(主要是内核安装过程无法写入FAT32分区)更新后无法启动。所以将SSD磁盘连接到另外一个工作正常到Raspberry Pi设备上，通过本文方法尝试修复::

      sudo apt install --reinstall linux-raspi-headers-5.4.0-1034 linux-image-5.4.0-1034-raspi linux-modules-5.4.0-1034-raspi linux-headers-5.4.0-1034-raspi ubuntu-drivers-common

   注意，我使用的是Ubuntu for Raspberry Pi，挂载目录不同::

      # Ubuntu把sda1挂载到/mnt/boot/firmware，这个分区是VFAT
      # 然后在/mnt/boot 目录下创建软链接(EXT4)，请仔细对比正常的Ubuntu系统
      mount /dev/sda2 /mnt
      mount /dev/sda1 /mnt/boot/firmware

      # 挂载磁盘
      rootfs=/mnt
      mount -t proc proc ${rootfs}/proc
      mount --rbind /sys ${rootfs}/sys
      mount --make-rslave ${rootfs}/sys
      mount --rbind /dev ${rootfs}/dev
      mount --make-rslave ${rootfs}/dev

      # 进入系统
      chroot ${rootfs} /bin/bash
      source /etc/profile
      export PS1="(chroot) $PS1"

制作Raspbian系统备份
=======================

- 将Raspbian的TF卡通过读卡器连接到主机上，然后挂载到本地目录::

   mount /dev/sdb2 /mnt/
   mount /dev/sdb1 /mnt/boot

- 进入到Raspbian目录下，进行系统打包::

   cd /mnt
   tar -cvpf raspbian.tar --exclude=./raspbian.tar --one-file-system .

- 注意 ``--one-file-system`` 命令不会跨磁盘分区进行目录打包，所以上述命令没有包含 ``/mnt/boot`` 目录，通过以下命令添加到tar包::

   tar -rvpf raspbian.tar boot

- 在上述系统tar包完成后，再做一次压缩::

   gzip raspbian.tar

恢复Raspbian系统到Ubuntu
=========================

- 创建一个 ``/dev/sda3`` 分区，空间配置8G，然后将分区挂载::

   mkdir /raspbian
   mount /dev/sda3 /raspbian

- 在我的树莓派的Ubuntu系统中，创建 ``/raspbian`` 目录，然后将这个压缩备份包解压到这个目录下::

   tar -xvpzf raspbian.tar.gz -C /raspbian --numeric-owner

切换Raspbian系统
=================

- 切换使用raspbian方法如下::

   # 挂载磁盘
   rootfs=/raspbian
   mount -t proc proc ${rootfs}/proc
   mount --rbind /sys ${rootfs}/sys
   mount --make-rslave ${rootfs}/sys
   mount --rbind /dev ${rootfs}/dev
   mount --make-rslave ${rootfs}/dev

   # 进入系统
   chroot ${rootfs} /bin/bash
   source /etc/profile
   export PS1="(chroot) $PS1"
