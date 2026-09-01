.. _opencore_macos_installer_install:

===================================
OpenCore采用macOS Installer安装
===================================

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

参考
=====

- gemini
- `MIST - macOS Installer Super Tool <https://github.com/ninxsoft/mist-cli>`_
