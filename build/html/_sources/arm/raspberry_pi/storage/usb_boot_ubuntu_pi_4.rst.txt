.. _usb_boot_ubuntu_pi_4:

=======================================
树莓派4 USB启动Ubuntu Server 20.04
=======================================

.. note::

   为了实现USB移动硬盘启动树莓派，我做了多次 :ref:`usb_boot_ubuntu_pi_4` ，所以虽然有了非常详细的排查过程，但是步骤上有些重复和散乱。所以，我重新整理一份操作手册，从我的实践经验来探索USB启动的最佳实践。

Raspbian和firmware
=====================

树莓派的USB启动需要更新和设置树莓派firmware，不过，我安装和使用的是 :ref:`ubuntu_linux` for Raspberry Pi，所以在Ubuntu 20.0.4  LTS操作系统中并没有包含树莓派firmware更新工具。解决的方法是，在SD卡中安装树莓派官方提供的Raspbian操作系统，利用raspbian中的firmware更新工具进行更新。

- 采用 :ref:`pi_quick_start` 中方法，我们先下载镜像并通过dd命令写入TF卡::

   sudo dd if=2020-08-20-raspios-buster-armhf-lite.img of=/dev/sdb bs=100M

- 然后将这个就绪的TF卡通过USB读卡连接到Linux主机上，执行以下命令，通过chroot切换到raspberry系统::

   mount /dev/sdb2 /mnt
   mount /dev/sdb1 /mnt/boot
   for f in dev dev/pts proc sys; do mount --bind /$f /mnt/$f;done
   export PS1="(chroot) $PS1"
   chroot /mnt/

- 更新最新的Raspbian系统::

   apt update
   apt upgrade

- 将Raspbian系统配置一个静态IP地址，这样就可以不需要外接显示器，直接通过ssh就可以登录树莓派操作，注意IP地址不要冲突，请参考 :ref:`studio_ip` 设置 ``192.168.6.110 raspberrypi`` 

在raspbian中，默认启动dhcpcd会自动配置IP地址，可以指定网卡接口使用静态IP地址，即修改 ``/etc/dhcpcd.conf`` 配置添加::

   interface eth0
   static ip_address=192.168.6.110/24
   static routers=192.168.6.9
   static domain_name_servers=202.96.209.133

注意，必须确保 ``dhcpcd.service`` 服务默认启动，上述配置才能生效::

   systemctl enable dhcpcd.service

- 然后卸载挂载的raspbian的TF卡，插入到树莓派中启动，然后测试是否能够按照上述静态IP地址访问ssh服务。

完成上述通过raspbian的TF卡启动树莓派之后，进入Raspberry Pi OS(即Raspbian)，我们可以通过ssh登陆到系统中，就不需要外接显示器，方便操作。

更新树莓派firmware支持USB启动
================================

现在依然还是Raspberry Pi OS系统，我们需要用官方系统来更新firmware。

- 设置正确的本地时间(将默认伦敦时间修改成上海时间)::

   unlink /etc/localtime
   ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

- 检查firmware更新配置 ``/etc/default/rpi-eeprom-update`` ，确保采用 ``stable`` 版本，如果是 ``cirtical`` 或者 ``beta`` 版本，都需要修改成 ``stable`` ::

   FIRMWARE_RELEASE_STATUS="stable"

- 进行系统更新::

   sudo apt update
   sudo apt upgrade
   sudo rpi-update
   sudo reboot

- 更新了系统和firmware之后，执行以下命令更新bootloader(具体需要根据实际当时提供的软件版本来定)::

   sudo rpi-eeprom-update -d -f /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-09-03.bin

提示信息::

   BCM2711 detected
   VL805 firmware in bootloader EEPROM
   *** INSTALLING /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-09-03.bin  ***
   BOOTFS /boot
   EEPROM update pending. Please reboot to apply the update.

.. note::

   更新firmware和bootloader前后检查bootlader版本::

      vcgencmd bootloader_version

   更新前后输出内容相同，也就是表明更新之前已经是最新版本::

      Sep  3 2020 13:11:43
      version c305221a6d7e532693cc7ff57fddfc8649def167 (release)
      timestamp 1599135103
      update-time 0
      capabilities 0x00000000

- 检查 bootloader 配置::

   vcgencmd bootloader_config

