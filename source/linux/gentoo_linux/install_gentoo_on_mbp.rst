.. _install_gentoo_on_mbp:

=================================
在MacBook Pro上安装Gentoo Linux
=================================

.. note::

   Gentoo Linux安装是一个纯手工一步步完成，需要非常小心谨慎，也非常占用时间。不过，只要安装成功，后续就可以不断滚动升级，并且能够获得很多系统运维的深刻知识，特别是自定义编译内核以及USE优化精简，都能够充分发挥硬件性能。所以还是值得投入时间精力进行实践的。

   我大约话费了2~3个晚上来完成初步部署，后续会定制一个精简的 :ref:`mobile_cloud_infra` 来实现开发

安装实践环境有以下两个:

- :ref:`mbp15_late_2013`
- :ref:`mba13_early_2014`

上述两个MacBook笔记本都是同一代产品，架构相同，区别仅是CPU主频(i7 vs. i5)以及GPU(Nvidia vs. Intel)，所以大致安装过程相同

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

网络
======

:ref:`gentoo_mbp_wifi` 是非常麻烦的过程: 我的 :ref:`mbp15_late_2013` 使用了 Broadcom BCM4360 无线芯片，对开源支持不佳。我至今依然没有很好解决这款wifi芯片的驱动(编译)，所以最初在安装Gentoo Linux时不得不使用有线网络连接。

不过，如果使用 :ref:`android` 手机，可以使用 :ref:`android_usb_tethering` 来实现一个通用的USB无线网卡。这样就可以非常容易在安装中连接到无线网络，顺利进行安装。是的，目前我就是采用这种方法来解决安装联网(甚至可以让 :ref:`freebsd` 在无法使用 Broadcom BCM4360 无线芯片情况下通过这种方式连接无线网络 )

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

.. note::

   在 :ref:`mba13_early_2014` 部署时，由于硬盘空间太小，并且我也不太可能切换到 :ref:`macos` ，所以就没有采用双启动，而是直接将整个磁盘都分配给Gentoo

- 启动LiveCD，进入安装过程(需要连接一个有线网络，通过DHCP获取IP连接Internet)

- 登陆是root用户身份，执行以下命令启动 ``sshd`` 并设置好root用户密码，这样就方便我远程登陆到主机上进行下一步安装:

.. literalinclude:: install_gentoo_on_mbp/gentoo_livecd_sshd
   :language: bash
   :caption: 启动Gentoo Linux安装的sshd服务

:ref:`mbp15_late_2013` 分区
-----------------------------

.. note::

   :ref:`mbp15_late_2013` 换过 :ref:`nvme` 存储( :ref:`mbp15_late_2013_update_nvme` )，所以磁盘空间较大(1T)

   **注意：我这里的案例是保留了macOS分区，也就是采用双启动方式。所以分区和后面挂载 /boot 分区和纯粹的只使用Linux的分区是不一样的** 如果你只安装Gentoo Linux(删除macOS)，那么就采用下面的 " :ref:`mba13_early_2014` 分区 " 方法

- 磁盘分区:

.. literalinclude:: install_gentoo_on_mbp/parted_nvme
   :language: bash
   :caption: MBP 15存储:对NVMe磁盘进行分区检查
   :emphasize-lines: 15

.. warning::

   只有分区3是可以删除(之前安装macOS保留的空白分区)，我将创建一个50G磁盘分区用于操作系统

   之所以没有将所有磁盘分区都用完，是因为我规划在其余 :ref:`nvme` 磁盘分区中采用 :ref:`zfs` 作为数据存储文件系统，来实现灵活的卷管理

- 创建一个名为 ``rootfs`` 分区，格式化成 ``xfs`` :

.. literalinclude:: install_gentoo_on_mbp/parted_nvme_2
   :language: bash
   :caption: ``rootfs`` 分区
   :emphasize-lines: 1-5,15,16

