.. _alpine_install_pi:

===========================
树莓派环境安装Alpine Linux
===========================

Alpine Linux for Raspberry Pi
================================

在 `Alpine Linux 官方下载 <https://www.alpinelinux.org/downloads/>`_ 提供了多种安装模式，也提供了不同架构，包括ARM以及特定的树莓派镜像。我在 :ref:`edge_cloud_infra` 中采用 :ref:`raspberry_pi` 来构建 :ref:`k3s` 实现边缘计算。其中重点探索:

- RASPBERRY PI: 运行在树莓派裸机上，提供轻量级的OS运行环境
- MINI ROOT FILESYSTEM: 最小化root文件系统，用于容器和minimal chroots

下载和镜像
=============

下载 `alpine-rpi-3.15.0-aarch64.tar.gz <https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/aarch64/alpine-rpi-3.15.0-aarch64.tar.gz>`_ 

.. note::

   所有的树莓派型号都可以使用 ``armhf`` 版本(包括Pi Zero 和 Compute Modules)； ``armv7`` 版本是兼容树莓派2B，而 ``aarch64`` 则兼容 Raspberry Pi 2 Model v1.2 , :ref:`pi_3` 和 Compute Module 3 以及 :ref:`pi_4`

为了部署 :ref:`edge_cloud_infra` ，采用 ``sys`` 模式安装，也就是经典安装模式

准备
===========

- 在SD卡上划分2个分区:

  - 第一个分区是 ``fat16`` ，只需要 256MB ，需要设置分区为 ``boot`` 和 ``lba`` 标记
  - 第二个分区是 ``ext4`` 分区，SD卡的剩余空间

::

   fdisk /dev/sdb
   
执行磁盘划分，完成后如下:

.. literalinclude:: alpine_install_pi/fdisk_p.txt
   :language: bash
   :linenos:
   :caption: sys安装模式alpine linux分区

- 磁盘文件系统格式化::

   sudo partprobe
   sudo mkdosfs -F 32 /dev/sdb1
   sudo mkfs.ext4 /dev/sdb2

.. note::

   如果使用 Alpine Linux，要使用 ``mkfs.ext4`` 需要安装 ``e2fsprogs`` 包::

      apk update
      apk add e2fsprogs

复制Alipine系统
=================

- 划分完分区的SD卡磁盘(当前是通过USB转接，所以显示为 ``sdb`` )，然后重新插入U盘识别挂载，或者刷新分区表后直接挂载 ``/dev/sdb1`` (以下命令案例是刷新后挂载) ::

   sudo mount /dev/sdb1 /mnt

- 解压缩::

   cd /mnt
   sudo tar zxvf ~/Downloads/alpine-rpi-3.15.0-aarch64.tar.gz

.. note::

   `Classic install or sys mode on Raspberry Pi <https://wiki.alpinelinux.org/wiki/Classic_install_or_sys_mode_on_Raspberry_Pi>`_ 提到建议在 ``usercfg.txt`` 中添加配置::

      enable_uart=1

   配置激活 :ref:`pi_uart` ，可以用于后续的串口通讯开发，以及系统调试

.. note::

   对于headless使用，可以添加以下参数使得具有足够内存(对于树莓派bootloader需要32兆内存)::

      gpu_mem=32

.. note::

   要支持音频，则添加::

      dtparam=audio=on

- 下载 `headless overlay file <https://github.com/davidmytton/alpine-linux-headless-raspberrypi/releases/download/2021.06.23/headless.apkovl.tar.gz>`_ (我使用headless模式，这样可以不用显示器)，存放到文件系统根目录(不需要解压缩)::

   cd /mnt
   sudo wget https://github.com/davidmytton/alpine-linux-headless-raspberrypi/releases/download/2021.06.23/headless.apkovl.tar.gz

.. note::

   上述 ``headless`` 提供了树莓派启动到初始化，只要连接到提供DHCP的 :ref:`priv_dnsmasq` ，能够获得IP地址就能自动启动ssh服务提供远程访问以完成进一步配置

.. note::

   如果是使用无线配置 ``headless`` ，则在根目录下创建一个 ``wifi.txt`` 格式是::

      ssid password

- 卸载挂载::

   sudo umount /mnt

启动
=========

- 将SD卡从USB转接器中取出，插入 :ref:`pi_3` ，然后加电启动，此时通过 :ref:`priv_dnsmasq` 提供的DHCP服务，该设备的Alpine Linux启动自动获取IP地址

确定IP地址的方法是检查 dnsmasq 的 ``/var/lib/misc/dnsmasq.leases`` 状态文件，例如::

   1641849999 b8:27:eb:f8:05:bd 192.168.6.21 localhost 01:b8:27:eb:f8:05:bd

- 通过ssh登陆主机::

   ssh root@192.168.6.21

此时系统尚未配置root密码，所以可以直接登陆

安装
===========

采用 ``sys`` 模式，参考 `Classic install or sys mode on Raspberry Pi <https://wiki.alpinelinux.org/wiki/Classic_install_or_sys_mode_on_Raspberry_Pi>`_

- 执行 ``setup-alpine`` 命令

  - 主机名设置(第一台案例): ``x-k3s-m-1.edge.huatai.me``
  - 提示有2个网卡 ``eth0 wlan0`` ，默认选择 ``eth0`` ，并配置固定IP地址 ``192.168.7.11`` ，默认网关 ``192.168.7.200``

我这里遇到一个问题，默认启动 ``chronyd`` 作为NTP客户端，但是没有校准本机时间，导致无法连接软件仓库进行更新。原因是我配置了无线网卡DHCP同时又配置了有线网卡静态IP地址，都分配了默认网关，导致无法路由访问internet。修正(暂时关闭有线网络 ``default gw`` )路由后，恢复正常时钟同步，才能继续。

  - 注意，最后要在 ``save config`` 时回答 ``none`` ; 然后还要 ``save cache`` ::

     No disks available. Try boot media /media/mmcblk0p1? (y/n) [n]
     Enter where to store configs ('floppy', 'mmcblk0p1', 'usb' or 'none') [mmcblk0p1] none
     Enter apk cache directory (or '?' or 'none') [/var/cache/apk]

- 更新软件::

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

   echo "/dev/mmcblk0p1 /media/mmcblk0p1 vfat defaults 0 0" >> etc/fstab
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

这里我遇到一个问题 :ref:`alpine_pi_clock_skew`

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
