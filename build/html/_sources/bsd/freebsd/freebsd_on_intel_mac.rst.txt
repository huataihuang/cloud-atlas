.. _freebsd_on_intel_mac:

===============================
在苹果Intel版Mac上安装FreeBSD
===============================

我在 :ref:`mbp15_late_2013` :ref:`choose_freebsd` 实现个人开发学习环境，原因是旧版本苹果笔记本(Intel架构)能够很好支持不同操作系统，包括BSD。

安装准备
=========

Intel架构的Mac设备提供了一个名为 ``bootcamp`` 的工具来帮助在Mac设备上并列安装Windows操作系统，实际上这个工具也可以用来服务于Linux/FreeBSD。本质上这个工具就是将磁盘重新分区(缩小macOS占用的磁盘分区)，这样启动时只要使用Mac的 ``alt/option`` 按键就可以切换不同分区的操作系统。不过，我发现这个 ``Boot Camp Assistant``
工具实际上并不仅仅是调整分区，而是完成一连串下载Windows支持文件以及创建Windows安装盘。这个过程是强制完成，所以如果没有Windows安装镜像，这个流程无法走通。

所以，我实际上是直接使用 ``Disk Utility`` 添加一个分区，添加分区会缩小当前完整占用磁盘的 macOS 卷。这个过程是自动化的，但是非常缓慢(需要缩小macOS文件系统，过程中无法操作Mac设备)。我通过 ``Disk Utility`` 将磁盘后半部分空出 ``924GB`` 给FreeBSD，仅为macOS保留100G空间。

.. warning::

   我原本以为能够像很久以前我在MacBook上双启动并列安装macOS和Linux一样，将FreeBSD安装在macOS调整让出的磁盘分区里。但是实践是失败的，FreeBSD Installer中我选择了ZFS root，结果整个磁盘数据被抹除(原先系统中的macOS)。

.. note::

   `BSD and Linux on an Intel Mac <https://acadix.biz/freebsd-intel-mac.php>`_ 使用 rEFIt 来作为启动管理器，这个工具我之前在 `install_gentoo_on_mbp` 实践过。rEFIt是一种可选的启动管理器，可以免除启动时按 ``alt/option`` 选择启动分区的麻烦。不过，实际上不安装启动器采用 ``alt/option`` 选择启动分区也行，所以我实际跳过这步。

   `BSD and Linux on an Intel Mac <https://acadix.biz/freebsd-intel-mac.php>`_ 也提到了和我相同的经历:现在 ``bootcamp`` 确实不再支持只划分分区，而是必须实际插入Windows安装光盘，否则 ``bootcamp`` 不允许对地盘分区。原文建议当Windows开始安装时，直接强制终止安装(保留新划分出的分区)。

- 制作启动U盘，采用 :ref:`create_boot_usb_from_iso_in_mac` 制作方法:

.. literalinclude:: ../../apple/macos/create_boot_usb_from_iso_in_mac/hdiutil_convert_iso
   :language: bash
   :caption: 使用hdiutil转换iso文件到镜像文件dmg

.. literalinclude:: ../../apple/macos/create_boot_usb_from_iso_in_mac/dd_img
   :language: bash
   :caption: 使用dd命令将img文件写入U盘

安装
=====

重新启动MacBook Pro设备，启动时按住 ``alt/option`` 键，这样就能选择启动磁盘。选择FreeBSD安装启动U盘启动，进行安装。

- 之前我是使用macOS划分了一个磁盘分区给FreeBSD，但是macOS划分的磁盘默认格式化成APFS，也就是说虽然分区有了，但是只是我知道有，而FreeBSD Installer看来整个磁盘没有任何空闲。此时FreeBSD Installer的ZFS root选择 ``nvd0`` (NVMe磁盘)会提示报错 ``gpart: geom 'nvd0': File existes``

- 我发现我不熟悉FreeBSD默认的 ``gpart`` 工具，所以改为用 :ref:`arch_linux` 的启动U盘，借助Linux的 ``fdisk`` 工具删除掉macOS上空出的分区(即完全使得一部分磁盘空白)。此时再次从FreeBSD安装U盘启动，就可以正常运行Installer的ZFS root设置。但是很不幸，Installer的ZFS root设置会整个将磁盘数据抹去(也就是Installer首先确认磁盘有空间，有空间就可以运行ZFS root设置，然而ZFS root设置是占据整个磁盘)

- 安装过程没有什么特别，就是最小化安装，然后重启。重启以后可以看到 :ref:`mbp15_late_2013` 上的WiFi是无法识别的，这是因为Broadcom无线驱动私有化，不能包含在FreeBSD安装中。需要 :ref:`freebsd_wifi` 设置，在没有设置无线网络之前，可以使用一个USB以太网卡连接一台Linux主机，并执行 :ref:`iptables_masquerade` 来提供互联网访问，以便进一步设置FreeBSD(配置 :ref:`freebsd_static_ip` )


参考
======

- `Apple MacBook support on FreeBSD <https://wiki.freebsd.org/AppleMacbook>`_
- `Apple Intel Mac mini support on FreeBSD <https://wiki.freebsd.org/IntelMacMini>`_
- `FreeBSD on a MacBook Pro <https://gist.github.com/mpasternacki/974e29d1e3865e940c53>`_
- `BSD and Linux on an Intel Mac <https://acadix.biz/freebsd-intel-mac.php>`_
- `FREEBSD, MAC MINI AND ZFS <https://www.codeimmersives.com/tech-talk/freebsd-mac-mini-and-zfs/>`_