.. note::

   对于UEFI启动，磁盘上必须有一个分区是系统的EFI启动分区，并且是 ``vfat`` 文件系统

   为什么我没有创建这个 EFI 系统分区呢？ 原因是系统磁盘上已经有一个Apple的 :ref:`macos` 操作系统，已经构建了 ``分区1`` ，这个分区已经是 ``boot, esp`` 标记。只需要将这个分区挂载为Linux的 ``/boot`` 目录就可以。

   当然，如果是整个磁盘作为Linux使用，则可以抹掉整个磁盘所有分区，然后单独为Linux创建一个 ``boot, esp`` 标记的 ``vfat32`` 分区，挂载到 ``/boot`` 。

- 创建文件系统 - 将分区3格式化成 ``xfs`` 文件系统( 使用了 ``-f`` 强制参数，因为需要覆盖之前的分区信息 ):

.. literalinclude:: install_gentoo_on_mbp/mkfs.xfs
   :language: bash
   :caption: 格式化 ``rootfs`` 分区，创建XFS文件系统

- 挂载 root 分区文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_gentoo_fs
   :language: bash
   :caption: 挂载文件系统

:ref:`mba13_early_2014` 分区
-------------------------------

.. note::

   :ref:`mba13_early_2014` 原装存储 只有 128GB (在没有 :ref:`mba11_late_2010_update_sata` 之前)

- 磁盘分区:

.. literalinclude:: install_gentoo_on_mbp/parted_sata
   :language: bash
   :caption: MBA 13存储: 对SATAe磁盘(128G)进行分区检查
   :emphasize-lines: 13,14

上述有2个 :ref:`macos` 分区，由于我只使用 Gentoo ，所以会删除掉这两个分区(先重建分区表)

- 重建GPT分区表，并创建2个分区:  ``boot, esp`` 标记的 ``vfat32`` 分区，挂载为 ``/boot/EFI`` ， 命名为 ``rootfs`` 的 :ref:`xfs` 分区，作为系统磁盘(保留 100GB 作为数据分区，使用 :ref:`zfs` )

.. literalinclude:: install_gentoo_on_mbp/parted_sata_rootfs
   :language: bash
   :caption: MBA 13存储: 对SATAe磁盘(128G)分区和格式化

完成后输出的分区情况如下:

.. literalinclude:: install_gentoo_on_mbp/parted_sata_rootfs_output
   :language: bash
   :caption: MBA 13存储: 对SATAe磁盘(128G)分区和格式化后状态

- 挂载 root 分区文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_gentoo_fs_sata
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

   此外stage还区分LLVM版本，这个版本是使用Clang编译的，并且Gentoo也支持将主编译器切换为Clang。但是由于gcc是事实标准，有些软件使用Clang编译会出错，所以Clang提供了fallback到gcc的方式。并且Clang不能编译glibc，所以实际上系统还是会保留gcc。此外，Clang编译的软件并没有比Gcc编译的软件更快，且通常会占用更多内存。不过，Clang采用了BSD协议，比较宽松，所以在BSD系统以及商业公司支持上通常会选择Clang，对于个人而言(散兵游勇)通常会选择Gcc。请参考 `为什么Clang不能取代GCC？ <https://www.zhihu.com/question/602844208>`_ 讨论，其中 `为什么Clang不能取代GCC？ - 韩朴宇的回答 - 知乎 <https://www.zhihu.com/question/602844208/answer/3044304429>`_ 有很多人讨论了这个问题，可以参考

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

.. note::

   当使用 ``emerge`` 进行软件安装(源代码编译)，下载源代码包的配置就是由 ``make.conf`` 指定的。非常不幸，由于GFW阻塞，现在(2023)几乎无法访问Gentoo官网以及默认下载网站，并且 ``mirrorselect`` 也无法运行(因为首先需要从官网拉取 ``mirrorlist`` 就是失败的)。参考 `make.conf.example <https://github.com/gentoo/portage/blob/master/cnf/make.conf.example>`_ ，实际上 ``mirrorselect`` 在 ``make.conf`` 配置中添加了如下类似内容::

      # 建议最后保留默认配置
      GENTOO_MIRRORS="<your_mirror_here> http://distfiles.gentoo.org http://www.ibiblio.org/pub/Linux/distributions/gentoo"

   在国内可以参考Gentoo官方文档 `Gentoo source mirrors <https://www.gentoo.org/downloads/mirrors/>`_ 选择国内镜像网站，例如阿里云提供的镜像网站:

   .. literalinclude:: install_gentoo_on_mbp/gentoo_mirrors
      :language: bash
      :caption: 在make.conf配置中添加阿里云国内镜像网


