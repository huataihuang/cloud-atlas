.. _install_gentoo_on_mbp:

=================================
在MacBook Pro上安装Gentoo Linux
=================================

制作Gentoo Linux安装U盘
=======================

-  在OS X 的Terminal终端，使用以下命令将 ``.iso`` 文件转换成 ``.img`` :

.. literalinclude:: install_gentoo_on_mbp/convert_iso_img
   :language: bash
   :caption: 将Gentoo安装镜像.iso文件转换成.img文件

.. note::

   Mac设备需要使用EFI stub loader，但是需要注意EFI限制了boot loaderc参数，所以需要将参数结合到内核中 （ `How to install Gentoo ONLY Mid-2012 macbook air <https://forums.gentoo.org/viewtopic-t-966240-view-previous.html?sid=8ccb81a5f18e9e1f7cb5ab533847ff93>`_ ）。

   `UEFI Gentoo Quick Install Guide <https://wiki.gentoo.org/wiki/UEFI_Gentoo_Quick_Install_Guide>`_ 指出需要使用 ``UEFI-enabled`` 启动介质，如LiveDVD或者Gentoo-based `SystemRescueCD <http://www.sysresccd.org/SystemRescueCd_Homepage>`_ ，详细参考 `Gentoo Handbook <https://wiki.gentoo.org/wiki/Handbook:Main_Page>`_ 。此外，也可以参考 `Arch Linux on a MacBook <https://wiki.archlinux.org/index.php/MacBook>`_

   OS X会自动添加 ``.dmg`` 文件名后缀，所以实际生成的文件名是 ``install-amd64-minimal-20230220T081656Z.img.dmg``

- 检查插入U盘对应设备:

.. literalinclude:: install_gentoo_on_mbp/diskutil_list
   :language: bash
   :caption: 检查U盘设备

- 如果U盘已经被自动挂载，则需要先下载挂载，例如::

   sudo diskutil unmountDisk /dev/disk2s2

- 将Gentoo Linux安装镜像写入U盘:

.. literalinclude:: install_gentoo_on_mbp/dd_gentoo_img
   :language: bash
   :caption: 制作Gentoo Linux安装U盘

安装
=======

.. note::

   我采用MacBook的双启动模式: 先安装 :ref:`macos` ，安装时使用macOS内置磁盘工具将磁盘划分为2个分区，保留一个分区给Gentoo Linux使用

   早期我安装双启动模式采用了 ``rEFInd`` 工具(现在依然可以使用):

   - 下载 `rEFInd二进制.zip文件 <http://www.rodsbooks.com/refind/getting.html>`_ 并解压缩
   - 按住 ``Command+R`` 开机（进入Mac的recovery模式）
   - 当OS启动后，选择 Utilities -> Terminal
   - 执行 ``rEFInd`` 安装程序::

      cd refind-bin-0.10.2
      ./refind-install

   再次启动系统

.. note::

   我现在为了简化，采用启动时安装 ``option`` 键，利用硬件内置的磁盘分区选择来启动不同操作系统。所以可以不用安装 ``rEFInd`` ，不过安装 ``rEFIne`` 可以方便自动启动选择界面。

- 启动LiveCD，进入安装过程(需要连接一个有线网络，通过DHCP获取IP连接Internet)

- 登陆是root用户身份，执行以下命令启动 ``sshd`` 并设置好root用户密码，这样就方便我远程登陆到主机上进行下一步安装:

.. literalinclude:: install_gentoo_on_mbp/gentoo_livecd_sshd
   :language: bash
   :caption: 启动Gentoo Linux安装的sshd服务

- 磁盘分区:

.. literalinclude:: install_gentoo_on_mbp/parted_nvme
   :language: bash
   :caption: 对NVMe磁盘进行分区检查
   :emphasize-lines: 15

.. warning::

   只有分区3是可以删除(之前安装macOS保留的空白分区)，我将创建一个50G磁盘分区用于操作系统

- 创建一个名为 ``rootfs`` 分区，格式化成 ``xfs`` :

.. literalinclude:: install_gentoo_on_mbp/parted_nvme_2
   :language: bash
   :caption: ``rootfs`` 分区
   :emphasize-lines: 1-5,15,16

