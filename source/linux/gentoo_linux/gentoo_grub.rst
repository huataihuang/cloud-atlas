.. _gentoo_grub:

=====================
Gentoo GRUB
=====================

GRUB是一个多启动 **第二启动加载器** ``multiboot secondary bootloader`` ，用于在系统架构的不同文件系统中加载内核。GRUB支持PC BIOS, PC EFI, IEEE 1275(Open Firmware), SPARC 以及 MIPS Lemote Yeeloong。

GRUB也就是 ``GRUB 2`` 替代了早期的 ``GRUB Legancy`` (GRUB 1)，提供了完全独立的代码，带来新的类似shell的语法用于高级脚本。

安装GRUB软件包
================

在 ``make.conf`` 中 ``GRUB_PLATFORMS`` 变量控制了 ``grub-install`` 安装目标。 ``amd64`` 架构包含了可以用于大多数西欧图能够的默认profile。(见下文)

- 以下配置案例针对 ``EMI`` ``EFI`` 和 ``PC`` 平台(BIOS):

.. literalinclude:: gentoo_grub/make.conf
   :caption: 针对 ``EMI`` ``EFI`` 和 ``PC`` 平台的配置 ``/etc/portage/make.conf``

我的系统是 :ref:`install_gentoo_on_mbp` 所以只需要支持EFI，配置 ``/etc/portage/make.conf`` 支持 EFI 64位:

.. literalinclude:: gentoo_grub/make_efi.conf
   :caption: MacBook Air/Pro 只需要平台的配置 ``/etc/portage/make.conf``

USE flags
-----------

一些有用的参数:

- ``device-mapper`` 通过 ``sys-fs/lvm2`` 支持 ``device-mapper``
- ``doc`` 添加附加文档
- ``efiemu`` 编译安装 ``efiemu`` 运行时
- ``fonts`` 编译安装用于gfxterm模块的字体
- ``libzfs`` 支持 ``sys-fs/zfs``
- ``mount`` 编译和安装 ``grub-mount`` 工具
- ...

比较重要的是 ``device-mapper`` 和 ``libzfs`` ，后续可以在相应环境中实践

:ref:`gentoo_emerge`
-----------------------

- ``emerge`` 使用 ``--newuse --deep`` 以便能够在修改 :ref:`gentoo_makeconf` 配置参数之后重新构建:

.. literalinclude:: gentoo_grub/emerge
   :caption: ``emerge`` 使用 ``--newuse --deep`` 参数安装grub

附件软件
-----------

os-prober
~~~~~~~~~~~

``os-prober`` 工具能够帮助检测系统中的其他操作系统，并且在 ``grub-mkconfig`` 命令运行时自动生成GRUB配置，对于多启动系统非常方便:

.. literalinclude:: gentoo_grub/os-prober
   :caption: 安装 ``os-prober`` 帮助检测系统中其他OS

.. note::

   由于安全原因， ``os-prober`` 默认禁用。在 ``/etc/default/grub`` 配置中添加 ``GRUB_DISABLE_OS_PROBER=false`` 来激活

libisoburn
~~~~~~~~~~~~

``grub-mkrescue`` 工具需要 ``dev-libs/libisoburn`` 支持，如果需要可以安装:

.. literalinclude:: gentoo_grub/libisoburn
   :caption: 安装 ``libisoburn`` 支持 ``grub-mkrescue`` 工具

mdadm
~~~~~~~~~

对于支持检测RAID设备，则需要安装 ``sys-fs/mdadm`` :

.. literalinclude:: gentoo_grub/mdadm
   :caption: 安装 ``sys-fs/mdadm`` 支持RAID检测

安装GRUB Bootloader
=======================

- UEFI with GPT
- BIOS with MBR

UEFI with GPT
================

.. warning::

   对于早期的64位系统，例如早期MacBooks(Intel Core 2)以及2010年之前的Windows电脑，实际使用的是32位EFI，此时需要激活 ``efi-32`` 来作为32位软件运行，修正GRUB平台。