- 配置 ``/etc/portage/repos.conf/gentoo.conf`` Gentoo ebuild存储库:

.. literalinclude:: install_gentoo_on_mbp/gentoo.conf
   :language: bash
   :caption: 创建 /etc/portage/repos.conf/gentoo.conf

.. note::

   可以参考 `Gentoo rsync mirrors <https://www.gentoo.org/support/rsync-mirrors/>`_ 配置 ``gentoo.conf`` ，例如选择中国的rsync镜像网站

   .. literalinclude:: install_gentoo_on_mbp/sync-url
      :language: bash
      :caption: /etc/portage/repos.conf/gentoo.conf 配置国内sync-url

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

:ref:`mbp15_late_2013` 分区
-----------------------------

对于保留macOS的安装，挂载boot分区是直接挂载原先macOS的ESP分区到 ``/boot`` 。如果抹除了macOS，则参考下面 " :ref:`mba13_early_2014` 分区 " 方法

- 挂载boot分区(这个分区是MacBook的macos和gentoo公用的):

.. literalinclude:: install_gentoo_on_mbp/mount_boot
   :language: bash
   :caption: 挂载 /boot

:ref:`mba13_early_2014` 分区
----------------------------

对于只使用Gentoo Linux的系统，则ESP分区挂载到 ``/boot/efi`` 目录下(参考 `Quick Installation Checklist <https://wiki.gentoo.org/wiki/Quick_Installation_Checklist>`_ )

.. literalinclude:: install_gentoo_on_mbp/mount_boot_mba13
   :language: bash
   :caption: 挂载 /boot(只使用Linux，则vfat分区需要挂载到 /boot 目录)

配置Portage
==============

如果服务器位于限制性防火墙后面(使用HTTP/HTTPS协议下载快照)，则使用::

   emerge-webrsync

如果没有网络限制，则可以使用传统的rsync方式同步::

   emerge --sync

.. note::

   国内镜像网站虽然没有GFW干扰，下载速度较快。但是 **国内镜像网站同步有延迟，可能会存在好几天都没有同步最新文件的情况** ，所以使用 ``emerge-webrsync`` 下载快照文件可能会失败(因为快照还没有同步)。不过，使用 ``emerge --sync`` 可以绕开这个同步延迟问题，最多也就是本次同步不能及时得到官方的最新版本(稍微旧几天的版本)。

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
   :emphasize-lines: 6

.. note::

   当使用 :ref:`systemd` 时，请确保 ``profile`` 名称中包含 ``systemd`` ，否则请确保 **不包含** ``systemd``

   在2023年9月的实践，我采用 ``no-multilib (stable)`` ，尝试构建一种轻量级的64位Linux系统

.. warning::

   ``profile`` 升级不能掉以轻心: 选择初始配置文件时，请确保使用与 stage3 最初使用的版本相同的配置文件

   选择初始 ``profile`` 文件时，请确保使用与 stage3 最初使用的版本相同的配置文件

- 设置profile案例(仅供参考):

.. literalinclude:: install_gentoo_on_mbp/eselect_profile_set
   :language: bash
   :caption: 设置 ``profile``

.. note::

   之前我曾经采用过 :ref:`sway` 最小化窗口管理器，所以选择 ``default/linux/amd64/17.1/desktop`` ( ``5`` )

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

配置USE变量
===========

``USE`` 是Gentoo为用户 提供的最强大的变量之一，可以配置支持或不支持某些选项来编译多个程序。例如有些程序可以支持 ``GTK+`` 或 ``Qt`` 情况下编译，或者支持 ``SSL`` ，有些程序甚至可以使用帧缓冲( ``svgalib`` )而不是X11支持来完成编译。

