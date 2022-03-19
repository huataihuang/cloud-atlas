.. _alpine_install_pi_1:

===========================
树莓派一代安装Alpine Linux
===========================


我尝试实现 :ref:`the_most_smallest_cheapest_k8s` 使用 :ref:`pi_1` 这种非常古老和廉价的设备，实现分布式容器系统，来运行各种服务。为了尽可能降低对硬件的要求，选择 :ref:`alpine_linux` 作为操作系统。

:ref:`pi_1` 是32位硬件，所以在 `Alpine Linux 官方下载 <https://www.alpinelinux.org/downloads/>`_ 下载 ``armhf`` 版本，并在本文记录安装部署过程。

下载和镜像
=============

下载 `alpine-rpi-3.15.1-armhf.tar.gz <https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/armhf/alpine-rpi-3.15.1-armhf.tar.gz>`_

.. note::

   所有的树莓派型号都可以使用 ``armhf`` 版本(包括Pi Zero 和 Compute Modules)； ``armv7`` 版本是兼容树莓派2B，而 ``aarch64`` 则兼容 Raspberry Pi 2 Model v1.2 , :ref:`pi_3` 和 Compute Module 3 以及 :ref:`pi_4`

为了部署 :ref:`edge_cloud_infra` ，采用 ``sys`` 模式安装，也就是经典安装模式

准备
===========

- 在SD卡上划分2个分区:

  - 第一个分区是 ``fat32`` ，只需要 256MB ，需要设置分区为 ``boot`` 和 ``lba`` 标记
  - 第二个分区是 ``ext4`` 分区，SD卡的剩余空间

.. note::

   注意，准备TF卡分区是在独立的Linux主机上，使用TF卡读卡器连接，所以TF卡被识别成 ``sdb`` ，等到TF卡安装到树莓派上时，会被识别成 ``mmcblk0`` 。这里划分分区时是TF卡读卡器转换过的显示 ``sdb`` ，需要注意后文设备名变化。

::

   fdisk /dev/sda
   
执行磁盘划分，完成后如下:

.. literalinclude:: alpine_install_pi_1/fdisk_p.txt
   :language: bash
   :linenos:
   :caption: sys安装模式alpine linux分区

- 磁盘文件系统格式化::

   sudo partprobe
   sudo mkdosfs -F 32 /dev/sda1
   sudo mkfs.ext4 /dev/sda2

.. note::

   如果使用 Alpine Linux，要使用 ``mkfs.ext4`` 需要安装 ``e2fsprogs`` 包::

      apk update
      apk add e2fsprogs

复制Alipine系统
=================

- 划分完分区的SD卡磁盘(当前是通过USB转接，所以显示为 ``sda`` )，然后重新插入U盘识别挂载，或者刷新分区表后直接挂载 ``/dev/sda1`` (以下命令案例是刷新后挂载) ::

   sudo mount /dev/sda1 /mnt

- 解压缩::

   cd /mnt
   sudo tar zxvf ~/Downloads/alpine-rpi-3.15.0-armhf.tar.gz

完成解压缩后可以看到 :ref:`alpine_linux` 的 ``armhf`` 版本仅占用了不到100M空间::

   /dev/sda1       253M   98M  155M  39% /mnt

- 卸载挂载::

   sudo umount /mnt

启动
=========

- 将SD卡从USB转接器中取出，插入 :ref:`pi_1` ，然后加电启动

此时系统尚未配置root密码，所以可以直接登陆

安装
===========

采用 ``sys`` 模式，参考 `Classic install or sys mode on Raspberry Pi <https://wiki.alpinelinux.org/wiki/Classic_install_or_sys_mode_on_Raspberry_Pi>`_

主机名和IP分配见 :ref:`edge_cloud_infra`

- 执行 ``setup-alpine`` 命令

  - 主机名设置(第一台案例): ``a-k3s-n-0.edge.huatai.me``
  - :ref:`pi_1` 只有一个以太网 ``eth0`` ，配置固定IP地址 ``192.168.10.10`` ，默认网关 ``192.168.10.1``
  - 注意，最后要在 ``save config`` 时回答 ``none`` ; 然后还要 ``save cache`` ::

     No disks available. Try boot media /media/mmcblk0p1? (y/n) [n]
     Enter where to store configs ('floppy', 'mmcblk0p1', 'usb' or 'none') [mmcblk0p1] none
     Enter apk cache directory (or '?' or 'none') [/var/cache/apk]

此时保存的配置实际上在内存中，只要不重启就不会丢失。接下来执行 ``sys`` 安装，所有数据都会实际存储到TF卡(持久化存储)。

遇到几个问题和处理方法
------------------------

- 时钟扭曲:

树莓派没有硬件时钟，所以启动时系统时间是错误的，并且由于和正确时间差距太大，导致 ``chrony`` (默认ntp服务)不能自动矫正。解决方法是手工执行一次 ``chronyc -a makestep`` 客户端命令强制进行时间同步。

