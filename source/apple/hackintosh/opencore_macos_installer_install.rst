.. _opencore_macos_installer_install:

===================================
OpenCore采用macOS Installer安装
===================================

下载
======

`MIST - macOS Installer Super Tool <https://github.com/ninxsoft/mist-cli>`_ 是一个Mac命令行工具，专用于自动下载macOS Firmware/Installer。

实际上以前也非常容易通过App Store下载最新的macOS Installer，但是现在苹果似乎改变了策略，在 developer 网站提供的是 ``.ipsw`` 下载，而不是传统的 Installer ，所以我为了能够完成 :ref:`c246_mi50_hackintosh` ，决定尝试第三方工具来完整下载macOS 26

.. note::

   原先可以通过如下命令下载，不知道是不是我的系统有问题， :strike:`一直没有反应` 比较长时间才显示出可升级:

   .. literalinclude:: opencore_macos_installer_install/softwareupdate
      :caption: 使用softwareupdate下载macOS Installer

- mist-cli提供了 .pkg 安装包，安装以后在命令行执行以下命令:

.. literalinclude:: opencore_macos_installer_install/mist_list
   :caption: 检查有哪些可以安装的版本

- 下载

.. literalinclude:: opencore_macos_installer_install/mist_download
   :caption: 下载最新macOS 26.6.2Installer

请注意输出信息，我最初按照常规安装方式去 ``/Applications/`` 目录下找安装目录结果找不到，根据输出信息才发现实际复制到了 ``/Users/Shared/Mist/Install macOS Tahoe 26.6.2-25G83.app`` 目录

.. literalinclude:: opencore_macos_installer_install/mist_download_output
   :caption: 下载最新macOS 26.6.2Installer输出信息
   :emphasize-lines: 12

格式化U盘
===========

使用macOS的 **磁盘工具 (Disk Utility)** 抹掉 (Erase)U盘内容，注意使用以下参数配置:

  - 名称: ``macOSInstaller`` (注意大小写，后续作为卷名)
  - 格式: Mac OS 扩展（日志式） ``Mac OS Extended (Journaled)``
  - 方案: GUID 分区图 ``GUID Partition Map``

使用 ``GUID Partition Map`` 会自动生成一个隐藏的200MB FAT32 ESP分区，以及一个可见的名为 ``macOSInstaller`` 的数据分区。

macOS安装镜像写入U盘
======================

- 写入 macOS Tahoe (version 26):

.. literalinclude:: opencore_macos_installer_install/createinstallmedia
   :caption: 创建安装U盘

参考
=====

- gemini
- `MIST - macOS Installer Super Tool <https://github.com/ninxsoft/mist-cli>`_