**大多数Linux发行版为了能够尽可能多支持不同环境(软件和硬件)，采用了最大化的编译参数，这导致增加了程序大小以及启动时间，而且会导致大量的依赖。使用Gentoo的用户可以通过定义编译选项来精简系统，使得硬件发挥更大功效。**

默认的 ``USE`` 设置使用Gentoo配置文件 ``make.defaults`` 。Gentoo使用了一个(复杂的)继承系统。检查当前的USE配置最简单的方法是:

.. literalinclude:: install_gentoo_on_mbp/emerge_info
   :language: bash
   :caption: 使用 ``emerge --info`` 获取USE配置

完整的 ``USE`` flags 可以在 ``/var/db/repos/gentoo/profiles/use.desc`` 查看

``CPU_FLAGS_*``
================

某些架构(包括 AMD64/X86, ARM, PPC)有一个名为 ``CPU_FLAGS_ARCH`` 的 ``USE_EXPAND`` 变量(视情况用相应的架构替换 ``ARCH`` )。这个变量将构建配置为特定的汇编代码或者其他内部函数中的编译，通常是 ``硬编码`` (hand-written) 或者其他扩展，并且与要求编译器为特定CPU功能(例如 ``march=`` )输出的优化代码不同。

除了根据需要配置其 ``COMMON_FLAGS`` 之外，用户还应设置此变量。

- 安装工具包:

.. literalinclude:: install_gentoo_on_mbp/install_cpuid2cpuflags
   :language: bash
   :caption: 安装 ``cpuid2cpuflags`` 工具包

- 执行:

.. literalinclude:: install_gentoo_on_mbp/cpuid2cpuflags
   :language: bash
   :caption: 运行 ``cpuid2cpuflags``

在我的 :ref:`mbp15_late_2013` 上输出:

.. literalinclude:: install_gentoo_on_mbp/cpuid2cpuflags_output
   :language: bash
   :caption: :ref:`mbp15_late_2013` 运行 ``cpuid2cpuflags`` 输出

在我的 :ref:`mba13_early_2014` 上输出:

.. literalinclude:: install_gentoo_on_mbp/cpuid2cpuflags_output_mba13
   :language: bash
   :caption: :ref:`mba13_early_2014` 运行 ``cpuid2cpuflags`` 输出

这里可以看到 :ref:`mbp15_late_2013` 和 :ref:`mba13_early_2014` 作为同代产品，CPU特性是相同的

- 将输出结果添加到 ``package.use`` :

.. literalinclude:: install_gentoo_on_mbp/cpuid2cpuflags_output_package.use
   :language: bash
   :caption: 运行 ``cpuid2cpuflags`` 输出添加到 ``package.use``

.. note::

   我记得大约20年前，我在使用Gentoo Linux在我的一台联想笔记本上编译Gentoo Linux。那时候还没有 ``cpuid2cpuflags`` ，是手工查CPU型号然后猜测哪些CPU相关的 Flags 需要配置，为 ``make.conf`` 添加类似 ``mmx sse2`` 这样的优化参数。现在都有工具可以代劳了...

(可选)配置 ``ACCEPT_LICENSE`` 变量
===================================

Gentoo包的licenses存储在ebuild的 ``LICENCE`` 变量中。系统接受的特定licenses可以在以下文件定义:

- /etc/portage/make.conf 文件中的系统范围。
- /etc/portage/package.license 文件中的每个包。
- /etc/portage/package.license/ 文件目录中的每个包。

Portage 在 ``ACCEPT_LICENSE`` 中查找允许安装的包::

   portageq envvar ACCEPT_LICENSE

默认输出是::

   @FREE

.. note::

   需要修订Licenses，添加 ``@BINARY-REDISTRIBUTABLE`` ，否则无法安装下文的 ``sys-kernel/linux-firmware``

- 简单的方法是修改 ``/etc/portage/make.conf`` 添加可以接受的licenses::

   ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

- 另外一种方法是为每个软件包配置licenses，也就是创建 ``/etc/portage/package.license`` 目录，然后创建一个为每个软件包配置licences的文件，如 ``/etc/portage/package.license/kernel`` 内容案例如下::

   app-arch/unrar unRAR
   sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE
   sys-firmware/intel-microcode intel-ucode

