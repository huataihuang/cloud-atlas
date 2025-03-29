.. _lfs_boot:

======================
使 LFS 系统可引导
======================

创建 /etc/fstab 文件
=======================

- 执行以下命令创建 ``/etc/fstab`` 

.. literalinclude:: lfs_boot/fstab
   :caption: ``/etc/fstab``

.. note::

   这里配置 ``<xxx>、<yyy> 和 <fff>`` 参考之前 :ref:`lfs_partition`

Linux内核
============

.. note::

   在LFS网站有两篇比较古老但是依然有参考价值的文档:

   - `kernel-configuration.txt <https://www.linuxfromscratch.org/hints/downloads/files/kernel-configuration.txt>`_
   - `Linux Kernel in a Nutshell <https://anduin.linuxfromscratch.org/LFS/kernel-nutshell/>`_

.. literalinclude:: lfs_boot/kernel
   :caption: 配置内核

一定要按照以下列表启用/禁用/设定其中列出的内核特性，否则系统可能不能正常工作，甚至根本无法引导:

.. literalinclude:: lfs_boot/kernel_config
   :caption: 配置部分必要特性

在构建 64 位系统，还需要启用一些特性:

.. literalinclude:: lfs_boot/kernel_64
   :caption: 配置64位系统


- 由于使用 :ref:`nvme` 设备，所以参考 `gentoo linux wiki: NVMe <https://wiki.gentoo.org/wiki/NVMe>`_ 配置内核

.. literalinclude:: lfs_boot/kernel_config_nvme
   :caption: 配置内核-NVMe

- 由于我使用XFS:

.. literalinclude:: lfs_boot/kernel_config_xfs
   :caption: 配置内核XFS

- 编译和安装:

.. literalinclude:: lfs_boot/kernel_make
   :caption: 编译内核

配置Linux内核模块加载顺序
===========================

多数情况下 Linux 内核模块可以自动加载，但有时需要指定加载顺序。负责加载内核模块的程序 modprobe 和 insmod 从 /etc/modprobe.d 下的配置文件中读取加载顺序，例如，如果 USB 驱动程序 (ehci_hcd、ohci_hcd 和 uhci_hcd) 被构建为模块，则必须按照先加载 echi_hcd，再加载 ohci_hcd 和 uhci_hcd 的正确顺序，才能避免引导时出现警告信息。

执行以下命令创建文件 ``/etc/modprobe.d/usb.conf``

.. literalinclude:: lfs_boot/usb.conf
   :caption: 创建 ``/etc/modprobe.d/usb.conf``

设置GRUB
==========

.. warning::

   由于我使用EFI引导，所以这段参考BLFS的 `Using GRUB to Set Up the Boot Process with UEFI <https://www.linuxfromscratch.org/blfs/view/12.2/postlfs/grub-setup.html>`_

内核UEFI支持配置
------------------

在内核配置中启用UEFI支持

.. literalinclude:: lfs_boot/kernel_uefi
   :caption: 内核UEFI支持配置

创建紧急救援启动磁盘
----------------------

这段创建一个启动U盘的工作我没有做，如有需要参看原文

找到或创建EFI系统分区
---------------------------

EFI系统中，bootloader是安装在一个特殊的称为 ``EFI System Partition(ESP)`` FAT32分区。通常已经有Linux安装或者Windows安装的系统，可能已经创建好了ESP分区。

- (这步我没有做，因为我已经有一个ESP分区挂载到 ``/boot`` )如果是首次构建系统，创建以下ESP分区(案例是 ``/dev/sda`` )

.. literalinclude:: lfs_boot/esp
   :caption: 创建ESP分区

- (我没有做)对应配置 ``/etc/fstab`` :

.. literalinclude:: lfs_boot/fstab_esp
   :caption: ESP分区挂载配置

在我的实践中，我的磁盘分区是在 ``/dev/nvme0n1`` 上划分的两个分区，分区1是 ESP 分区，已经在 :ref:`lfs_partition` 中完成过了。

