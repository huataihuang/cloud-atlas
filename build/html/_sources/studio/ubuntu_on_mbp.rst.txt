.. _ubuntu_on_mbp:

===========================
MacBook Pro上运行Ubuntu
===========================

安装
=========

现代的Linux操作系统桌面实际上已经非常完善，对于硬件的支持也非常好，除了由于Licence限制无法直接加入私有软件需要特别处理，几乎可以平滑运行在常用的电脑设备上。当然，对于MacBook Pro支持也非常完善。

安装提示：

- MacBook Pro/Air使用了UEFI（取代了传统的BIOS），这要求硬盘上必须有一个FAT32分区，标记为EFI分区

在Ubuntu安装过程中，磁盘分区中需要先划分200M的primary分区，标记为EFI分区。这步骤必须执行，否则安装后MacBook Pro无法从没有EFI分区的磁盘启动。

- Ubuntu操作系统 ``/`` 分区需要采用 ``Ext4`` 文件系统，实践发现和Fedora不同，采用 Btrfs 作为根文件系统（ 特别配置了 ``XFS`` 的 ``/boot`` 分区）无法启动Ubuntu。

- 最小化安装Ubuntu Budgie

最小化安装Ubuntu Budgie实际上只安装了Desktop的基础部分，以及安装了一个Firefox浏览器。

最小化安装对于运行云计算平台OpenStack，以及兼顾一些日常工作已经足够。没有必要完整安装大量的应用软件。

- 可选的安装包::

   sudo apt install screen openssh-server nmon net-tools

驱动安装
===========

Ubuntu默认没有安装激活MacBook Pro的BCM 43xx网卡驱动，这导致安装以后无法连接网络。解决的方法是通过将LiveCD镜像挂载并作为APT的软件仓库源，就可以直接安装 ``Broadcom STA无线驱动（私有）``::

   mkdir /media/cdrom
   mount -t iso9660 -o loop ~/ubuntu-budgie-18.10-desktop-amd64.iso /media/cdrom
   apt-cdrom -m -d /media/cdrom add

   sudo apt-get update
   sudo apt-get --reinstall install bcmwl-kernel-source

.. note::

   详细请参考 `Ubuntu在MacBook Pro上WIFI <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/ubuntu/install/ubuntu_on_macbook_pro_with_wifi.md>`_

针对MacBook Pro的调整(可选)
==============================

Ubuntu Budgie可以在MacBook Pro上非常顺畅运行，不过，针对MacBook Pro硬件（Retina屏幕）有一些调整建议：

- 默认安装采用了整体放到200%方式（ ``Perferences > Displays > Scale`` ）来避免Retian屏幕字体过小的问题，这种设置对眼睛确实比较舒适，不过也带来了可视内容减少的问题。我改为 100% ，即原始屏幕分辨率。此时字体会过小，但是窗口（包括Titlle等）会比较合适
- 默认Budgie Theme是 ``Pocillo`` ，是浅色菜单，由于现在比较倾向于Dark模式来保护视力，所以选择安装 ``Arc Design`` 黑暗模式Theme （ ``System Tools > Budgie Themes > Arc Design`` ）
- 默认字体在100%的scale模式下会显示过小，所以调整字体（ ``System Tools > Budgie Desktop Settings > Fonts`` ）

  - Monospace - Ubuntu Mono Regular 13 调整为 16
  - Interface - Ubuntu Regular 11 调整为 13
  - Documents - Sans Regular 11 调整为 13
  - Window Titles - Ubuntu Bold 11 调整为 13