注意，时间如果不准确，会导致主机无法连接internet进行软件仓库同步，这会导致进一步无法设置系统。所以在执行 ``setup-alpine`` 命令时如果遇到无法更新软件仓库，则应该检查一下系统时钟，并使用上述命令进行矫正。

- 启动ssh服务后root用户无法远程登陆:

默认 ``/etc/ssh/sshd_config`` 没有配置允许root用户使用密码登陆，所以即使 ``setup-alpine`` 正确配置了root用户密码，也无法ssh远程登陆。解决方法是修改 ``/etc/ssh/sshd_config`` 配置::

   #PermitRootLogin prohibit-password
   PermitRootLogin yes

然后重启 ``sshd``

- 更新软件库索引::

   apk update

添加 SD 卡分区作为系统分区
============================

由于我们已经在上文中将 ``/dev/mmcblk0p2`` 格式化成 ext4 文件系统，现在开始挂载并配置成系统分区::

   mount /dev/mmcblk0p2 /mnt
   export FORCE_BOOTFS=1
   # 这里添加一步创建boot目录
   mkdir /mnt/boot
   setup-disk -m sys /mnt

.. note::

   这里一定要先执行 ``export FORCE_BOOTFS=1`` 设置这个环境变量，否则执行::

      setup-disk -m sys /mnt

   会提示报错::

      ext4 is not supported. Only supported are: vfat

   所以这里我添加了一步::

      mkdir /mnt/boot

   虽然文档中没有写，但是我发现没有创建 ``/mnt/boot`` 目录会提示错误::

      /sbin/setup-disk: line 473: can't create /mnt/boot/config.txt: nonexistent directory
      /sbin/setup-disk: line 474: can't create /mnt/boot/cmdline.txt: nonexistent directory

此时提示信息::

   ext4 is not supported. Only supported are: vfat
   Continuing at your own risk.
   Installing system on /dev/mmcblk0p2:
   100%
   => initramfs: creating /boot/initramfs-rpi
   You might need fix the MBR to be able to boot

.. note::

   在 :ref:`pi_1` 上执行 ``setup-disk -m sys /mnt`` 速度慢到让我吃惊，似乎有什么异常需要解决。待排查

- 然后重新以读写模式挂载第一个分区，准备进行更新::

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

   echo "/dev/mmcblk0p1 /media/mmcblk0p1 vfat defaults 0 0" >> etc/fstab  # 这是增加挂载分区1
   sed -i '/cdrom/d' etc/fstab   # Of course, you don't have any cdrom or floppy on the Raspberry Pi
   sed -i '/floppy/d' etc/fstab
   cd /media/mmcblk0p1

- 因为下次启动，需要标记root文件系统是第二个分区，所以需要修订 ``/media/mmcblk0p1/cmdline.txt`` 

原先配置是::

   modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1

执行以下命令添加 ``root`` 指示::

   sed -i 's/$/ root=\/dev\/mmcblk0p2 /' /media/mmcblk0p1/cmdline.txt

完成修订后 ``/media/mmcblk0p1/cmdline.txt`` 内容如下::

   modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 root=/dev/mmcblk0p2

- 重启系统::

   reboot

这里我遇到一个问题 :ref:`alpine_pi_clock_skew` (详情见该文) ，所以还需要附加操作。

系统简单配置
=================

- 添加huatai用户，并设置sudo::

   apk add sudo
   adduser huatai
   adduser huatai wheel
   visudo

- 作为服务器运行，关闭无线功能::

   rc-update del wpa_supplicant boot   

参考
======

- `Installing Alpine Linux on a Raspberry Pi <https://github.com/garrym/raspberry-pi-alpine>`_
- `Alpine Linux Raspberry Pi <https://wiki.alpinelinux.org/wiki/Raspberry_Pi>`_
- `Alpine Linux Raspberry Pi - Headless Installation <https://wiki.alpinelinux.org/wiki/Raspberry_Pi_-_Headless_Installation>`_ 无显示器安装
- `Alpine Linux Classic install or sys mode on Raspberry Pi <https://wiki.alpinelinux.org/wiki/Classic_install_or_sys_mode_on_Raspberry_Pi>`_ 系统安装模式 ``这篇文档是主要的参考``
- `Setting Up a Software Development Environment on Alpine Linux <https://www.overops.com/blog/my-alpine-desktop-setting-up-a-software-development-environment-on-alpine-linux/>`_-
- `Is Alpine a good alternative to Raspberry Pi OS (RPi4) when it comes to running a home server + small website (pretty much all Docker-based)? <https://www.reddit.com/r/AlpineLinux/comments/mrk03f/is_alpine_a_good_alternative_to_raspberry_pi_os/>`_