配置时区
===========

所有的时区信息可以从 ``/usr/share/zoneinfo/`` 目录下查找，我使用 ``Asia/Shanghai``

对于使用默认的 OpenRC ，配置时区写在 ``/etc/timezone`` 文件:

.. literalinclude:: install_gentoo_on_mbp/timezone
   :language: bash
   :caption: 配置OpenRC的timezone配置

然后重新配置 ``sys-libs/timezone-data`` 软件包，这个软件包会更新 ``/etc/localtime`` :

.. literalinclude:: install_gentoo_on_mbp/timezone-data
   :language: bash
   :caption: 重新配置 sys-libs/timezone-data

.. note::

   ``sys-libs/timezone-data`` 是将 ``/usr/share/zoneinfo/Asia/Shanghai`` 复制为 ``/etc/localtime`` 。这和我之前在 :ref:`deploy_ntp` 采用软连接方法不同

配置本地化(语言支持)
=======================

- 修订 ``/etc/locale.gen`` (我这里直接添加，原配置文件是一些注释案例):

.. literalinclude:: install_gentoo_on_mbp/locale.gen
   :language: bash
   :caption: 在 /etc/locale.gen 中添加 UTF-8 支持

- 根据 ``/etc/locale.gen`` 生成所有本地化支持:

.. literalinclude:: install_gentoo_on_mbp/locale-gen
   :language: bash
   :caption: 运行 ``locale-gen`` 命令，根据 /etc/locale.gen 生成本地化支持

可以看到实际生成了2个本地化支持:

.. literalinclude:: install_gentoo_on_mbp/locale-gen_output
   :language: bash
   :caption: 运行 ``locale-gen`` 命令输出，显示支持2个本地化字符集

选择本地化
============

- 显示可支持的 ``lcoale`` :

.. literalinclude:: install_gentoo_on_mbp/eselect_locale_list
   :language: bash
   :caption: 查看当前locale

输出信息如下:

.. literalinclude:: install_gentoo_on_mbp/eselect_locale_list_output
   :language: bash
   :caption: 查看当前locale输出

当前是 ``C.UTF8`` 

- 可以修订，例如 ``en_US.utf8`` :

.. literalinclude:: install_gentoo_on_mbp/eselect_locale_set
   :language: bash
   :caption: 设置locale

- 重新加载环境:

.. literalinclude:: install_gentoo_on_mbp/env-update
   :language: bash
   :caption: 更新加载环境

配置内核准备
===============

(可选)安装firmware 和/或 microcode
-------------------------------------

Firmware
~~~~~~~~~~

在开始配置内核并重启系统前，建议安装  ``sys-kernel/linux-firmware`` !!!

原因是现代很多无限网卡需要Firmware才能正常工作，而AMD/Nvidia/Intel的GPU通常也需要Firmware才能发挥全部功能:

- 安装Fireware:

.. literalinclude:: install_gentoo_on_mbp/install_firmware
   :language: bash
   :caption: 安装 ``sys-kernel/linux-firmware``

Microcode
~~~~~~~~~~

CPU处理器也需要固件更新:

- AMD处理器: ``sys-kernel/linux-firmware``
- Intel处理器: ``sys-firmware/intel-microcode``

- 安装intel microcode:

.. literalinclude:: install_gentoo_on_mbp/install_intel-microcode
   :language: bash
   :caption: 安装 ``sys-kernel/intel-microcode``

.. note::

   CPU microcode后续再具体学习实践

内核配置和编译
=====================

**终于来到了最核心的部分**

Gentoo提供了三种内核管理方法，并且安装以后任何时候都可以切换到其他新方法: 以下是最简单到最复杂的方法

- 全自动方法: 分发内核

分发内核用于配置、自动构建和安装 Linux 内核、其相关模块和（可选，但默认启用）initramfs 文件。 未来的内核更新是完全自动化的，因为它们是通过包管理器处理的，就像任何其他系统包一样。 如果需要自定义，可以提供自定义内核配置文件。 这是最少涉及的过程，并且非常适合新的 Gentoo 用户，因为它开箱即用，并且系统管理员的参与最少。

