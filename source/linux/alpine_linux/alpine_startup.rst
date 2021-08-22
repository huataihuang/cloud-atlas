.. _alpine_startup:

============================
Alpine Linux快速起步
============================

安装Alpine
=============

从 `Alpine Linux <https://alpinelinux.org/>`_ 官方网站可以下载不同目标的安装镜像，都非常小巧:

- standard: 标准版， ``x86_64`` iso镜像大约145MB，作为通用的版本，适合大多数情况，我主要用这个版本安装到MacBookPro 2013 later版本笔记本上，将运行简易桌面以及作为虚拟化和容器化运行平台
- extended: 扩展版， 包含常用软件，适合路由器和服务器。这个版本是完全在内存中运行，只提供 x86 和 x86_64 版本
- netboot: 只提供内核,initramfs，网络启动进行安装
- raspberry pi: 针对 :ref:`raspberry_pi` 优化版本，提供了32位和64位
- generic ARM: 通用ARM内核以及uboot bootlader，支持armv7和aarch64
- mini root filesystem: 用于容器和minimal chroot
- virtual: 类似标准版，但是内核做了精简，针对虚拟化系统优化
- xen: 内建了Xen Hypervisor，以及用于Xen的软件包，用于Xen Dom0

我比较感兴趣是:

- ``extended`` 版本: 尝试仅使用USB就能启动服务器，实现优化性能部署，通过挂载本地内置磁盘来实现服务器功能
- ``raspberry pi`` 版本: 尝试在树莓派上构建一个轻量级系统
- ``virtual`` 版本: 虚拟化guest操作系统，已经针对虚拟化做了内核裁剪

extended版本安装和体验
========================

- 下载 ``alpine-extended-3.14.1-x86_64.iso`` ，使用以下命令dump到U盘(macOS平台执行)::

   sudo dd if=alpine-extended-3.14.1-x86_64.iso of=/dev/rdisk2 bs=100m

如果是Linux平台执行::

   sudo dd if=alpine-extended-3.14.1-x86_64.iso of=/dev/sdb bs=100M

- 插入MacBook Pro，按住 ``option`` 键同时按电源键，则选择从U盘启动，启动后直接进入字符界面(启动速度极快)

alpine linux启动极快，并且extended版本是直接从U盘启动，操作系统完全加载到RAM中运行，所以可以避免U盘存储读写慢的问题。

- 默认 ``root`` 用户账号登陆，没有密码。提示信息::

   You can setup the system with the command: setup-alpine

.. note::

   很不幸，MacBook Pro内置无线网卡默认不能识别，所以最好先使用USB有线网卡连接网络，进行初始设置，否则非常麻烦。

standard版本安装和体验
==========================

- 下载 ``alpine-standard-3.14.1-x86_64.iso`` ，使用以下命令dump到U盘(macOS平台执行)::

   sudo dd if=alpine-standard-3.14.1-x86_64.iso of=/dev/rdisk2 bs=100m

- 插入MacBook Pro，按住 ``option`` 键同时按电源键，则选择从U盘启动，启动后直接进入字符界面

同样，没有任何密码，直接输入 ``root`` 账号名登陆

- 执行以下命令配置和初始化Alpine Linux系统::

   setup-alpine

- alpine linux有3种启动模式:

  - ``diskless`` 无盘模式就是只在U盘运行
  - ``data`` 和无盘模式相似也是在内存运行，但是会挂载本地磁盘到 ``/var`` 目录下，提供日志，邮件数据库等存储
  - ``sys`` 传统的安装到硬盘模式

setup-alpine交互命令安装
--------------------------

- ``keyboard layout`` 直接选择 ``us`` 和 ``us``
- ``hostname`` 设置 ``alpine`` (后续可以再修改)
- ``network`` 初始化就是 ``eth0`` (必须使用可以识别度有线网卡，我的MBP使用苹果USB网卡识别为 ``eth0`` )
- ``DHCP`` 获得网络配置
- ``timezone`` 设置为 ``Aisa/Shanghai``
- ``proxy`` 设置为默认的 ``none``
- ``ssh server`` 选择 ``openssh``
- ``ntp client`` 设置为 ``chrony``

然后就开始抹盘安装，可以选择 ``sys`` 采用传统分区安装，也可以选择 ``lvm`` 设置卷管理。我目前选择 ``sys`` ，之后我准备做分区调整，改为使用 :ref:`btrfs`

standard版本体验
------------------

- 默认安装只有字符界面
- 使用空间极小::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                       7.8G         0      7.8G   0% /dev/shm
   /dev/sda3               453.1G      1.0G    429.0G   0% /
   tmpfs                     3.1G    108.0K      3.1G   0% /run
   /dev/sda1               511.0M    288.0K    510.7M   0% /boot/efi

- 默认没有包含私有化的Broadcom无线网卡firmware，所以需要 :ref:`alpine_wireless` 单独编译安装firmware

参考
======

- `Alpine newbie install manual <https://wiki.alpinelinux.org/wiki/Alpine_newbie_install_manual>`_