.. note::

   如果UEFI使用了CSM标准(Compatibility Support Module, 兼容支持模块)，那么会让UEFI特性就像BIOS。在firemware设置时，用户接口通常被称为 “传统模式" 或 "兼容模式" 。

UEFI with GPT分区
-------------------

UEFI系统从一个微软便携执行格式(PE32+标准)的 ``EFI System Partition(ESP)`` 分区启动执行文件( ``.efi`` 文件)。EFI系统分区可以是任意大小。

.. warning::

   对于UEFI GPT启动，系统必须使用一个包含FAT文件系统的独立ESP分区。

在EFI系统分区，只有bootloader的 ``.efi`` 文件是必须的。不过，通常在 ``/boot`` 挂载目录会包含内核，以及 :ref:`initramfs` (如果需要)，以及GRUB配置和支持文件。

.. note::

   EFI系统分区通常挂载为 ``/boot`` , ``/boot/efi`` 或者 ``/efi`` 。这样内核，initramfs以及bootloader支持文件可以存储在独立的分区和文件系统，或者存储在根文件系统自身。但是存储在根文件系统，会要求GRUB访问根文件系统来读取相应文件，有时候是非常难以设置和实现的(例如根文件系统是加密系统)。所以，通常我们采用独立分离的分区和独立文件系统挂载。

我在 :ref:`install_gentoo_on_mbp` 中(Mabook Air)采用了UEFO with GPT方式分区，注意 **EFI分区是fat32格式** :

.. literalinclude:: install_gentoo_on_mbp/parted_sata_rootfs
   :language: bash
   :caption: MBA 13存储: 对SATAe磁盘(128G)分区和格式化
   :emphasize-lines: 5,6,16

分区挂载配置 ``/etc/fstab`` 注意分区文件系统是 ``vfat``  :

.. literalinclude:: install_gentoo_on_mbp/fstab_mba13
   :language: bash
   :caption: :ref:`mba13_mid_2013` 使用UUID配置 /etc/fstab
   :emphasize-lines: 2

为EFI安装GRUB
----------------

.. note::

   Gentoo的 ``amd64`` profile已经设置了 ``GRUB_PLATFORMS`` 变量，并且 ``grub-install`` 通常可以自己获知是否要为EFI安装GRUB，还是要为BIOS with MBR / BIOS with GPT安装GRUB。所以，通常在 ``/etc/portage/make.conf`` 配置 ``GRUB_PLATFORMS`` 不是必须的。用户通常在 ``make.conf`` 设置这个变量是为了匹配他们主机系统，以便 ``emerge sys-boot/grub`` 安装更少的文件。

在安装GRUB之前， ``EFI系统分区`` 必须已经挂载。如果在 ``fstab`` 中已经配置，该分区就可以挂载到相应挂载点。