- 混合方法：:ref:`gentoo_genkernel`

新内核源代码通过系统包管理器安装。 系统管理员使用 Gentoo 的 ``genkernel`` 工具来一般配置、自动构建和安装 Linux 内核、其相关模块和（可选，但默认情况下未启用）initramfs 文件。 如果需要自定义，可以提供自定义内核配置文件。 未来的内核配置、编译和安装需要系统管理员以运行 eselect kernel、genkernel 和可能的其他命令的形式参与每次更新。

- 全手动方式:

新内核源代码通过系统包管理器安装。 内核是使用 eselect 内核和一系列 make 命令手动配置、构建和安装的。 未来的内核更新会重复配置、构建和安装内核文件的手动过程。 这是最复杂的过程，但提供了对内核更新过程的最大控制。

.. note::

   初次安装我采用 ``分发内核`` (Distribution kernels) ，以便尽快运行。等系统稳定后，在切换到 ``全手动方式``

分发内核
---------

分发内核是涵盖解包、配置、编译和安装内核的完整过程的 ``ebuild`` 。 这种方法的主要优点是作为 ``@world`` 升级的一部分，包管理器将内核更新到新版本。 这不需要比运行 emerge 命令更多的参与。 分发内核默认为支持大多数硬件的配置，但是提供了两种自定义机制： ``savedconfig`` 和 ``config snippets`` 。

- 在使用分发内核之前，先确保系统安装了正确的 ``installkernel`` 包 (一种是 ``systemd-boot`` 一种是 ``gentoo`` ，我使用后者，默认已经在 stage3 安装好了，所以不用重复)::

   emerge --ask sys-kernel/installkernel-gentoo

- 安装分发内核，有两种方式:

一种是从源代码编译一个Gentoo patches的内核(我采用这个方法):

.. literalinclude:: install_gentoo_on_mbp/install_gentoo-kernel
   :language: bash
   :caption: 从源代码编译安装Gentoo patches的内核

另一种是直接安装预先编译好的内核::

   emerge --ask sys-kernel/gentoo-kernel-bin

.. note::

   安装内核后，包管理器会自动将其更新到更新的版本。 以前的版本将被保留，直到包管理器被要求清理陈旧的包

   如果要清理旧包::

      emerge --depclean

   或者指定清理旧内核版本::

      emerge --prune sys-kernel/gentoo-kernel sys-kernel/gentoo-kernel-bin

- (无需操作)分发内核安装完成后，能够自动重建由其他软件包安装的内核模块:

  - ``linux-mod.eclass`` 提供 ``dist-kernel`` USE 标志，它控制对 ``virtual/dist-kernel`` 的 subslot 依赖性
  - ``sys-fs/zfs`` 和 ``sys-fs/zfs-kmod`` 等包上使用了 ``dist-kernel`` USE 标志，所以能够根据更新的内核自动重建，相应地生成 ``initramfs``

- (一般无需操作)如果需要，也可以在内核升级完成后手工触发 ``initramfs`` 重建::

   emerge --ask @module-rebuild

- 如果需要一些内核模块在早期启动时加载(例如ZFS)，则应该通过以下命令重建 ``initramfs`` ::

   emerge --config sys-kernel/gentoo-kernel
   emerge --config sys-kernel/gentoo-kernel-bin

.. note::

   安装内核源代码和手工编译(或者 ``Genkernel`` )，我准备后续独立搞( :ref:`gentoo_kernel` )，这里先忽略 

配置系统
============

文件系统配置
=============

``/etc/fstab`` 提供了文件系统挂载配置(挂载点和选项)。文件系统标签和UUID可以通过 ``blkid`` 命令查看，对于多磁盘，由于启动系统时识别磁盘可能顺序随机(导致设备识别名变化)，所以建议使用UUID来识别设备进行挂载。但是，需要注意，当分区被擦除，则文件系统label和UUID值将会变化或移除。