输出信息显示启动顺序是先TF卡，后USB存储::

   ...
   BOOT_ORDER=0xf41

修改树莓派启动顺序
====================

- 将最新都EEPROM镜像复制到临时目录下::

   cd /tmp
   cp /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-09-03.bin ./pieeprom.bin

- 导出配置::

   rpi-eeprom-config pieeprom.bin > bootconf.txt

- 修改 ``bootconf.txt`` 的最后一行::

   BOOT_ORDER=0xf41

将启动顺序改成从外接USB存储启动(如果包含TF卡启动的顺序目前发现会有D进程)::

   BOOT_ORDER=0x4

- 然后将修改的配置加入到EEPROM镜像文件::

   rpi-eeprom-config --out pieeprom-new.bin --config bootconf.txt pieeprom.bin

- 然后刷入修改过bootloader顺序的 EEPROM::

   sudo rpi-eeprom-update -d -f ./pieeprom-new.bin

Ubuntu for Raspberry Pi
========================

我们的目标是在USB外接SSD移动硬盘上运行Ubuntu for Raspberry Pi，当前采用的是 Ubuntu 20.04.1 LTS Server版本。直接将下载的镜像文件dd到移动硬盘上::

   dd if=ubuntu-20.04.1-preinstalled-server-arm64+raspi.img of=/dev/sda bs=100M

完成上述操作后，整个Ubuntu系统已经复制到移动硬盘上，使用 ``fdisk -l`` 命令可以看到::

   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd

   Device     Boot  Start     End Sectors  Size Id Type
   /dev/sda1  *      2048  526335  524288  256M  c W95 FAT32 (LBA)
   /dev/sda2       526336 6349231 5822896  2.8G 83 Linux

可以看到外接SSD磁盘1T空间，当前系统目录仅使用里2.8G。通常首次启动系统时会自动展开根文件系统，占据整块磁盘。但是，我希望的部署方式是仅让根目录使用30G空间，以便将剩余磁盘空间用于 :ref:`ceph` 和 :ref:`gluster` 以及部署 :ref:`kubernetes` ，所以采用 :ref:`resize_ext4_rootfs` 修改根目录空间。

- 删除 ``/dev/sda2`` 分区，然后重建分区，确保起始扇区和原先一致，然后将结束位置扩展到30G大小::

   # fdisk /dev/sda
   
   Welcome to fdisk (util-linux 2.33.1).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.
   
   
   Command (m for help): p   这里输入p打印当前磁盘分区信息
   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd
   
   Device     Boot  Start     End Sectors  Size Id Type
   /dev/sda1  *      2048  526335  524288  256M  c W95 FAT32 (LBA)
   /dev/sda2       526336 6349231 5822896  2.8G 83 Linux
   
   Command (m for help): d  这里输入d，删除分区
   Partition number (1,2, default 2): 2  这里输入2，删除分区2，也就是根目录所在分区
   
   Partition 2 has been deleted.
   
   Command (m for help): p  再次输入p打印当前分区信息，可以看到分区2已经删除
   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd
   
   Device     Boot Start    End Sectors  Size Id Type
   /dev/sda1  *     2048 526335  524288  256M  c W95 FAT32 (LBA)
   
   Command (m for help): n  这里输入n，添加新分区
   Partition type
      p   primary (1 primary, 0 extended, 3 free)
      e   extended (container for logical partitions)
   Select (default p): p  这里输入p，表示添加primary分区
   Partition number (2-4, default 2):  这里输入回车，表示接受默认值2，创建分区2
   First sector (526336-2000343039, default 526336):  这里输入回车，表示接受默认值，也就是之前分区的起始扇区
   Last sector, +/-sectors or +/-size{K,M,G,T,P} (526336-2000343039, default 2000343039): +32G  这里输入+32G，表示新创建分区32G
   
   Created a new partition 2 of type 'Linux' and of size 32 GiB.
   Partition #2 contains a ext4 signature. 系统提示分区2包含一个ext4标志，并询问是否要删除这个标志
   
   Do you want to remove the signature? [Y]es/[N]o: n  这里输入n，表示不删除原先的分区ext4标志
   
   Command (m for help): p  这里输入p，再次打印当前分区信息
   
   Disk /dev/sda: 953.9 GiB, 1024175636480 bytes, 2000343040 sectors
   Disk model: My Passport 25F3
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 1048576 bytes
   Disklabel type: dos
   Disk identifier: 0xab86aefd
   
   Device     Boot  Start      End  Sectors  Size Id Type
   /dev/sda1  *      2048   526335   524288  256M  c W95 FAT32 (LBA)
   /dev/sda2       526336 67635199 67108864   32G 83 Linux
   
   Command (m for help): w  可以看到分区2起始位置和之前完全一致，只是空间增大到32G，确认无误输入w保存修改
   The partition table has been altered.
   Calling ioctl() to re-read partition table.
   Syncing disks.

