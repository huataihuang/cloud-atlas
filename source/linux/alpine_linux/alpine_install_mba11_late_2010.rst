.. _alpine_install_mba11_late_2010:

===========================================
MacBook Air 11" Late 2010安装Alpine Linux
===========================================

我在尝试复活 :ref:`mavericks_mba11_late_2010` 还是遇到系统陈旧存在效率低下的问题。但是我不甘心，因为 :ref:`mba11_late_2010` 实在太小巧了，而且能够用十六年前复古的设备，想想还是很酷的。

想到我一直考虑采用 :ref:`sunshine` / :ref:`moonlight` 以及 :ref:`rdp` 远程使用 :ref:`hackintosh` ，我忽然想到最轻量级的 :ref:`alpine_linux` 或许可以帮助我实现一个非常巧妙的移动工作的方案:

- Alpine Linux作为始终持续开发和进步的Linux发行版，能够用最先进的技术来充分发掘我这台古老设备的能力: 没错， :ref:`moonlight-embedded` 能够用服务器端部署端 :ref:`linux` , :ref:`macos` 和 :ref:`windows` 来运行高负载极度复杂端软件，相当于我通过类似 ``chromebook`` 调用超级计算机或集群。
- 本地只运行轻量级的 :ref:`vim` 配合纯C+ :ref:`python` 开发，以及良好配置的文本编辑能力，让我能够随时编辑 :ref:`devops_docs` 并通过CI/CD推送自动部署

2010 款 MacBook Air (NVIDIA 320M) 的 EFI 灰屏 Bug
===================================================

我在最初制作Alpine Linux启动U盘时发现现代的 ``iso-hybrid`` dd制作的U盘无法在 :ref:`mba11_late_2010` 上使用，屏幕显示为灰色无响应。另外，尝试使用 ``rEFInd`` 作为Bootloader来切换OS X和XFS文件系统的Alpine Linux时候，发现一旦在 ``rEFInd`` 的驱动目录存放 ``xfs_x64.efi`` 就会导致启动时"屏幕显示为灰色无响应"。

**以下是gemini提供信息**

2009–2010 年代搭载 NVIDIA 混合/集成显卡（如 9400M、320M、GT 330M）的 Mac 存在一个广为人知的固件缺陷: Apple 早期 EFI 固件在加载非 macOS 内核时，对 NVIDIA 320M 显卡初始化的硬件 Bug:

- **VBIOS 缺失与 PCI 状态未激活** : 当 Apple 的 EFI 固件通过 EFI 模式 引导系统时，固件假定加载的一定是 macOS（XNU 内核）。因此，EFI 固件不会将 NVIDIA 320M 显卡的 legacy VBIOS（Video BIOS）映射到内存空间，也不会将该 PCI 设备设置在符合 VGA/VESA 兼容的物理状态下。
- **Linux 内核的 GPU 初始化崩溃** : 当 64 位 Linux 内核通过 EFI Boot Stub（或 EFI 版本的 GRUB）接管硬件时，内核的 nouveau 驱动（或 NVIDIA 304.xx 驱动）以及 efifb 试图去读取 320M 的 VBIOS 或 VGA 寄存器。由于该物理设备根本没有被苹果 EFI 固件初始化，读取失败直接导致 GPU 锁死（GPU Lockup / Freeze）。

CSM / Legacy BIOS 模式修复
-----------------------------

当通过 CSM (Compatibility Support Module) / Legacy BIOS 模式引导时（无论是原生的 Boot Camp 机制还是通过 rEFInd 激活 hdbios）:

- Apple 固件内部的 **Option ROM / BIOS 模拟层** 会被激活
- 模拟层在启动时会 **强制执行 NVIDIA 320M 的 Legacy VBIOS 初始化例程** ，将显卡置于标准 VGA 兼容模式。
- 随后 ``GRUB-BIOS`` 启动 Linux 内核， ``nouveau`` 驱动就能在内存中找到完整的 VBIOS 镜像并顺利完成 KMS (Kernel Mode Setting) 模式切换。

.. note::

   Linux 社区 讨论中主要有2种方式解决EFI 模式下启动 Linux 会遇到显卡不显示或开机黑屏/灰屏问题:

   - 在 EFI 模式下手动通过 setpci 强制开启 320M 的 PCI 寄存器: 直接向 Intel PCH 主板芯片组和 NVIDIA 320M 的 PCI 寄存器写入十六进制物理地址（开启 VGA Enable 和 Command 寄存器）
   - 采用“ GPT + bios_grub 分区 + GRUB-BIOS (CSM) ”

