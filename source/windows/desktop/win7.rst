.. _win7:

===============
Windoes 7
===============

我有一台非常古老的 :ref:`thinkpad_x220` ，但是依然能够运行Linux作为 :ref:`mobile_cloud` 。为了能够偶尔运行Windows程序应对特殊需求，我也同时安装Windows 7系统。笔记本自带OEM版本Windows 7，由于硬件古老没有必要再升级到Windows 10/11了(我也不需要花里胡哨的功能)。

安装镜像
==========

笔记本是从公司自购的二手设备，需要自己安装操作系统，所以搜索了一下，目前微软已经不再提供Windows 7的镜像下载了，需要从 `Internet Archive <https://archive.org/>`_ 找寻下载资源:

- `archive.org 下载: Windows 7 Professional SP1 (32 bit and 64 bit ISOs) <https://archive.org/details/win-7-pro-32-64-iso>`_ 提供了64位(3.1G)和32位(2.4G)这个版本似乎比较小，时间戳是2020年6月16日上传，网友的评论信息也很全面，应该是比较好的版本(评论中有人提供了product keys) **我选择这个版本**
- `archive.org 下载: 7601.24214.180801 1700.win 7sp 1 Ldr Escrow CLIENT PROFESSIONAL X 64 FRE En Us <https://archive.org/details/7601.24214.1808011700.win7sp1ldrescrowclientprofessionalx64freenus>`_ 提供了64位(5.5G)和32位(3.8G)两个镜像。这个版本应该是微软最新的安装镜像，非常庞大，安装以后占据15.5GB(有人提供的信息)，但是使用者信息较少， **我没有选择这个版本**

.. note::

   我的实践发现，实际上Win7默认安装以及自动更新后系统空间确实非常庞大，我分配了20G磁盘(实际大约为18.xG)，结果安装完成后整个磁盘完全被占满，只剩下哦不到1M空间(我也不知道为何会这样)。导致我饿甚至无法下载任何文件。

reddit上有一个帖子 `windows 7 official downloads <https://www.reddit.com/r/windows7/comments/ocdtyu/windows_7_official_downloads/>`_ 提供了微软官方下载链接索引(未验证)

硬件需求
============

根据微软官方 `Windows 7 system requirements <https://support.microsoft.com/en-us/windows/windows-7-system-requirements-df0900f2-3513-a851-13e7-0d50bc24e15f>`_ , Windows 7对硬件需求:

- 1 gigahertz (GHz) or faster 32-bit (x86) or 64-bit (x64) processor
- 1 gigabyte (GB) RAM (32-bit) or 2 GB RAM (64-bit)
- 16 GB available hard disk space (32-bit) or 20 GB (64-bit)
- DirectX 9 graphics device with WDDM 1.0 or higher driver

我在 :ref:`priv_cloud_infra` 部署 :ref:`kvm` 环境中运行，分配 ``2c4g`` 规格

安装
========

:ref:`deploy_win_vm`

磁盘空间释放
================

关闭Virtual Mmeory
-------------------

Windows 7默认安装非常占用空间，甚至把我的C盘完全占满了。不得已，我做了一些磁盘空间优化:

- 关闭Virtual Memory(Paging File) : 参考 `How to turn off Virtual Memory (Paging File) in Windows 7 <https://www.microcenter.com/tech_center/article/5413/how-to-turn-off-virtual-memory-(paging-file)-in-windows-7>`_

  - 关闭Paging File后释放了大约5.4GB空间

关闭System Restore
---------------------

System Restore是Windows为了防范错误安装软件包的回滚机制，可以在异常时回退到前一次安装状态。这个功能非常虽然有用，但是非常占用磁盘空间，特别是大量的补丁升级之后，更是占用空间。

清理旧Windows升级文件
-----------------------

Windows会在操作系统目录下保存很多升级文件，如果磁盘空间充足确实不需理会，而且这些系统文件提供了补丁安装的回滚功能。不过，对于有限的磁盘空间， :ref:`delete_old_win_update_files` 能够释放宝贵的虚拟磁盘空间。

虚拟机备份
=============

我构建的 ``z-win7`` 虚拟机是在 :ref:`ceph_rbd` 上构建的存储，可以按照 :ref:`clone_vm_rbd` 来备份初始安装并升级好的Windows虚拟机(安装太花费时间了)。对于需要在不同系统中迁移虚拟机，可以采用 :ref:`ceph_rbd_export_import` 或者 :ref:`ceph_rbd_transfer_between_two_clusters`

虚拟磁盘扩容
=============

我初始配置的磁盘给予20GB，但是明显不够长期运行，所以增加扩容10GB，以便能够 :ref:`install_vgpu_license_server`

参考
======

- `archive.org 提供下载: Windows 7 Professional SP1 (32 bit and 64 bit ISOs) <https://archive.org/details/win-7-pro-32-64-iso>`_ 评论中也提供了很多使用经验，包括Intel文档 `Install Windows 7 on USB 3.0 Computers <https://www.intel.com/content/dam/support/us/en/documents/mini-pcs/nuc-kits/Install-Win7-to-USB3_0-Computers.pdf>`_ (Windoes 7没有内置USB 3.0驱动，但是Intel NUC只有USB 3.0接口)
- `How to Free Up Disk Space: 7 Useful Hacks <https://www.hp.com/hk-en/shop/tech-takes/post/7-hacks-free-up-space-hard-drive>`_
- `Guide to Freeing up Disk Space under Windows 7 <https://www.hanselman.com/blog/guide-to-freeing-up-disk-space-under-windows-7>`_
