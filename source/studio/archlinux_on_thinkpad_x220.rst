.. _archlinux_on_thinkpad_x220:

================================
ThinkPad X220上运行Arch Linux
================================

在 :ref:`ubuntu_on_thinkpad_x220` 一段时间后，感觉还有一些不满意：主要是 :ref:`thinkpad_x220` 对Linux非常友好，能够hack BIOS释放更大性能，可玩性高，所以权衡之后，转为采用arch linux来运行底层操作系统，部署了桌面系统作为个人开发平台。

当然，Ubuntu对商业软件支持更为完善，对于生产系统，还是建议使用Ubuntu，或者更为保守稳定的RHEL。

安装
======

- 创建安装U盘::

   hdiutil convert -format UDRW -o archlinux-2019.09.01-x86_64.img archlinux-2019.09.01-x86_64.iso
   sudo dd if=archlinux-2019.09.01-x86_64.img.dmg of=/dev/rdisk3 bs=10m

- 通过U盘启动

启动后进入的是字符终端，安装方式类似Gentoo。

无线网络设置
================

.. note::

   Arch Linux安装需要网络，通常建议先通过有线网络连接Internet来完成安装过程。不过，我的工作环境没有有线，所以先设置无线网络。

- 检查网络接口名称::

   iwconfig

可以看到如下输出::

   wlp3s0   IEEE 802.11   ESSIID:off/any
            ...

- 激活无线网卡::

   ip link set wlp3s0 up

- 搜索可用的无线网络::

   iwlist wlp3s0 scan | less

- 检查兼容网卡::

   lspci -k

可以看到内核加载了无线网卡的模块

设置无线的简易方法:wifi-menu
------------------------------

Arch Linux提供了一个字符终端设置无线的交互工具 ``wifi-menu`` ，直接执行这个命令可以打开 ncurse 控制台图形界面，非常方便使用。

设置无线的复杂方法:netctl
---------------------------

- 进入 netctl 案例目录::

   cd /etc/netctl/examples
   cp /etc/netctl/examples/wireless-wep /etc/netctl/home

这里 ``home`` 是profile名字。

- 修改profile文件 ``/etc/netctl/home`` ，主要修订 Interface 和 SSID 以及密钥

- 启动无线网络连接::

   netctl start home

准备工作
============

- 更新系统时钟::

   timedatectl set-ntp true

- 磁盘分区::

   parted /dev/sda

.. note::

   - /dev/sda1 划分为 EFI系统分区，大小 260-512MB
   - /dev/sda2 根分区，大小50GB

- 格式化分区::

   mkfs.ext4 /dev/sda2

- 挂载文件系统::

   mount /dev/sda2 /mnt
   mkdir /mnt/boot
   mount /dev/sda1 /mnt/boot

安装
======

- 选择镜像网站

arch linux的镜像网站定义在 ``/etc/pacman.d/mirrorlist`` 。在这个定义文件中，越靠前的网站优先级越高，所以建议将地理位置最近的网站列到最前面。例如，在中国，可以选择163镜像网站。

- 安装基本软件包::

   pacstrap /mnt base

配置
======

- fstab

生成fstab文件(这里 ``-U`` 或 ``-L`` 定义UUID或labels)::

   genfstab -U /mnt >> /mnt/etc/fstab

- chroot

将根修改到新系统::

   arch-chroot /mnt

- 设置时区::

   ln -sf /usr/share/zoneinifo/Assia/Shanghai /etcc/localtime

运行 hwclock 生成 /etc/cadjtime ::

   hwclock --systohc

- 本地化语言支持 - 只需要UTF支持就可以，所以修改 ``/etc/locale.gen`` 保留 ``en_US.UTF-8 UTF-8`` 然后执行::

   locale-gen

创建 ``locale.conf`` 设置如下::

   LANG=en_US.UTF-8

网络配置
----------

- 创建 ``/etc/hostname`` 文件，内容是主机名::

   zcloud

- 编辑 ``/etc/hosts`` ::

   127.0.0.1    localhost
   127.0.1.1    zcloud.huatai.me  zcloud

Initramfs
-------------

通常不需要创建新的 ``initramfs`` ，因为在执行 ``pacstrap`` 命令安装linux软件包的时候已经执行过 ``mkinitcpio`` 。不过，对于LVM, 系统加密 或者 RAID ，则需要修改 ``mkinitcpio.conf`` 然后创建 initramfs 镜像::

   mkinitcpio -p linux