启动
======

:ref:`mba11_late_2010` 对于现代的 ``iso-hybrid`` 镜像直接 ``dd`` 创建的启动U盘，会触发BUG导致屏幕完全灰色卡死( :ref:`alpine_install_mba11_late_2010_detail` )，所以我最终采用 :ref:`linux_apple_usb_superdrive` 刻录标准CD-ROM来启动安装。

初始设置
==========

通过光盘启动Alpine Linux安装，首先执行 ``setup-alpine`` 命令设置环境

.. literalinclude:: alpine_install_mba11_late_2010/setup-alpine
   :caption: 设置安装环境

磁盘分区
==========

请注意，我已经 :ref:`mavericks_mba11_late_2010` ，所以在安装alpine linux之前，磁盘分区如下:

.. literalinclude:: alpine_install_mba11_late_2010/fdisk_macos
   :caption: 已经安装了Mavericks系统的磁盘分区

如上所述，为了workround :ref:`mba11_late_2010` EFI启动第三方64位efi死机问题，我在alpine linux分区采用了传统CSM分区，也就是整个磁盘混合了 "GPT + CSM分区"，以便 ``rEFInd`` 能够根据分区标记 ``bios_grub`` 来启动Linux所使用的Grub:

在标准的 UEFI 机器上，将 ESP 分区（ ``/dev/sda1`` ， **FAT32** ）挂载到 ``/mnt/boot`` 或 ``/mnt/boot/efi`` ，然后运行 ``setup-disk -m sys /mnt`` ，Alpine 的自动化脚本会自动调用 ``grub-install --target=x86_64-efi`` ，将 **64 位** 纯 UEFI 版的 GRUB ( ``grubx64.efi`` ) 直接写入 ESP 分区。

但是，Alpine 自动化脚本 ( ``setup-disk -m sys`` ) 默认安装的是 UEFI 模式的 GRUB，而不是 Legacy CSM 模式的 GRUB: ``setup-disk`` 探测到系统处于 **64 位 EFI 环境** ，会自动安装 ``x86_64-efi`` 版本的 GRUB 到 ``/dev/sda1`` 。

触发 GPU 致命 Bug：一旦通过 ``/dev/sda1`` 里的 ``grubx64.efi`` 启动，Apple 固件就会以 **纯 64 位 EFI 模式** 初始化 NVIDIA 320M 显卡，就会遇到启动直接灰屏死机。

.. warning::

   为解决 :ref:`mba11_late_2010` 兼容问题，在执行 ``setup-disk`` 指令前指定 ``BOOTLOADER=none`` 来禁止自动安装GRUB，并采用手工方式安装 ``i386-pc`` （BIOS/CSM）模式的 GRUB 到 MBR。

CSM分区 ``bios_grub`` 标志
---------------------------------

在 64 位系统中最常见的两种组合（纯 UEFI 模式，或传统 MBR 磁盘格式）是不需要 ``bios_grub`` 标志的:

- 在传统 MBR 分区表结构的磁盘上:

  - **结构空间** : 磁盘的第 0 扇区是 MBR（512 字节），而第一个主分区通常是从第 2048 扇区（扇区偏置 1MB 处）开始划分的。
  - **物理间隙** : 第 1 到 第 2047 扇区之间存在一段 约 1MB 的未分配空白区域（被称为 ``MBR Gap`` 或 ``Post-MBR Gap`` ）。
  - **GRUB 的藏身之处** : 执行 ``grub-install /dev/sda`` 时，GRUB 会直接把体积较小的 ``boot.img`` 写入第 0 扇区的 MBR，然后把体积较大（约几百 KB）的 ``core.img`` （包含文件系统驱动）塞进这段 1MB 的空白扇区里。

因此，在MBR磁盘上，完全不需要专门划分一个分区来存放 ``core.img``