- 执行 ``resize2fs`` 命令，不指定大小则会自动扩展文件系统占据整个 ``/dev/sda2`` 分区，也就是我们扩展的32G空间::

   resize2fs /dev/sda2

提示信息输出如下::

   resize2fs 1.44.5 (15-Dec-2018)
   Resizing the filesystem on /dev/sda2 to 8388608 (4k) blocks.
   The filesystem on /dev/sda2 is now 8388608 (4k) blocks long.

- 挂载sda磁盘分区，检查是否工作正常::

   mount /dev/sda2 /mnt
   mount /dev/sda1 /mnt/boot/firmware

然后执行 ``df -h`` 命令检查，可以看到sda磁盘文件系统如下::

   /dev/sda2        32G  1.8G   29G   6% /mnt
   /dev/sda1       253M   61M  193M  24% /mnt/boot/firmware

- 注意，默认首次启动Ubuntu是会扩展根文件系统的，所以我们需要禁用这个自动扩展功能

对于 Raspbian 镜像，参考 `Disable auto file system expansion in new Jessie image 2016-05-10 <https://raspberrypi.stackexchange.com/questions/47773/disable-auto-file-system-expansion-in-new-jessie-image-2016-05-10>`_ 是修改启动命令行配置文件 ``cmdline.txt`` 将::

   dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet init=/usr/lib/raspi-config/init_resize.sh

修改成::

   dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet

不过，我发现上述配置当前并不存在，但是可以参考上述问答中提到Ubuntu采用了不同的方法，Ubuntu是使用 ``cloud-init`` 软件来实现系统初始化，包括磁盘resizefs。具体配置见 ``/etc/cloud/cloud.cfg`` ，可以看到::

   cloud_init_modules:
    - migrator
    - seed_random
    - bootcmd
    - write-files
    - growpart
    - resizefs
    - disk_setup
    - mounts
    - set_hostname
    - update_hostname
    - update_etc_hosts
    - ca-certs
    - rsyslog
    - users-groups
    - ssh

其中 ``growpart`` 就是分区扩展， ``resizefs`` 模块就是用来修改根文件系统大小，要禁止这2个功能模块，只需要删除上述 ``/etc/cloud/cloud.cfg`` 中的  ``-growpart`` 和 ``- resizefs`` 就可以了。如果要完全禁止 ``cloud-init`` ，则只需要::

   touch /etc/cloud/cloud-init.disabled

或者内核启动参数加上 ``cloud-init=disabled`` 。


配置Ubuntu的网络
=================

现在还没有切换到USB外接移动硬盘上的Ubuntu for Raspberry Pi，但是我们可以先配置好这个硬盘系统上的操作系统所使用网络，例如设置静态IP地址，方便后续通过ssh登陆维护。

- 挂载 ``/dev/sda`` 磁盘上分区::

   mount /dev/sda2 /mnt
   mount /dev/sda1 /mnt/boot/firmware

- 切换chroot，进入外接SSD移动硬盘中的Ubuntu系统，这样方便后续我们对操作系统进行全面修订::

   for f in dev dev/pts proc sys; do mount --bind /$f /mnt/$f;done
   chroot /mnt/
   export PS1="(chroot) $PS1"

.. note::

   请注意：从这里开始，我们已经chroot方式切换到移动硬盘的Ubuntu系统上，所有后面所有操作都是直接作用于移动硬盘文件系统。即操作 ``/etc/netplan/01-netcfg.yaml`` 实际上相当于没有chroot之前的Raspbian系统目录 ``/mnt/etc/netplan/01-netcfg.yaml`` 。

   ``请一定要注意这个差别!!!``