Root密码及用户账号
====================

- 设置root密码::

   passwd

- 设置日常账号::

   group add -g 20 staff
   useradd -g 20 -u 501 -d /home/huatai -m huatai
   passwd huatai

- 设置sudo::

   pacman -S sudo
   echo "huatai   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

安装Boot Loader
==================

.. note::

   请参考 `EFISTUB <https://wiki.archlinux.org/index.php/EFISTUB>`_ ，我这里采用了将 ESP 分区挂载到 ``/boot`` 目录，直接使用 EFISUB 就不需要安装bootloader。

   如果要使用常规的boot loader，例如GRUB，则需要将 ESP 分区挂载到 ``/efi`` 目录。

   详细请参考 `EFI system partition - Mount the partitioon <https://wiki.archlinux.org/index.php/EFI_system_partition#Mount_the_partition>`_

待实践，通常应该是::

   pacman -S grub
   grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
   grub-mkconfig -o /boot/grub/grub.cfg

由于我使用EFISTUB直接启动内核，所以不需要安装boot loader，目前这步跳过。

使用EFISTUB启动
==================

- 安装 efibootmgr ::

   pacman -S efibootmgr

参考 `EFISTUB - Using UEFI directly <https://wiki.archlinux.org/index.php/EFISTUB#Using_UEFI_directly>`_ 执行如下命令::

   efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw initrd=\initramfs-linux.img' --verbose

.. note::

   ``PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`` 设置PARTUUID参数请检查 ``ls -lh /dev/disk/by-partuuid/`` 目录下设备文件的软链接，可以找到对应磁盘 ``/dev/sda1`` 的 PARTUUID。请注意，PARTUUID和磁盘UUID不同，在 ``/etc/fstab`` 中使用的是UUID。

.. warning::

   这里存在一个问题，就是arch linux不能识别ESP分区的vfat文件系统，启动时候会报错 ``mount: /new_root: unknown filesystem type 'vfat'`` 。原因是我将VFAT的分区 ``/etc/sda1`` 作为 ``/boot`` ，但是默认安装的内核是没有带有VFAT模块。

   解决方法参考 `Minimal initramfs <https://wiki.archlinux.org/index.php/Minimal_initramfs>`_ 修改添加vfat模块以及对应的fsck工具(我这里也添加了btrfs，以便后续使用btrfs数据盘。注意需要安装对应的fsck工具) ::

      MODULES=(vfat btrfs)
      BINARIES=(fsck fsck.ext2 fsck.ext3 fsck.ext4 e2fsck fsck.vfat fsck.msdos fsck.fat fsck.btrfs)
   
   安装fsck工具::

      pacman -S dosfstools btrfs-prog

   生成新的initramfs::

      mkinitcpio -P

- 设置以后检查启动项::

   efibootmgr --verbose

- 设置启动顺序::

    efibootmgr --bootorder XXXX,XXXX --verbose

这里 ``xxxx,xxxx`` 是刚才 ``efibootmgr --verbose`` 输出的每个启动项的编号。

- 重启系统

使用exit或者ctrl-d命令chroot环境，然后 ``umount -R /mnt`` ，最后输入 ``reboot`` 命令重启系统。
   
安装必要软件包
================

- 为方便工作，安装以下软件包::

   pacman -S sudo screen wpa_supplicant \
     firefox leafpad keepassxc

.. note::

   firefox虽然没有chromium(chrome)速度快，但是相对节约资源，并且随着版本迭代，速度已经基本和chrome接近。

   KeePassX在Linux平台需要安装mono实在太沉重，所以替换成社区版本到KeePassXC，不过不能打开KeePassX的最新割舍密码库文件，所以采用先从KeePassX导出CSV文件，然后导入到KeePassXC中使用。


- 升级系统::

   sudo pacman -Syu

无线网路设置
---------------

家庭WPA无线网络
~~~~~~~~~~~~~~~~

- 同样需要配置无线网络，参见前述。

公司802.1X无线网络
~~~~~~~~~~~~~~~~~~~

参考 `Getting wired internet with 802.1X security running at install <https://bbs.archlinux.org/viewtopic.php?id=219157>`_ 