- 磁盘格式化为 GPT，却又强行使用 ``CSM/Legacy BIOS（grub-bios）`` 模式引导时，矛盾出现:

  - **GPT 破坏了传统的空白间隙** : GPT 格式在磁盘开头和结尾都写入了严格的 GPT 分区表头与条目结构。原来 MBR 后面那段可以用来“偷塞” core.img 的空白扇区被 GPT 的数据占据了。
  - **BIOS 模式识别不了文件系统** : Legacy BIOS/CSM 的底层固件极其笨拙，它在启动的第一阶段根本不认识 Ext4 或 XFS 文件系统，也无法直接去 ``/boot/grub/`` 目录下读取文件。它只能盲目地跳转到某段固定的物理扇区去执行 GRUB 的 ``core.img`` 。
  - **bios_grub 分区的作用** : 为了不破坏 GPT 的数据，又给 CSM 模式下的 GRUB 提供一个存放 ``core.img`` 的固定物理空间，GPT 规范专门定义了这个特殊的分区类型（GUID 为 ``21686148-6449-6E6F-744D-616E69666573`` ）。它的本质就是 **在 GPT 磁盘上人工人工划分出一段独立的裸扇区（通常 1~10MB，无需格式化），专门用来放置 GRUB 的 core.img** 。

- 现代 64 位电脑的常规 ``纯 UEFI 模式`` 下 不需要 ``bios_grub`` 分区:

  - 主板固件本身就已经内置了 FAT16/FAT32 文件系统驱动。
  - 启动时，UEFI 固件可以直接读取 ESP 分区（EFI System Partition，通常是 ``/dev/sda1`` ，FAT32 格式） 中的 ``.efi`` 文件（比如 ``/EFI/BOOT/BOOTX64.EFI`` ）。
  - GRUB 的 ``core.img`` 已经被封装成了标准的 EFI 镜像文件，直接存放在 ESP 分区里，不再需要裸扇区。

.. csv-table:: 三种引导模式对比
   :file: alpine_install_mba11_late_2010/boot.csv
   :widths: 20,20,30,30
   :header-rows: 1

采用EXT4作为rootfs的实践记录
==================================

.. note::

   我最初是想采用XFS作为根文件系统的，但是实践遇到了太多异常， :strike:`最后还是放弃回退到本段采用EXT4作为rootfs` ，所以又改回EXT4作为文件系统。结果遇到相似的报错，最后折腾出和我的古早硬件相关，所以两种文件系统我最后都实践完成，以验证解决方案。

.. csv-table:: GPT + CSM 分区EXT4文件系统方案
   :file: alpine_install_mba11_late_2010/csm_partitions_ext4.csv
   :widths: 20,10,20,10,40
   :header-rows: 1

.. literalinclude:: alpine_install_mba11_late_2010/parted_ext4_fixed
   :caption: 分区中根文件系统是Ext4

上述分区命令我按照之前XFS根文件系统分区命令修订，完成后执行 ``parted /dev/sda print`` 检查:

.. literalinclude:: alpine_install_mba11_late_2010/parted_ext4_fixed_output
   :caption: 改正过的EXT4分区，注意不要设置分区的 ``boot`` FLAG(会导致GPT分区表出现2个ESP相互冲突)
   :emphasize-lines: 11,12

- 安装磁盘工具

.. literalinclude:: alpine_install_mba11_late_2010/install_mkfs_ext4
   :caption: 安装 mkfs.ext4

- 格式化磁盘分区

.. literalinclude:: alpine_install_mba11_late_2010/mkfs_ext4
   :caption: 将sda5格式化为ext4

- 挂载文件系统(只需要挂载一个根文件系统，也就是 ``/dev/sda5`` )

.. literalinclude:: alpine_install_mba11_late_2010/mount_ext4
   :caption: 挂载 ``/dev/sda5`` 分区

安装alpine
===========

- 运行 Alpine 安装 (跳过默认 bootloader)

.. literalinclude:: alpine_install_mba11_late_2010/setup-disk
   :caption: 安装Alpine

请注意，我采用了 ``BOOTLOADER=none`` ，跳过了bootloader安装，这是因为我需要解决 :ref:`mba11_late_2010` 的UEFI缺陷，需要采用手工方式安装grub的CSM兼容模式。

.. note::

   这个 ``BOOTLOADER=none`` 参数跳过bootloader安装实际上带来了很多麻烦，后续的折腾都是因为缺乏系统默认的步骤而不得不一一手工补全。 **好处是折腾带来对系统更深刻的认识**

一切正常的话，最后输出信息:

.. literalinclude:: alpine_install_mba11_late_2010/setup-disk_output
   :caption: 安装Alpine成功

安装grub
===========

由于 :ref:`mba11_late_2010` 对现代纯EFI启动支持存在缺陷，所以通过设置传统BIOS引导让 ``rEFInd`` 能够根据激活分区来查找启动项:

.. literalinclude:: alpine_install_mba11_late_2010/grub
   :caption: 安装grub