.. note::

   对于UEFI启动，磁盘上必须有一个分区是系统的EFI启动分区，并且是 ``vfat`` 文件系统

   为什么我没有创建这个 EFI 系统分区呢？ 原因是系统磁盘上已经有一个Apple的 :ref:`macos` 操作系统，已经构建了 ``分区1`` ，这个分区已经是 ``boot, esp`` 标记。只需要将这个分区挂载为Linux的 ``/boot/EFI`` 目录就可以。

   当然，如果是整个磁盘作为Linux使用，则可以抹掉整个磁盘所有分区，然后单独为Linux创建一个 ``boot, esp`` 标记的 ``vfat32`` 分区，挂载到 ``/boot/EFI`` 。

- 创建文件系统 - 将分区3格式化成 ``xfs`` 文件系统( 使用了 ``-f`` 强制参数，因为需要覆盖之前的分区信息 ):

.. literalinclude:: install_gentoo_on_mbp/mkfs.xfs
   :language: bash
   :caption: 格式化 ``rootfs`` 分区，创建XFS文件系统

- 挂载 root 分区文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_gentoo_fs
   :language: bash
   :caption: 挂载文件系统

安装stage
=============

Gentoo Linux提供了 Multilib (32和64位)，也提供了纯64位的 No-Multilib 。通常建议使用 ``Multilib`` ，因为这个选项的 stage tarball兼容性最好，系统会尽可能使用64位库，只有需要兼容性的时候才会回退到32位版本。这为将来的定制提供了很大的灵活性。

如果选择 ``no-multilib`` tarball，则会构建完全的64位操作系统环境。但是后续要切换到 ``Multilib`` 变得不可能，尽管在技术上依然是可能的。

.. warning::

   除非绝对必要，刚开始使用Gentoo的用户不应该选择 ``no-Multilib`` tarball。因为从 ``no-multilib`` 迁移到 ``multilib`` 需要对Gentoo 和较低级别的工具链有非常好的知识(对于Toolchain developers也是非常困难的)。

.. note::

   Gentoo Linux默认使用 ``OpenRC`` 作为init，而不是复杂的 :ref:`systemd` (可选)

- 下载 ``stage tarball`` 并解压缩:

.. literalinclude:: install_gentoo_on_mbp/stage_tarball
   :language: bash
   :caption: 下载 ``stage tarball`` 解压缩

配置编译选项
==============

为了优化系统，可以设置影响 Gentoo 官方支持的包管理器 Portage 行为的变量。 所有这些变量都可以设置为环境变量（使用 ``export`` ），但通过 ``export`` 设置不是永久的。

Portage 在运行时读取 ``make.conf`` 文件，这将根据文件中保存的值更改运行时行为。 ``make.conf`` 可以被认为是 Portage 的主要配置文件，所以要小心对待它的内容。

- ``vi /mnt/gentoo/etc/portage/make.conf`` 编辑配置

``CFLAGS`` 和 ``CXXFLAGS``
----------------------------

``CFLAGS`` 和 ``CXXFLAGS`` 变量分别定义了 GCC C 和 C++ 编译器的优化标志。 虽然这些是在这里一般定义的，但为了获得最佳性能，需要分别为每个程序优化这些标志。

在 ``make.conf`` 中，应该定义优化标志，使系统通常响应最快。 不要在这个变量中放置实验设置； 过多的优化会使程序行为异常（崩溃，故障）。

.. note::

   对于优化选项，请参考GNU在线手册或gcc信息页面。 ``make.conf.example`` 也包含了很多示例和信息。

- 修订 ``make.conf`` 配置添加 ``-march=native`` (通常已足够)，可以以本机处理器最佳原生优化进行编译:

.. literalinclude:: install_gentoo_on_mbp/make.conf
   :language: bash
   :caption: make.conf
   :emphasize-lines: 5,12

.. note::

   ``MAKEOPTS="-j4"`` 现在不是必须的，因为 ``nproc`` 返回的就是本机处理器核心数量

Chrooting
==============

(可选):选择镜像网站
----------------------

- 执行选择最佳镜像网站:

.. literalinclude:: install_gentoo_on_mbp/select_mirrors
   :language: bash
   :caption: 在make.conf配置中添加最佳镜像网站配置

- 配置 ``/etc/portage/repos.conf/gentoo.conf`` Gentoo ebuild存储库:

