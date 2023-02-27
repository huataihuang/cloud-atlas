.. _gentoo_kernel:

=====================
Gentoo内核编译
=====================

.. note::

   Gentoo文档非常详细，我无法完整翻译，只能选择部分自己的需要以及理解进行综合。此外会加上自己的实践经验(基于我现有硬件以及软件需求)

手动配置内核
=================

Gentoo为用户提供了 **两种** 内核配置、安装和升级的方式:

- 自动(genkernel) ，也就是我在 :ref:`install_gentoo_on_mbp` 快速采用的内核安装方法
- 手动(manual) ，大多数Gentoo用户会选择手动配置内核:

  - 更大的灵活性
  - 更小的（内核）尺寸
  - 更短的编译时间
  - 学习经历
  - ``闲着无聊``
  - 内核配置的绝对知识，和/或
  - 对内核的完全控制

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

参考
======

- `Kernel/Gentoo Kernel Configuration Guide <https://wiki.gentoo.org/wiki/Kernel/Gentoo_Kernel_Configuration_Guide>`_
- `Kernel/Overview <https://wiki.gentoo.org/wiki/Kernel/Overview>`_