注意，执行 ``grub-install`` 命令要确保没有报错，输出类似:

.. literalinclude:: alpine_install_mba11_late_2010/grub_output
   :caption: 执行 ``grub-install`` 时输出信息

注意，这里执行 ``grub-mkconfig`` 生成配置显示输入如下

.. literalinclude:: alpine_install_mba11_late_2010/grub-mkconfig_output
   :caption: 执行 ``grub-mkconfig`` 时输出信息

.. note::

   为什么 64 位系统要用 ``i386-pc`` ？

   ``i386-pc`` 代表“传统 BIOS / Legacy CSM”引导模式：在 GRUB 的命名规范中， ``i386-pc``  专门用于指代传统的 16位/32位 MBR/BIOS 引导阶段。因为无论是 32 位还是 64 位的 x86  CPU，在刚开机处于 BIOS/CSM 模式时，硬件都会先切回实模式（Real Mode）模拟 16/32 位环境来执行分区的 MBR 引导代码，然后再由 GRUB 负责将 CPU 切换到 64 位长模式（Long Mode）并加载 64 位的 Alpine Linux 内核。

   ``x86_64-efi`` 代表“纯 UEFI”引导模式：如果使用 ``--target=x86_64-efi`` ，GRUB 会生成一个 ``.efi`` 文件去寻找 ESP 分区，这会触发 2010 款 MacBook Air (NVIDIA 320M) 在纯 EFI 模式下的 64 位显卡灰屏死机 Bug。

- 所有工作完成，最后退出chroot重启

.. literalinclude:: alpine_install_mba11_late_2010/reboot
   :caption: 退出chroot重启

启动异常排查
================

我原本以为将根文件系统从XFS改为更常用的EXT4能够解决遇到的非常奇特的XFS文件系统mount以后立即umount的问题，但是没想到改为EXT4作为根文件系统也出现了类似的磁盘挂载报错。不过错误信息有所不同:

.. literalinclude:: alpine_install_mba11_late_2010/mount_sysroot_error
   :caption: 显示挂载 ``/sysroot`` 报错

``ext4`` 内核模块 ``mkinitfs``
--------------------------------

我排查发现系统没有加载 ``ext4`` 内核模块，和gemini讨论后排查发现，原来我最初执行 ``BOOTLOADER=none setup-disk -m sys /mnt`` 命令实际上跳过了整个GRUB安装流程，其中包含了和内核模块相关的 ``mkinitfs`` 步骤。所以需要手工补齐:

- 参考 `Alpine Linux wiki: Initramfs init <https://wiki.alpinelinux.org/wiki/Initramfs_init>`_ 在 ``chroot`` 进入 ``/dev/sda5`` 上的安装系统内，先检查 ``/etc/mkinitfs/mkinitfs.conf`` 内容如下:

.. literalinclude:: alpine_install_mba11_late_2010/mkinitfs.conf
   :caption: ``/etc/mkinitfs/mkinitfs.conf`` 必须包含必要的驱动和文件系统模块，如 ``ext4``

**该配置文件虽然列出了所需的ext4内核模块，但是因为跳过了bootloader自动安装流程，所以必须手工执行mkinitfs命令来重建initramfs** :

.. literalinclude:: alpine_install_mba11_late_2010/mkinitfs
   :caption: 手工执行 ``mkinitfs`` 补全initrmafs中内核模块ext4

完成以后可以通过如下命令方法来验证:

.. literalinclude:: alpine_install_mba11_late_2010/check_mkinitfs
   :caption: ``initramfs`` 是一个压缩文件

检查结果确认存在 ``./usr/lib/modules/6.18.50-0-lts/kernel/fs/ext4/ext4.ko.gz`` 说明 ``mkinitfs`` 是有效的。

**但是，再次重启发现还是同样的挂载/sysroot报错** ，不过，我发现有进展的是，直接在 recovery shell 中，虽然 ``lsmod | grep ext4`` 看不到模块，但是只要手动执行 ``mount -t ext4 /dev/sda5 /sysroot`` 就会立即成功，而且自动加载了 ``ext4`` 内核模块。这证明我刚才 ``mkinitfs`` 的操作是有效的。

那么为什么还是无法在启动时自动挂载 ``/sysroot`` 并且同样报错呢？

``init`` 设置延迟等待磁盘设备就绪
-----------------------------------