.. warning::

   LVM的卷和LVM的snapshot使用相同的UUID，所以如果挂载LVM卷不要使用UUID。

   我的实践在 :ref:`mbp15_late_2013` (macOS和Linux双启动)和 :ref:`mba13_early_2014` (Linux独占)略有不同，所以这里分开记述

:ref:`mbp15_late_2013` 文件系统
---------------------------------

- 使用 ``blkid`` 检查磁盘，当前显示主机内部的NVMe设备分区如下:

.. literalinclude:: install_gentoo_on_mbp/blkid_output
   :language: bash
   :caption: :ref:`mbp15_late_2013` blkid显示输出内置NVMe设备分区(label和UUID)
   :emphasize-lines: 1,2

其中 分区3 是安装Gentoo Linux的分区，将被挂载到根分区 ``/`` ; 分区1是原先 :ref:`macos` 安装时已经构建的 ``vfat32`` 文件系统分区，用于存储EFI启动信息，这个分区也是和 Gentoo Linux 共用的，将被挂载到 ``/boot`` 目录

- 检查 ``ls -lh /dev/disk/by-uuid`` 可以看到上述分区信息，这个设备路径可以用于配置 ``/etc/fstab`` :

.. literalinclude:: install_gentoo_on_mbp/disk_by_uuid
   :language: bash
   :caption: :ref:`mbp15_late_2013` /dev/disk/by-uuid 目录下文件软连接显示UUID对应设备
   :emphasize-lines: 1,2

- 配置 ``/etc/fstab`` 如下:

.. literalinclude:: install_gentoo_on_mbp/fstab
   :language: bash
   :caption: :ref:`mbp15_late_2013` 使用UUID配置 /etc/fstab

:ref:`mba13_early_2014` 文件系统
--------------------------------

- 使用 ``blkid`` 检查磁盘，当前显示主机内部的SATA设备分区如下:

.. literalinclude:: install_gentoo_on_mbp/blkid_output_mba13
   :language: bash
   :caption: :ref:`mba13_early_2014` blkid显示输出内置SATA设备分区(label和UUID)

- 同样，检查 ``ls -lh /dev/disk/by-uuid`` 可以看到上述分区信息，这个设备路径可以用于配置 ``/etc/fstab`` :

.. literalinclude:: install_gentoo_on_mbp/disk_by_uuid_mba13
   :language: bash
   :caption: :ref:`mba13_early_2014` /dev/disk/by-uuid 目录下文件软连接显示UUID对应设备

- 配置 ``/etc/fstab`` 如下:

.. literalinclude:: install_gentoo_on_mbp/fstab_mba13
   :language: bash
   :caption: :ref:`mba13_early_2014` 使用UUID配置 /etc/fstab

网络配置
==========

主机名
--------

- 主机名配置 ``xcloud`` ( ``bcloud`` ):

.. literalinclude:: install_gentoo_on_mbp/set_hostname
   :language: bash
   :caption: 设置主机名

网络
-------

- 对于动态获取IP地址，可以采用 ``dhcpcd`` :

.. literalinclude:: install_gentoo_on_mbp/dhcpcd
   :language: bash
   :caption: 使用dhcpcd动态分配IP

.. note::

   如果使用有线网络，则上述使用dhcpcd就已经足够，甚至无需配置网络。Gentoo使用了自己独特的 ``netifrc`` 框架来配置和管理网络接口。这个 ``net-misc/netifrc`` 默认已经安装

hosts文件
-----------

``/etc/hosts`` 文件帮助解析不能通过DNS服务器解析的服务器，通常要设置本机 ``hostname`` 对应解析:

.. literalinclude:: install_gentoo_on_mbp/hosts
   :language: bash
   :caption: /etc/hosts 配置主机解析

系统信息
==========

- 配置root用户密码::

   passwd

Init和启动配置
================

OpenRC
-------

OpenRC使用 ``/etc/rc.conf`` 来配置服务的启动和关闭，这个配置文件中有大量的注释来帮助设置. (待实践)

安装工具
==========

系统日志服务
---------------