.. literalinclude:: install_gentoo_on_mbp/gentoo.conf
   :language: bash
   :caption: 创建 /etc/portage/repos.conf/gentoo.conf

.. note::

   可以参考 `Gentoo rsync mirrors <https://www.gentoo.org/support/rsync-mirrors/>`_ 配置 ``gentoo.conf`` ，例如选择中国的rsync镜像网站

复制DNS信息
==============

- 将本机的DNS配置信息复制到 Gentoo 安装目录:

.. literalinclude:: install_gentoo_on_mbp/resolv.conf
   :language: bash
   :caption: 复制DNS配置信息

挂载必要文件系统
===================

- 挂载文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_fs
   :language: bash
   :caption: 挂载文件系统

进入新环境
============

- 进入Gentoo新环境:

.. literalinclude:: install_gentoo_on_mbp/chroot
   :language: bash
   :caption: 进入Gentoo新环境

挂载boot分区
===============

- 挂载boot分区(这个分区是MacBook的macos和gentoo公用的):

.. literalinclude:: install_gentoo_on_mbp/mount_boot
   :language: bash
   :caption: 挂载 /boot

配置Portage
==============

如果服务器位于限制性防火墙后面(使用HTTP/HTTPS协议下载快照)，则使用::

   emerge-webrsync

如果没有网络限制，则可以使用传统的rsync方式同步::

   emerge --sync

**做到这里**

选择正确profile
================

.. note::

   ``Desktop profiles`` 并非专用于桌面环境。 它们仍然适用于像 i3 或 sway 这样的最小窗口管理器。

``profile`` 是任何 Gentoo 系统的构建块(building block)。它不仅为 ``USE`` 、 ``CFLAGS`` 和其他重要变量指定默认值，还将系统锁定在特定范围的包版本。 这些设置都由 Gentoo 的 Portage 开发人员维护。

- 查看系统当前使用的 ``profile`` :

.. literalinclude:: install_gentoo_on_mbp/eselect_profile_list
   :language: bash
   :caption: 检查当前使用的 ``profile``

输出显示:

.. literalinclude:: install_gentoo_on_mbp/eselect_profile_list_output
   :language: bash
   :caption: 检查当前使用的 ``profile``

.. note::

   当使用 :ref:`systemd` 时，请确保 ``profile`` 名称中包含 ``systemd`` ，否则请确保 **不包含** ``systemd``

.. warning::

   ``profile`` 升级不能掉以轻心: 选择初始配置文件时，请确保使用与 stage3 最初使用的版本相同的配置文件

   选择初始 ``profile`` 文件时，请确保使用与 stage3 最初使用的版本相同的配置文件

- 设置profile:

.. literalinclude:: install_gentoo_on_mbp/eselect_profile_set
   :language: bash
   :caption: 设置 ``profile``

更新 @world set
================

此时，明智的做法是更新系统的 ``@world set`` ，以便建立 ``base`` 。

以下步骤是必要的，以便系统可以应用自构建 ``stage3`` 以来出现的任何更新或 ``USE flag`` 更改以及任何配置文件选择:

.. literalinclude:: install_gentoo_on_mbp/update_world_set
   :language: bash
   :caption: 更新 @world set

.. note::

   简单来说，配置文件名称越短，系统的 ``@world set`` 就越不具体； ``@world set`` 不具体，系统需要的包就越少：

   例如,  ``default/linux/amd64/17.1`` 只需要更新很少的包；而 ``default/linux/amd64/17.1/desktop/gnome/systemd`` 就会更新很多包，因为 ``init`` 系统从 OpenRC 切换到 :ref:`systemd` 并且会安装GNOME桌面环境框架。


参考
=======

- `Apple MacBook <http://www.gentoo-wiki.info/Apple_MacBook>`_ - 早期版本MacBook的安装
- `ArchLinux MacBook <https://wiki.archlinux.org/index.php/MacBook#MacBook_Pro_with_Retina_display>`_ - 在MacBook上运行Arch Linux，文档较为全面
- `Apple Macbook Pro Retina <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina>`_ - 在Retina版本的MacBook Pro上安装Gentoo
- `Install Gentoo Prefix on MacBook Pro <http://pjq.me/wiki/doku.php?id=linux:gentoo-prefix>`_ - 在OS X系统中运行Gentoo Prefix获得Gentoo Linux体验