GRUB和EFI的最小化启动配置
----------------------------

在基于 UEFI 的系统上，GRUB 通过将 EFI 应用程序（一种特殊的可执行文件）安装到 ESP 中来工作。EFI 固件将从记录在 EFI 变量中的引导条目以及 **硬编码路径** ``EFI/BOOT/BOOTX64.EFI`` 中搜索 EFI 应用程序中的引导加载程序。

要在硬编码路径 ``EFI/BOOT/BOOTX64.EFI`` 中安装带有 EFI 应用程序的 GRUB，首先确保启动分区安装在 ``/boot`` 上，``ESP`` 安装在 ``/boot/efi`` 上。

.. note::

   注意，如果ESP分区挂载在 ``/boot/efi`` 目录，那么 ``grub-install`` 不需要任何参数。但是，我的 ESP 分区改在在 ``/boot`` 分区，直接执行 ``grub-install`` 会提示找不到 EFI 目录。这个问题在 :ref:`gentoo_grub` 已经有实践经验。

我在 :ref:`gentoo_grub` 有实践记录，所以这里参考执行行如下(需要指定安装路径):

.. literalinclude:: lfs_boot/grub-install
   :caption: 安装EFI

.. note::

   **这段话非常重要，请仔细体会**

   从GRUB视角来看，内核文件的位置相对于它使用的分区:

   - 如果使用独立的 ``/boot`` 分区(ESP分区挂载到 ``/boot`` 上)，那么 grub 和boot分区在一个磁盘分区起点( ``/boot`` 为起点)，从grub角度看内核和它是并列的，所以此时内核位置是 ``/vmlinuz-6.10.5-lfs-12.2`` ，也就是要去掉 ``/boot`` -- 请注意 :ref:`archlinux_on_mbp` 就是这种方式)
   - 如果没有使用独立的 ``/boot`` 分区，也就是ESP分区是挂载到 ``/boot/efi`` 上，那么分区起点就是 ``/`` ，此时从grub看分区访问内核的路径就是 ``/boot/vmlinuz-6.10.5-lfs-12.2`` 。这种方式是发行版主要采用的方式，都是采用 ``ESP`` 分区挂载为 ``/boot/efi`` ，所以你在 ``/boot/grub/grub.cfg`` 中看到的配置是 ``/boot/vmlinuz-6.10.5-lfs-12.2``