``grub-install`` 复制GRUB支持文件到 ``/boot/grub`` 目录，GRUB的PE32+执行程序到 ``\EFI\gentoo`` 目录，命名为 ``grubx64.efi`` (如果ESP挂载到 ``/efi`` 目录下，那么完整文件路径就是 ``/efi/EFI/gentoo/grubx64.efi`` ；对于我的实践，ESP挂载目录是 ``/boot`` 目录，完整文件路径是 ``/boot/EFI/gentoo/grubx64.efi`` 。

然后， ``grub-install`` 会调用 ``efibootmgr`` 加入一个启动入口(我之前在 :ref:`install_gentoo_on_mbp` 是直接添加内诶和挂载目录)

.. note::

   要使得 ``grub-install`` 能够正确调用 ``efibootmgr`` ，必须以读写方式挂载 ``efivarfs`` pseudo文件系统，然后再使用 ``grub-install`` 命令。如果 ``pseudo-filesystem`` 被编译成内核模块，则 ``efivarfs`` 内核模块必须加载:

   - 检查 ``efivarfs`` 内核模块:

   .. literalinclude:: gentoo_grub/efivarfs
      :caption: 检查 ``efivarfs`` 内核模块是否加载

   输出类似:

   .. literalinclude:: gentoo_grub/efivarfs_output
      :caption: 检查 ``efivarfs`` 内核模块输出信息

   - 检查 ``efivarfs`` pseudo文件系统挂载:

   .. literalinclude:: gentoo_grub/efivarfs_mount
      :caption: 检查 ``efivarfs`` pseudo文件系统挂载

   输出类似:

   .. literalinclude:: gentoo_grub/efivarfs_mount_output
      :caption: 检查 ``efivarfs`` pseudo文件系统挂载输出信息
   
如果ESP挂载在 ``/boot/efi`` 目录，则可以不加任何参数直接运行 ``grub-install`` :

.. literalinclude:: gentoo_grub/grub-install
   :caption: 直接运行 ``grub-install``

不过，正如我在 :ref:`install_gentoo_on_mbp` 实践，我的EFI系统分区是挂载到 ``/boot`` 目录的，所以这里会有一个报错，显示找不到EFI目录:

.. literalinclude:: gentoo_grub/grub-install_error
   :caption: 非 ``/efi`` 挂载目录，直接运行 ``grub-install`` 会出现报错
   :emphasize-lines: 2

只需要通过 ``--efi-directory`` 参数传递EFI系统分区挂载的目录参数就可以，例如我的案例是挂载到 ``/boot`` 目录，则执行:

.. literalinclude:: gentoo_grub/grub-install_boot_dir
   :caption: EFI系统分区挂载在 ``/boot`` 目录，通过 ``--efi-directory`` 参数运行 ``grub-install``

如果一切正常，则输出如下:

.. literalinclude:: gentoo_grub/grub-install_boot_dir_output
   :caption: EFI系统分区挂载在 ``/boot`` 目录，通过 ``--efi-directory`` 参数运行 ``grub-install`` 输出信息

.. note::

   默认情况下，GRUB安装系统的目标平台。但是如果使用了其他系统平台，例如主机是CSM模式启动，也就是EFI采用了BIOS with GPT模拟，则需要采用参数 ``--target=x86_64-efi`` 参数，或者 ``--target=i386-efi`` (32位UEFI target)

.. note::

   对于可移动介质(例如U盘)，需要使用参数 ``--removable`` 。此时安装到 ``\EFI\BOOT`` 目录下的ESP文件名是 ``BOOTX64.efi`` (如果ESP挂载为 ``/efi`` 则完整文件路径名是 ``/efi/EFI/BOOT/BOOTX64.efi`` )。注意，这个参数仅建议用于移动介质，或者主机使用了有限制的UEFI firmware不支持任意路径名的情况。

BIOS with MBR
================

现代主机大都支持和使用UEFI，可能在虚拟机中会遇到使用BIOS的情况，待后续补充

BIOS with GPT
================

``GPT/MBR hybrid partitions`` 情况比较特殊，以后有机会再补充实践

类似Windows双启动案例，也是等有机会再实践

配置GRUB
===========

``grub-mkconfig`` 脚本会自动生成grub配置:

- 和早期的 ``GRUB Legacy`` 和 ``LILO`` 不同，通常不需要手工配置GRUB配置
- ``grub-mkconfig`` 会结合使用 ``/etc/grub.d/*`` 目录下配置和 ``/etc/default/grub`` 配置文件来生成正确的 ``/boot/grub/grub.cfg`` (GRUB自身唯一使用的配置文件)
- 管理员通常只需要调整 ``/etc/default/grub`` 配置

执行配置非常简单:

.. literalinclude:: gentoo_grub/grub-mkconfig
   :caption: 使用 ``-o`` 参数指定 ``grub-mkconfig`` 输出的配置文件

输出:

.. literalinclude:: gentoo_grub/grub-mkconfig_output
   :caption: 输出信息举例


参考
======

- `gentoo linux wiki: GRUB <https://wiki.gentoo.org/wiki/GRUB>`_
