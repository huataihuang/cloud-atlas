.. _freebsd_on_intel_mac:

===============================
在苹果Intel版Mac上安装FreeBSD
===============================

我在 :ref:`mbp15_late_2013` 和 :ref:`mba11_late_2010` 上 :ref:`choose_freebsd` 实现个人开发学习环境，原因是:

- 旧版本苹果笔记本(Intel架构)硬件已经很陈旧了，无法运行最新的 :ref:`macos` ，但是能够很好支持 :ref:`linux` 和 FreeBSD，能够充分发挥硬件性能
- FreeBSD是非常独特的操作系统，在网络和存储方面有着深厚的技术积累，和Linux各有千秋

.. note::

   我之前是在 :ref:`mbp15_late_2013` 安装FreeBSD，实践中尝试先安装macOS后安装FreeBSD，希望构建双启动系统。不过，我实践时选择ZFS文件系统，结果自动抹除了macOS(失败)。

   第二次实践是在 :ref:`mba11_late_2010` 上安装单FreeBSD系统，力图构建一个轻量级图形 :ref:`mobile_work` 环境，以便我在旅途中能够继续完成工作。

FreeBSD版本
============

已知 FreeBSD 有如下版本(或阶段): ``current --> alpha（进入 stable 分支）--> beta --> rc --> release``

- alpha: alpha 是 current 进入 release 的第一步
- rc
- beta
- release
- current: current相对稳定后会推送到 stable，但是不保证二者没有大的 bug
- stable: stable 的真实意思是该分支的 ABI（Application Binary Interface，应用程序二进制接口）是稳定的(但和Linux发行版的"稳定版"概念不同，反而是一种 **不稳定** 的 "开发版" )

.. note::

   只有 alpha、rc、beta 和 release（且是一级架构）才能使用命令 ``freebsd-update`` 更新系统，其余版本系统均需要通过源代码编译的方式（或使用二进制的 pkgbase）更新系统。

   FreeBSD 开发计划准备删除命令 ``freebsd-update`` ，一律改用 ``pkgbase`` 

   参见 `FreeBSD Manual Pages freebsd-update <https://man.freebsd.org/cgi/man.cgi?freebsd-update>`_

安装准备
=========

Intel架构的Mac设备提供了一个名为 ``bootcamp`` 的工具来帮助在Mac设备上并列安装Windows操作系统，实际上这个工具也可以用来服务于Linux/FreeBSD。本质上这个工具就是将磁盘重新分区(缩小macOS占用的磁盘分区)，这样启动时只要使用Mac的 ``alt/option`` 按键就可以切换不同分区的操作系统。不过，我发现这个 ``Boot Camp Assistant``
工具实际上并不仅仅是调整分区，而是完成一连串下载Windows支持文件以及创建Windows安装盘。这个过程是强制完成，所以如果没有Windows安装镜像，这个流程无法走通。

所以，我实际上是直接使用 ``Disk Utility`` 添加一个分区，添加分区会缩小当前完整占用磁盘的 macOS 卷。这个过程是自动化的，但是非常缓慢(需要缩小macOS文件系统，过程中无法操作Mac设备)。我通过 ``Disk Utility`` 将磁盘后半部分空出 ``924GB`` 给FreeBSD，仅为macOS保留100G空间。

.. warning::

   我原本以为能够像很久以前我在MacBook上双启动并列安装macOS和Linux一样，将FreeBSD安装在macOS调整让出的磁盘分区里。但是实践是失败的，FreeBSD Installer中我选择了ZFS root，结果整个磁盘数据被抹除(原先系统中的macOS)。

.. note::

   `BSD and Linux on an Intel Mac <https://acadix.biz/freebsd-intel-mac.php>`_ 使用 rEFIt 来作为启动管理器，这个工具我之前在 :ref:`install_gentoo_on_mbp` 实践过。rEFIt是一种可选的启动管理器，可以免除启动时按 ``alt/option`` 选择启动分区的麻烦。不过，实际上不安装启动器采用 ``alt/option`` 选择启动分区也行，所以我实际跳过这步。

   `BSD and Linux on an Intel Mac <https://acadix.biz/freebsd-intel-mac.php>`_ 也提到了和我相同的经历:现在 ``bootcamp`` 确实不再支持只划分分区，而是必须实际插入Windows安装光盘，否则 ``bootcamp`` 不允许对地盘分区。原文建议当Windows开始安装时，直接强制终止安装(保留新划分出的分区)。

- 制作启动U盘，采用 :ref:`create_boot_usb_from_iso_in_mac` 制作方法:

.. literalinclude:: ../../../apple/macos/create_boot_usb_from_iso_in_mac/hdiutil_convert_iso
   :language: bash
   :caption: 使用hdiutil转换iso文件到镜像文件dmg

.. literalinclude:: ../../../apple/macos/create_boot_usb_from_iso_in_mac/dd_img
   :language: bash
   :caption: 使用dd命令将img文件写入U盘