对于使用OpenRC，当前Gentoo的Stage3压缩包缺少一些工具，原因是有多个软件提供相同功能，所以Gentoo让用户自行选择。而 :ref:`systemd` 是集成了日志服务，所以不需要这个安装配置。以下是OpenRC的配置日志服务 ``sysklogd`` (一个开箱即用的传统系统日志服务，没有采用重量级的 ``rsyslog`` 或 ``syslog-ng`` ):

.. literalinclude:: install_gentoo_on_mbp/sysklogd
   :language: bash
   :caption: 安装sysklogd作为日志服务

(可选)工具集合
----------------

安装cron服务/文件索引/ssh服务启用/dos文件系统工具:

.. literalinclude:: install_gentoo_on_mbp/option_tools
   :language: bash
   :caption: 可选工具配置

配置bootloader
================

Gentoo 官方文档 `Configuring the bootloader <https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader>`_ 提供了多种bootloader设置方法。对于UEFI系统，例如我的MacBook Pro，我采用之前 :ref:`archlinux_on_mbp` 相同的方法: 采用 ``efibootmgr`` 来管理UEFI启动顺序，这也是Gentoo官方bootloader文档中介绍的可选方法之一

- 安装:

.. literalinclude:: install_gentoo_on_mbp/install_efibootmgr
   :language: bash
   :caption: 安装 efibootmgr

:ref:`mbp15_late_2013`
------------------------

- 配置启动Gentoo:

.. literalinclude:: install_gentoo_on_mbp/efibootmgr_set
   :language: bash
   :caption: :ref:`mbp15_late_2013` 设置efibootmgr

.. note::

   - ``--disk /dev/nvme0n1`` 是指整个磁盘设备
   - ``--part 1`` 是指ESP分区，这个分区是Apple和Gentoo共享的
   - ``root=PARTUUID=fbf163f3-a42e-411a-be61-f2ae7b398e61`` 这个参数是 ``PARTUUID`` ，是通过 ``ls -lh /dev/disk/by-partuuid/`` 查询得到。注意，不是磁盘UUID(在 ``/etc/fstab`` 中使用磁盘UUID)

:ref:`mba13_early_2014`
-------------------------

- 配置启动Gentoo:

.. literalinclude:: install_gentoo_on_mbp/efibootmgr_set_mba13
   :language: bash
   :caption: :ref:`mba13_early_2014` 设置efibootmgr

.. note::

   - ``--disk /dev/sda`` 是指整个磁盘设备
   - ``--part 1`` 是指ESP分区，这个分区是vfat32格式的启动分区
   - ``root=PARTUUID=1c16164d-fab1-49f8-8d95-7c7dd02ec8ed`` 这个参数是 ``PARTUUID`` ，是通过 ``ls -lh /dev/disk/by-partuuid/`` 查询得到。注意，不是磁盘UUID(在 ``/etc/fstab`` 中使用磁盘UUID)

收尾工作
==========

- 添加用户账号(huatai)，并且添加到sudo中:

.. literalinclude:: install_gentoo_on_mbp/add_user
   :language: bash
   :caption: 添加用户账号

- 重启系统::

   exit
   cd
   umount -l /mnt/gentoo/dev{/shm,/pts,}
   umount /mnt/gentoo{/boot,/sys,/proc,}
   reboot 

.. note::

   安装完成后，后续可以执行 :ref:`upgrade_gentoo` 来保持系统滚动更新

参考
=======

- `Apple MacBook <http://www.gentoo-wiki.info/Apple_MacBook>`_ - 早期版本MacBook的安装
- `ArchLinux MacBook <https://wiki.archlinux.org/index.php/MacBook#MacBook_Pro_with_Retina_display>`_ - 在MacBook上运行Arch Linux，文档较为全面
- `Apple Macbook Pro Retina <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina>`_ - 在Retina版本的MacBook Pro上安装Gentoo
- `Install Gentoo Prefix on MacBook Pro <http://pjq.me/wiki/doku.php?id=linux:gentoo-prefix>`_ - 在OS X系统中运行Gentoo Prefix获得Gentoo Linux体验