.. note::

   为了确保主机磁盘增减时候GRUB访问磁盘分区引导依然正确，应该将 ``/dev/sda`` 这样的设备路径改为分区和文件系统的UUID:

   - ``set root=(hdx,y)`` 替换为 ``search --set=root --fs-uuid <内核所在文件系统的 UUID>`` (注意是 **磁盘文件系统UUID**
   - ``root=/dev/sda2`` 替换为 ``root=PARTUUID=<构建 LFS 使用的分区的 UUID>`` (注意是 **分区UUID** )

   上述 ``search --set=root ...`` 方法在主流发行版 :ref:`ubuntu_linux` 上就是这么设置的，可以参考


挂载EFI变量文件系统(efivars)
-------------------------------

.. note::

   我在 :ref:`ubuntu_linux` 系统上看到默认就是挂载 ``efivars`` 文件系统，但是没有配置 ``/etc/fstab`` 就能挂载，可能是在其他地方有配置。我这里按照LFS的文档来完成

在UEFI平台安装GRUB需要EFI变量文件系统(EFI Variable file sysem, ``efivarfs``)挂载。所以这里执行:

.. literalinclude:: lfs_boot/mount_efivars
   :caption: 挂载 ``efivarifs``

这个信息似乎是因为我的Host主机 :ref:`ubuntu_linux` 已经挂载了 ``efivarfs``

.. literalinclude:: lfs_boot/fstab_efivars
   :caption: ``/etc/fstab`` 中添加 ``efivarifs`` 配置

设置配置
-----------

我这里的ESP分区挂载在 ``/boot`` 不是标准的方法，后续实践应该挂载为 ``/boot/efi`` 

建议系统安装 ``efibootmgr`` ，这样就能够执行 ``efibootmgr | cut -f 1`` 检查EFI中启动配置

.. literalinclude:: lfs_boot/efibootmgr
   :caption: 当前系统 ``efibootmgr`` 内容
   :emphasize-lines: 19,22

可以看到，我的系统启动优先级是 ``Boot0002  System Utilities`` => ``Boot0008* Generic USB Boot`` => ``Boot000F* ubuntu`` ...

:strike:`也就是为何我现在系统能够进入Ubuntu，是因为它排在第三启动顺序`

我现在的LFS系统安装在 ``Boot0012* Slot 2 : NVM Express Controller - PHBT85100270016N   -INTEL MEMPEK1J016GAL                   -D5E4D25C``

这里启动的第一顺序是 ``Boot0002  System Utilities`` ，在HP服务器的iLO管理界面，通过调整系统启动磁盘顺序，就是调整这个 ``System Utilities`` 启动顺序(不过在 ``efibootmagr`` 中看不到)

不过，最好还是通过 ``efibootmgr`` 在命令好解决，类似 :ref:`gentoo_linux` 安装实践

.. note::

    我实际是通过HP服务器的iLO启动顺序来管理的

创建GRUB配置
----------------

``/boot/grub/grub.cfg`` 配置文件中 ``root=`` 配置部分需要根据实际情况调整，我这里采用了UUID指定磁盘分区2，这个UUID也就是 ``/etc/fstab`` 中的配置

.. literalinclude:: lfs_boot/grub.cfg
   :caption: 创建 ``/boot/grub/grub.cfg`` 配置文件

这里我添加了2行配置GRUB串口输出，参考 `How does one set up a serial terminal and/or console in Red Hat Enterprise Linux? <https://access.redhat.com/articles/3166931>`_

异常排查
============

启动以后Grub菜单页面显示之后，一旦选择并回车进入选项，则提示:

.. literalinclude:: lfs_boot/grub_not_found_vmlinuz
   :caption: 提示无法找到vmlinuz内核

但是没有进一步提示，我不确定是不是磁盘挂载问题

我尝试把 ``grub.cfg`` 配置项复制到同一台服务器的 ``ubuntu`` 磁盘的 ``grub.cfg`` 配置中，然后在 :ref:`hpe_dl360_gen9` 的 :ref:`hp_ilo` WEB管理界面中调整启动磁盘顺序，将 ``ubuntu`` 磁盘调整到前面。

这次 ``ubuntu`` 磁盘启动的gurb有详细信息，显示出错误内容:

.. literalinclude:: lfs_boot/grub_ubuntu_not_found_vmlinuz
   :caption: 切换到ubuntu磁盘启动后grub信息
   :emphasize-lines: 6

这个问题在LFS文档中其实有说明，需要仔细阅读理解:

- 关键点是 ``set root`` 指定哪个磁盘文件系统来搜索内核，我最初照抄文档中 ``set root=(hd0,2)`` 存在的问题是我的服务器有多块硬盘，启动以后存在LFS的磁盘并不一定会固定是额卑微 ``hd0`` ，所以应该修订为 ``search --set=root --fs-uuid <内核所在文件系统的 UUID>``
- 另一个关键点是 ``ESP`` 分区是挂载为 ``/boot`` 还是 ``/boot/efi`` ，这决定了内核获取从磁盘分区开始计算到底要不要包含 ``/boot`` (见上文)
- **我已经修订上文的配置文件**

最终完成
===========

最终成功后的服务器登陆后检查

.. literalinclude:: lfs_boot/df
   :caption: 磁盘使用
   :emphasize-lines: 3,7

可以看到一个基础的Linux系统只需要 ``1.6G`` 磁盘就可以运行起来

.. literalinclude:: lfs_boot/meminfo
   :caption: 内存使用

:ref:`linux_memory_management` 需要分析