- 创建 ``/etc/netctl/office`` 配置文件，认证信息采用 wpa_supplicant ::

   Description="802.1X wireless connection"
   Interface=wlp3s0
   Connection=wireless
   
   IP=dhcp
   Auth8021X=yes
   WPAConfigFile=/etc/wpa_supplicant/wpa_supplicant-office.conf

- 创建 ``/etc/wpa_supplicant/wpa_supplicant-office.conf`` 配置文件包含认证信息::

   ctrl_interface=/var/run/wpa_supplicant
   ap_scan=0
   network={
     key_mgmt=IEEE8021X
     eap=TTLS
     identity="email address"
     password="password"
     phase2="autheao=MSCHAPV2"
   }

- 然后通过netctl启动无线网络::

   sudo netctl start office

就可以连接802.1X认证网络。

图像界面
------------

- 安装显卡驱动(虽然没有选择mesa 3D支持但是依然会安装)::

   sudo pacman -S xf86-video-intel

- 安装 xorg-server (没选安装 xorg 是为了降低软件包)::

   sudo pacman -S xorg-server
   
.. note::

   参考 `arch linux文档 - Xorg <https://wiki.archlinux.org/index.php/Xorg>`_

- 安装XFce4::

   sudo pacman -S xfce4

.. note::

   参考 `arch linux文档 - Xfce <https://wiki.archlinux.org/index.php/Xfce>`_ 设置Xfce，安装步骤可以参考 `How to Set Up the XFCE Desktop Environment on Arch Linux <https://www.maketecheasier.com/set-up-xfce-arch-linux/>`_ 和 `How to install Arch Linux with XFCE Desktop - Page 2 <https://www.howtoforge.com/tutorial/arch-linux-installation-with-xfce-desktop/2/>`_

   xfce4组合包含了基础软件包，如果还安装 ``xfce4-goodies`` 则会包含桌面组件

- 可以直接启动Xfce::

   startxfce4

- 中文设置

只需要安装一种中文字体'文泉驿'就可以正常在图形界面显示中文，并且这个字体非常小巧::

   pacman -S wqy-microhei

安装输入法fcitx(主要考虑轻量级)::

   pacman -S fcitx fcitx-sunpinyin fcitx-im

.. note::

   fcitx-im 是为了包含所有输入模块，包括 fcitx-gtk2, fcitx-gtk3, 和 fcitx-qt5

   fcitx-sunpinyin 是输入速度和输入精度较为平衡的输入法，并且轻巧

.. note::

   中文设置参考 `arch linux 文档 - Localization/Chinese <https://wiki.archlinux.org/index.php/Localization/Chinese>`_

   输入法fcitx参考 `arch linux 文档 - Fcitx (简体中文) <https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>`_

安装了fcitx之后，重新登陆Xfce桌面会自动启动fcitx。不过，此时还没有能够通过 ``ctrl+space`` 唤出中文输入法。这里建议安装 ``fcitx-configtool`` 工具，安装以后在终端运行 ``fcitx-config-gtk3`` 命令就可以打开图形界面配置。

配置方法: 对于新安装的英文系统，要取消只显示当前语言的输入法（Only Show Current Language），才能看到和添加中文输入法(Pinyin, Libpinyin等)。添加输入法之后，按下 ``ctrl+space`` 就可以正常输入中文。

- 编辑 ``~/.xinitrc`` 添加::

   exec startxfce4

这样就可以简单执行 ``startx`` 启动桌面。

- 或者更方便使用显示管理器 LightDM (不过，我感觉多占用一个系统服务也是资源，所以没有安装)::

   sudo pacman -S lightdm

.. note::

   `7 Great XFCE Themes for Linux <https://www.maketecheasier.com/xfce4-desktop-themes-linux/>`_ 介绍了不同的XFCE themes，可以选择一个喜欢的安装。

   不过，我发现默认安装的theme，选择 Apperance 中的 Adwaita-dark Style就已经非常美观简洁，除了图标比较简陋以外，其他似乎不需要再做调整。

参考
=======

- `archlinux Installation guide <https://wiki.archlinux.org/index.php/Installation_guide>`_
- `How to Install Arch Linux <https://www.wikihow.com/Install-Arch-Linux>`_
- `How To Setup A WiFi Network In Arch Linux Using Terminal <http://www.linuxandubuntu.com/home/how-to-setup-a-wifi-in-arch-linux-using-terminal>`_
