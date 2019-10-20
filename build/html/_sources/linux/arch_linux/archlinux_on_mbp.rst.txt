.. _archlinux_on_mbp:

==============================
MacBook Pro上运行Arch Linux
==============================

安装
=========

MacBook Pro上先安装macOS，然后调整磁盘，空出空间给Arch Linux安装。安装完成后，实现双启动。

.. note::

   Mac设备的Firemware update依赖macOS的系统更新，所以如果完全铲除了macOS系统只保留Linux，则无法更新firmware。我保留了128G空间给macOS一方面能够及时更新firmware，另一方面也能够随时切换回macOS系统做iOS/macOS开发。

安装macOS
-------------

- 重命名U盘:

可以使用Disk Utility工具将U盘格式化成一个命名为`CatalinaInstaller`的U盘符

- 输入以下命令创建macOS安装U盘::

   sudo /Applications/Install\ macOS\ Catalina.app/Contents/Resources/createinstallmedia --volume /Volumes/CatalinaInstaller --nointeraction

- macOS安装非常直观，只需要插入U盘，按住command键，然后按电源键启动，就可以选择从U盘启动，然后格式化磁盘，将mcaOS安装到MacBook Pro上。

macOS分区调整
~~~~~~~~~~~~~~~~

默认安装的macOS会占据整个磁盘，为了能够安装Linux，我们需要收缩macOS分区。使用的工具就是macOS的Disk Utilities。

- 添加新的分区

.. figure:: ../../_static/linux/arch_linux/diskutil_partition.png
   :scale: 90

注意一定要添加分区，不能添加卷。添加卷实际上是macOS APFS文件系统内部的子卷，只有添加分区才能收缩现有的macOS所在分区。

.. figure:: ../../_static/linux/arch_linux/diskutil_partition_1.png
   :scale: 90

- 点击 ``+`` 按钮添加一个分区，然后按住以下截图中饼图上箭头所指的调整分区的圆点旋转调整两个分区的大小。例如，我调整Linux分区到400G，保留Mac分区100G。

.. figure:: ../../_static/linux/arch_linux/diskutil_partition_2.png
   :scale: 90

新创建的分区格式可以任选，反正安装Linux时候还会删除重新创建。

安装U盘制作
--------------

如果是macOS平台制作启动U盘，则执行如下命令创建安装U盘::

   hdiutil convert -format UDRW -o archlinux-2019.10.01-x86_64.img archlinux-2019.10.01-x86_64.iso
   sudo dd if=archlinux-2019.10.01-x86_64.img.dmg of=/dev/rdisk3 bs=10m

如果是Linux平台制作启动U盘，则执行如下命令创建安装U盘::

   sudo dd if=archlinux-2019.10.01-x86_64.img.dmg of=/dev/sdb bs=10M

安装arch linux
=================

在MacBook Pro上安装arch linux遇到的第一个问题是无线网卡无法识别。类似 :ref:`ubuntu_on_mbp` 由于Broadcom的授权限制，发行版不能携带Broadcom BCM4360 802.11ac无线网卡设备驱动。

解决方法是先采用USB网卡连接Internet，先完成操作系统安装，然后再安装 ``broadcom-wl-dkms`` 软件包来支持无线网卡。

- 更新时钟::

   timedatectl set-ntp true

- 磁盘分区::

   parted -a optimal /dev/sda

此时 ``print`` 显示分区还是之前在macOS下划分的分区::

   Model: ATA APPLE SSD SM0512 (scsi)
   Disk /dev/sda: 500GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags: 
   
   Number  Start   End    Size   File system  Name                  Flags
    1      20.5kB  210MB  210MB  fat32        EFI System Partition  boot, esp
    2      210MB   100GB  100GB
    3      100GB   500GB  400GB                                     msftdata

删除分区3::

   rm 3

重新创建分区3，分区大小50GB::

   mkpart primary ext4 100GB 150GB
   name 3 arch_linux

- 格式化文件系统::

   mkfs.ext4 /dev/sda3

- 挂载文件系统::

   mount /dev/sda3 /mnt
   mkdir /mnt/boot
   mount /dev/sda1 /mnt/boot

- 选择镜像网站

arch linux的镜像网站定义在 ``/etc/pacman.d/mirrorlist`` 。在这个定义文件中，越靠前的网站优先级越高，所以建议将地理位置最近的网站列到最前面。例如，在中国，可以选择163镜像网站。

- 安装基本软件包::

   pacstrap /mnt base linux linux-firmware

配制
======

- fstab: 生成fstab文件(这里 ``-U`` 或 ``-L`` 定义UUID或labels)::

   genfstab -U /mnt >> /mnt/etc/fstab

- chroot: 将根修改到新系统::

   arch-chroot /mnt

- 设置时区::

   ln -sf /usr/share/zoneinifo/Asia/Shanghai /etc/localtime

运行 ``hwclock`` 生成 ``/etc/cadjtime`` ::

   hwclock --systohc

- 本地化语言支持 - 只需要UTF支持就可以，所以修改 ``/etc/locale.gen`` 保留 ``en_US.UTF-8 UTF-8`` 然后执行::

   locale-gen

创建 ``locale.conf`` 设置如下::

   LANG=en_US.UTF-8

- 创建 ``/etc/hostname`` 内容是主机名::

   xcloud

- 编辑 ``/etc/hosts`` ::

   127.0.0.1    localhost
   127.0.1.1    xcloud.huatai.me  xcloud