偶然发现，在手动挂载了 ``/sysroot`` 之后，再执行一次 ``exit`` 命令退出 ``recovery shell`` 时，系统居然开始正常启动服务，并且最终完成了所有服务启动后，看到了登录终端界面!!! 完全通过了，使用没有任何问题!!!

这个发现验证了实际上系统已经修正，但是启动时有环境问题: 问题集中到启动时设备文件就绪( ``/sysroot`` 目录肯定存在，这是initramfs中包含的)

我的这台 :ref:`mba11_late_2010` 非常古老，使用的SATA SSD性能也比较弱，在启动瞬间(2.5秒)，初始化设备的对应 ``/dev/sda5`` :strike:`很有可能在挂载的瞬间没有就绪` **最终发现实际上是挂载时没有传递文件系统类型**

gemini提供了一些内核参数，如 ``rootwait rootdelay=3`` 实际验证都没有任何效果(启动时没有任何停顿感)。gemini提示该参数在使用了 ``initramfs`` 后，控制权因为移交给 ``/init`` Shell脚本而无效。

- 方法一: 内核参数增加 ``roottimeout=10`` ，这样Alpine Linux的 ``/init`` 脚本使用这个显式超时参数，让 ``initramfs`` 脚本在挂载磁盘前，以1秒为周期循环等待，最多等10秒，直到 ``/dev/sda5`` 节点真正出现。
- 方法二: 在 ``initramfs`` 中启用Alpine Linux专用的 ``nlplug-findofs`` 工具模块(基于Netlink监听内核设备热插拔事件)。只要驱动加载，就会一直阻塞等待直到设备生成。

但是，这两个方法我验证都没有效果( ``nlplug-findofs`` 应该默认就使用了)

经过反复尝试，我发现当我 ``mount`` 时候不传递文件系统类型就会报同样错误

.. literalinclude:: alpine_install_mba11_late_2010/mount_without_fstype
   :caption: 挂载时不传递文件系统类型

报错:

.. literalinclude:: alpine_install_mba11_late_2010/mount_without_fstype_error
   :caption: 挂载时不传递文件系统类型就会报和启动时错误日志相同错误

而执行带参数 ``-t ext4`` 的挂载命令则完全正常:

.. literalinclude:: alpine_install_mba11_late_2010/mount_with_fstype
   :caption: 挂载时传递文件系统类型就能成功

那么为什么alpine linux启动时挂载文件系统没有传递文件系统类型呢？

原来alpine linux为了简化系统，没有采用常规发行版，例如ubuntu采用的 ``mount`` 工具命令。通过查看 ``/bin/mount`` 可以看到它是软链接到 ``/bin/bbsuid`` 程序，这个程序依赖 ``nlplug-findfs`` 来是设备的文件系统。

但是在我的 :ref:`mba11_late_2010` 上， ``initramfs`` 启动非常快，当挂载 ``/sysroot`` 前 ``nlplug-findfs`` 去查询 ``/dev/sda5`` 的文件系统类型时，该设备还没有就绪。这导致没有正确获得 ``rootfstype`` 变量，所以 ``mount /dev/sda5 /sysroot`` 没有传递文件系统类型而失败。

gemini最初建议我手工修订 ``initramfs`` 中的 ``init`` 脚本，即使 ``nlplug-findfs`` 检测失败，也要强制注入 ``rootfstype=$KOPT_rootfstype`` (这个 ``$KOPT_rootfstype`` 是从GRUB传递的内核参数变量 ``rootfstype=extr`` ) 

- 解压initramfs:

.. literalinclude:: alpine_install_mba11_late_2010/cpio_initramfs
   :caption: 解压 ``initramfs`` 

- 修改 ``/tmp/initramfs_work/init`` 脚本

.. literalinclude:: alpine_install_mba11_late_2010/init
   :caption: 修订init，即使$rootfstype没有拿到，也要用$KOT_rootfstype来替代
   :language: bash

- 重新打包并覆盖到磁盘 /boot 目录

.. literalinclude:: alpine_install_mba11_late_2010/re_initramfs
   :caption: 将修改后的目录树打包回initramfs

因为我发现如果提前做了 ``modprobe ext4`` 那么即使不传递 ``-t ext4`` 参数，也能直接使用 ``mount /dev/sda5 /sysroot`` 。gemini建议通过 ``mkinitfs`` 为 ``initramfs`` 中添加一个 ``/etc/modules`` ，这个模块文件可以让 ``initramfs`` 在mount之前就加载好内核模块。

