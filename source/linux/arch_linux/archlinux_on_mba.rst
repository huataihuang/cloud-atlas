.. _archlinux_on_mba:

==============================
MacBook Air上运行Arch Linux
==============================

为了能够 :ref:`lfs_mba` ，我采用先在 :ref:`mba11_late_2010` 完成精简的 Arch Linux，以便能够温习 :ref:`arch_linux` 的运维。本次实践在原先 :ref:`archlinux_on_mbp` 和 :ref:`archlinux_on_thinkpad_x220` 综合改进，并参考最新 `archlinux Installation guide <https://wiki.archlinux.org/index.php/Installation_guide>`_

下载 arch linux iso 和制作启动U盘
===================================

- 从 `Arch Liux Downloads <https://archlinux.org/download/>`_ 页面找到合适的下载，我当前使用的是 ``archlinux-2024.09.01-x86_64.iso``

.. literalinclude:: archlinux_on_mba/sha256
   :caption: 对下载iso检查 sha256sum

- macOS平台制作启动U盘，执行如下命令创建安装U盘:

.. literalinclude:: archlinux_on_mba/udisk
   :caption: 在macOS平台执行iso转换并创建启动U盘

按住 ``option(alt)`` 键启动 :ref:`mba11_late_2010` ，即从U盘启动安装

网络连接
==========

.. note::

   安装步骤和 :ref:`archlinux_on_mbp` / :ref:`archlinux_on_thinkpad_x220` 类似，实践中罗帷调整

   Arch Linux安装需要网络，通常建议先通过有线网络连接Internet来完成安装过程

:ref:`mba11_late_2010` 无线网卡兼容性较好，能够直接被 Arch Linux 安装识别，通过 :ref:`wpa_supplicant` 简单命令就能够启动无线:

.. literalinclude:: archlinux_on_mba/wifi
   :language: bash
   :caption: 简单配置wifi

如果没有无线，则将电脑通过有线连接，启动 ``dhcpcd`` 获取有线网络动态分配地址(或静态配置)

然后就可以通过 :ref:`ssh` 访问arch linux安装的主机(需要先设置 ``root`` 密码以便能够远程登陆)

磁盘分区
===========

.. csv-table:: UEFI with GPT磁盘分区
   :file: archlinux_on_mba/partition.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

使用 :ref:`parted` 划分分区:

.. literalinclude:: archlinux_on_mba/parted
   :language: bash
   :caption: 划分磁盘

最后执行 ``parted /dev/sda print`` 输入如下

.. literalinclude:: archlinux_on_mba/parted_print
   :caption: ``parted`` 显示分区
   :emphasize-lines: 8-11

挂载文件系统
===============

``root`` 卷需要挂载到 ``/mnt`` ，其他分区需要依次挂载到这个 ``/mnt`` 下子目录:

.. literalinclude:: archlinux_on_mba/mount
   :language: bash
   :caption: 挂载分区

.. note::

   参考 `EFI_system_partition#Typical_mount_points <https://wiki.archlinux.org/title/EFI_system_partition#Typical_mount_points>`_ :

   - ``/efi`` 独立挂载目录现在推荐使用，替代了长期使用的 ``/boot/efi``
   - 在使用 :ref:`parted` 为EFI分区创建时已经命名分区为 ``ESP`` ，这个名字在后续 ``grub`` 设置时会使用到

安装
=======

- 为加快文件下载，修订 ``/etc/pacman.d/mirrorlist`` ，添加163镜像网站到第一行(越靠前优先级越高):

.. literalinclude:: archlinux_on_mba/mirrorlist
   :caption: 在 ``/etc/pacman.d/mirrorlist`` 添加163的镜像网站，加速文件下载

- 安装基本软件:

.. literalinclude:: archlinux_on_mba/pacstrap
   :caption: 安装基础软件包，Linux内核和firmware

配置
=======

- 生成fstab文件(这里 ``-U`` 或 ``-L`` 定义UUID或labels):

.. literalinclude:: archlinux_on_mba/fstab
   :caption: 生成fstab文件

此时检查 fstab 内容如下:

.. literalinclude:: archlinux_on_mba/fstab_output
   :caption: 生成fstab文件内容检查
   :emphasize-lines: 6,9,12,15

- chroot 将根修改到新系统:

.. literalinclude:: archlinux_on_mba/chroot
   :language: bash
   :caption: chroot进入安装的arch linux系统

- 设置时区:

