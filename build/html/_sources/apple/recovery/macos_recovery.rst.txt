.. _macos_recovery:

==================
macOS故障恢复
==================

.. note::

   如果你的Mac系统由于错误操作导致操作系统摧毁，同时又没有做过Time Machine备份，也没有安装介质。此时，只要你有联网环境，苹果提供了一种在线恢复出厂系统的方法，非常适合最后的故障救援。 

.. warning::

   实际上我在铲除系统之前，已经完整作了数据备份，所以恢复出厂macOS没有任何数据丢失。如果你要采用我介绍的这个方法，请务必做好数据备份。

2020年底，随着macOS 11.1 big Sur进入第二个迭代版本，我考虑将我使用了7年的MacBook Pro 2013 Late升级到最新的，也是最后一个可升级最新版本。根据 `macOS Big Sur is compatible with these computers <https://support.apple.com/en-us/HT211238>`_ 可以看到，我的古老的 MacBook Pro 2013 Late ( :ref:`introduce_my_studio`  ) 是macOS Big Sur兼容的最陈旧的设备了(看来无缘下一代操作系统了)。

但是，我在使用 :ref:`macos_install_drive` 安装最新的 macOS Big Sur (macOS Version 11.1) 时候，遇到一个非常奇怪的问题：安装提示我系统磁盘存在 S.M.A.R.T. 错误，要立即备份数据替换磁盘，并拒绝安装新系统。

我反复使用Disk Utility进行磁盘检查都没有发现问题，甚至使用U盘安装系统时，重新格式化磁盘(没有报错)，依然在安装过程中提示磁盘S.M.A.R.T. error。

我有些不太相信我的硬件已经故障了，毕竟在之前的旧版本macOS中运行很久也没有遇到问题，磁盘检测也看不到错误。 参考 `S.M.A.R.T. Status is: "Unsupported" on my Internal Hard Drive <https://discussions.apple.com/thread/251209469>`_ 中HWTech说不是所有的Apple SSD都支持SMART，并且对于USB设备，由于macOS没有包含必要的驱动，也会不支持USB磁盘的SMART功能。

.. note::

   我感觉我的Macbook Pro 2013 late是最新的 Big Sur 支持的最古老的硬件，很可能是勉强运行。此外Big Sur为了兼容Intel和最新的ARM架构M1处理器，相信操作系统是及其复杂的，很多功能可能已经过于叠床架屋了，有可能对旧版本硬件不友好。

   由于安装最新big Sur非常折腾，我准备采用稳定的Catalina操作系统。因为我的笔记本用来构建双启动操作系统，主要使用Linux来构建。

由于无法安装最新Big Sur系统，同时为了验证安装，我又完全铲除了整个操作系统，所以现在我需要通过联网方式来恢复出厂macOS系统。

启动macOS Recovery
===================

在按下电源键的同时安装以下组合键就能够进入macOS Recovery:

- ``Command (⌘)-R`` 重装你Mac最近安装的最新macOS系统(推荐)
- ``Option-⌘-R`` 更新到Mac硬件系统能够兼容的最新的macOS系统
- ``Shift-Option-⌘-R`` 重新安装你购买Mac硬件的随机相同版本的macOS（也就是旧版本）

后记
======

很不幸，通过 macOS Internet Recovery 安装Mavericks版本，也是同样提示 S.M.A.R.T. Fails，无法选择内置SSD存储进行安装。看来，这台使用了7年的MacBook Pro笔记本硬件寿命到期了，已经无法安装macOS操作系统。

我准备死马当活马，通过Linux系统再延续一段时间:

- 部署 :ref:`lfs_linux`
- 验证完整的 :ref:`kvm` 虚拟化和 :ref:`openstack` ，实现一种随时可以拉起整个系统的运行节点，所有运行数据都在远程 :ref:`pi_cluster` 构建的分布式存储中

  - 主机作为计算节点，不存储持久化数据
  - 本地存储只做缓存和docker镜像存储

参考
=====

- `How to reinstall macOS from macOS Recovery <https://support.apple.com/en-us/HT204904>`_