alpine linux提供了一个机制，就是 ``/etc/mkinitfs/features.d/base.files`` 配置文件指定了哪些文件会被添加到 ``/boot/initramfs`` 文件中。所以修订 ``/etc/mkinitfs/features.d/base.files`` 添加一行:

.. literalinclude:: alpine_install_mba11_late_2010/base.files
   :caption: ``/etc/mkinitfs/features.d/base.files`` 指定添加到initramfs中的文件

上述配置表示将系统中的 ``/etc/mkinitfs/modules`` 添加到 ``/boot/initramfs`` 中作为 ``/etc/modules``

现在只要编辑一下 ``/etc/mkinitfs/modules`` ，配置一行要加载的内核模块名字就可以:

.. literalinclude:: alpine_install_mba11_late_2010/modules
   :caption: 设置ext4作为加载模块 ``/etc/mkinitfs/modules``

然后执行 ``mkinitfs`` :

.. literalinclude:: alpine_install_mba11_late_2010/mkinitfs
   :caption: 手工执行 ``mkinitfs`` 将 /etc/modules 补充

**现在init脚本不需要hack了，只需要确保能够注入/etc/modules到initramfs中，就可以确保首先加载ext4模块**

.. note::

   **终于搞定了，折腾了我三天时间...**

   下文中XFS的失败，现在看来也应该是同样的原因: 必须让 ``initramfs`` 不仅包含XFS/EXT4内核模块，而且要在执行 ``mount ... /sysroot`` 之前就加载好这两个文件系统模块，才能确保不需要传递文件系统类型(实际上是因为硬件太古老导致初始化太慢，init脚本 ``nlplug-findfs`` 侦测失败)。

``以下是XFS文件系统折腾，和EXT4相互印证``
==========================================

采用XFS作为rootfs的实践记录
=======================================

.. csv-table:: GPT + CSM 分区方案
   :file: alpine_install_mba11_late_2010/csm_partitions.csv
   :widths: 20,10,20,10,40
   :header-rows: 1

.. literalinclude:: alpine_install_mba11_late_2010/parted_fixed
   :caption: 分区(注意sda5不能设置boot FLAG，否则会和sda1同时具有ESP标记引起混乱)

.. warning::

   之前的实践在这里踩了一个大坑，设置 ``/dev/sda`` 添加了 ``boot`` 标记，导致在GPT分区表环境下会和 ``ESP`` 标记重合。见下文异常排查部分

完成分区以后，执行 ``doas parted /dev/sda print`` 检查确认分区:

.. literalinclude:: alpine_install_mba11_late_2010/parted_print_fixed
   :caption: 分区检查
   :emphasize-lines: 11-13

这里有一个异常显示 ``/dev/sda4`` 显示为 ``xfs`` ，这是因为之前我创建过一个 ``/dev/sda4`` 分区并格式化成xfs。虽然在这里分区之前删除了旧分区，但是旧文件系统签名还在，这会导致后续GRUB写入该分区裸代码时导致引导工具混淆。所以需要擦除旧签名！

- 使用 ``wipefs`` 工具检查和清理签名:

.. literalinclude:: alpine_install_mba11_late_2010/wipefs
   :caption: 检查sda4额文件系统签名

输出显示:

.. literalinclude:: alpine_install_mba11_late_2010/wipefs_output
   :caption: 检查sda4额文件系统签名显示残留了xfs签名

彻底擦除签名:

.. literalinclude:: alpine_install_mba11_late_2010/wipefs_clean
   :caption: 擦除xfs签名

- 安装磁盘工具

.. literalinclude:: alpine_install_mba11_late_2010/install_mkfs
   :caption: 安装 mkfs.ext4 和 mkfs.xf

- 格式化磁盘分区:

.. literalinclude:: alpine_install_mba11_late_2010/mkfs
   :caption: 将sda5格式化为ext4, sda6格式化为xfs

- 最后再次检查 ``parted`` 输出:

.. literalinclude:: alpine_install_mba11_late_2010/parted_print_finish
   :caption: 最终的磁盘分区和文件系统
   :emphasize-lines: 11-13

- 挂载文件系统:

.. literalinclude:: alpine_install_mba11_late_2010/mount
   :caption: 挂载文件系统

完成以后，执行 ``df -h`` 可以看到文件系统挂载如下:

.. literalinclude:: alpine_install_mba11_late_2010/df
   :caption: 最后完成的磁盘挂载
   :emphasize-lines: 8,9

安装alpine
===========