.. literalinclude:: archlinux_on_mba/timezone
   :language: bash
   :caption: 设置上海时区

- 运行 hwclock 生成 /etc/cadjtime :

.. literalinclude:: archlinux_on_mba/hwclock
   :language: bash
   :caption: 同步校正时间到硬件时钟

- 本地化语言支持 - 只需要UTF支持就可以，所以修改 ``/etc/locale.gen`` 保留 ``en_US.UTF-8 UTF-8`` 然后执行:

.. literalinclude:: archlinux_on_mba/local-gen
   :language: bash
   :caption: 本地化语言支持 UTF

- 创建 ``locale.conf`` 设置如下:

.. literalinclude:: archlinux_on_mba/locale.conf
   :language: bash
   :caption: ``/etc/locale.conf`` 配置

- 创建 ``/etc/hostname`` 文件，内容是主机名:

.. literalinclude:: archlinux_on_mba/hostname
   :caption: ``/etc/hostname`` 配置主机名

- 编辑 ``/etc/hosts`` :

.. literalinclude:: archlinux_on_mba/hosts
   :caption: ``/etc/hosts`` 配置基本主机名解析
   :emphasize-lines: 4,5

- **Initramfs** : 通常不需要创建新的 ``initramfs`` (修订 ``/etc/mkinitcpio.conf`` )，因为在执行 ``pacstrap`` 命令安装linux软件包的时候已经执行过 ``mkinitcpio`` 。不过，对于LVM, 系统加密 或者 RAID ，则需要修改 ``mkinitcpio.conf`` 然后创建 initramfs 镜像

.. literalinclude:: archlinux_on_mba/mkinitcpio
   :language: bash
   :caption: 修订 ``/etc/mkinitcpio.conf`` 后执行 ``mkinitcpio`` 生成定制的 **Initramfs**

- 设置root密码:

.. literalinclude:: archlinux_on_mba/passwd
   :language: bash
   :caption: 设置root密码

- 创建日常账号( ``admin`` )并设置sudo:

.. literalinclude:: archlinux_on_mba/admin_sudo
   :language: bash
   :caption: 设置admin账号并设置sudo

- 安装Boot Loader (参考 :ref:`gentoo_grub` )

.. literalinclude:: archlinux_on_mba/grub
   :language: bash
   :caption: 安装和设置grub

如果一切正常， ``grub-install`` 执行输出如下:

.. literalinclude:: archlinux_on_mba/grub-install_output
   :caption: ``grub-install`` 执行输出信息

注意，如果没有安装 ``efibootmgr`` 会出现如下报错:

.. literalinclude:: archlinux_on_mba/grub-install_efibootmgr_err_output
   :caption: ``grub-install`` 执行输出显示没有安装 ``efibootmgr`` 错误
   :emphasize-lines: 2

如果一切正常， ``grub-mkconfig`` 执行输出如下:

.. literalinclude:: archlinux_on_mba/grub-mkconfig_output
   :caption: ``grub-mkconfig`` 执行输出信息

这里提示 ``os-prober`` 没有激活配置，所以不会添加其他可启动分区的操作系统入口配置

.. note::

   由于安全原因， ``os-prober`` 默认禁用。在 ``/etc/default/grub`` 配置中添加 ``GRUB_DISABLE_OS_PROBER=false`` 来激活

- 安装必要软件:

.. literalinclude:: archlinux_init/archlinux_init_devops
   :language: bash
   :caption: 安装运维管理工具

- 配置无线网络(这里无线网卡识别为 ``wlp1s0b1`` ，所以下面配置方法中，需要将 ``wlan0`` 替换为 ``wlp1s0b1`` ，其他一致):

.. literalinclude:: archlinux_wpa_supplicant/wpa_passphrase
   :language: bash
   :caption: 创建对应无线网卡的 ``/etc/wpa_supplicant/wpa_supplicant-<无线网卡名>.conf``

.. literalinclude:: archlinux_wpa_supplicant/systemctl_enable_wpa_passphrase_dhcpcd
   :language: bash
   :caption: 激活对应无线网卡的 ``wpa_supplicant`` 服务，并激活 ``dhcpcd`` (DHCP客户端)

- 设置必要启动的服务:

.. literalinclude:: archlinux_on_mba/systemd_service
   :caption: 设置必要启动服务

参考
=========

- `archlinux Installation guide <https://wiki.archlinux.org/index.php/Installation_guide>`_
- `USB flash installation medium <https://wiki.archlinux.org/title/USB_flash_installation_medium>`_
