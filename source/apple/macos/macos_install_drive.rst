.. _macos_install_drive:

=====================
macOS启动安装U盘
=====================

我的Mac笔记本，操作系统已经是比较过时，当需要升级到最新的macOS系统，当然可以使用系统提供的升级工具一点点升级上去，通常不会出现任何问题。不过，我也有一些应用软件洁癖，对于已经使用了很久，无数次调试把系统搞的有点乱的情况，总是想着重新彻底重新安装一次。

Mac设备支持在线安装操作系统：在按下电源的同时安装 ``option`` 键，就可以选择无线网络，通过在线方式启动进行安装恢复操作系统，不需要使用传统的安装U盘。这是非常有效的系统抢救恢复操作，不过，苹果会限制你只能安装最近一次升级的最高版本，不会跳到最新的操作系统安装。这种情况下，我为了能够方便反复安装，我采用在App
Store中选择最新操作系统安装升级，但是在下载了安装软件之后，不直接安装(直接安装会在升级后立即清理掉下载的软件安装程序)，而是自己制作启动U盘，然后使用U盘来安装自己的多台设备。

.. note::

   macOS的不同版本都支持自制启动安装U盘，但是执行的命令有可能有细微差异，例如目录，参数等。详细记录可以参考我以前的一些实践记录 `创建macOS启动安装U盘 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/mac/create_macos_boot_install_drive.md>`_ ，本文则仅仅记录最新的 macOS Big Sur Version 11 的安装U盘制作。

制作启动安装U盘
================

- 使用Disk Utility将U盘格式化成 Mac OS Extended(Jorunaled) 文件系统 - 这里假设格式化磁盘命名为 ``macos_installer`` ，则后续制作U盘的卷名就是 ``/Volumes/macos_installer``

- 在终端执行以下命令创建启动安装U盘:

.. literalinclude:: macos_install_drive/createinstallmedia_big_sur
   :caption: 创建Big Sur启动安装U盘

.. literalinclude:: macos_install_drive/createinstallmedia_sequoia
   :caption: 创建Sequoia启动安装U盘

修改安全设置
================

Mac有可能不允许使用扩展启动磁盘，这样就不能用U盘启动安装。这种情况下需要修改安全配置：

- 重启Mac在启动过程中同时按住 ``Command-R`` ，这会使Mac进入 :ref:`macos_recovery` 模式

- 在Recovery模式下，会启动一个 ``macOS Utilities`` 窗口，这时你选择 ``Utilites => Startup Security Utility`` 菜单

- 在弹出的 ``Authentication Needed`` 窗口中输入这台Mac上具有administrator权限的用户账号和密码

- 在 ``Startup Security Utility`` 窗口，勾选 ``Allow booting from external or removable media`` ，然后关闭窗口

从安装U盘启动
================

- 重启Mac，在启动时安装 ``Option`` 键

- 这时会出现 ``Startup Manager`` 界面，让你选择启动设备。此时选择外接设备U盘

- Mac就会启动进入Recovery模式，你会看到4个选项，其中就有 ``Install macOS Big Sur`` ，选择这个选项就可以安装。不过，如果你像我一样，想要抹掉数据干净地重装系统，则在这个安装步骤之前，先选择 ``Disk Utility`` 重新格式化一次内部驱动器，然后再选择 ``install macOS Big Sur`` 。

.. warning::

   通过抹除主机数据重装系统会导致原先存储在主机中数据全部丢失，所以务必先做好数据备份。最好使用Time Machine做一次完整系统的快照备份，这样即使出现意外也好恢复系统和数据。

参考
=======

- `How to Create a OS X El Capitan Boot Installer USB Flash Drive <http://osxdaily.com/2015/09/30/create-os-x-el-capitan-boot-install-drive/>`_
- `How to create a bootable macOS Mojave 10.14 USB install drive <https://9to5mac.com/2018/06/18/how-to-create-a-bootable-macos-mojave-10-14-usb-install-drive-video/>`_
- `How to сlean install macOS Mojave 10.14 <https://setapp.com/how-to/clean-install-macos-mojave>`_
- `How to create a bootable macOS Big Sur installer drive <https://www.macworld.com/article/3566910/how-to-create-a-bootable-macos-big-sur-installer-drive.html>`_
