.. _archlinux_on_thinkpad_x220_u_disk:

=====================================
ThinkPad X220上运行Arch Linux(U盘)
=====================================

之前在 :ref:`archlinux_on_thinkpad_x220` 是作为个人工作站，随着我在 :ref:`priv_cloud_infra` 部署需要有独立主机来实现带外管理和监控，并且ThinkPad X220已经不作为主工作桌面，硬盘已经拆除，所以将ThinkPad X220上安装U盘来运行一个经鉴定  :ref:`arch_linux` 。

.. warning::

   我最初以为在U盘上安装Arch Linux和 :ref:`archlinux_on_thinkpad_x220` 是一样的 ，毕竟拆掉了SSD硬盘之后，插入的U盘也被识别成 ``/dev/sda`` 设备。然而，实践发现，同样的步骤安装 ``EFISTUB`` 启动却失败。原来还是需要配置一个启动管理器。

准备工作
=========

- 创建安装U盘::

   sudo dd if=archlinux-2022.06.01-x86_64.iso of=/dev/rdisk3 bs=10m
   
将U盘插到ThnkPad X220的USB接口，启动主机，选择U盘启动，字符终端

- Arch Linux安装需要网络，在 :ref:`thinkpad_x220` 上可以自动识别网络设备，所以安装比 :ref:`archlinux_on_mbp` 方便很多::

   ip link

可以看到::

   enp0s25
   wlan0

有线网络设置
==============

默认启动dhcp分配IP地址，所以如果有线局域网已经提供DHCP服务，则可以自动分配IP地址连接网络。 默认安装系统是已经启动了sshd服务，就可以远程登陆系统进行下一步安装

- 如果网络没有提供DHCP服务，则采用静态IP配置::

   ip address add 192.168.6.199/24 dev enp0s25
   ip route add 0.0.0.0 via 192.168.6.200 dev enp0s25
   ip link set enp0s25 up

准备工作
============

- 更新系统时钟::

   timedatectl set-ntp true

- :ref:`parted` 磁盘分区(128G规格)::

   parted /dev/sda mklabel gpt
   parted -a optimal /dev/sda mkpart ESP fat32 0% 256MB
   parted /dev/sda set 1 esp on
   parted /dev/sda set 1 boot on
   parted -a optimal /dev/sda mkpart primary xfs 256MB 100%

.. note::

   - /dev/sdb1 划分为 EFI系统分区，大小 260-512MB
   - /dev/sdb2 根分区，大小100+GB(剩余空间)

完成后检查 ``fdisk -l`` 可以看到::

   Disk /dev/sda: 115.69 GiB, 124218507264 bytes, 242614272 sectors
   Disk model: Ultra Fit
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: FD028129-1CA4-4370-BAF7-510BF30CED83

   Device      Start       End   Sectors   Size Type
   /dev/sda1    2048    499711    497664   243M EFI System
   /dev/sda2  499712 242612223 242112512 115.4G Linux filesystem

- 格式化分区::

   mkdosfs -F 32 /dev/sda1
   mkfs.xfs /dev/sda2

- (废弃，针对EFISTUB的方法)挂载文件系统::

   mount /dev/sda2 /mnt
   mkdir /mnt/boot
   mount /dev/sda1 /mnt/boot

- (正确，采用GRUB)挂在文件系统::

   mount /dev/sda2 /mnt

安装
======

- 安装基本软件包::

   pacstrap /mnt base linux linux-firmware

配置
======

- fstab

生成fstab文件(这里 ``-U`` 或 ``-L`` 定义UUID或labels)::

   genfstab -U /mnt >> /mnt/etc/fstab

- chroot

将根修改到新系统::

   arch-chroot /mnt

- 设置时区::

   ln -sf /usr/share/zoneinifo/Asia/Shanghai /etcc/localtime

运行 hwclock 生成 /etc/cadjtime ::

   hwclock --systohc

- 安装简化版vi作为服务器配置维护工具::

   pacman -S vi

- 本地化语言支持 - 只需要UTF支持就可以，所以修改 ``/etc/locale.gen`` 保留 ``en_US.UTF-8 UTF-8`` 然后执行::

   locale-gen

创建 ``locale.conf`` 设置如下::

   LANG=en_US.UTF-8

网络配置
----------

- 创建 ``/etc/hostname`` 文件，内容是主机名::

   acloud

