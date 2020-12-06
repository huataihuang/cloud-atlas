.. _macos_install_drive:

=====================
macOS启动安装U盘
=====================

我的Mac笔记本，操作系统已经是比较过时，当需要升级到最新的macOS系统，当然可以使用系统提供的升级工具一点点升级上去，通常不会出现任何问题。不过，我也有一些应用软件洁癖，对于已经使用了很久，无数次调试把系统搞的有点乱的情况，总是想着重新彻底重新安装一次。

Mac设备支持在线安装操作系统：在按下电源的同时安装 ``option`` 键，就可以选择无线网络，通过在线方式启动进行安装恢复操作系统，不需要使用传统的安装U盘。这是非常有效的系统抢救恢复操作，不过，苹果会限制你只能安装最近一次升级的最高版本，不会跳到最新的操作系统安装。这种情况下，我为了能够方便反复安装，我采用在App
Store中选择最新操作系统安装升级，但是在下载了安装软件之后，不直接安装(直接安装会在升级后立即清理掉下载的软件安装程序)，而是自己制作启动U盘，然后使用U盘来安装自己的多台设备。

.. note::

   macOS的不同版本都支持自制启动安装U盘，但是执行的命令有可能有细微差异，例如目录，参数等。详细记录可以参考我以前的一些实践记录 `创建macOS启动安装U盘 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/mac/create_macos_boot_install_drive.md>`_ ，本文则仅仅记录最新的 macOS Big Sur Version 11 的安装U盘制作。

我准备等近期 11.1 发布后制作安装U盘时再更新本文，待续 ......

参考
=======

- `How to Create a OS X El Capitan Boot Installer USB Flash Drive <http://osxdaily.com/2015/09/30/create-os-x-el-capitan-boot-install-drive/>`_
- `How to create a bootable macOS Mojave 10.14 USB install drive <https://9to5mac.com/2018/06/18/how-to-create-a-bootable-macos-mojave-10-14-usb-install-drive-video/>`_
- `How to сlean install macOS Mojave 10.14 <https://setapp.com/how-to/clean-install-macos-mojave>`_
