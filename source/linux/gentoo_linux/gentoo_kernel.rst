.. _gentoo_kernel:

=====================
Gentoo内核编译
=====================

.. note::

   Gentoo文档非常详细，我无法完整翻译，只能选择部分自己的需要以及理解进行综合。此外会加上自己的实践经验(基于我现有硬件以及软件需求)

手动配置内核
=================

Gentoo为用户提供了 **两种** 内核配置、安装和升级的方式:

- 自动(genkernel) ，也就是我在 :ref:`install_gentoo_on_mbp` 快速采用的内核安装方法 :ref:`gentoo_genkernel`
- 手动(manual) ，大多数Gentoo用户会选择手动配置内核:

  - 更大的灵活性
  - 更小的（内核）尺寸
  - 更短的编译时间
  - 学习经历
  - ``闲着无聊``
  - 内核配置的绝对知识，和/或
  - 对内核的完全控制

由于编译内核的选项实在太繁杂了，我主要是为自己的硬件裁剪内核，所以考虑分两个步骤(阶段):

- 先使用 :ref:`gentoo_kernel` 对内核主要功能进行 **粗略裁剪**
- 再通过手工调整方法，对内核细节进行微调

配置概念
=========

内核配置即简单又不简单:

- 通过 ``make menuconfig`` 可以从交互菜单选择，系统会自动做一些关联配置，所以还是比较傻瓜化的
- 内核包含的默认值一半是通用且合理的，也就是大多数用户只需要对基本配置做少量改动
- 在配置内核时，应该循序渐进，每次少量修改默认配置，并进行充分编译和运行验证

内置(build-in) vs. 模块化(modular)
-----------------------------------

大多数配置选项都是三态的(tristate)：

- 根本不构建 (N)
- 直接构建到内核中 (Y) 
- 构建为模块 (M)。

一般规则:

- 建议将硬件支持(还需要在内核中包含固件支持)和内核功能直接构建到内核中。 然后内核可以确保功能和硬件支持在需要时可用。
- 部分功能，例如重要分区的文件系统支持，应该直接构建到内核中(使用模块化会需要 initramfs 支持)

硬件
-------

- 使用 ``lspci`` ( ``sys-apps/pciutils`` 包) 和 ``lsusb`` ( ``sys-apps/usbutils`` 包)来识别硬件
- 通常以太网适配器必须识别以太网芯片并为特定网卡配置硬件支持
- 建议将非必须的驱动程序配置为模块(例如偶然使用的外接设备)

内核功能
---------

- 对于磁盘文件系统支持(我选择主要支持 ``vfat`` / ``xfs`` / ``zfs`` / ``ext`` )
- 高级网络功能(路由或防火墙)

内核源代码
===========

Gentoo 提供了以下几种支持的内核软件包:

- ``genkernel`` 默认激活了通用选项和驱动，完全自动化，适合不熟悉手工编译内核的用户
- ``gentoo-sources`` 推荐大多数Gentoo用户使用(既然已经选择了Gentoo)，能够最大化定制系统内核
- ``gentoo-kernel`` 已经预先编译好的适合大多数系统的内核，适合对编译内核不感兴趣的用户
- ``git-sources`` 这是从上游内核开发源代码上每天自动生成的软件包

此外，还有一些不被(官方)支持的内核软件包

- 安装内核源代码:

.. literalinclude:: gentoo_kernel/install_gentoo-sources
   :language: bash
   :caption: 安装 ``gentoo-sources`` 源代码包

- 配置内核:

  - :ref:`gentoo_mbp_kernel`
  - :ref:`gentoo_mbp_wifi`
  - :ref:`gentoo_nvidia`

.. literalinclude:: gentoo_kernel/menuconfig
   :language: bash
   :caption: 配置内核源代码编译选项

- 编译内核和安装内核(和模块):

.. literalinclude:: gentoo_kernel/kernel_make_install
   :language: bash
   :caption: 编译内核并安装

更新boot loader
=================

如果使用GRUB，则执行以下命令::

   grub-mkconfig -o /boot/grub/grub.cfg

由于我在 :ref:`install_gentoo_on_mbp` 采用了 :ref:`archlinux_on_mbp` 相同的 ``efibootmgr`` 管理UEFI启动顺序，所以执行以下命令配置EFI启动:

.. literalinclude:: install_gentoo_on_mbp/efibootmgr_set_xcloud
   :language: bash
   :caption: 设置efibootmgr启动定制xcloud内核

.. note::

   这里没有使用 :ref:`initramfs` ( :ref:`ramfs` 的特例 ) ，如果有需要在内核启动时预先加载的内核模块，例如 :ref:`linux_lvm` 或 :ref:`zfs` 作为根卷，或者需要使用特定的文件系统，都需要采用 :ref:`ramfs` 预先加载内核模块或者维护工具。

.. warning::

   建议将关键文件系统直接编译进内核：例如我使用XFS作为根文件系统，但是默认内核配置 ``xfs`` 是作为模块编译的，这导致要么使用 :ref:`initramfs` 要么就必须直接编译进内核，否则重启系统无法工作。

修复和挽救
===========

实际上，内核裁剪和构建总是会遇到各种问题，导致系统无法启动。此时，我们需要采用 :ref:`install_gentoo_on_mbp` 的挂载并 ``chroot`` 步骤，重新进入系统进行排障:

- 通过Gentoo 安装U盘再次启动启动，然后启动sshd服务并且设置好root密码:

.. literalinclude:: install_gentoo_on_mbp/gentoo_livecd_sshd
   :language: bash
   :caption: 启动Gentoo Linux安装的sshd服务

- 挂载 root 分区文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_gentoo_fs
   :language: bash
   :caption: 挂载文件系统

- 挂载文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_fs
   :language: bash
   :caption: 挂载文件系统

- 进入Gentoo新环境:

.. literalinclude:: install_gentoo_on_mbp/chroot
   :language: bash
   :caption: 进入Gentoo新环境

- 挂载boot分区(这个分区是MacBook的macos和gentoo公用的):

.. literalinclude:: install_gentoo_on_mbp/mount_boot
   :language: bash
   :caption: 挂载 /boot

现在所有环境恢复磁盘上Gentoo Linux的运行状态，除了内核采用了LiveCD提供内核，整个文件系统都是磁盘上文件系统。就可以从新开始内核配置和编译了，可以尝试重新开始内核构建。

参考
======

- `Kernel/Gentoo Kernel Configuration Guide <https://wiki.gentoo.org/wiki/Kernel/Gentoo_Kernel_Configuration_Guide>`_
- `Kernel/Overview <https://wiki.gentoo.org/wiki/Kernel/Overview>`_
- `Kernel/Rebuild <https://wiki.gentoo.org/wiki/Kernel/Rebuild>`_