- 设置root密码::

   passwd

- 设置日常帐号::

   groupadd -g 20 staff
   useradd -g 20 -u 501 -d /home/huatai -m huatai
   passwd huatai

- 设置sudo::

   pacman -S sudo
   echo "huatai   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

- 之前在 :ref:`archlinux_on_thinkpad_x220` 遇到默认内核没有加载Vfat模块导致无法读取EFI分区,编辑 ``/etc/mkinitcpio.conf`` ::

   MODULES=(vfat xfs)
   BINARIES=(fsck fsck.ext2 fsck.ext3 fsck.ext4 e2fsck fsck.vfat fsck.msdos fsck.fat fsck.xfs xfs_repair)

然后安装软件包::

   pacman -S dosfstools xfsprogs

再重新生成initramfs::

   mkinitcpio -P

安装必要软件包
---------------

- 使用pacman安装必要软件包::

   pacman -S vim which

UEFI启动
=============

在EFI系统中，实际上并不需要安装Grub这样的启动管理系统就可以启动Linux，只需要在EFI中设置启动顺序。

- 安装 efibootmgr ::
 
   pacman -S efibootmgr

参考 `EFISTUB - Using UEFI directly <https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly>`_ 执行如下命令::

   efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw initrd=\initramfs-linux.img' --verbose

.. note::

   ``PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`` 设置PARTUUID参数请检查 ``ls -lh /dev/disk/by-partuuid/`` 目录下设备文件的软链接，可以找到对应磁盘 ``/dev/sda1`` 的 PARTUUID。请注意，PARTUUID和磁盘UUID不同，在 ``/etc/fstab`` 中使用的是UUID。

.. warning::

   默认安装的arch linux内核不支持vfat文件系统，而EFI分区就是vfat，所以在前面重新构建initfs，将vfat支持加入。这个步骤非常重要，否则系统启动时会报错 ``mount: /new_root: unknown filesystem type 'vfat'`` 。

- 设置启动顺序::

    efibootmgr --bootorder XXXX,XXXX --verbose

这里 ``xxxx,xxxx`` 是刚才 ``efibootmgr --verbose`` 输出的每个启动项的编号。

.. note::

   现在重启操作系统，则立即进入Arch Linux系统。那么如何启动macOS呢？

   Mac硬件系统有一个 ``option`` 键提供了EFI启动选择，在按下电源键同时安装 ``option`` 键，就会出现启动操作系统的选项。不过Mac的 ``option`` 键启动看不到Linux分区，所以这里只能作为重新启动macOS的方法。

   以上就可以满足macOS和Arch Linux的双启动设置需求。

Nvidia显卡
=============

我的笔记本MacBook 是 2013年底版本，属于 MacBook Pro 11,x 系列。从 ``dmidecode`` 可以看到::

   System Information
        Manufacturer: Apple Inc.
        Product Name: MacBookPro11,3

- 检查显卡::

   lspci -k | grep -A 2 -E "(VGA|3D)"

输出::

   01:00.0 VGA compatible controller: NVIDIA Corporation GK107M [GeForce GT 750M Mac Edition] (rev a1)
    Subsystem: Apple Inc. GK107M [GeForce GT 750M Mac Edition]
        Kernel driver in use: nouveau

当前是开源驱动 ``nouveau`` ，性能较差。

对于 GeForce 600-900 以及 Quadro/Tesla/Tegra K系列显卡，或者更新的显卡(2010-2019年)，安装 ``nvidia`` 或 ``nvidia-lts`` 驱动包::

   sudo pacman -S nvidia

安装完成后需要重启系统，因为 ``nvidia`` 软件包包含屏蔽 ``nouveau`` 模块配置，所以需要重启。

屏幕亮度
========

对于 :ref:`archlinux_on_thinkpad_x220` 是默认就可以通过屏幕亮度调节键直接调整亮度，这个屏幕亮度值是通过设置 ``/sys/class/backlight/gmux_backlight/brightness`` 来调整的。不过，对于Nvidia显卡，直接调整这个值不生效，需要以 ``root`` 身份执行以下命令::

   setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0

然后调整就能够生效。

通过 :ref:`archlinux_aur` 安装 ``gmux_backlight`` 软件包之后，就可以以普通用户身份调整屏幕亮度，即修改 ``/sys/class/backlight/gmux_backlight/brightness`` 。

Suspend
=============

从 Linux Kernel 3.13 开始支持 Suspend(内核 3.12 从suspend唤醒时屏幕没有背光，只能使用 hibernate)，但是需要禁止USB唤醒功能，否则会导致suspend之后立即又恢复工作。执行以下命令将 ``XHC1`` 设置到 ``/proc/acpi/wakeup`` 就可以关闭::

   echo XHC1 | sudo tee /proc/acpi/wakeup

这个内核proc在设置之后， ``cat /proc/acpi/wakeup`` 输出::

   DeviceS-state  Status   Sysfs node       
   ...
   XHC1  S3*disabled  pci:0000:00:14.0      
   ...

.. note::

   不过，依然需要关闭蓝牙鼠标连接，否则鼠标移动还是唤醒系统。但至少不再无法suspend了。

参考
========

- `Arch Linux社区文档 - MacBookPro11,x <https://wiki.archlinux.org/index.php/MacBookPro11,x>`_
- `Arch Linux社区文档 - NVIDIA <https://wiki.archlinux.org/index.php/NVIDIA>`_
