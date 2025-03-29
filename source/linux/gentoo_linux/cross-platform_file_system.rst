.. _cross-platform_file_system:

==================================
跨平台文件系统(MAC/Windows/Linux)
==================================

我 :ref:`install_gentoo_on_mbp` 采用双启动方式，一台物理主机上可以切换运行 :ref:`macos` 和 :ref:`gentoo_linux` 。此外，我有一个2TB的移动硬盘用于数据备份。这就存在一个问题，如何在不同操作系统之前共享数据存储?

虽然Linux/macOS都支持SMB和NFS，但是总是需要有一个复杂的服务器搭建过程，对于离线备份(移动硬盘)也不方便。所以，考虑采用跨平台的文件系统来实现文件共享:

- 多种操作系统支持的文件系统
- 支持大容量硬盘分区

其实主流的MAC/Windows/Linux内置支持的文件系统只有: ``FAT32`` 和 ``exFAT``

其他文件系统都是通过第三方工具来实现的:

- NTFS(Windows):

  - Linux使用 NTFS-3G
  - macOS使用 NTFS for Mac by Paragon

- EXT4(Linux):

  - macOS使用 extFS for Mac by Paragoan (我还真购买了正版 ^_^ )

选择
========

- ``FAT32`` 是最成熟的传统文件系统，在各个平台都有长期支持: 缺点是最大只支持4GB文件大小，并且有2TB分区限制。这里有一个致命缺陷，大量的视频文件现在都是超过4GB的，显然很难在FAT32文件系统存储
- ``exFAT`` (Extensible File Allocation Table)是微软2006年推出的为flash memory开发的文件系统，优点是支持大文件和存储(512T)，缺点是非日志文件系统，读写时断电可能存在文件系统损坏

  - 大容量硬盘(理论64ZiB)，推荐最大512TB
  - 理论文件大小是 ``2^64-1`` 字节
  - 采用空余空间寻址，空间分配和删除性能得到改进
  - 单个文件夹支持草果 ``2^16`` 个文件
  - 支持热插拔资料完整无损机制Transaction-Safe FAT（TFAT，在WinCE中可选的功能）
  - 2019年8月，微软公开了exFAT的技术文档，并支持将exFAT功能集成到Linux内核中: Linux内核于 v5.4 提供初步支持

.. note::

   `Paragon <https://www.paragon-software.com>`_ 是一家专注与跨平台文件系统的公司，提供了 extFS(Linux)/exFAT(Windows)/NTFS(Windows)/APFS(macOS) 跨平台读写软件

   我购买过 ``extFS for Mac by Paragoan`` ，也就是可以将文件系统格式化成 ``EXT4`` ，然后跨平台在macOS上读写

:ref:`macos` 从 Mac OS X 10.6.5 (2009年) 开始完全支持读写exFAT外接设备，并且在Linux平台也支持该文件系统。目前是最好的外接存储设备(移动硬盘)文件系统。相信这么多年(10+)发展，macOS和Linux对exFAT的支持也是比较完善的。

exFAT无需第三方软件，降低了潜在风险；唯一担心的是突然断电，对于笔记本内置硬盘，这个风险较低，就是外接硬盘需要注意。好在外接硬盘是离线备份，相对还好。

.. note::

   `Cross-Platform File System file sharing between MAC, WINDOWS, LINUX? <https://apple.stackexchange.com/questions/170407/cross-platform-file-system-file-sharing-between-mac-windows-linux>`_ 有用户提供了一个很好的经验，就是在Linux服务器上采用ZFS，这样就能实现CIFS共享给多种操作系统使用。 :ref:`zfs` 文件系统成熟稳定、功能丰富，对于CIFS/NFS有非常方便的配置方法。

参考
=====

- `Cross-Platform File System file sharing between MAC, WINDOWS, LINUX? <https://apple.stackexchange.com/questions/170407/cross-platform-file-system-file-sharing-between-mac-windows-linux>`_
- `WikiPedia: ExFAT <https://zh.wikipedia.org/wiki/ExFAT>`_