- 如果下载的是 ``mini-memstick.img`` 则使用如下命令:

.. literalinclude:: freebsd_on_intel_mac/dd_img
   :language: bash
   :caption: 最小化安装镜像

.. note::

   如果可以还是下载完整版本镜像，因为最小化镜像虽然下载快，但是安装过程所有内容都需要从网上下载，导致安装非常花时间。

安装
=====

重新启动MacBook Pro设备，启动时按住 ``alt/option`` 键，这样就能选择启动磁盘。选择FreeBSD安装启动U盘启动，进行安装。

- 之前我是使用macOS划分了一个磁盘分区给FreeBSD，但是macOS划分的磁盘默认格式化成APFS，也就是说虽然分区有了，但是只是我知道有，而FreeBSD Installer看来整个磁盘没有任何空闲。此时FreeBSD Installer的 ``Guided Root-on-ZFS`` 选择 ``nvd0`` (NVMe磁盘)会提示报错 ``gpart: geom 'nvd0': File existes``

- 我发现我不熟悉FreeBSD默认的 ``gpart`` 工具，所以改为用 :ref:`arch_linux` 的启动U盘，借助Linux的 ``fdisk`` 工具删除掉macOS上空出的分区(即完全使得一部分磁盘空白)。此时再次从FreeBSD安装U盘启动，就可以正常运行Installer的 ``Guided Root-on-ZFS`` 设置。但是很不幸，Installer的 ``Guided Root-on-ZFS`` 设置会整个将磁盘数据抹去(也就是Installer首先确认磁盘有空间，有空间就可以运行 ``Guided Root-on-ZFS`` 设置，然而 ``Root-on-ZFS`` 设置是占据整个磁盘)

在ZFS自动部署中，能够自动完成ZFS的RAID构建根文件系统 ``zroot`` 存储池，非常自动化非常方便

.. literalinclude:: freebsd_on_intel_mac/zroot
   :caption: :ref:`mba11_late_2010` 上的 ``zroot`` 存储池磁盘分布

并且由于FreeBSD内置支持 :ref:`zfs` ，还可以在安装过程中组建 ``ZRAID`` ，例如以下案例是我在自己组建的工作站上使用4块 :ref:`kioxia_exceria_g2` ( ``2TB`` )构建 ``ZRAID1`` ，能够在保证系统数据冗余安全情况下获得 ``5.2TB`` 使用空间:

.. literalinclude:: freebsd_on_intel_mac/zroot_raidz
   :caption: 安装过程中使用4块磁盘构建RAIDZ

- 安装过程没有什么特别，就是最小化安装，然后重启。重启以后可以看到 :ref:`mbp15_late_2013` 上的WiFi是无法识别的，这是因为Broadcom无线驱动私有化，不能包含在FreeBSD安装中。需要 :ref:`freebsd_wifi` 设置，在没有设置无线网络之前，可以使用一个USB以太网卡连接一台Linux主机，并执行 :ref:`iptables_masquerade` 来提供互联网访问，以便进一步设置FreeBSD(配置 :ref:`freebsd_static_ip` )

默认安装选择的安装组件推荐:

- 在默认基础上，额外选择 ``src`` 即可，因为驱动需要内核源代码编译安装
- 不要选择 ``kernel-dbg`` 、 ``lib32`` 、 ``src`` 以外的组件，这3个组件外的其他程序都需要联网安装，非常缓慢。其他软件包可以在操作系统安装完成后安装
- 我的安装取消了 ``lib32`` 是因为我想构建一个完全64位系统

问题记录
==========

我在 :ref:`mba11_late_2010` 遇到一个问题，键盘使用存在断断续续的问题，我不确定是不是我更换的第三方键盘硬件问题还是FreeBSD的兼容问题，系统日志显示:

.. literalinclude:: freebsd_on_intel_mac/dmesg_keyboard
   :caption: 系统日志中关于键盘的报错

参考
======

- `Apple MacBook support on FreeBSD <https://wiki.freebsd.org/AppleMacbook>`_
- `Apple Intel Mac mini support on FreeBSD <https://wiki.freebsd.org/IntelMacMini>`_
- `FreeBSD on a MacBook Pro <https://gist.github.com/mpasternacki/974e29d1e3865e940c53>`_
- `BSD and Linux on an Intel Mac <https://acadix.biz/freebsd-intel-mac.php>`_
- `FREEBSD, MAC MINI AND ZFS <https://www.codeimmersives.com/tech-talk/freebsd-mac-mini-and-zfs/>`_
- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_ 提供了完整的安装步骤截图，并且介绍 :ref:`linuxulator`
- `FreeBSD中文社区「FreeBSD 从入门到跑路」: 第 2.1 节 FreeBSD 安装图解 <https://book.bsdcn.org/di-2-zhang-an-zhuang-freebsd/di-2.1-jie-tu-jie-an-zhuang>`_ 非常清晰的入门教程