- 在移动硬盘的Ubuntu系统的 ``/etc/netplan`` 目录下添加配置文件

01-netcfg.yaml::

   network:
     version: 2
     renderer: networkd
     ethernets:
       eth0:
         optional: true
         dhcp4: no
         dhcp6: no
         addresses: [192.168.6.16/24, ]
         #addresses: [192.168.6.8/24,192.168.1.8/24 ]
         #gateway4: 192.168.1.1
         nameservers:
           addresses: [202.96.209.133, ]

并删除掉 ``50-cloud-init.yaml`` 配置文件，然后执行生效配置::

   netplan apply

很神奇，netplan工具完全支持chroot，可以跳过不必要步骤，提示如下::

   Running in chroot, ignoring request: is-active
   Running in chroot, ignoring request: stop
   Running in chroot, ignoring request.
   Running in chroot, ignoring request: start

修订ubuntu帐号密码
====================

ubuntu帐号初始密码在首次登录时会强制修改，但是由于为了避免连接显示器使用(因为我是将树莓派作为服务器)，所以通过ssh首次登录修订密码会失败。(每次ssh登录都提示修订密码，但是输入新密码后ssh连接立即被断开，导致没有更新 ``/etc/passwd`` 配置文件中帐号密码失效规则，就会每次登录都要求修改密码每次都失败)

解决方法是在 ubuntu 帐号的 ``/home/ubuntu/.ssh`` 目录下增加帐号公钥，这样登录ubuntu系统可以绕开密码认证，通过密钥认证ssh登录服务器后，再修订ubuntu帐号密码，就不会导致ssh断开触发密码修改失败。

解压缩内核(重要关键)
========================

.. warning::

   每次Ubuntu更新内核都需要重复执行这个步骤，否则会导致系统无法启动!!!

当前Ubuntu不支持压缩版本的64位arm内核启动，所以我们需要将 ``vmlinuz`` 解压成 ``vmlinux`` 。

- 找出移动硬盘中Ubuntu启动镜像中gzip压缩的内容起点::

   cd /boot/firmware
   od -A d -t x1 vmlinuz | grep '1f 8b 08 00'

输出显示::

   0000000 1f 8b 08 00 00 00 00 00 02 03 ec 5b 0f 54 54 67

- 这里 ``0000000`` 就是内核开始位置，我们要从这个位置开始解压缩内核::

   dd if=vmlinuz bs=1 skip=0000000 | zcat > vmlinux 

更新启动config.txt
====================

- 配置 ``config.txt`` 文件告知树莓派如何启动::

   vi /boot/firmware/config.txt

注释掉所有 ``[pi*]`` 段落，然后添加 ``kernel=vmlinux`` 和 ``initramfs initrd.img followkernel`` 到 ``[all]`` 段落::

   #[pi4]
   #kernel=uboot_rpi_4.bin
   #max_framebuffers=2

   #[pi2]
   #kernel=uboot_rpi_2.bin

   #[pi3]
   #kernel=uboot_rpi_3.bin

   [all]
   arm_64bit=1
   device_tree_address=0x03000000
   kernel=vmlinux
   initramfs initrd.img followkernel

更新 .dat 和 .elf 文件
=========================

Ubuntu发行版的firmware版本不如树莓派官方版本新，所以需要使用树莓派官方版本更新。

- 请采用 :ref:`gitzip` 方法下载最新的 ``raspberrypi/firmware`` ，或者采用我前面通过 Raspberry Pi OS更新过整个操作系统和firmware之后，直接复制本地系统已经升级过的firmware文件(我采用这个方法)::

   cp /boot/*.dat /mnt/boot/firmware/
   cp /boot/*.elf /mnt/boot/firmware/

重启
=====

完成Ubuntu的内核解压缩和更新Ubuntu的firmware之后，就可以关闭树莓派，然后再次加电启动。此时观察可以看到树莓派从移动硬盘的Ubuntu for Raspberry Pi 20.04.1 LTS启动。

参考
=====

- `USB Boot Ubuntu Server 20.04 on Raspberry Pi 4 <https://eugenegrechko.com/blog/USB-Boot-Ubuntu-Server-20.04-on-Raspberry-Pi-4>`_