- 编辑 ``/etc/hosts`` ::

   127.0.0.1    localhost
   127.0.0.1    acloud.staging.huatai.me acloud

Root密码及用户账号
====================

- 设置root密码::

   passwd

- 设置日常账号::

   groupadd -g 20 staff
   useradd -g 20 -u 502 -d /home/huatai -m huatai
   passwd huatai

- 设置sudo::

   pacman -S sudo
   echo "huatai   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

安装系统工具
==============

- 安装openssh::

   pacman -S openssh

此时还在chroot状态，所以无法直接使用 :ref:`systemd` ，则执行以下命令手工启动 ``sshd`` ::

   ssh-keygen -A
   /usr/bin/sshd

使用EFISTUB启动(失败)
========================

.. note::

   我尝试了EFISTUB方式，但是在移动U盘上失败，启动页面空白。所以改为参考 `Install Arch Linux on a removable medium <https://wiki.archlinux.org/title/Install_Arch_Linux_on_a_removable_medium>`_ 采用安装标准boot loader 来启动

   本段落是我的尝试记录，实际未成功，所以应该跳过这段

- 安装 efibootmgr ::

   pacman -S efibootmgr

- 获取 ``/dev/sda1`` 分区ID (PARTUUID)::

   ls -lh /dev/disk/by-partuuid/

显示::

   lrwxrwxrwx 1 root root 10 Jun 14 02:42 258b404c-d631-4b9a-9457-05c928be2e02 -> ../../sda2
   lrwxrwxrwx 1 root root 10 Jun 14 02:42 f8b79904-985b-455f-8182-75e313efbbdf -> ../../sda1

这里 ``sda1`` 的PARTUUID是我们需要用来创建启动PART ID的参数::

   efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=258b404c-d631-4b9a-9457-05c928be2e02 rw initrd=\initramfs-linux.img' --verbose

.. note::

   参数:

   - ``--part 1`` 标识ESP分区
   - ``root=`` 标识root分区，也就是这里的 ``sda2``
   - 如果使用swap分区，则还可以添加 ``resume=`` 参数来标识swap分区

.. warning::

   这里有一个疑惑， ``--disk /dev/sda`` 能保证系统启动时候设备识别么？毕竟每次启动系统是被磁盘顺序不同，可能会有不同的设备标记。

   例如，我安装启动U盘和目标U盘都插在主机上，启动时候

- arch linux不能识别ESP分区的vfat文件系统，启动时候会报错 ``mount: /new_root: unknown filesystem type 'vfat'`` 。原因是我将VFAT的分区 ``/etc/sda1`` 作为 ``/boot`` ，但是默认安装的内核是没有带有VFAT模块。

修改 ``/etc/mkinitcpio.conf`` 添加 vfat 和 xfs 模块::

      MODULES=(vfat xfs)
      BINARIES=(fsck fsck.ext2 fsck.ext3 fsck.ext4 e2fsck fsck.vfat fsck.msdos fsck.fat fsck.xfs)
   
- 安装fsck工具::

   pacman -S dosfstools xfsprogs

- 生成新的initramfs::

   mkinitcpio -P

这里有一些WARNING提示，是和硬件相关的 firmware ::

   ==> WARNING: Possibly missing firmware for module: aic94xx
   ==> WARNING: Possibly missing firmware for module: bfa
   ==> WARNING: Possibly missing firmware for module: qed
   ==> WARNING: Possibly missing firmware for module: qla1280
   ==> WARNING: Possibly missing firmware for module: qla2xxx
   ==> WARNING: Possibly missing firmware for module: wd719x
   ==> WARNING: Possibly missing firmware for module: xhci_pci

只要系统已经安装了 ``linux-firmware`` ，上述WARNING可以忽略

- 设置以后检查启动项::

   efibootmgr --verbose

- 设置启动顺序::

    efibootmgr --bootorder XXXX,XXXX --verbose

这里 ``xxxx,xxxx`` 是刚才 ``efibootmgr --verbose`` 输出的每个启动项的编号。默认就是刚才新添加的启动项在最前面，也就是默认先启动刚才新安装的配置

.. note::

   如果历史上积累了太多无用的EFI启动项，可以通过以下命令删除::

      efibootmgr -b # -B

   这里 ``#`` 是项目，请替换成实际值，例如::

      efibootmgr -b 001F -B

