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

.. note::

   Gentoo也和其他发行版一样提供了直接可以运行的编译好的标准执行内核 ``gentoo-kernel-bin`` ，可以方便快速完成系统安装和启动。一旦系统安装和工作正常，就可以开始自定义编译内核，同时保留 ``sys-kernel/gentoo-kernel-bin`` 用于在自定义内核启动失败时应急修复。

Gentoo 提供了以下几种支持的内核软件包:

- ``gentoo-sources`` 推荐大多数Gentoo用户使用(既然已经选择了Gentoo)，能够最大化定制系统内核
- ``gentoo-kernel`` 适合大多数系统的内核，采用通用配置每次自动完成编译，适合对编译内核不感兴趣的用户

  - ``gentoo-kernel-bin`` 是官方提供已经编译好的通用内核，直接安装无需每次 :ref:`upgrade_gentoo` 时编译
  - **个人推荐** 安装 ``gentoo-kernel-bin`` :
  
    - 发行版提供的通用编译内核可以作为系统救援内核，一旦自己定制内核出现错误无法启动，则可以切换到官方内核进行修复
    - 我们总是会使用自己编译的内核(使用Gentoo的目标之一)，所以再安装一个官方通用内核源代码编译意义不大：安装了 ``gentoo-kernel`` 源代码包会导致每次 :ref:`upgrade_gentoo` 都会花费一两个小时编译内核，浪费时间

- ``git-sources`` 这是从上游内核开发源代码上每天自动生成的软件包

``genkernel`` 工具默认激活了通用选项和驱动，完全自动化，适合不熟悉手工编译内核的用户

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

分发内核(Distribution kernels)
=================================

`distribution kernel project <https://wiki.gentoo.org/wiki/Project:Distribution_Kernel>`_ 提供了通过Portage安装和管理的内核。这些内核是已经编译过多(如果需要)并且就像其他软件包一样使用 :ref:`gentoo_emerge` 命令安装，可以减轻管理负担。内核更新可以在更新系统时候( ``emerge -avuDN @world`` )完成，并且只有配置bootloader使用新内核时候才需要手动步骤。

不过， ``distribution kernels`` 使用了符合大多数系统的通用配置，所以可以视为 "仅能工作" 而已。那些对内核编译不感兴趣的用户可以使用 ``distribution kernels`` ，以避免自己配置编译内核的繁重工作。

.. note::

   ``virtual/dist-kernel`` 并不是一个实际的源代码软件包，而是为 ``sys-kernel/gentoo-kernel`` 提供了一个通用配置的编译选项。这样每次更新 ``sys-kernel/gentoo-kernel`` 就会自动编译一个通用的分发内核。这个内核可以作为应急救援使用，假设自己的定制内核无法正常工作，就可以切换到这个分发内核进行修复。
   
``unstable`` 切换 ``stable`` 后对 ``dist-kernel`` 切换
-------------------------------------------------------

我在解决 :ref:`gentoo_sway_fcitx` 和 :ref:`gentoo_kde_fcitx` 时，为了安装 :ref:`gentoo_overlays` 的第三方仓库软件，启用了 :ref:`gentoo_makeconf` 的 ``unstable`` 全局参数 ``~amd64`` 。但是，系统去除了 ``~amd64`` 之后，执行 :ref:`upgrade_gentoo` 之后，出现了同时安装 ``

.. literalinclude:: gentoo_kernel/multi_kernel
   :caption: 系统同时安装了多个kernel版本，且 ``gentoo-kernel`` 和 ``gentoo-kernel-bin`` 冲突
   :emphasize-lines: 1,3

我想将系统内核降级到 6.6.13，但是 ``virtual/dist-kernel`` 指向 ``gentoo-kernel-6.7.1`` 导致我无法 ``emerge -acv sys-kernel/gentoo-kernel`` (卸载)，始终报错: 提示 ``virtual/dist-kernel`` 依赖 ``sys-kernel/gentoo-kernel``

参考 `Dist Kernel 6.1.69 <https://forums.gentoo.org/viewtopic-p-8812316.html?sid=32207a34bf01e1e2c3c96d8d95027573>`_ 案例:

- 首先需要 ``emerge --deselect`` :

.. literalinclude:: gentoo_kernel/emerge_deselect
   :caption: ``emerge --deselect`` 掉 ``gentoo-kernel``

此时输出显示:

.. literalinclude:: gentoo_kernel/emerge_deselect_output
   :caption: ``emerge --deselect`` 掉 ``gentoo-kernel`` 输出显示 ``gentoo-kernel`` 以及从world favorites文件中remove

- 然后完成一次完整的 :ref:`upgrade_gentoo` :

.. literalinclude:: upgrade_gentoo/emerge_world_short
   :language: bash
   :caption: 使用emerge升级整个系统(简化参数)

此时由于去除了 ``~amd64`` 全局参数之后，整个系统软件包回归到 ``stable`` 状态，并修正了依赖关系。再次执行 ``emerge -acv sys-kernel/gentoo-kernel`` 就可以顺利完成。

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
- `gentoo wiki: Handbook:AMD64/Blocks/Kernel <https://wiki.gentoo.org/wiki/Handbook:AMD64/Blocks/Kernel>`_