- 运行 Alpine 安装 (跳过默认 bootloader)

.. literalinclude:: alpine_install_mba11_late_2010/setup-disk
   :caption: 安装Alpine

请注意，我采用了 ``BOOTLOADER=none`` ，跳过了bootloader安装，这是因为我需要解决 :ref:`mba11_late_2010` 的UEFI缺陷，需要采用手工方式安装grub的CSM兼容模式。

一切正常的话，最后输出信息:

.. literalinclude:: alpine_install_mba11_late_2010/setup-disk_output
   :caption: 安装Alpine成功

安装grub
===========

由于 :ref:`mba11_late_2010` 对现代纯EFI启动支持存在缺陷，所以通过设置传统BIOS引导让 ``rEFInd`` 能够根据激活分区来查找启动项:

.. literalinclude:: alpine_install_mba11_late_2010/grub
   :caption: 安装grub

注意，执行 ``grub-install`` 命令要确保没有报错，输出类似:

.. literalinclude:: alpine_install_mba11_late_2010/grub_output
   :caption: 执行 ``grub-install`` 时输出信息

注意，这里执行 ``grub-mkconfig`` 生成配置显示输入如下

.. literalinclude:: alpine_install_mba11_late_2010/grub-mkconfig_output
   :caption: 执行 ``grub-mkconfig`` 时输出信息

.. note::

   为什么 64 位系统要用 ``i386-pc`` ？

   ``i386-pc`` 代表“传统 BIOS / Legacy CSM”引导模式：在 GRUB 的命名规范中， ``i386-pc``  专门用于指代传统的 16位/32位 MBR/BIOS 引导阶段。因为无论是 32 位还是 64 位的 x86  CPU，在刚开机处于 BIOS/CSM 模式时，硬件都会先切回实模式（Real Mode）模拟 16/32 位环境来执行分区的 MBR 引导代码，然后再由 GRUB 负责将 CPU 切换到 64 位长模式（Long Mode）并加载 64 位的 Alpine Linux 内核。

   ``x86_64-efi`` 代表“纯 UEFI”引导模式：如果使用 ``--target=x86_64-efi`` ，GRUB 会生成一个 ``.efi`` 文件去寻找 ESP 分区，这会触发 2010 款 MacBook Air (NVIDIA 320M) 在纯 EFI 模式下的 64 位显卡灰屏死机 Bug。

- ``mkinitfs`` 补充 ``ext4`` 内核模块

编辑 ``/etc/mkinitfs/mkinitfs.conf`` 配置，添加 ``ext4`` 内核模块

.. literalinclude:: alpine_install_mba11_late_2010/mkinitfs.conf
   :caption: 在 ``mkinitfs.conf`` 配置行最后加上 ``ext4``

然后执行内核对应的intiramfs创建:

.. literalinclude:: alpine_install_mba11_late_2010/mkinitfs
   :caption: 补充 ``ext4`` 内核模块

.. note::

   这个步骤是我后续发现的问题:

   之前通过 ``setup-disk -m sys /mnt`` 安装整个系统到 ``/dev/sda6`` 的 XFS文件系统上，Alpine Linux就会自动在 ``/etc/mkinitfs/mkinitfs.conf`` 中添加 ``xfs`` 这个内核模块，以便构建后的 ``intitramfs`` 中包含文件系统驱动。但是，实际上 ``/boot`` 挂载的EXT4文件系统模块 ``ext4`` 没有包含。这会导致启动以后 ``mount -t ext4 /dev/sda5 /mnt`` 报错:

   .. literalinclude:: alpine_install_mba11_late_2010/mount_ext4_error
      :caption: 挂载EXT4文件系统报设备不存在的异常

   这个问题困扰了我，因为 ``/dev/sda5`` 设备文件是存在的

   后来才发现，原来是内核缺少 ``ext4`` 模块，无法识别文件系统才会有 ``No such device`` 的报错。如果是磁盘文件不存在，报错应该是 ``No such file or directory``

   这个操作步骤参考 `Alpine Linux wiki: Initramfs init <https://wiki.alpinelinux.org/wiki/Initramfs_init>`_

- 所有工作完成，最后退出chroot重启

.. literalinclude:: alpine_install_mba11_late_2010/reboot
   :caption: 退出chroot重启