- 重启系统

使用exit或者ctrl-d命令chroot环境，然后 ``umount -R /mnt`` ，最后输入 ``reboot`` 命令重启系统。

安装Boot Loader - GRUB
=============================

- 对于使用GRUB的系统，和前面EFISTUB不同，暂时不挂载 ``/dev/sda1`` ，只挂载 ``/dev/sda2`` 到 ``/mnt`` 即执行 ``pacstrap /mnt base linux linux-firmware`` 。不过，我已经执行过一次 ``efibootmgr`` ，所以简单将文件移动到 ``/boot`` 目录下即可

- 执行chroot::

   arch-chroot /mnt

- 其他安装软件步骤都是相同的，见上文

- 安装Grub bootloader::

   pacman -S grub efibootmgr

.. note::

   Grub会调用 ``efibootmgr`` 来操作UEFI

- 创建EFI分区挂载目录::

   mkdir /boot/efi

- 挂载ESP分区::

   mount /dev/sda1 /boot/efi

- 安装grub::

   grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

- 创建配置::

   grub-mkconfig -o /boot/grub/grub.cfg

- 注意 ``/etc/fstab`` 配置，需要修订 ``/boot/efi`` 挂载 ``/dev/sda1`` ::

   # /dev/sda2
   UUID=e5f1f419-266c-41b3-9df8-fef7fcd26f02    /           xfs         rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota  0 1
   # /dev/sda1
   UUID=5800-6B75       /boot/efi       vfat        rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2

.. note::

   这里 ``/dev/sda1`` 挂载修改为 ``/boot/efi``
   
- 修改 ``/etc/mkinitcpio.conf`` 添加 vfat 和 xfs 模块(重要步骤，确保内核启动支持vfat和xfs分区)，并且带上必要的磁盘fsck(按需要支持的分区类型添加)::

      MODULES=(vfat xfs)
      BINARIES=(fsck fsck.ext2 fsck.ext3 fsck.ext4 e2fsck fsck.vfat fsck.msdos fsck.fat fsck.xfs)

- 修改 ``HOOKS`` 段落，将 ``block`` 和 ``keyboard`` 提前到 ``autodetect`` 前面。这个措施对于在多系统启动是在早期用户空间加载需要的模块::

   #HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
   HOOKS=(base udev block keyboard autodetect modconf filesystems fsck)

- 如果U盘需要用于不同的处理器，例如intel或amd，则同时安装 ``amd-ucode`` 和 ``intel-ucode`` 软件包::

   #pacman -S amd-ucode intel-ucode
   pacman -S intel-ucode
   
- 安装fsck工具::

   pacman -S dosfstools xfsprogs

- 生成新的initramfs::

   mkinitcpio -P

安装必要软件包
================

- 为方便工作，安装以下软件包::

   pacman -S sudo screen wpa_supplicant 

- 升级系统::

   sudo pacman -Syu

网络配置
===========

这次安装的arch linux是作为服务器使用，所以只安装字符界面工具。网络配置我没有采用 :ref:`archlinux_on_thinkpad_x220` 的 netctl 工具。

:ref:`archlinux_config_ip` 提供了不同的网络配置方法，这里实践仅采用简洁的 :ref:`systemd_networkd` 完成

静态IP
==========

- 编辑 ``/etc/systemd/network/enp0s25.network`` ::

   [Match]
   Name=enp0s25

   [Network]
   Address=192.168.6.199/24
   Gateway=192.168.6.200
   DNS=192.168.6.200

- 启动服务::

   sudo systemctl enable --now systemd-networkd

.. note::

   上述配置是完成对物理主机的有线网卡静态IP地址配置，这个IP地址是内网IP地址

无线网络
===========



参考
=======

- `Install Arch Linux on a removable medium <https://wiki.archlinux.org/title/Install_Arch_Linux_on_a_removable_medium>`_
- `How to Install Arch Linux[Step by Step Guide] <https://itsfoss.com/install-arch-linux/>`_
- `archlinux Installation guide <https://wiki.archlinux.org/index.php/Installation_guide>`_
- `How to Install Arch Linux <https://www.wikihow.com/Install-Arch-Linux>`_
- `How To Setup A WiFi Network In Arch Linux Using Terminal <http://www.linuxandubuntu.com/home/how-to-setup-a-wifi-in-arch-linux-using-terminal>`_