.. warning::

   **我的XFS实践到这里结束** ， :strike:`但是最终失败了` ``等等，我还能救一下，请看上文我的EXT4折腾笔记``

   重启以后还是没有解决下文 ``启动异常排查`` 的boot挂载报错，我排查了两天没有解决，最终还是放弃在GPT+CSM中使用XFS作为根文件系统，改为采用传统的 ``EXT4`` 文件系统来规避这个问题。

   不过，在EXT4文件系统折腾中遇到了相似的问题，最终解决方案非常坎坷地找到了，看来XFS应该也是相同的问题，我就不再重新搞了。

XFS启动异常排查
====================

实际的实践中，我在这个重启之后遇到一个非常奇怪的异常，系统启动以后挂载 ``/dev/sda6`` 根分区以后迅速又卸载了分区，然后报告挂载boot介质失败:

.. literalinclude:: alpine_install_mba11_late_2010/boot_mount_fail
   :caption: 启动后挂载分区失败

这个问题困扰了我一天，我反复排查，甚至怀疑是initramfs在GPT+CSM分区环境下对XFS文件系统支持存在问题，所以折腾无效，我又重装系统尝试改为

.. csv-table:: GPT + CSM 分区EXT4文件系统方案
   :file: alpine_install_mba11_late_2010/csm_partitions_ext4.csv
   :widths: 20,10,20,10,40
   :header-rows: 1

.. literalinclude:: alpine_install_mba11_late_2010/parted_ext4
   :caption: 分区中根文件系统是Ext4

上述分区命令我按照之前XFS根文件系统分区命令修订，完成后执行 ``parted /dev/sda print`` 检查:

.. literalinclude:: alpine_install_mba11_late_2010/parted_ext4_output
   :caption: 分区中根文件系统是Ext4，print检查
   :emphasize-lines: 8,12

咦，好奇怪，怎么会有 **2个 boot, esp 标记**

我检查了之前的笔记，这才发现，我当时为XFS根文件系统创建CSM分区的时候，同样也给 ``/dev/sda5`` boot分区打上了 ``boot,esp`` FLAG，导致当时的磁盘分区也有 **2个 boot, esp 标记**

当时创建分区的 ``gparted`` 命令如下:

.. literalinclude:: alpine_install_mba11_late_2010/parted
   :caption: 分区
   :emphasize-lines: 6

正是因为给sda5设置了boot FLAG，所以执行 ``doas parted /dev/sda print`` 检查确认分区可以看到 **sda5被错误地同时加上了ESP flag** :

.. literalinclude:: alpine_install_mba11_late_2010/parted_print
   :caption: 分区检查
   :emphasize-lines: 12

这是一个极大的错误!!!

在 GPT 分区表规范中， ``boot`` 标志和 ``esp`` 标志共享同一个 GUID 位。当 ``/dev/sda5``  被打上 ``boot, esp`` 标记后，系统中同时存在了 ``/dev/sda1`` 和 ``/dev/sda5`` 两个 ESP 分区，这会在 GRUB 启动和内核初始化时引发严重混乱。

激活 CSM/Legacy 模式引导 GRUB 时，固件与 rEFInd 会扫描 GPT 分区表中的 ESP 标记:

- 固件会误将 ``/dev/sda5`` 当作第二个 EFI 系统分区
- 在生成设备映射树（Device Tree）时，主板固件可能将真正的 ``/dev/sda1`` 与 ``/dev/sda5`` 的设备路径（Device Path）搞混，甚至把物理磁盘扇区映射给错误的虚拟设备节点。

我忽然想起来，当时排查这个XFS分区挂载又卸载的问题，我尝试Live CD启动，执行 ``mount -t xfs /dev/sda6 /mnt`` 是正常的，但是执行 ``mount -t ext4 /dev/sda5 /mnt/boot`` 却始终报错 ``mount: mounting /dev/sda5 on /mnt/boot failed: No such device`` ，但是 ``ls /dev/sda5`` 却明明显示有这个设备。当时我还非常奇怪，而且发现只有 ``chroot /mnt`` 也就是进入XFS分区(该步骤前重新mount过设备文件)才能挂载 ``/dev/sda5`` 。看来当时就已经有端倪了...

.. note::

   没有继续，但是请参考上文EXT4的解决方案，实际上真正的解决需要确保:

   - ``initramfs`` 中正确加入了 ``ext4`` 和 ``xfs`` 内核模块
   - 确保 ``initramfs`` 中有 ``/etc/modules`` 来提前加载好内核模块，这样才能保证即使没有传递 ``-t ext4`` 或 ``-t xfs`` 也能正确挂载磁盘


